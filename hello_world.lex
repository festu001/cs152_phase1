   /* cs152-fall08 */
   /* A flex scanner specification for the calculator language */
   /* Written by Dennis Jeffrey */

%{   
   int currLine = 1, currPos = 1;
   int numIntegers = 0;
   int numOperators = 0;
   int numParens = 0;
   int numEquals = 0;
%}

DIGIT    [0-9]
   
%%

"-"            {printf("MINUS\n"); currPos += yyleng; numOperators += 1;}
"+"            {printf("PLUS\n"); currPos += yyleng; numOperators += 1;}
"*"            {printf("MULT\n"); currPos += yyleng; numOperators += 1;}
"/"            {printf("DIV\n"); currPos += yyleng; numOperators += 1;}
"="            {printf("EQUAL\n"); currPos += yyleng; numEquals += 1; }
"("            {printf("L_PAREN\n"); currPos += yyleng; numParens += 1;}
")"            {printf("R_PAREN\n"); currPos += yyleng; numParens += 1;}

{DIGIT}+       {printf("NUMBER %s\n", yytext); currPos += yyleng; numIntegers += 1;}

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

printf("numIntegers = %d\n", numIntegers);
printf("numEquals = %d\n", numEquals);
printf("numParens = %d\n", numParens);
printf("numOperators = %d\n", numOperators);
}
