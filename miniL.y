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

program:    functions {printf("program -> functions\n");}
   ;
functions:  function functions {printf("functions -> function functions\n");}
   |        /*empty*/ {printf("functions -> epsilon\n");}
   ;
function:   FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement END_BODY
            {printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement END_BODY\n");}
   ;

declarations:  declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations \n");}
   |           /*empty*/ {printf("declarations -> epsilon \n");}
   ;

declaration:   identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER \n");}
   |           identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
                  {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER \n");}
   ;
identifiers:   identifier {printf("identifiers -> identifier \n");}
   |           IDENT COMMA identifiers {printf("identifiers -> IDENT COMMA identifiers \n");}
   ;

identifier:    IDENT {printf("identifier -> IDENT \n");}
   ;

statements:   statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements \n");}
   |          statement SEMICOLON {printf("statements -> statement SEMICOLON \n");}
   ;

statement:    statement_var {printf("statement -> statement_var \n");}
   |          statement_if {printf("statement -> statement_if \n");}
   |          statement_while {printf("statement -> statement_while \n");}
   |          statement_do {printf("statement -> statement_do \n");}
   |          statement_read {printf("statement -> statement_read \n");}
   |          statement_write {printf("statement -> statement_write \n");}
   |          statement_continue {printf("statement -> statement_continue \n");}
   |          statement_return {printf("statement -> statement_return \n");}
   ;

statement_var: var ASSIGN expression {printf("statement_var -> var ASSIGN expression \n");}
   ;

statement_if:  IF bool_exp THEN statements ENDIF {printf("statement_if -> IF bool_exp THEN statements ENDIF \n");}

statement_while:  WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement_while -> WHILE bool_exp BEGINLOOP statements ENDLOOP \n");}

statement_do:  BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement_do -> BEGINLOOP statements ENDLOOP WHILE bool_exp \n");}

statement_read:   READ var var_loop {printf("statement_read -> READ var var_loop \n");}

statement_write:  WRITE var var_loop {printf("statement_write -> WRITE var var_loop \n");}

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
