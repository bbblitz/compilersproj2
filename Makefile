
CFLAGS=-g

lex.yy.c:
	lex lexer.l

y.tab.c:
	yacc grammer.y

all: 
	yacc grammer.y
