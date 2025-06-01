%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

void add_type_param(char *type, char *identifier);
void add_main_args(void);
void add_function(char *name);
void add_enumeration_elem(char *name, int val);
void add_enumeration(char *name);

%}

%union
{
    char *str;
    int num;
}

/* Tokens */
%token INT CHAR STAR BRACKETS TYPEDEF ENUM
%token <str> IDENTIFIER
%token <num> NUMBER
%token LPAREN RPAREN COMMA SEMICOLON LBRACE RBRACE ASSIGN

%%

prototypes:
    | prototypes prototype
    | prototypes enum_def
    ;

prototype:
    INT IDENTIFIER LPAREN param_list RPAREN SEMICOLON
    {
        add_function($2);
    }
    ;

param_list:
    /* empty */ { /* No parameters */ }
    | param_list COMMA param { /* Allow multiple params */ }
    | param
    | param_list COMMA argc_argv_special_case { /* Allow multiple params */ }
    | argc_argv_special_case
    ;

param:
    IDENTIFIER IDENTIFIER
    {
        add_type_param($1, $2);
    }
    | CHAR STAR IDENTIFIER
    {
        add_type_param(0, $3);
    }
    ;

/* Special case for argc, argv */
argc_argv_special_case:
    INT IDENTIFIER COMMA CHAR STAR IDENTIFIER BRACKETS
    {
        add_main_args();
    }
    ;

/* Enum Parsing */
enum_def:
    TYPEDEF ENUM LBRACE enum_list RBRACE IDENTIFIER SEMICOLON
    {
        add_enumeration($6);
    }
    ;

enum_list:
    enum_entry
    | enum_list COMMA enum_entry
    | enum_list COMMA
    ;

enum_entry:
    IDENTIFIER ASSIGN NUMBER
    {
        add_enumeration_elem($1, $3);
    }
    ;

%%

#include <assert.h>

#define NELEM(A) (sizeof(A) / sizeof(A[0]))

struct type_param
{
    int main_args;
    char *type;
    char *identifier;
};

int type_param_items;
struct type_param type_params[0x400];

int debug;

void add_type_param(char *type, char *identifier)
{
    if (debug)
    {
        printf("    %s %s %s\n", __func__, type ? type : "char *", identifier);
    }

    assert(type_param_items + 1 < NELEM(type_params));

    type_params[type_param_items++] = (struct type_param)
    {
        .type = type,
        .identifier = identifier,
    };
}

void add_main_args(void)
{
    if (debug)
    {
        printf("    %s\n", __func__);
    }

    assert(type_param_items + 1 < NELEM(type_params));

    type_params[type_param_items++] = (struct type_param)
    {
        .main_args = 1,
    };
}

struct function
{
    char *name;
    int items;
    struct type_param *type_params;
};

int function_items;
struct function functions[0x400];

void add_function(char *name)
{
    if (debug)
    {
        printf("%s %s\n", __func__, name);
    }

    assert(function_items + 1 < NELEM(functions));

    int size = sizeof(struct type_param) * type_param_items;
    functions[function_items++] = (struct function)
    {
        .name = name,
        .items = type_param_items,
        .type_params = memcpy(calloc(size, 1), type_params, size),
    };
    type_param_items = 0;
    memset(type_params, 0, sizeof type_params);
}

int enumeration_elem_items;
struct enumeration_elem
{
    char *name;
    int val;
};

struct enumeration_elem enumeration_elems[0x400];

void add_enumeration_elem(char *name, int val)
{
    if (debug)
    {
        printf("    %s %s %d\n", __func__, name, val);
    }

    assert(enumeration_elem_items + 1 < NELEM(enumeration_elems));

    enumeration_elems[enumeration_elem_items++] = (struct enumeration_elem)
    {
        .name = name,
        .val = val,
    };
}

struct enumeration
{
    char *name;
    int items;
    struct enumeration_elem *enumeration_elems;
};

int enumeration_items;
struct enumeration enumerations[0x400];

void add_enumeration(char *name)
{
    if (debug)
    {
        printf("%s %s\n", __func__, name);
    }

    assert(enumeration_items + 1 < NELEM(enumerations));

    int size = sizeof(struct enumeration_elem) * enumeration_elem_items;
    enumerations[enumeration_items++] = (struct enumeration)
    {
        .name = name,
        .items = enumeration_elem_items,
        .enumeration_elems = memcpy(calloc(size, 1), enumeration_elems, size),
    };
    enumeration_elem_items = 0;
    memset(enumeration_elems, 0, sizeof enumeration_elems);
}

void dump_state(void)
{
    for (int index = 0; index < enumeration_items; ++index)
    {
        struct enumeration *enumeration = enumerations + index;

//      printf("enumeration %s\n", enumeration->name);
        printf("static int parse_%s(%s *val, char *str) {\n", enumeration->name, enumeration->name);
        printf("    if (0) {}\n");
        for (int index = 0; index < enumeration->items; ++index)
        {
            struct enumeration_elem *enumeration_elem = enumeration->enumeration_elems + index;
//          printf("    %s %d\n", enumeration_elem->name, enumeration_elem->val);
            printf("    else if (!strcmp(str, \"%s\")) {*val = %d ; return 1;}\n", enumeration_elem->name, enumeration_elem->val);
        }
        printf("    else return 0;\n");
        printf("}\n");
        printf("\n");
    }

    printf("static int inner_wrap_argc_argv(int argc, char *argv[]) {\n");
    printf("    if (0) {}\n");
    for (int index = 0; index < function_items; ++index)
    {
        struct function *function = functions + index;

//      printf("function %s\n", function->name);
        printf("    else if (!strcmp(argv[0], \"%s\")) {\n", function->name);

        for (int index = 0; index < function->items; ++index)
        {
            struct type_param *type_param = function->type_params + index;

//          printf("    ");
            if (type_param->main_args)
            {
//              printf("main_args\n");
            }
            else
            {
                if (type_param->type)
                {
                    printf("        PARSE(%s, %s, argv[%d]);\n", type_param->type, type_param->identifier, index + 1);
                }
                else
                {
                    printf("        char *%s = argv[%d];\n", type_param->identifier, index + 1);
                }
            }
        }

        printf("        return %s(", function->name);
        for (int index = 0; index < function->items; ++index)
        {
            int last = index + 1 == function->items;

            struct type_param *type_param = function->type_params + index;

            if (type_param->main_args)
            {
                printf("argc - %d, argv + %d", index + 1, index + 1);
            }
            else
            {
                if (type_param->type)
                {
                    printf("%s%s", type_param->identifier, last ? "" : ", ");
                }
                else
                {
                    printf("%s%s", type_param->identifier, last ? "" : ", ");
                }
            }
        }
        printf(");\n");
        printf("    }\n");
    }
    printf("    return -1;\n");
    printf("}\n");
    printf("\n");
    printf("int wrap_argc_argv(int argc, char *argv[]) {\n");
    printf("    wrap_enter();\n");
    printf("    int ret = inner_wrap_argc_argv(argc, argv);\n");
    printf("    wrap_leave();\n");
    printf("    return ret;\n");
    printf("}\n");
}

void yyerror(const char *s)
{
    extern int yylineno;
    fprintf(stderr, "Error: %s at line:%d\n", s, yylineno);
}

char intro[] =

"#include \"wrap_utils.h\"\n"
"#include \"wrap.h\"\n"
"#include <stdint.h>\n"
"#include <string.h>\n"
"#include <stdio.h>\n"
"#define PARSE(TYPE, NAME, STR) TYPE NAME; memset(&NAME, 0, sizeof(NAME)); if (!parse_ ## TYPE(&NAME, STR)) { wrap_printf(\"failed to parse \\\"%s\\\" into %s\\n\", STR, #NAME); return -1;}";

int main()
{
    yyparse();

    printf("%s", intro);

    printf("\n");

    dump_state();

    return 0;
}
