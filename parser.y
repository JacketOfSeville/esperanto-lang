%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to be called if a syntax error occurs
void yyerror(const char *s);

// Declares a function to tokenize the input
int yylex();

// Exposes the input file for the program
extern FILE *yyin;

%}

// Declaration of a union type to have values of tokens 
// and non-terminals be stored in by the parser
%union {
    char *str;
}

// Defines a list of tokens for recognition by the lexer
// Each token is associated with a type, this case 'str'
%token <str> LET ID ASSIGN FUNCTION RETURN PRINT LPAREN RPAREN LBRACE RBRACE STRING NUMBER FLOAT TIMES DIVIDE PLUS MINUS IF ELSE WHILE FOR '>' '<' GE LE EQ NE

// Directives for precedence and associativity of operators
// %left => associates to the left
%left PLUS MINUS // PLUS and MINUS have the same weight
%left TIMES DIVIDE
// %right => associates to the right
%right ASSIGN
%right NOT
%right LET
// %nonassoc => does not associate to either side
%nonassoc IFX
%nonassoc ELSE

// Directive for specification of the type of each non-terminal
// symbol in the grammar, meaning these can be replaced and 
// will not be returned as result to the EOF operation
%type <str> factor statement statements expression assignment simple_expression term program function_declaration function_call parameter_list argument_list return_statement

%%

program:
    // Defines the non-terminal to generate and execute the code
    statements {
        printf("%s", $1);
        free($1);
    };

statements:
    // Define the statement non-terminal for parsing 
    statement { $$ = $1; }
    | statements statement { 
        $$ = malloc(strlen($1) + strlen($2) + 8);
        strcpy($$, $1);
        strcat($$, $2);
        free($1); // Free the memory
        free($2); // Free the memory
    };

statement:
    // Define the end of the line and line break
    expression ';' {
        $$ = malloc(strlen($1) + 2);
        strcpy($$, $1);
        strcat($$, ";\n");
        free($1); // Free the memory
    } 
    // Define the function for printing out an expression
    | PRINT expression ';' {
        $$ = malloc(strlen($2) + 6);
        strcpy($$, "console.log(");
        strcat($$, $2);
        strcat($$, ");\n");
        free($2); // Free the memory
    }
    // Define the function for printing out a string
    | PRINT STRING ';' {
        $$ = malloc(strlen($2) + 8);
        strcpy($$, "console.log(`");
        strcat($$, $2);
        strcat($$, "`);\n");
        free($2); // Free the memory
    }
    // Define the function for declaring a variable
    | LET expression ';' {
        $$ = malloc(strlen($2) + 6);
        strcpy($$, "let ");
        strcat($$, $2);
        strcat($$, ";\n");
        free($2); // Free the memory
    }
    // Define the function for handling 'if' statements
    | IF LPAREN expression RPAREN statement %prec IFX {
        $$ = malloc(strlen($3) + strlen($5) + 10);
        strcpy($$, "if (");
        strcat($$, $3);
        strcat($$, ") {\n");
        strcat($$, $5);
        strcat($$, "}\n");
        free($3); // Free the memory
        free($5); // Free the memory
    }
    // Define the function for handling 'if else' statements
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = malloc(strlen($3) + strlen($5) + strlen($7) + 15);
        strcpy($$, "if (");
        strcat($$, $3);
        strcat($$, ") {\n");
        strcat($$, $5);
        strcat($$, "} else {\n");
        strcat($$, $7);
        strcat($$, "}\n");
        free($3); // Free the memory
        free($5); // Free the memory
        free($7); // Free the memory
    }
    // Define the function for handling 'while' loop statements
    | WHILE LPAREN expression RPAREN statement {
        $$ = malloc(strlen($3) + strlen($5) + 12);
        strcpy($$, "while (");
        strcat($$, $3);
        strcat($$, ") {\n");
        strcat($$, $5);
        strcat($$, "}\n");
        free($3); // Free the memory
        free($5); // Free the memory
    }
    // Define the function for handling 'for' loop statements
    | FOR LPAREN expression ',' expression ',' expression RPAREN statement {
        $$ = malloc(strlen($3) + strlen($5) + strlen($7) + strlen($9) + 20);
        strcpy($$, "for (let ");
        strcat($$, $3);
        strcat($$, " = ");
        strcat($$, $5);
        strcat($$, "; ");
        strcat($$, $3);
        strcat($$, " <= ");
        strcat($$, $7);
        strcat($$, "; ");
        strcat($$, $3);
        strcat($$, "++ ) {\n");
        strcat($$, $9);
        strcat($$, "}\n");
        free($3); // Free the memory
        free($5); // Free the memory
        free($7); // Free the memory
        free($9); // Free the memory
    }
    // Define the function for handling scope definition with '{}'
    | LBRACE statements RBRACE {
        $$ = malloc(strlen($2) + 2);
        strcpy($$, "\n");
        strcat($$, $2);
        free($2); // Free the memory
    }
    // Declares the function_declaration type
    | function_declaration {
        $$ = $1;
    };

function_declaration:
    // Define the function for handling Functions 
    // e.g. function ID(param) { statements return }
    FUNCTION ID LPAREN parameter_list RPAREN LBRACE statements return_statement RBRACE {
        $$ = malloc(strlen($2) + strlen($4) + strlen($7) + strlen($8) + 20);
        strcpy($$, "function ");
        strcat($$, $2);
        strcat($$, "(");
        strcat($$, $4);
        strcat($$, ") {\n");
        strcat($$, $7);
        strcat($$, $8);
        strcat($$, "}\n");
        free($4); // Free the memory
        free($7); // Free the memory
        free($8); // Free the memory
    };

return_statement:
    // Define the function for handling the 'return' statement
    RETURN expression ';' {
        $$ = malloc(strlen($2) + 6);
        strcpy($$, "return ");
        strcat($$, $2);
        strcat($$, ";\n");
        free($2); // Free the memory
    } | /* Empty*/ {
        $$ = "";
    };

parameter_list:
    // Define the guidelines for handling IDs and parameter lists
    ID {
        $$ = $1;
    } | parameter_list ',' ID {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, ", ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    } | /* Empty */ {
        $$ = "";
    };

function_call:
    // Define the function for handling the call of functions
    // e.g. result = function(params);
    ID LPAREN argument_list RPAREN {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, "(");
        strcat($$, $3);
        strcat($$, ")");
        free($3); // Free the memory
    };

argument_list:
    // Define the function for handling arguments for functions and/or statements
    // e.g. result = function(arg1, arg2, arg3)
    expression {
        $$ = $1;
    } | argument_list ',' expression {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, ", ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    } | /* Empty */ {
        $$ = "";
    };

expression:
    // Define expression as assignments to a variable or cuntion calling
    assignment { $$ = $1; }
    | function_call { $$ = $1; };

assignment:
    // Define the function for handling the assignment of values to varaibles
    ID ASSIGN expression {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " = ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    } | simple_expression { $$ = $1; };

simple_expression:
    term { $$ = $1; }
    // Define the function for handling the sum of values
    | simple_expression PLUS term {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " + ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    }
    // Define the function for handling the subtraction of values
    | simple_expression MINUS term {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " - ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    }
    // Define the function for handling the 'greater than' comparison of values
    | simple_expression '>' term {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " > ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    }
    // Define the function for handling the 'less than' comparison of values
    | simple_expression '<' term {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " < ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    }
    // Define the function for handling the 'greater than equals' comparison of values
    | simple_expression GE term {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " >= ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    }
    // Define the function for handling the 'less than equals' comparison of values
    | simple_expression LE term {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " <= ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    }
    // Define the function for handling the 'equality' comparison of values
    | simple_expression EQ term {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " == ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    }
    // Define the function for handling the 'inequality' comparison of values
    | simple_expression NE term {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " != ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    };

term:
    // Define functions for handling operations with factors
    factor { $$ = $1; }
    // Define the function for handling the 'not/reversal' operator
    | NOT factor {
        $$ = malloc(strlen($2) + 6);
        strcpy($$, "!");
        strcat($$, $2);
        free($2); // Free the memory
    }
    // Define the function for handling the multiplication of values
    | term TIMES factor {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " * ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    }
    // Define the function for handling the division of values
    | term DIVIDE factor {
        $$ = malloc(strlen($1) + strlen($3) + 12);
        strcpy($$, $1);
        strcat($$, " / ");
        strcat($$, $3);
        free($1); // Free the memory
        free($3); // Free the memory
    };

factor:
    // Define statements for handling numerical factors, IDs and other expr.
    NUMBER { $$ = $1; }
    | FLOAT { $$ = $1; }
    | ID { $$ = $1; }
    | LPAREN expression RPAREN {
        $$ = malloc(strlen($2) + 6);
        strcpy($$, "(");
        strcat($$, $2);
        strcat($$, ")");
        free($1); // Free the memory
        free($3); // Free the memory
    };

%%

// Handle errors
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char **argv) {
    // Skip over the program's name
    ++argv, --argc;
    // If there are any remaining command arguments
    if (argc > 0)
        // Open the file in the 1st argument in Read mode
        yyin = fopen(argv[0], "r");
    else
        // If there are no arguments, use the Std. Input stream (keyboard)
        yyin = stdin;

    // Parses whatever is in 'yyin'
    yyparse();
    return 0;
}