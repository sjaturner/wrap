%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

void add_type_param(char *type, char *identifier);
void add_main_args(char *type, char *identifier);

void add_function(char *name);


void add_enumeration_elem(char *name, int val);

void add_enumeration(char *name);

int debug;

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
        if (debug)
        {
            printf("Function: %s\n", $2);
        }
        free($2);
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
        if (debug)
        {
            printf("  Parameter: %s %s\n", $1, $2);
        }
        free($1);
        free($2);
    }
    | CHAR STAR IDENTIFIER
    {
        if (debug)
        {
            printf("  Parameter: char *%s\n", $3);
        }
        free($3);
    }
    ;

/* Special case for argc, argv */
argc_argv_special_case:
    INT IDENTIFIER COMMA CHAR STAR IDENTIFIER BRACKETS
    {
        if (debug)
        {
            printf("  Special Case Parameters: int %s, char *%s[]\n", $2, $6);
        }
        free($2);
        free($6);
    }
    ;

/* Enum Parsing */
enum_def:
    TYPEDEF ENUM LBRACE enum_list RBRACE IDENTIFIER SEMICOLON
    {
        if (debug)
        {
            printf("Enum: %s\n", $6);
        }
        free($6);
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
        if (debug)
        {
            printf("  %s = %d\n", $1, $3);
        }
        free($1);
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

void add_type_param(char *type, char *identifier)
{
    assert(type_param_items + 1 < NELEM(type_params));

    type_params[type_param_items++] = (struct type_param)
    {
        .type = type,
        .identifier = identifier,
    };
}

void add_main_args(char *type, char *identifier)
{
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
    assert(function_items + 1 < NELEM(functions));

    int size = sizeof(struct type_param) * type_param_items;
    functions[function_items++] = (struct function)
    {
        .name = name,
        .items = type_param_items,
        .type_params = memcpy(calloc(size, 1), type_params, size),
    };
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
    assert(enumeration_items + 1 < NELEM(enumerations));

    int size = sizeof(struct enumeration_elem) * enumeration_elem_items;
    enumerations[enumeration_items++] = (struct enumeration)
    {
        .name = name,
        .items = enumeration_elem_items,
        .enumeration_elems = memcpy(calloc(size, 1), enumeration_elems, size),
    };
}

void yyerror(const char *s)
{
    extern int yylineno;
    fprintf(stderr, "Error: %s at line:%d\n", s, yylineno);
}

int main()
{
    debug = 1;
    yyparse();
    return 0;
}
