   /* cs152-miniL phase1 */
%{   
   #include "miniL-parser.h"
   int currLine = 1, currPos = 1; 

   static const char* reservedWord[] = {"function", "beginparams", "endparams", "beginlocals", 
    "endlocals", "beginbody", "endbody", "integer", "array", "enum", "of", "if", "then", "endif", 
    "else", "for", "while", "do", "beginloop", "endloop", "continue", "read", 
    "write", "and", "or", "not", "true", "false", "return"};

   static const char* reservedWordMap[] = {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", 
    "END_LOCALS","BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "ENUM", "OF", "IF", "THEN", "ENDIF",
    "ELSE", "FOR", "WHILE", "DO", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", 
    "WRITE", "AND",  "OR", "NOT", "TRUE", "FALSE", "RETURN"};

    const int numReserved = sizeof(reservedWord) / sizeof(reservedWord[0]);
%}

DIGIT          [0-9]
LETTER         [a-zA-Z]
ALPHANUMERIC   [0-9a-zA-Z]
DIGIT_UNDER    [0-9_]
LETTER_UNDER   [a-zA-Z_]
ALPHA_UNDER    [0-9a-zA-Z_]

%%
"-"            {currPos += yyleng; return SUB; } 
"+"            {currPos += yyleng; return ADD; }
"*"            {currPos += yyleng; return MULT; } 
"/"            {currPos += yyleng; return DIV; }
"%"            {currPos += yyleng; return MOD; }

":="            {currPos += yyleng; return ASSIGN; }
"("            {currPos += yyleng; return L_PAREN; }
")"            {currPos += yyleng; return R_PAREN;}
"["            {currPos += yyleng; return L_SQUARE_BRACKET; }
"]"            {currPos += yyleng; return R_SQUARE_BRACKET; }
","            {currPos += yyleng; return COMMA;}
":"            {currPos += yyleng; return COLON;}
";"            {currPos += yyleng; return SEMICOLON;}

"=="            {currPos += yyleng; return EQ;}
"<>"            {currPos += yyleng; return NEQ;}
"<"             {currPos += yyleng; return LT;}
">"             {currPos += yyleng; return GT;}
"<="            {currPos += yyleng; return LTE;}
">="            {currPos += yyleng; return GTE;}

"function"     {currPos += yyleng; return FUNCTION;}
"beginparams"  {currPos += yyleng; return BEGIN_PARAMS;}
"endparams"    {currPos += yyleng; return END_PARAMS;}
"beginlocals"  {currPos += yyleng; return BEGIN_LOCALS;}
"endlocals"    {currPos += yyleng; return END_LOCALS;}
"beginbody"    {currPos += yyleng; return BEGIN_BODY;}
"endbody"      {currPos += yyleng; return END_BODY;}
"integer"      {currPos += yyleng; return INTEGER;}
"array"        {currPos += yyleng; return ARRAY;}
"of"           {currPos += yyleng; return OF;}
"if"           {currPos += yyleng; return IF;}
"then"         {currPos += yyleng; return THEN;}
"endif"        {currPos += yyleng; return ENDIF;}
"else"         {currPos += yyleng; return ELSE;}
"while"        {currPos += yyleng; return WHILE;}
"do"           {currPos += yyleng; return DO;}
"for"          {currPos += yyleng; return FOR;}
"beginloop"    {currPos += yyleng; return BEGINLOOP;}
"endloop"      {currPos += yyleng; return ENDLOOP;}
"continue"     {currPos += yyleng; return CONTINUE;}
"read"         {currPos += yyleng; return READ;}
"write"        {currPos += yyleng; return WRITE;}
"and"          {currPos += yyleng; return AND;}
"or"           {currPos += yyleng; return OR;}
"not"          {currPos += yyleng; return NOT;}
"true"         {currPos += yyleng; return TRUE;}
"false"        {currPos += yyleng; return FALSE;}
"return"       {currPos += yyleng; return RETURN;}

{DIGIT}+      {
   yylval.num_val == atoi(yytext); 
   return NUMBER; 
   currPos += yyleng;
   }

{LETTER}({ALPHA_UNDER}*{ALPHANUMERIC}+)?    {
   
   yylval.ident_val = yytext; 
   return IDENT;
   currPos += yyleng;
}


({DIGIT}+{ALPHA_UNDER}{ALPHANUMERIC}*)|("_"{ALPHA_UNDER}]+) {/* Checking for valid identifiers */ printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currPos, currLine, yytext); exit(0);}
{LETTER}({ALPHA_UNDER}*{ALPHANUMERIC}+)?"_"                 {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currPos, currLine, yytext); exit(0);}


[ \t]+         {/* Ignoring whitespace */ currPos += yyleng;}
"\n"           {currLine++; currPos = 1;}
"\r"
[##].*         {currLine++; currPos = 1;}
.              {/* Error message for unrecognized symbol */ printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}
%%
