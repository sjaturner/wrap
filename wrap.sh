flex wrap.l
bison -d wrap.y
gcc lex.yy.c wrap.tab.c -o parser
./parser < wrap.h
