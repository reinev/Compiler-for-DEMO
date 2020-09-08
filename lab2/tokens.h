/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_DEMOGRAM_TAB_H_INCLUDED
# define YY_YY_DEMOGRAM_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    BY = 258,
    CHAR = 259,
    CHARCONST = 260,
    COLON = 261,
    COMMA = 262,
    DIVIDE = 263,
    ELSE = 264,
    ENDOFFILE = 265,
    EQUALS = 266,
    FOR = 267,
    IF = 268,
    INT = 269,
    LBRACKET = 270,
    LPAREN = 271,
    LSQUARE = 272,
    MINUS = 273,
    NAME = 274,
    ELE = 275,
    NOT = 276,
    NUMBER = 277,
    PLUS = 278,
    PROCEDURE = 279,
    RBRACKET = 280,
    READ = 281,
    RPAREN = 282,
    RSQUARE = 283,
    SEMICOLON = 284,
    THEN = 285,
    TIMES = 286,
    TO = 287,
    WHILE = 288,
    WRITE = 289,
    UNKNOWN = 290,
    LT = 291,
    LE = 292,
    EQ = 293,
    NE = 294,
    GE = 295,
    GT = 296,
    AND = 297,
    OR = 298
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 23 "DEMOgram.y" /* yacc.c:1909  */

  unsigned long int val;
  char             *cptr;
  struct NODE     *nodeptr;
  struct BP        *bp;
  struct LOOP      *loop;
  struct LOOPEXPR  *loopex;
  struct ITEHEAD   *ite;

#line 108 "DEMOgram.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_DEMOGRAM_TAB_H_INCLUDED  */
