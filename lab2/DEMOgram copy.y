%{ 
/* Copyright 2016, Keith D. Cooper & Linda Torczon
 * 
 * Written at Rice University, Houston, Texas as part
 * of the instructional materials for COMP 506.
 *
 * The University may have some rights in this work.
 *
 */

#define YYERROR_VERBOSE


#include <stdio.h>
#include "demo.h"

int yylineno;
char *yytext;
struct NODE * children[CHILD_NUM];

%}

%union {
  unsigned long int val;
  char             *cptr;
  struct NODE     *nodeptr;
  struct BP        *bp;
  struct LOOP      *loop;
  struct LOOPEXPR  *loopex;
  struct ITEHEAD   *ite;
}


%token <val> BY
%token <val> CHAR
%token <val> CHARCONST
%token <val> COLON
%token <val> COMMA
%token <val> DIVIDE
%token <val> ELSE
%token <val> ENDOFFILE
%token <val> EQUALS
%token <val> FOR
%token <val> IF
%token <val> INT
%token <val> LBRACKET
%token <val> LPAREN
%token <val> LSQUARE
%token <val> MINUS
%token <val> NAME
%token <val> ELE
%token <val> NOT
%token <val> NUMBER
%token <val> PLUS
%token <val> PROCEDURE
%token <val> RBRACKET
%token <val> READ
%token <val> RPAREN
%token <val> RSQUARE
%token <val> SEMICOLON
%token <val> THEN
%token <val> TIMES
%token <val> TO
%token <val> WHILE
%token <val> WRITE
%token <val> UNKNOWN


%token <val> LT
%token <val> LE
%token <val> EQ
%token <val> NE
%token <val> GE
%token <val> GT
%token <val> AND
%token <val> OR

%type <val> Grammar

%type <nodeptr> AndTerm
%type <nodeptr> Bool
%type <val> CharConst
%type <val> Decl
%type <nodeptr> Expr
%type <nodeptr> Factor
%type <val> ITEControlLogic
%type <val> Name
%type <nodeptr> Number
%type <nodeptr> OrTerm
%type <val> Proc
%type <val> ProcList
%type <val> Read
%type <val> Reference
%type <nodeptr> RelExpr
%type <val> SpecList
%type <val> Spec
%type <val> Stmts
%type <val> Stmt
%type <val> MStmt
%type <val> UStmt
%type <val> Stmt1
%type <nodeptr> Term
%type <val> Type
%type <val> WhileHead
%type <val> Write

%start  Grammar

%%

 /* High level list of procedures */

Grammar:  ProcList ENDOFFILE { walk($1);
                                                           freeAST($1);
                                                           freeST(sym_table);
       return 1; }
;


ProcList :  ProcList Proc { add_sybling_node($1, $2);	/* Stmts = root Stmt = sibling*/
							$$ = $1;}
       |    Proc {	children[0] = $1;
					$$ = make_op_node( NODE_STATEMENTS, children, 1);}
;

Proc   :  PROCEDURE Name LBRACKET
              Decls Stmts
          RBRACKET { $$ = $5; }
       |  PROCEDURE Name LBRACKET Decls Stmts ENDOFFILE
          { yyerror("Missing final right bracket ('}')"); }
; 

/* Declaration Syntax */

Decls  :   Decls Decl SEMICOLON { cur = TYPE_UNK; }
       |   Decl SEMICOLON { cur = TYPE_UNK; }
;

Decl   :   Type  SpecList
;

Type   :   INT	{ cur = TYPE_INT; }
       |   CHAR { cur = TYPE_CHAR; }
;

SpecList:  SpecList COMMA Spec
       |   Spec
;

Spec   :   Name
;

/* The Statment Grammar */
Stmts  :   Stmts Stmt	{ 	add_sybling_node($1, $2);	/* Stmts = root Stmt = sibling*/
							$$ = $1; }
       |  Stmt  { 	children[0] = $1;
       				$$ = make_op_node( NODE_STATEMENTS, children, 1); }
;

ITEControlLogic : IF LPAREN Bool RPAREN
;


Stmt : MStmt
     | UStmt
;

UStmt:  ITEControlLogic THEN Stmt
     |  ITEControlLogic THEN MStmt ELSE UStmt
;

MStmt:  ITEControlLogic THEN MStmt ELSE MStmt
     |  Stmt1 
;

Stmt1 :  Reference EQUALS Expr SEMICOLON {  children[0] = $1;
											children[1] = $3;
											$$ = make_op_node( NODE_ASSIGN, children, 2);
                                          }
      |  LBRACKET Stmts RBRACKET
      |  LBRACKET RBRACKET 
         { yyerror("Empty statement list"); }
      |  WhileHead LBRACKET Stmts RBRACKET 
      |  Read
      |  Write 
      |  SEMICOLON 
         { yyerror("Unexpected semicolon; indicates an empty statement"); }
      |  error {yyclearin; yyerrok; }
;


WhileHead : WHILE LPAREN Bool RPAREN 
;

Read   : READ Reference SEMICOLON 
;
Write  : WRITE Expr SEMICOLON { children[0]=$2;
								$$ = make_op_node(NODE_WRITE, children, 1); }
;

/* The Expression Grammar */
Expr   : Expr PLUS Term {	children[0] = $1;
							children[1] = $3;
							$$ = make_op_node(NODE_PLUS, children, 2);}
       | Expr MINUS Term 
       | Term {$$ = $1;}
;

Term   : Term TIMES Factor 
       | Term DIVIDE Factor 
       | Factor {$$ = $1;}
;

Factor : LPAREN Expr RPAREN { $$ = $2; }
       | Reference { $$ = $1; }
       | Number { $$ = $1; }
       | CharConst { $$ = $1; }
;

Reference :  Name { $$ = make_leaf_node(NODE_NAME, strdup($1), 0);}
;


Name   : NAME {
				  $$ = strdup(TokenString);
				  if (getsym(TokenString) == NULL && cur != TYPE_UNK) {

					putsym(TokenString, cur, 0);
				  }
              }
;

Number : NUMBER {$$ = make_leaf_node(TYPE_INT,"", atoi(TokenString));}
;


CharConst : CHARCONST {$$ = make_leaf_node(TYPE_CHAR,"", atoi(TokenString));}
;

Bool : NOT OrTerm
     | OrTerm 
;

OrTerm : OrTerm OR AndTerm 
       | AndTerm  
;

AndTerm : AndTerm AND RelExpr
        | RelExpr 
;
RelExpr : RelExpr LT Expr
        | RelExpr LE Expr
        | RelExpr EQ Expr
        | RelExpr NE Expr
        | RelExpr GE Expr
        | RelExpr GT Expr
        | Expr 	
;

%%
static int ErrLine = 0;

int yywrap()
{
  return 1;
} 

void yyerror(s)
   char *s;
{
  if (yylineno != ErrLine) {
    fprintf(stderr, "Line %d: %s\n",yylineno,s);
    syntax_error++;
  }

  ErrLine = yylineno;
  fprintf(LOG, "Parser, line %d: %s\n",yylineno,s);
  fprintf(LOG, "\tlexeme is '%s'.\n", yytext);

  /* will delete CODE and Storage Layout files back in main() */
}


