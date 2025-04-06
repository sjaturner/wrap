%{
#include "wrap.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap
%option yylineno

%%

"/*"([^*]|\*+[^*/])*\*+"/"    
"//".*                        
"#".*                         

"int"                         { return INT; }
"char"                        { return CHAR; }
"*"                           { return STAR; }
"[]"                          { return BRACKETS; }
"typedef"                     { return TYPEDEF; }
"enum"                        { return ENUM; }
"{"                           { return LBRACE; }
"}"                           { return RBRACE; }
"="                           { return ASSIGN; }

[a-zA-Z_][a-zA-Z0-9_]*        { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+                        { yylval.num = atoi(yytext); return NUMBER; }
"("                           { return LPAREN; }
")"                           { return RPAREN; }
","                           { return COMMA; }
";"                           { return SEMICOLON; }

[ \n\t\r]+                    { /* Ignore everything else */ }

%%

void suppress_warnings(void)
{
    input();
    yyunput(0,0);
}
