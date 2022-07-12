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
%token ENDLOOP
%token CONTINUE
%token READ
%token WRITE
%token TRUE
%token FALSE
%token RETURN

%left AND
%left OR
%right NOT

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
function:   FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement END_BODY
            {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement END_BODY\n");}
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

statement_continue: CONTINUE  {printf("statement_continue -> CONTINUE \n");}
  ;

statement_return:   RETURN expression {printf("statement_return -> RETURN expression\n");}
  ;

bool_exp: relational_exps {printf("bool_exp -> relational_exps\n");}
  | bool_exp OR relational_exps  {printf("bool_exp -> bool_exp OR relational_exps\n");}
  ;

relational_exps: relational_exp     {printf("relational_exps -> relational_exp \n");}
  |   relational_exps AND relational_exp    {printf("relational_exps -> relational_exps AND relational_exp\n");}
  ;

relational_exp: NOT equation {printf("relational_exp -> NOT equation\n");}
  |   equation  {printf("relational_exp -> equation\n");}
  |   TRUE      {printf("relational_exp -> TRUE\n");}
  |   FALSE     {printf("relational_exp -> FALSE\n");}
  |   L_PAREN bool_exp R_PAREN    {printf("relational_exp -> L_PAREN bool_exp R_PAREN\n");}
  ;

equation: expression comp expression {printf("equation -> expression comp expression\n");}
  ;

comp: EQ    {printf("comp -> EQ\n");}
  |   NEQ   {printf("comp -> NEQ\n");}
  |   LT    {printf("comp -> LT\n");}
  |   GT    {printf("comp -> GT\n");}
  |   LTE   {printf("comp -> LTE\n");}
  |   GTE   {printf("comp -> GTE\n");}
  ;

expression: mult_exp add_sub_exp {printf("expression -> mult_exp add_sub_exp\n");}
  ;

expression_loop: /*empty*/ {printf("expression_loop -> epsilon\n");}
  |   COMMA expression expression_loop {printf("expression_loop -> COMMA expression expression_loop\n");}
  ;

mult_exp: term {printf("mult_exp -> term\n");}
  |   term MULT mult_exp {printf("mult_exp -> term MULT mult_exp\n");}
  |   term DIV mult_exp {printf("mult_exp -> term DIV mult_exp\n");}
  |   term MOD mult_exp {printf("mult_exp -> term MOD mult_exp\n");}
  ;

add_sub_exp: /*empty*/  
  |   ADD expression {printf("add_sub_exp -> ADD expression\n");}
  |   SUB expression {printf("add_sub_exp -> SUB expression\n");}
  ;

term: var {printf("term -> var\n");}
  |   SUB var {printf("term -> SUB var\n");}
  |   NUMBER  {printf("term -> NUMBER\n");}
  |   SUB NUMBER {printf("term -> SUB NUMBER\n");}
  |   L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
  |   identifier L_PAREN expression expression_loop R_PAREN {printf("term -> identifier L_PAREN expression expression_loop R_PAREN\n");}
  ;

var:  identifier {printf("var -> identifier\n");}
  |   identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf(" \n");}
  ;

var_loop: /*empty*/ {printf("var_loop -> epsilon\n");}  
  |   COMMA var var_loop {printf("var_loop -> COMMA var var_loop");}
  ;

%% 

int main(int argc, char **argv) {
   if (argc >= 1) 
   {
        yyin = fopen(argv[1], "r");
        if(yyin == NULL)
        {
            printf("syntax: %s filename", argv[0]);
        }
   }
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
   printf("Error: Line %d, position %d: %s\n", currLine, currPos, msg);
}
