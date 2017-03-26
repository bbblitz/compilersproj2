
CFLAGS=-g

all:   y.tab.c lex.yy.c proj2.c
	gcc  $(CFLAGS) -o parser y.tab.c proj2.c -lfl
y.tab.c:  grammer.y
	yacc -v grammer.y
lex.yy.c: lexer.l 
	flex lexer.l
