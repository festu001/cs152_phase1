    /* cs152-miniL phase2 */
%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
%}

%union{
  char* ident_val;
  int num_val;
}

%error-verbose
%locations
%start program

%token <ident_val> IDENT
%token <num_val> NUMBER

%token FUNCTION
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token ENUM
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token FOR
%token WHILE
%token DO
%token BEGINLOOP
%token CONTINUE
%token READ
%token WRITE
%token TRUE
%token FALSE
%token RETURN

%left AND
%left OR
$right NOT

%left ADD
%left SUB
%left MULT
%left DIV
%left MOD

%left EQ
%left NEQ
%left LT
%left GT
%left LTE
%left GTE

%token COLON
%token SEMICOLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%left ASSIGN

%% 

  /* write your rules here */

%% 

int main(int argc, char **argv) {
   if (argc >= 2) 
   {
        yyin = fopen(argv[1], "r");
        if(yyin == NULL)
        {
            yyin = stdin;
        }
   }
   else 
   {
        yyin = stdin;
   }
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
   exit(0);
}
