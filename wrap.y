%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
%}

%union {
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
    INT IDENTIFIER LPAREN param_list RPAREN SEMICOLON {
        printf("Function: %s\n", $2);
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
    IDENTIFIER IDENTIFIER { printf("  Parameter: %s %s\n", $1, $2); free($1); free($2); }
    | CHAR STAR IDENTIFIER { printf("  Parameter: char *%s\n", $3); free($3); }
    ;

/* Special case for argc, argv */
argc_argv_special_case:
    INT IDENTIFIER COMMA CHAR STAR IDENTIFIER BRACKETS {
        printf("  Special Case Parameters: int %s, char *%s[]\n", $2, $6);
        free($2);
        free($6);
    }
    ;

/* Enum Parsing */
enum_def:
    TYPEDEF ENUM LBRACE enum_list RBRACE IDENTIFIER SEMICOLON {
        printf("Enum: %s\n", $6);
        free($6);
    }
    ;

enum_list:
    enum_entry
    | enum_list COMMA enum_entry
    | enum_list COMMA
    ;

enum_entry:
    IDENTIFIER ASSIGN NUMBER {
        printf("  %s = %d\n", $1, $3);
        free($1);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyparse();
    return 0;
}
