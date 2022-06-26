   /* cs152-fall08 */
   /* A flex scanner specification for the calculator language */
   /* Written by Dennis Jeffrey */

%{   
   int currLine = 1, currPos = 1;
   int numIntegers = 0;
   int numOperators = 0;
   int numParens = 0;
   int numEquals = 0;

   static const char* reservedWord[] = {"function", "beginparams", "endparams", "beginlocals", 
    "endlocals", "beginbody", "endbody", "integer", "array", "enum", "of", "if", "then", "endif", 
    "else", "for", "while", "do", "beginloop", "endloop", "continue", "read", 
    "write", "and", "or", "not", "true", "false", "return"};

   static const char* reservedWordMap[] = {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", 
    "END_LOCALS","BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "ENUM", "OF", "IF", "THEN", "ENDIF",
    "ELSE", "FOR", "WHILE", "DO", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", 
    "WRITE", "AND", "OR", "NOT", "TRUE", "FALSE", "RETURN"};


%}

DIGIT    [0-9]
   
%%

"-"            {printf("SUB\n"); currPos += yyleng;}
"+"            {printf("ADD\n"); currPos += yyleng;}
"*"            {printf("MULT\n"); currPos += yyleng;}
"/"            {printf("DIV\n"); currPos += yyleng;}
"%"            {printf("MOD\n"); currPos += yyleng;}

"="            {printf("ASSIGN\n"); currPos += yyleng;}
"("            {printf("L_PAREN\n"); currPos += yyleng;}
")"            {printf("R_PAREN\n"); currPos += yyleng;}
"["            {printf("L_SQUARE_BRACKET\n"); currPos += yyleng;}
"]"            {printf("R_SQUARE_BRACKET\n"); currPos += yyleng;}
","            {printf("COMMA\n"); currPos += yyleng;}
":"            {printf("COLON\n"); currPos += yyleng;}
";"            {printf("SEMICOLON\n"); currPos += yyleng;}

"=="            {printf("EQ\n"); currPos += yyleng;}
"<>"            {printf("NEQ\n"); currPos += yyleng;}
"<"             {printf("LT\n"); currPos += yyleng;}
">"             {printf("GT\n"); currPos += yyleng;}
"<="            {printf("LTE\n"); currPos += yyleng;}
">="            {printf("GTE\n"); currPos += yyleng;}



{DIGIT}+       {printf("NUMBER %s\n", yytext); currPos += yyleng;}

[ \t]+         {/* ignore spaces */ currPos += yyleng;}

"\n"           {currLine++; currPos = 1;}

.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%

int main(int argc, char ** argv)
{
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
   yylex();

}
