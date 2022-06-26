   /* cs152-miniL phase1 */
%{   
   int currLine = 1, currPos = 1; 
%}


%%
"-"            {/* ARITHMETIC OPERATORS START HERE */ printf("SUB\n"); currPos += yyleng;} 
"+"            {printf("ADD\n"); currPos += yyleng;}
"*"            {printf("MULT\n"); currPos += yyleng;} 
"/"            {printf("DIV\n"); currPos += yyleng;}
"%"            {printf("MOD\n"); currPos += yyleng;}

[ \t]+         {/* Ignore spaces */ currPos += yyleng;}
"\n"           {/* Handle newlines, currently is not recognizing newlines though. */ currLine++; currPos = 1;}

.              {/* Error message for unrecognized symbol */ printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}
%%
	
int main(int argc, char ** argv)
{
   yylex();
}
