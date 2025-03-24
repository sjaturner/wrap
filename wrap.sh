flex wrap.l
bison -d wrap.y
gcc -Wall -g lex.yy.c wrap.tab.c -o parser
./parser < wrap.h
