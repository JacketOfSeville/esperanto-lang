%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

// External declaration of yylval
extern YYSTYPE yylval;

// Define a Windows-compatible strndup function
#ifdef _WIN32
#define strndup(yytext, len) \
    ({ \
        char* dup = malloc((len) + 1); \
        strncpy(dup, (yytext), (len)); \
        dup[(len)] = '\0'; \
        dup; \
    })
#else
#include <string.h>
#endif
%}

/* Define constants for RegEx */
IDENTIFIER [a-zA-z_][a-zA-Z_0-9]* 
FLOAT      [0-9]+\.[0-9]+ 
NUMBER     [0-9]+

/* RegEx rules for parsing tokens */
%%

{FLOAT}      { yylval.str = strdup(yytext); return FLOAT; }
{NUMBER}     { yylval.str = strdup(yytext); return NUMBER; }
"LASU"       { return LET; }
"SE"         { return IF; }
"ALIE"       { return ELSE; }
"DUM"        { return WHILE; }
"POR"        { return FOR; }
"PRESI"      { return PRINT; }
"FUNKCIO"    { return FUNCTION; }
"REVENI"     { return RETURN; }
"NE"         { return NOT; }
"-*-".*      { /* Do not render or tokenize comments */ }
{IDENTIFIER} { yylval.str = strdup(yytext); return ID; }
"+"          { return PLUS; }
"-"          { return MINUS; }
"*"          { return TIMES; }
"/"          { return DIVIDE; }
"("          { return LPAREN; }
")"          { return RPAREN; }
"{"          { return LBRACE; }
"}"          { return RBRACE; }
";"          { return ';'; }
","          { return ','; }
"="          { return ASSIGN; }
">"          { return '>'; }
"<"          { return '<'; }
">="         { return GE; }
"<="         { return LE; }
"=="         { return EQ; }
"!="         { return NE; }
\"[^\"]*\"   { yylval.str = strndup(yytext + 1, yyleng - 2); return STRING; }
[ \t\n]+     { /* Ignore whitespaces */ }
.            { printf("Unknown character: %s\n", yytext); exit(1); }

%%

// Function to be used by the lexer to indicate EOF
int yywrap() {
    return 1;
}