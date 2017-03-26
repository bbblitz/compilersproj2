
CFLAGS=-g

all:   y.tab.c lex.yy.c proj2.c
	gcc  $(CFLAGS) -o parser y.tab.c proj2.c -lfl
y.tab.c:  gramm2.y lex.yy.c
	yacc -v gramm2.y
lex.yy.c: lexer.l 
	flex lex.l

clean:
	rm lex.yy.c y.tab.c y.output parser
