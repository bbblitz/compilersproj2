
CFLAGS=-g

all: clean
	lex lexer.l
	yacc grammer.y

clean:
	rm lex.yy.c
