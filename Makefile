lex.yy.c: wrap.l
	flex $^
wrap.tab.c wrap.tab.h: wrap.y
	bison -d $^	
parser: lex.yy.c wrap.tab.c
	gcc -Wall -g $^ -o $@
wrap.c: wrap.h parser
	./parser < $< > $@
test: wrap_utils.c test.c wrap.c
	gcc -Wall -g $^ -o $@
clean:
	rm -f lex.yy.c wrap.tab.h wrap.tab.c parser wrap.c test tags
	@echo done

