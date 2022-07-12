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

%left AND
%left OR
%right NOT

%token TRUE
%token FALSE
%token RETURN



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


%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token COMMA
%token SEMICOLON
%token COLON
%left ASSIGN

%% 

program:    functions {printf("program -> functions\n");}
   ;
functions:  /*empty*/ {printf("functions -> epsilon\n");}
   |        function functions {printf("functions -> function functions\n");}
   ;
function:   FUNCTION identifier SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
            {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
   ;

declarations:  /*empty*/ {printf("declarations -> epsilon \n");}
   |           declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
   |           identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declarations -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
   ;

declaration:   identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
   |           identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
                  {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
   ;
identifiers:   identifier {printf("identifiers -> identifier\n");}
   |           identifier COMMA identifiers {printf("identifiers -> IDENT COMMA identifiers\n");}
   ;

identifier:    IDENT {printf("identifier -> IDENT %s\n", $1);}
   ;

statements:   /*empty*/ {printf("statements -> epsilon\n");}
   |          statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
   ;

statement:    var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
   |          IF bool_exp THEN statements ENDIF {printf("statement -> IF bool_exp THEN statements ENDIF \n");}
   |          IF bool_exp THEN statements ELSE statements ENDIF {printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF \n");}
   |          WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP \n");}
   |          DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp \n");}
   |          FOR vars ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP 
                  {printf("statement ->  FOR vars ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP\n");}
   |          READ vars {printf("statement -> READ vars\n");}
   |          WRITE vars {printf("statement -> WRITE vars\n");}
   |          CONTINUE  {printf("statement -> CONTINUE\n");}
   |          RETURN expression {printf("statement -> RETURN expression\n");}
   ;


bool_exp: relational_exps {printf("bool_exp -> relational_exps\n");}
  | relational_exps OR bool_exp  {printf("bool_exp -> relational_exps OR bool_exp\n");}
  ;

relational_exps: relational_exp     {printf("relational_exps -> relational_exp \n");}
  |   relational_exp AND relational_exps    {printf("relational_exps -> relational_exp AND relational_exps\n");}
  ;

relational_exp: expression comp expression {printf("relational_exp -> expression comp expression\n");}
  |   NOT expression comp expression {printf("relational_exp -> NOT expression comp expression\n");}
  |   TRUE {printf("relational_exp -> TRUE\n");}
  |   NOT TRUE {printf("relational_exp -> NOT TRUE\n");}
  |   FALSE     {printf("relational_exp -> FALSE\n");}
  |   NOT FALSE     {printf("relational_exp -> NOT FALSE\n");}
  |   L_PAREN bool_exp R_PAREN    {printf("relational_exp -> L_PAREN bool_exp R_PAREN\n");}
  ;

comp: EQ    {printf("comp -> EQ\n");}
  |   NEQ   {printf("comp -> NEQ\n");}
  |   LT    {printf("comp -> LT\n");}
  |   GT    {printf("comp -> GT\n");}
  |   LTE   {printf("comp -> LTE\n");}
  |   GTE   {printf("comp -> GTE\n");}
  ;

expression_loop: expression {printf("expression_loop -> expression\n");}
  |    expression COMMA expression_loop {printf("expression_loop -> expression COMMA expression_loop\n");}
  ;

expression: mult_exp {printf("expression -> mult_exp\n");}
  |   mult_exp ADD expression {printf("expression -> mult_exp ADD expression\n");}
  |   mult_exp SUB expression {printf("expression -> mult_exp SUB expression\n");}
  ;

mult_exp: term {printf("mult_exp -> term\n");}
  |   term MULT mult_exp {printf("mult_exp -> term MULT mult_exp\n");}
  |   term DIV mult_exp {printf("mult_exp -> term DIV mult_exp\n");}
  |   term MOD mult_exp {printf("mult_exp -> term MOD mult_exp\n");}
  ;

term: var {printf("term -> var\n");}
  |   SUB var {printf("term -> SUB var\n");}
  |   NUMBER  {printf("term -> NUMBER\n");}
  |   SUB NUMBER {printf("term -> SUB NUMBER\n");}
  |   L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
  |   SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN\n");}
  |   identifier L_PAREN R_PAREN {printf("term -> identifier L_PAREN R_PAREN\n");}
  |   identifier L_PAREN expression_loop R_PAREN {printf("term -> identifier L_PAREN expression expression_loop R_PAREN\n");}
  ;

vars: var {printf("vars -> var\n");}  
  |   var COMMA vars {printf("var_loop -> var COMMA vars");}
  ;

var:  identifier {printf("var -> identifier\n");}
  |   identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET \n");}
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
