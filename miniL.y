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

Carlton Wanks
#4297
🥐 choccy croisussy 🥐
Alone Chat

Carlton Wanks — 04/30/2022
Image
Carlton Wanks — 05/02/2022
Image
Carlton Wanks — 05/03/2022
https://www.cs.yale.edu/homes/aspnes/pinewiki/RadixSort.html#:~:text=The%20resulting%20algorithms%20are%20known,which%20they%20differ%20is%20greater.
Carlton Wanks — 05/04/2022
https://youtu.be/1mdHGYjiydo
YouTube
AceTheScript
(GGST)PSA: Heavily Potemkin Punished
Image
Carlton Wanks — 05/06/2022
Image
Carlton Wanks — 05/17/2022
https://www.postpone.app/
Postpone
Postpone is the Reddit post scheduler and manager for content creators.
Image
Carlton Wanks — 05/17/2022
Purchase sexy halloween costumes on clearance to post
Carlton Wanks — 05/26/2022
This amount is your Parent 1 (father's/mother's/stepparent's) portion of IRS Form 1040-line 1 + Schedule 1, lines 3 + 6 + Box 14 (Code A) of Schedule K-1 (Form 1065).
Carlton Wanks — 05/26/2022
Payments to tax-deferred pension and retirement savings plans (paid directly or withheld from earnings), including, but not limited to, amounts reported on the W-2 Form in Boxes 12a through 12d, codes D, E, F, G, H, and S. Don't include amounts reported in code DD (employer contributions toward employee health benefits).
Carlton Wanks — 05/27/2022
Image
Carlton Wanks — 05/28/2022
Image
Carlton Wanks — 05/28/2022
Image
Carlton Wanks — 05/29/2022
Kitchen knife
Kitchen spoon (slotted and solid)
Kitchen scissors
Tongs
Saucepan (ideally two different sizes, one small one large?)
Sheetpans (also two sizes)
Plastic prep bowls 
Carlton Wanks — 05/31/2022
https://chrome.google.com/webstore/detail/behind-the-overlay/ljipkdpcjbmhkdjjmbbaggebcednbbme
Behind The Overlay
One click to close any overlay on any website.
Image
Carlton Wanks — 05/31/2022
WARNING: EXTREMELY CURSED and NSFW COPYPASTA

I've never wanted to be bred by anyone more than I want to by Potemkin. That perfect, humongous body. Those absolutely jacked arms. The thunder thighs of an absolute powerhouse. It honestly fucking hurts knowing that he'll never mate with me, pass his genes through me, and have me birth a set of his perfect offspring. I'd do fucking ANYTHING for the chance to have Potemkin get me pregnant. A N Y T H I N G. And the fact that I can't is quite honestly too much to fucking bear. Why would ArcSys create something so perfect? To fucking tantalize us? Fucking laugh in our faces?! Honestly guys, I just fucking can't anymore. Fuck.
Carlton Wanks — 06/02/2022
Image
Image
Image
Carlton Wanks — 06/05/2022
Image
Carlton Wanks — 06/05/2022
import numpy as np

def generateReads():
    print("TODO: Write generator for reads")
Image
Carlton Wanks — 06/05/2022
https://www.pixiv.net/en/users/47617/artworks
pixiv
アシオミマサト's illustrations/manga
エロ漫画家
商業はティーアイネットとかワニマガジンとかで生息中

ギルティギアのミリアちゃん大好き勢。

R18用Twitterアカウント→(https://twitter.com/a_masaton)

多忙につきリクエスト等は受け付けておりません、ご了承ください。


*ご連絡はツイッターかPixivメッセージで宜しくお願い致します。
アシオミマサト's illustrations/manga
Carlton Wanks — 06/07/2022
AsterixDB datetime
https://asterixdb.apache.org/docs/0.8.8-incubating/aql/functions.html
Carlton Wanks — 06/07/2022
parse_datetime('2015-02-21','YYYY-MM-DD')
Carlton Wanks — 06/07/2022
-- Initializing the dataverse
DROP DATAVERSE bird_data IF EXISTS;
CREATE DATAVERSE bird_data;
USE bird_data;

-- Creating the data type we will use. Because Parquet files embed the schema within each file, 
-- we can let AsterixDB simply read the file's schema for us without explicitly declaring it.
CREATE TYPE ParquetType AS {
};

-- To access Parquet files, we need to create an external dataset so AsterixDB has access to it.
create external DATASET ParquetDataset(ParquetType) using hdfs 
(
    ("path"="D:/cs167/workspace/Project_b3/eBird_1k.parquet"),
    ("input-format"="parquet-input-format")
);


--SELECT COMMON_NAME, COUNT(*) as count, parse_date(OBSERVATION_DATE, "YYYY/MM/DD") as date
-- FROM ParquetDataset
--WHERE date BETWEEN "2015/02/21"  AND "2015/05/22"
--GROUP BY COMMON_NAME;

SELECT COMMON_NAME, COUNT(*) as count
FROM(
  SELECT parse_date(OBSERVATION_DATE, "YYYY/MM/DD") as date   
  FROM ParquetDataset
  WHERE date BETWEEN '2015/02/21' AND '2015/05/22'
) as result
GROUP BY COMMON_NAME;
Carlton Wanks — 06/08/2022
leasing@highlanderatnorthcampus.com
Carlton Wanks — 06/19/2022
1dkXJC%TRx7YJiM&WmPUlJK3
Carlton Wanks — 06/23/2022
I'm not gonna be free today for a bit, if you want to work on the project could you implement some more of the rules from the
Carlton Wanks — 06/26/2022
Image
Carlton Wanks — 07/05/2022
Image
Carlton Wanks — 07/05/2022
4269 3800 9711 1326
Image
Carlton Wanks — 07/07/2022
Mageslayer
Image
Carlton Wanks — 07/11/2022
For worlds...

On the way home from Vanderport...
- Witt decides to leave at Sternhold. Will not openly say where he's going, but if pressed will say that Bastien is helping him find a place to "disappear to". Will say he'll send letters, at least, and thanks the party for their company and teaching him.
- At some point when passing out of Sternhold and into the Foothills, they'll be stopped by men of House Vanderberg, but the men accidentally say House Vanderwasse before being corrected by his peers; Sir Espen has founded a cadet branch of House Vanderwasse on account of his faithful service and skilled lordship of the foothills region! (Lord Vanderwasse swayed him to implement some of Chloe's ideas from her influence-spending as a test ground there in exchange for getting to found his own house)
- Back at Vanderport, Zihark will notice that his mentor and fellow Viper, Fatima, has taken up the guise of a servant. To what end...?
- Thymin, at some point during their stay at Vanderport, will get to converse with another Ember Islander dwarf about the coming human civil war. They will complain about how the local nobles (aka the Vanderwases) seem to sure be getting cozy with the Exiles 🙄
- Vasilii, whose Writ of Sanctioning currently is in question due to his master's imprisonment and now disappearance under mysterious circumstances (give 2 parts of Laeros' notes), is intercepted by an agent of Lord Vanderwasse's spymaster and taken to a safehouse in the Bottomfeeders' Borough, the poor neighborhood. At some point, his master will appear to him, although seemingly phasing in and out of reality, disjointed and half-present, and give a cryptic message saying that "He knows of you". Before he can clarify who "He" is, he will vanish. Later, seemingly unrelated, Anatoly the healer will come to discuss matters about mysterious occurrences in the Borderlands...
- Grettir will constantly be hailed in the streets as the Butcher's Bane, and will both constantly have fools trying to fight him. He will not feel even an inkling of danger, to the point of boring him; all he can think of are fragmented memories of his time in the foglands haunting him. 
Carlton Wanks — 07/11/2022
Winter timeskip...
Preparations for the coming Civil War between two twin princes, Alphonse and  Bernard Dumont. 
- The older Prince Alphonse is a cunning and ambitious man but with a cruel streak, earning him many enemies despite his legal precedence. His open associations with the Conclave of Mages in the Leylands have caused them to sway their puppets, the Leylands' ruling house of Myrthal, to declare their allegiance to the Alphonse.
- Meanwhile, his brother Bernard is a brave, brash, and pious man, with a reputation for being reckless yet generous. Eager to avenge his brother's injustices against the Holy Flame, his bid for the throne is backed by the House of Godwin, along with many in the Crownlands who believe he would be a better ruler than his brother (or perhaps an easier to manipulate one...).
Carlton Wanks — 07/11/2022
Hey y'all, so some things I'd like to hear about from you guys because I need to know this for the purposes of my prep.

- With Witt wanting to leave, is anyone planning to speak with him and convince him to stay with you guys or at least press him further for his reasoning/otherwise question him?

- You will be arriving back at Vanderport sometime in late Fall/early Winter; there'll be a timeskip until the spring unless you guys decide to do something on an urgent timescale. If your character has something they want to do during this gap of a few months, let me know. This will be used for me to reveal information about the coming Civil War as the relevant factions are marshalling their forces for the Spring to start their war.
Carlton Wanks — 07/12/2022
Image
Carlton Wanks — 07/16/2022
Image
Carlton Wanks — 07/16/2022
"King Landon of Wolmunde, of the House of Dumont, has passed away. His son and rightful heir, Alphonse, now ascends to the throne; long may he reign!

However, there are those for whom the laws of the realm mean nothing, and who would rather see the realm engulfed once more by bloody warfare than respect the legal and rightful claim of King Alphonse, first of his name! The traitor Prince Bernard has fled the capital for the Gardenlands, where his treasonous supporters marshal their forces and spread their vile lies. This cannot be considered as anything less than treason, the punishment for which is death. The realm calls upon all its loyal subjects to answer the call of their rightful King and crush these traitors!"

This letter bears the kingdom's royal seal.

"To all of my fellow countrymen who fight for what is right, the pretender Alphonse is guilty of innumerable unspeakable crimes, and must abdicate immediately and face justice for these unspeakable acts. He consorts with dark powers, assails the Keepers of the Holy Flame, and worst of all, a kinslayer! Having murdered our father, Flame rest his soul, to ascend to the throne, his ambition could not be quenched, and he even attempted to murder me, his own brother! Alphonse is not fit to rule, for how can a King whose soul is so shrouded in Darkness be trusted to guide this Kingdom to the Light? I urge all who would fight on the side of justice to rally to my banner, and together we shall cast out the Darkness that looms over the realm!"

This letter is stamped with the personal seal of Prince Bernard Dumont. 
Carlton Wanks — 07/16/2022
Image
Carlton Wanks — 07/17/2022
Image
Image
Image
Carlton Wanks — 07/17/2022
Zomboid MP User/Pass
Image
Carlton Wanks — 07/17/2022
Image
Carlton Wanks — Yesterday at 2:15 AM
Zihark's mentor, Fatima, is disguised as a servant in Lord Vanderwasse's keep
Carlton Wanks — Yesterday at 3:27 PM
14, 15, 22, 25, 35
Carlton Wanks — Yesterday at 10:26 PM
CC = gcc
CFLAGS = -g -O0 -std=c99

miniL: miniL-lex.o miniL-parser.o
    $(CC) $^ -o $@ -lfl

%.o: %.c
    $(CC) $(CFLAGS) -c $< -o $@

miniL-lex.c: miniL.lex miniL-parser.c
    flex -o $@ $< 

miniL-parser.c: miniL.y
    bison -d -v -g -o $@ $<

clean:
    rm -f .o miniL-lex.c miniL-parser.c miniL-parser.h.output *.dot miniL
Carlton Wanks — Today at 9:35 AM
var ASSIGN expression {
              /* printf("statement -> var ASSIGN expression\n");/
              std::string temp;

              temp.append("= ");
              temp.append($1.place);
              temp.append(", "); 
              temp.append($3.place);

              $$.code = strdup(temp.c_str());
              $$.place = strdup("");
              }

   |          IF bool_exp THEN statements ENDIF {
                / printf("statement -> IF bool_exp THEN statements ENDIF \n"); */
                std::string temp;
                temp.append(": );
                temp.append($2.code);
                temp.append();

                }
Carlton Wanks — Today at 11:43 AM
statement:    var ASSIGN expression {
              /* printf("statement -> var ASSIGN expression\n");*/
              std::string temp;

              temp.append($1.place); 
              temp.append($3.place);

              std::string intermediate = $3.place;
              if ($1.array && $3.array) {
                intermediate = newTemp();
                temp.append(". ");
                temp.append(intermediate);
                temp.append("\n");
                temp.append("=[] ");
                temp.append(intermediate);
                temp.append(", ");
                temp.append($3.place);
                temp.append("\n");
                temp.append("[]= ");
              }
            
              else if ($1.array) {
                temp.append("[]= ");
              }

              else if ($3.array) {
                temp.append("=[] ");
              }
              
              else {
                temp.append("= ");
              }
  
              temp.append($1.place);
              temp.append(", ");
              temp.append(intermediate);
              temp.append("\n");

              $$.code = strdup(temp.c_str());
            }
              
   |          IF bool_exp THEN statements ENDIF {
                /* printf("statement -> IF bool_exp THEN statements ENDIF \n"); */
                std::string temp;
                std::string thenStart = new_label();
                std::string after = new_label();
                
                temp.append($2.code);
                
                // If bool expession is true, then go to the label.
                temp.append("?:= ");
                temp.append(thenStart);
                temp.append(", ");
                temp.append($2.place);
                temp.append("\n");

                // then label, followed by its code.
                temp.append(": ");
                temp.append(thenStart);
                temp.append("\n");
                temp.append($4.code);

                $$.code = strdup(temp.c_str());
                }

   |          IF bool_exp THEN statements ELSE statements ENDIF {
                /* printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF \n"); */
                std::string temp;
                std::string thenStart = new_label();
                std::string after = new_label();
                
                temp.append($2.code);
                
                // If bool expession is true, then go to the label.
                temp.append("?:= ");
                temp.append(thenStart);
                temp.append(", ");
                temp.append($2.place);
                temp.append("\n");

                // else code
                temp.append($5.code);

                // goto after
                temp.append(":= ");
                temp.append(after);
                temp.append("\n");

                // then label, followed by its code.
                temp.append(": ");
                temp.append(thenStart);
                temp.append("\n");
                temp.append($4.code);

                // after label
                temp.append(": ");
                temp.append(after);
                temp.append("\n");

                $$.code = strdup(temp.c_str());
... (80 lines left)
Collapse
message.txt
7 KB
﻿
statement:    var ASSIGN expression {
              /* printf("statement -> var ASSIGN expression\n");*/
              std::string temp;

              temp.append($1.place); 
              temp.append($3.place);

              std::string intermediate = $3.place;
              if ($1.array && $3.array) {
                intermediate = newTemp();
                temp.append(". ");
                temp.append(intermediate);
                temp.append("\n");
                temp.append("=[] ");
                temp.append(intermediate);
                temp.append(", ");
                temp.append($3.place);
                temp.append("\n");
                temp.append("[]= ");
              }
            
              else if ($1.array) {
                temp.append("[]= ");
              }

              else if ($3.array) {
                temp.append("=[] ");
              }
              
              else {
                temp.append("= ");
              }
  
              temp.append($1.place);
              temp.append(", ");
              temp.append(intermediate);
              temp.append("\n");

              $$.code = strdup(temp.c_str());
            }
              
   |          IF bool_exp THEN statements ENDIF {
                /* printf("statement -> IF bool_exp THEN statements ENDIF \n"); */
                std::string temp;
                std::string thenStart = new_label();
                std::string after = new_label();
                
                temp.append($2.code);
                
                // If bool expession is true, then go to the label.
                temp.append("?:= ");
                temp.append(thenStart);
                temp.append(", ");
                temp.append($2.place);
                temp.append("\n");

                // then label, followed by its code.
                temp.append(": ");
                temp.append(thenStart);
                temp.append("\n");
                temp.append($4.code);

                $$.code = strdup(temp.c_str());
                }

   |          IF bool_exp THEN statements ELSE statements ENDIF {
                /* printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF \n"); */
                std::string temp;
                std::string thenStart = new_label();
                std::string after = new_label();
                
                temp.append($2.code);
                
                // If bool expession is true, then go to the label.
                temp.append("?:= ");
                temp.append(thenStart);
                temp.append(", ");
                temp.append($2.place);
                temp.append("\n");

                // else code
                temp.append($5.code);

                // goto after
                temp.append(":= ");
                temp.append(after);
                temp.append("\n");

                // then label, followed by its code.
                temp.append(": ");
                temp.append(thenStart);
                temp.append("\n");
                temp.append($4.code);

                // after label
                temp.append(": ");
                temp.append(after);
                temp.append("\n");

                $$.code = strdup(temp.c_str());
              }
   |          WHILE bool_exp BEGINLOOP statements ENDLOOP {
                /* printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP \n"); */
                std::string temp;
                std::string whileStart = new_label();
                std::string loopStart = new_label();
                std::string loopEnd = new_label();
                std::string statement = $4.code;
                std::string jump;
                jump.append(":= ");
                jump.append(whileStart);
                while (statement.find("continue") != std::string::npos) {
                  statement.replace(statement.find("continue"), 8, jump);
                }

                temp.append(": "); 
                temp.append(whileStart); 
                temp.append("\n"); 

                temp.append($2.code);
                temp.append("?:= "); 
                temp.append(loopStart); 
                temp.append(", "); 
                temp.append($2.place); 
                temp.append("\n");
                
                temp.append(":= "); 
                temp.append(loopEnd); 
                temp.append("\n");

                temp.append(": ");
                temp.append(loopStart);
                temp.append("\n");

                temp.append(statement);
                temp.append(":= ");
                temp.append(whileStart);
                temp.append("\n");

                temp.append(": ");
                temp.append(loopEnd);
                temp.append("\n");

                $$.code = strdup(temp.c_str());
                
              }
   |          DO BEGINLOOP statements ENDLOOP WHILE bool_exp {
                /* printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp \n");*/
                std::string temp;
                std::string loopStart = new_label();
                std::string whileStart = new_label();
                std::string statement = $3.code;
                
                // jump 
                std::string jump;
                jump.append(":= ");
                jump.append(whileStart);

                while (statement.find("continue") != std::string::npos) {
                  statement.replace(statement.find("continue"), 8, jump);
                }

                temp.append(": ");
                temp.append(loopStart);
                temp.append("\n");

                temp.append(statement);
                temp.append(": ");
                temp.append(whileStart);
                temp.append("\n");

                temp.append($6.code);
                temp.append("?:= ");
                temp.append(loopStart);
                temp.append(", ");
                temp.append($6.place);
                temp.append("\n");

                $$.code = strdup(temp.c_str());
              }
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
