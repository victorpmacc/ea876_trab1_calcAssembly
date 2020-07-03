
all: lex.yy.c y.tab.c
	gcc -o main lex.yy.c y.tab.c -ll

lex.yy.c: src/main.l y.tab.c
	flex src/main.l

y.tab.c: src/main.y
	bison -dy src/main.y

clean:
	rm y.tab.c lex.yy.c y.tab.h main
