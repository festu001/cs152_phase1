    /* cs152-miniL phase2 */
%{
  #define YY_NO_UNPUT
 #include <stdio.h>
 #include <stdlib.h>
 #include <string>

 #include <map>
 #include <string.h>
 #include <set>

 int tempCount = 0;
 int labelCount = 0;
 extern char* yytext;
 std::map<std::string, std::string> varTemp;
 std::map<std::string, int> arrSize;
 bool mainFunc = false;
 std::set<std::string> funcs;
 std::set<std::string> reserved {"NUMBER", "IDENT", "RETURN", "FUNCTION","SEMICOLON",
    "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS","BEGIN_BODY", "END_BODY", "COLON", 
    "INTEGER", "ARRAY", "ENUM", "OF", "IF", "THEN", "ENDIF", "COMMA", "L_SQUARE_BRACKET", 
    "R_SQUARE_BRACKET", "L_PAREN", "R_PAREN", "CONTINUE", "READ", "WRITE", "DO", 
    "ELSE", "FOR", "WHILE", "DO", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "ASSIGN", "EQ", "NEQ",
    "LT", "GT", "LTE", "GTE", "ADD", "SUB", "MULT", "DIV", "MOD", 
    "WRITE", "AND",  "OR", "NOT", "TRUE", "FALSE", "RETURN", "program", "functions", "function",
    "declarations", "declaration", "identifiers", "identifier", "statements", "statement", 
    "bool_exp", "relational_exps", "relational_exp", "comp", "expression_loop", "expression",
    "mult_exp", "term", "vars", "var"};

 void yyerror(const char *msg);
 int yylex();
 std::string new_temp();
 std::string new_label();
 extern int currLine;
 extern int currPos;
 extern FILE * yyin;
%}

%union{
  char* ident_val;
  int num_val;
  struct S {
    char* code;
  } statement;
  struct E {
    char* place;
    char* code;
    bool arr;
  } expr;
}

%start program

%token <ident_val> IDENT
%token <num_val> NUMBER
%type <expr> program function functions declarations declaration bool_exp relational_exp relational_exps 
%type <expr> comp vars var identifiers identifier expression_loop expression mult_exp term
%type <statement> statements statement

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


%left MULT DIV MOD
%left ADD SUB
%left EQ NEQ LT GT LTE GTE

%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token COMMA
%token SEMICOLON
%token COLON
%left ASSIGN

%% 

program:    functions {

   }
   ;
functions:  /*empty*/ {
  
   }
   |        function functions {

   }
   ;
function:   FUNCTION identifier SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY{
      std::string temp = "func ";
      temp.append($2.place);
      temp.append("\n");
      std::string s = $2.place;
      if (s == "main") {
        mainFunc = true;
      }
      temp.append($5.code);
      std::string decs = $5.code;
      int decNum = 0;
      while(decs.find(".") != std::string::npos){
        int pos = decs.find(".");
        decs.replace(pos, 1, "=");
        std::string part = ", $" + std::to_string(decNum) + "\n";
        decNum++;
        decs.replace(decs.find("\n", pos), 1, part);
      }
      temp.append(decs);

      temp.append($8.code);
      std::string statements = $11.code;
      if (statements.find("continue") != std::string::npos) {
        printf("ERROR: Continue outside loop in function $s\n", $2.place);
      }
      temp.append(statements);
      temp.append("endfunc\n\n");
      printf(temp.c_str());
   }
   ;

declarations:  /*empty*/ {
      $$.place = strdup("");
      $$.code = strdup("");

   }
   |           declaration SEMICOLON declarations {
      std::string temp;
      temp.append($1.code);
      temp.append($3.code);
      $$.code = strdup(temp.c_str());
      $$.place = strdup("");
   }
   |           identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declarations -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
   ;

declaration:   identifiers COLON INTEGER {
      std::string temp;
      temp.append($1.code);
      std::string variable = $1.place;
      std::string work;

      size_t pos = temp.find("|", 0);
      while (pos != std::string::npos){
        temp.append(". ");
        work = variable.substr(0, pos);
        temp.append(work);
        temp.append("\n");
        pos = temp.find("|", 0);
      }
      $$.code = strdup(temp.c_str());
      $$.place = strdup("");

}
   |           identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {

      std::string temp;
      temp.append($1.code);
      std::string variable = $1.place;
      std::string work;
      if($5 <= 0)
      {
        printf("ERROR: Declaring array of size 0 or less.\n");
      }

      size_t pos = temp.find("|", 0);
      while (pos != std::string::npos){
        temp.append(".[] ");
        work = variable.substr(0, pos);
        temp.append(work);
        temp.append(", ");
        temp.append(std::to_string($5));
        temp.append("\n");
        pos = temp.find("|", 0);
      }
      $$.code = strdup(temp.c_str());
      $$.place = strdup("");


                    
   }
   |           identifier INTEGER  {printf("error, invalid syntax\n");}
   ;
identifiers:   identifier {
      $$.place = strdup($1.place);
      $$.code = strdup("");
   }
   |           identifier COMMA identifiers {
      std::string temp;
      temp.append($1.place);
      temp.append("|");
      temp.append($3.place);
      $$.place = strdup(temp.c_str());
      $$.code = strdup("");
   }
   ;

identifier:    IDENT {
      $$.place = strdup($1);
      $$.code = strdup("");
   }
   ;

statements:   /*empty*/ {

   }
   |          statement SEMICOLON statements {
      std::string temp;
      temp.append($1.code);
      temp.append($3.code);
      $$.code = strdup(temp.c_str());
   }
   ;

statement:    var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
   |          IF bool_exp THEN statements ENDIF {printf("statement -> IF bool_exp THEN statements ENDIF \n");}
   |          IF bool_exp THEN statements ELSE statements ENDIF {printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF \n");}
   |          WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP \n");}
   |          DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp \n");}
   |          FOR vars ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP 
                  {printf("statement ->  FOR vars ASSIGN NUMBER SEMICOLON bool_exp SEMICOLON vars ASSIGN expression BEGINLOOP statements ENDLOOP\n");}
   |          READ vars {
      std::string temp;
      temp.append($2.code);
      size_t pos = temp.find("|", 0);
      while (pos != std::string::npos){
        temp.replace(pos,1, "<");
        pos = temp.find("|", pos);
      }
      $$.code = strdup(temp.c_str());
    }
   |          WRITE vars {
      std::string temp;
      temp.append($2.code);
      size_t pos = temp.find("|", 0);
      while (pos != std::string::npos){
        temp.replace(pos,1, ">");
        pos = temp.find("|", pos);
      }
      $$.code = strdup(temp.c_str());
    }
   |          CONTINUE  {
      $$.code = strdup("continue\n");
    }

   |          RETURN expression {
      std::string temp;
      temp.append($2.code);
      temp.append("ret ");
      temp.append($2.place);
      temp.append("\n");
      $$.code = strdup(temp.c_str());
    }
   ;


bool_exp: relational_exps {
    $$.code = strdup($1.code);
    $$.place = strdup($1.place);
  }
  | relational_exps OR bool_exp  {
    std::string temp;
    std::string dst = new_temp();
    temp.append($1.code);
    temp.append($3.code);
    temp += ". " + dst + "\n";
    temp += "|| " + dst + ", ";
    temp.append($1.place);
    temp.append(", ");
    temp.append($3.place);
    temp.append("\n");
    $$.code = strdup(temp.c_str());
    $$.place = strdup(dst.c_str());
  }
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

term: var {

      std::string dst = new_temp();
      std::string temp;

      if($1.arr) {
        temp.append($1.code);
        temp.append(". ");
        temp.append(dst);
        temp.append("\n");
        temp += "=[] " + dst + ", ";
        temp.append($1.place);
        temp.append("\n");
      } else {
        temp.append(". ");
        temp.append(dst);
        temp.append("\n");
        temp += temp + "= " + dst + ", ";
        temp.append($1.place);
        temp.append("\n");
        temp.append($1.code);
      }

      if (varTemp.find($1.place) != varTemp.end()) {
        varTemp[$1.place] = dst;
      }
      $$.code = strdup(temp.c_str());
      $$.place = strdup(dst.c_str());

    }
  |   SUB var {
    
      std::string dst = new_temp();
      std::string temp;
      temp.append($2.code);
      temp.append(". ");
      temp.append($$.place);
      temp.append("\n");

      if($2.arr) {
        temp += "=[] " + dst + ", ";
        temp.append($2.place);
        temp.append("\n");
      } else {
        temp += "= " + dst + ", ";
        temp.append($2.place);
        temp.append("\n");
      }
      temp.append("* ");
      temp.append($$.place);
      temp.append(", ");
      temp.append($$.place);
      temp.append(", -1\n");

      if (varTemp.find($2.place) != varTemp.end()) {
        varTemp[$2.place] = dst;
      }
      $$.code = strdup(temp.c_str());
      $$.place = strdup(dst.c_str());
      $$.arr = false;
    
    }
  |   NUMBER  {

      std::string dst = new_temp();
      std::string temp;
      temp.append(". ");
      temp.append(dst);
      temp.append("\n");
 
      temp = temp + "= " + dst + ", " + std::to_string($1) + "\n";
      $$.code = strdup(temp.c_str());
      $$.place = strdup(dst.c_str());

    }
  |   SUB NUMBER {


    }
  |   L_PAREN expression R_PAREN {

      $$.code = strdup($2.code);
      $$.place = strdup($2.place);

    }
  |   SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN\n");}
  |   identifier L_PAREN R_PAREN {


    }
  |   identifier L_PAREN expression_loop R_PAREN {

        std::string func = $1.place;
        std::string temp;
        if (funcs.find(func) == funcs.end()){
          printf("Calling undeclared function $s.\n", func.c_str());
        }
        std::string dst = new_temp();
        temp.append($3.code);
        temp += ". " + dst + "\ncall ";
        temp.append($1.place);
        temp += ", " + dst + "\n";

        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());

      }
  ;

vars: var {
    std::string temp;
    temp.append($1.code);
    if ($1.arr){
      temp.append(".[]| ");
    }
    else {
      temp.append(".| ");
    }
    temp.append($1.place);
    temp.append("\n");
    $$.code = strdup(temp.c_str());
    $$.place = strdup("");
  }  
  |   var COMMA vars {
    std::string temp;
    temp.append($1.code);
    if ($1.arr){
      temp.append(".[]| ");
    }
    else {
      temp.append(".| ");
    }
    temp.append($1.place);
    temp.append("\n");
    temp.append($3.code);
    $$.code = strdup(temp.c_str());
    $$.place = strdup("ident.c_str()");
  }
  ;

var:  identifier {

    std::string temp;
    std::string ident = $1.place;
    if (funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end()){
      printf("identifier %s is not declared.\n", ident.c_str());
    }
    else if (arrSize[ident] > 1){
      printf("Did not provide index for array Identifier %s.\n", ident.c_str());
    }
    $$.code = strdup("");
    $$.place = strdup(ident.c_str());
    $$.arr = false;
    
  }
  |   identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
    
    std::string temp;
    std::string ident = $1.place;
    if (funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end()){
      printf("identifier %s is not declared.\n", ident.c_str());
    }
    else if (arrSize[ident] == 1){
      printf("Provided index for non-array Identifier %s.\n", ident.c_str());
    }
    temp.append($1.place);
    temp.append(", ");
    temp.append($3.place);
    $$.code = strdup($3.place);
    $$.place = strdup(ident.c_str());
    $$.arr = TRUE;

  }
  ;



%% 


void yyerror(const char *msg) {
  extern int yylineno;
  extern char *yytext;
  printf("%s on line %d at char %d at symbol \"%s\"\n", msg, yylineno, currPos, yytext);
  exit(1);
}

std::string new_temp(){
  std::string t = "t" + std::to_string(tempCount);
  tempCount++;
  return t;
}
std::string new_label(){
  std::string l = "L" + std::to_string(labelCount);
  labelCount++;
  return l;
}
