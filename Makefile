CFLAGS = -g -Wall -ansi -pedantic

miniL: miniL.lex miniL.y
	bison -d -v miniL.y
	flex miniL.lex
	g++ $(CFLAGS) -std=c++11 lex.yy.c miniL.tab.c -lfl -o miniL
	rm -f lex.yy.c *.output *.tab.c *.tab.h


test: miniL
	cat ./phase1/mytest.min | ./miniL > ./phase1/mytest.mil

test2:
	echo 5 > input.txt
	mil_run fibonacci,mil < input.txt

clean:
	rm -f lex.yy.c y.tab.* y.output *.o parser
	rm -f *.o miniL-lex.c miniL-parser.c miniL-parser.h *.output *.dot miniL *.tab.h *.tab.c