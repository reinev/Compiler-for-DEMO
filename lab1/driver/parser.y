%{
#include <stdio.h>
#include <stdlib.h>
#include "ilocEmitter.h"
#include "symbolTable.h"
#define YYERROR_VERBOSE

int yylineno;
int type; // 0 for int, 1 for char
int syntax_error = 0;

extern int yylex(void); 

int yywrap(void) {return 1;}
char *yytext;
char *lexeme;
void yyerror( char *s );

%}
%union {
   char *string;
   struct Variable *variable;
   struct IfStmt *ifStmt;
   struct ForStmt *forStmt;
   struct WhileStmt *whileStmt;
   struct Array *array;
   struct Dim *dim; 
   struct Indices *index;
}

%token PROCEDURE
%token INT CHAR
%token LC RC
%token LB RB
%token LP RP
%token<string> NAME
%token SEMI COMMA COLON ASSIGNOP
%token WHILE THEN
%token FOR
%token IF ELSE
%token TO BY
%token READ
%token WRITE
%token NOT OR AND
%token LT LE EQ NE GE GT
%token ADD MINUS MULTI DIVID
%token <string>  NUMBER
%token <string> CHARCONST
%token ENDOFFILE
%start Procedure

%type<variable> Factor Term Stmt Expr Stmts Reference 
%type<variable> Bool OrTerm AndTerm RelExpr
%type<ifStmt> IfStmt WithElse IfStmtElse
%type<forStmt> ForStmt
%type<whileStmt> WhileStmt WhileHead
%type<dim> Bound
%type<array> Bounds
%type<index> Exprs

%%
Procedure : PROCEDURE NAME 
               LC Decls Stmts RC
          | PROCEDURE NAME 
               LC Decls Stmts RC RC
               {yyerror("Unexpected '}'"); yyclearin; yyerrok;}
          | PROCEDURE NAME 
               LC Decls Stmts
               {yyerror("Unexpected '}'"); yyerrok;}

;           

Decls : Decls Decl SEMI
      | Decl SEMI
;

Decl : Type SpecList
;

Type : INT {type = 0;}
     | CHAR {type = 1;}
;

SpecList : SpecList COMMA Spec
         | Spec
;

Spec : NAME
     | NAME LB Bounds RB
;

Bounds : Bounds COMMA Bound
       | Bound 
;

Bound : NUMBER COLON NUMBER
;

Stmts : Stmts Stmt
      | Stmt
;

IfStmt : IF LP Bool RP
;

ForStmt : FOR NAME ASSIGNOP Expr TO
            Expr BY Expr 
           
;

WhileHead : WHILE LP
;

WhileStmt : WhileHead Bool RP 

;

IfStmtElse : IfStmt THEN WithElse ELSE 
 ;

Stmt : Reference ASSIGNOP Expr SEMI 
     | Reference ADD ASSIGNOP Expr SEMI
         {yyerror("Do not use plus equal in demo"); yyerrok;}
     | Reference ASSIGNOP Expr SEMI SEMI
         {yyerror("Unexpected ';' "); yyclearin; yyerrok;}
     | WRITE ASSIGNOP Expr SEMI
         {yyerror("can't assign to write "); yyerrok;}
     | LC Stmts RC
     | LC RC
        {yyerror("Empty expression "); yyerrok;}
     | WhileStmt LC Stmts RC
     | ForStmt LC Stmts RC
     | IfStmt THEN Stmt
     | IfStmtElse WithElse 
     | READ Reference SEMI
     | WRITE Expr SEMI
     | NAME NAME SEMI
       {yyerror("Invalid expression"); yyerrok;}
     | error
;

WithElse : IfStmtElse WithElse
         | Reference ASSIGNOP Expr SEMI
         | Reference ADD ASSIGNOP Expr SEMI
            {yyerror("Do not use plus equal in demo"); yyerrok;}
         | Reference ASSIGNOP Expr SEMI SEMI
            {yyerror("Unexpected ';' "); yyerrok;}
         | WRITE ASSIGNOP Expr SEMI
            {yyerror("can't assign to write "); yyerrok;}
         | LC Stmts RC
         | LC RC
            {yyerror("Empty expression "); yyerrok;}
         | WhileStmt LC Stmts RC
         | ForStmt LC Stmts RC
         | READ Reference SEMI
         | WRITE Expr SEMI
         | error ';' {yyerror("Redundent ';'"); yyclearin; yyerrok;}
         | error
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

Expr : Expr ADD Term
     | Expr MINUS Term
     {
         Variable *result = malloc(sizeof(Variable));
         Variable *left = (Variable *)$1;
         Variable *right = (Variable *)$3;
         if(right->array != NULL && left->array != NULL) {
            int leftAddr = NextRegister();
            Emit(-1, load, left->registerNumber, leftAddr, -1);
            int rightAddr = NextRegister();
            Emit(-1, load, right->registerNumber, rightAddr, -1);
            result->registerNumber = NextRegister();
            Emit(-1, sub, leftAddr, rightAddr, result->registerNumber);
         } else if(right->array != NULL){
            int addr = NextRegister();
            Emit(-1, load, right->registerNumber, addr, -1);
            result->registerNumber = NextRegister();
            if(left->isI == 1) {
               int tempReg = NextRegister();
               Emit(-1, loadI, left->value, tempReg, -1);
               Emit(-1, sub, tempReg, addr, result->registerNumber);
            } else {
               Emit(-1, sub, left->registerNumber, addr, result->registerNumber);
            }
         } else if(left->array != NULL) {
            int addr = NextRegister();
            Emit(-1, load, left->registerNumber, addr, -1);
            result->registerNumber = NextRegister();
            if(right->isI == 1) {
               Emit(-1, subI, addr, right->value, result->registerNumber);
            } else {
               Emit(-1, sub, right->registerNumber, addr, result->registerNumber);
            }
         } else {
            if(left->isI == 1 && right->isI == 1) {
               int immd = left->value - right->value;
               result->value = immd;
               result->isI = 1;
               $$ = (struct Variable*)result;   
            }  else if(left->isI == 0 && right->isI == 1) {
               int addr0 = left->registerNumber;
               result->registerNumber = NextRegister();
               Emit(-1, subI, addr0, right->value, result->registerNumber);
            }  else if(left->isI == 1 && right->isI == 0) {
               int addr1 = right->registerNumber;
               result->registerNumber = NextRegister();
               int newRegister = NextRegister();
               Emit(-1, loadI, left->value, newRegister, -1);
               Emit(-1, sub, newRegister, addr1, result->registerNumber);
            }  else {
               int addr0 = left->registerNumber;
               int addr1 = right->registerNumber;
               result->registerNumber = NextRegister();
               Emit(-1, sub, addr0, addr1, result->registerNumber);
            }
         }

         $$ = (struct Variable*)result;
     }
     | Term
       {$$ = $1;}
;

Term : Term MULTI Factor
      {
         Variable *result = malloc(sizeof(Variable));
         Variable *left = (Variable *)$1;
         Variable *right = (Variable *)$3;
         if(right->array != NULL && left->array != NULL) {
            int leftAddr = NextRegister();
            Emit(-1, load, left->registerNumber, leftAddr, -1);
            int rightAddr = NextRegister();
            Emit(-1, load, right->registerNumber, rightAddr, -1);
            result->registerNumber = NextRegister();
            Emit(-1, mult, leftAddr, rightAddr, result->registerNumber);
         } else if(right->array != NULL){
            int addr = NextRegister();
            Emit(-1, load, right->registerNumber, addr, -1);
            result->registerNumber = NextRegister();
            if(left->isI == 1) {
               Emit(-1, multI, addr, left->value, result->registerNumber);
            } else {
               Emit(-1, mult, left->registerNumber, addr, result->registerNumber);
            }
         } else if(left->array != NULL) {
            int addr = NextRegister();
            Emit(-1, load, left->registerNumber, addr, -1);
            result->registerNumber = NextRegister();
            if(right->isI == 1) {
               Emit(-1, multI, addr, right->value, result->registerNumber);
            } else {
               Emit(-1, mult, right->registerNumber, addr, result->registerNumber);
            }
         } else {
            if(left->isI == 1 && right->isI == 1) {
               int immd = left->value * right->value;
               result->value = immd;
               result->isI = 1;
               $$ = (struct Variable*)result;   
            } else if(left->isI == 1 && right->isI == 0) {
               int addr0 = right->registerNumber;
               result->registerNumber = NextRegister();
               Emit(-1, multI, addr0, left->value, result->registerNumber);
            } else if(left->isI == 0 && right->isI == 1) {
               int addr0 = left->registerNumber;
               result->registerNumber = NextRegister();
               Emit(-1, multI, addr0, right->value, result->registerNumber);
            } else {
               int addr0 = left->registerNumber;
               int addr1 = right->registerNumber;
               result->registerNumber = NextRegister();
               Emit(-1, mult, addr0, addr1, result->registerNumber);
            }
         }

         $$ = (struct Variable*)result;
      }
     | Term DIVID Factor
     {
         Variable *result = malloc(sizeof(Variable));
         Variable *left = (Variable *)$1;
         Variable *right = (Variable *)$3;
         if(right->array != NULL && left->array != NULL) {
            int leftAddr = NextRegister();
            Emit(-1, load, left->registerNumber, leftAddr, -1);
            int rightAddr = NextRegister();
            Emit(-1, load, right->registerNumber, rightAddr, -1);
            result->registerNumber = NextRegister();
            Emit(-1, _div, leftAddr, rightAddr, result->registerNumber);
         } else if(right->array != NULL){
            int addr = NextRegister();
            Emit(-1, load, right->registerNumber, addr, -1);
            result->registerNumber = NextRegister();
            if(left->isI == 1) {
               int tempReg = NextRegister();
               Emit(-1, loadI, left->value, tempReg, -1);
               Emit(-1, _div, tempReg, addr, result->registerNumber);
            } else {
               Emit(-1, _div, left->registerNumber, addr, result->registerNumber);
            }
         } else if(left->array != NULL) {
            int addr = NextRegister();
            Emit(-1, load, left->registerNumber, addr, -1);
            result->registerNumber = NextRegister();
            if(right->isI == 1) {
               Emit(-1, divI, addr, right->value, result->registerNumber);
            } else {
               Emit(-1, _div, right->registerNumber, addr, result->registerNumber);
            }
         } else {
            if(left->isI == 1 && right->isI == 1) {
               int immd = left->value / right->value;
               result->value = immd;
               result->isI = 1;
               $$ = (struct Variable*)result;   
            }  else if(left->isI == 0 && right->isI == 1) {
               int addr0 = left->registerNumber;
               result->registerNumber = NextRegister();
               Emit(-1, divI, addr0, right->value, result->registerNumber);
            }  else if(left->isI == 1 && right->isI == 0) {
               int addr1 = right->registerNumber;
               result->registerNumber = NextRegister();
               int newRegister = NextRegister();
               Emit(-1, loadI, left->value, newRegister, -1);
               Emit(-1, _div, newRegister, addr1, result->registerNumber);
            }  else {
               int addr0 = left->registerNumber;
               int addr1 = right->registerNumber;
               result->registerNumber = NextRegister();
               Emit(-1, _div, addr0, addr1, result->registerNumber);
            }
         }

         $$ = (struct Variable*)result;
     } 
     | Factor
       {$$ = $1;}
;

Factor : LP Expr RP
       | Reference 
         {  
            $$ = $1;
         }
       | NUMBER 
         {
            Variable *v = malloc(sizeof(Variable));
            v->value = atoi($1);
            v->isI = 1;
            v->type = 0;
            $$ = (struct Variable*)v;
         }
       | CHARCONST
         {
            Variable *v = malloc(sizeof(Variable));
            v->value = (int)$1[1];
            v->isI = 1;
            v->type = 1;
            $$ = (struct Variable*)v;
         }
;

Reference : NAME
            {
               struct Variable *vari = (struct Variable *)lookup($1);
               if(vari == NULL) {
                  yyerror("need declare first\n");
               } else {
                  $$ = vari;
               }
            }
          | NAME LB Exprs RB
            {
               Variable *array = lookup($1);
               if(array == NULL) {
                  yyerror("need declare first\n");
               }
               if(array->array == NULL) {
                  yyerror("not refered an array");
               }
               Indices *index = (Indices *)$3;
               int bytes = array->array->type == 0? 4 : 1;
               
               int indexAddr = NextRegister(); // base
               Emit(-1, loadI, array->array->base, indexAddr, -1);

               int offset = NextRegister();
               Emit(-1, loadI, 0, offset, -1);
               int by = 1;
               int dims = array->array->dim;
               int bounds[4];
               for(int dim = 0; dim < dims; dim++) {
                  bounds[dim] = array->array->dims[dim][1] - array->array->dims[dim][0];
                  by *= bounds[dim];
               }
               for(int dim = 0; dim < dims - 1; dim++) {
                  int tempReg = NextRegister();
                  Emit(-1, multI, index->index[dim], by, tempReg);
                  Emit(-1, add, offset, tempReg, offset);
                  by /= bounds[dim];
               }
               
               Emit(-1, add, offset, index->index[dims - 1], offset);
               
               // times sizeof(int/char)
               Emit(-1, multI, offset, bytes, offset);
               // base + offset
               Emit(-1, add, indexAddr, offset, indexAddr);
               
               array->registerNumber = indexAddr;
               $$ = (struct Variable *)array;
            }
;

Exprs : Exprs COMMA Expr
      {
         Indices *index = (Indices *)$1;
         if(index == NULL) {
            index = malloc(sizeof(Indices));
            index->dim = 0;
         }

         Variable *temp = (Variable *)$3;
         index->index[index->dim] = temp->registerNumber;
         index->dim++;
         $$ = (struct Indices *)index;
      }
      | Expr
      {  
         Variable *vari = (Variable *)$1;
         if(vari->isI) {
            vari->registerNumber = NextRegister();
            Emit(-1, loadI, vari->value, vari->registerNumber, -1);
         }
         Indices *index = malloc(sizeof(Indices));
         index->index[0] = vari->registerNumber;
         index->dim = 1;
         $$ = (struct Indices *)index;
      }
;

%%

void yyerror(char *s) {
   syntax_error ++;
   fprintf(stderr, "Parser: '%s' around line %d.\n", s, yylineno);
}