lex.yy.c: wrap.l
	flex $^
wrap.tab.c wrap.tab.h: wrap.y
	bison -d $^	
parser: lex.yy.c wrap.tab.c
	gcc -Wall -g $^ -o $@
wrap.c: wrap.h parser
	./parser < $< > $@
clean:
	rm -f lex.yy.c wrap.tab.h wrap.tab.c parser
	@echo done

