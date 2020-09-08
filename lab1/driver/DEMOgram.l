%option noyywrap
%{

 /* DEMO scanner
  * 
  * Written at Rice University, Houston, Texas.
  *
  */
 
 /* definitions */

#ifdef FLEX_SCANNER
extern int yylineno;
#define YYINCR(n) yylineno += n
#else
#define YYINCR(n)
#endif

#include "tokens.h"
#include "strings.h"
#include "demo.h"


int CTRL_M = 0;


%%
 /* rules  */
"and" {
	//printf("AND\n");
	return AND;
}
"by" {
	//printf("BY\n");
	return BY;
}
"char" {
	//printf("CHAR\n");
	return CHAR;
}
"else" {
	//printf("ELSE\n");
	return ELSE;
}
"for" {
	//printf("FOR\n");
	return FOR;
}
"if" {
	//printf("IF\n");
	return IF;
}
"int" {
	//printf("INT\n");
	return INT;
}
"not" {
	//printf("NOT\n");
	return NOT;
}
"or" {
	//printf("OR\n");
	return OR;
}
"procedure" {
	//printf("PROCEDURE\n");
	return PROCEDURE;
}
"read" {
	//printf("READ\n");
	return READ;
}
"then" {
	//printf("THEN\n");
	return THEN;
}
"to" {
	//printf("TO\n");
	return TO;
}
"while" {
	//printf("WHILE\n");
	return WHILE;
}
"write" {
	//printf("WRITE\n");
	return WRITE;
}

"+" {
	//printf("%c\n", '+');
	return '+';
}
"-"	{
	//printf("%c\n", '-');
	return '-';
}
"*" {
	//printf("%c\n", '*');
	return '*';
}
"/" {
	//printf("%c\n", '/');
	return '/';
}
"<" {
	//printf("LT\n");
	return LT;
}
"<=" {
	//printf("LE\n");
	return LE;
}
"==" {
	//printf("EQ\n");
	return EQ;
}
"!=" {
	//printf("NE\n");
	return NE;
}
">" {
	//printf("GT\n");
	return GT;
}
">=" {
	//printf("GE\n");
	return GE;
}

":" {
	//printf("%c\n", ':');
	return ':';
}
";"	{
	//printf("%c\n", ';');
	return ';';
}
"," {
	//printf("%c\n", ',');
	return ',';
}
"=" {
	//printf("%c\n", '=');
	return '=';
}
"{" {
	//printf("%c\n", '{');
	return '{';
}
"}" {
	//printf("%c\n", '}');
	return '}';
}
"[" {
	//printf("%c\n", '[');
	return '[';
}
"]" {
	//printf("%c\n", ']');
	return ']';
}
"(" {
	//printf("%c\n", '(');
	return '(';
}
")" {
	//printf("%c\n", ')');
	return ')';
}

[A-Za-z][A-Za-z0-9]* {
	//printf("NAME\n");
	return NAME;
}
[0-9]+ {
	//printf("NUMBER\n");
	return NUMBER;
}
'([^\n]|\\.)' {
	//printf("CHARCONST\n");	
	return CHARCONST;
}
"//".* {
	//printf("//");
}
[ \t]* {
	//printf("blank");
}
[\n] {
	//printf("yylineno++\n");
	yylineno++;
}

%%

/* user code */

