   /* cs152-miniL phase1 */
%{   
   int currLine = 1, currPos = 1; 

   static const char* reservedWord[] = {"function", "beginparams", "endparams", "beginlocals", 
    "endlocals", "beginbody", "endbody", "integer", "array", "enum", "of", "if", "then", "endif", 
    "else", "for", "while", "do", "beginloop", "endloop", "continue", "read", 
    "write", "and", "or", "not", "true", "false", "return"};

   static const char* reservedWordMap[] = {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", 
    "END_LOCALS","BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "ENUM", "OF", "IF", "THEN", "ENDIF",
    "ELSE", "FOR", "WHILE", "DO", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", 
    "WRITE", "AND", "OR", "NOT", "TRUE", "FALSE", "RETURN"};

    const int numReserved = sizeof(reservedWord) / sizeof(reservedWord[0]);
%}

DIGIT    [0-9]
LETTER [a-zA-Z]
CHAR [0-9a-zA-Z_]
CHAR_UNDERSCORE [0-9a-zA-Z]

%%
"-"            {/* ARITHMETIC OPERATORS START HERE */ printf("SUB\n"); currPos += yyleng;} 
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

{LETTER}({CHAR}*{CHAR_UNDERSCORE}+)?    {
   short reservedFound = 0;
   int i;
   for (i = 0; i < numReserved; i++)
   {
      if (strcmp(yytext, reservedWord[i]) == 0)
      {
         reservedFound = 1;
         printf("%s\n", reservedWordMap[i]);
      }
   }
   if (reservedFound == 0)
      printf("%s\n", yytext);
   currPos += yyleng;

}

[ \t]+         {/* Ignore spaces */ currPos += yyleng;}
"\n"           {/* Handle newlines, currently is not recognizing newlines though. */ currLine++; currPos = 1;}

.              {/* Error message for unrecognized symbol */ printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

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
