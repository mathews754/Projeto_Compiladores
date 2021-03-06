/* Escreva uma analisador capaz de extrair os tokens de uma expressão
 * aritimética simples, incluindo parenteses.*/

%{

/* Código Global C que será copiado para o fonte */
/* #includes, variáveis globais e constantes vão aqui... */

#include "parser_py.tab.h"
int contador = 0;
%}

/* Definições */
CHAR_VALUE            [\'][a-zA-Z][\']
INT_VALUE             [-+]?[0-9]+
FLOAT_VALUE           [-+]?[0-9]*\.?[0-9]+
STRING_VALUE          \"(\\.|[^"])*\"
LOGICAL_VALUE         True|False

ID                    [a-zA-Z_][a-zA-Z_0-9]*
VETOR                 [a-zA-Z_][a-zA-Z0-9_]*(\[[0-9]+\])+
TIPO                  bool|int|float|char|str
OP_COMPAR             <|>|==|!=|>=|<=
OP_LOGICA             or|and

%%
{TIPO}                                 {strncpy(yylval.simbolo, yytext, 50); return TIPO;}

if                                     {strncpy(yylval.simbolo, yytext, 50); return IF;}
else                                   {strncpy(yylval.simbolo, yytext, 50); return ELSE;}
while                                  {strncpy(yylval.simbolo, yytext, 50); return WHILE;}

{OP_COMPAR}                            {yylval.strVal = strdup(yytext); return OP_COMPAR;}
{OP_LOGICA}                            {yylval.strVal = strdup(yytext); return OP_LOGICA;}
":"                                    {strncpy(yylval.simbolo, yytext, 50); return DP;}
";"                                    {strncpy(yylval.simbolo, yytext, 50); return PV;}

{CHAR_VALUE}                           {yylval.strVal = strdup(yytext); return VALOR_CARACTERE;}
{INT_VALUE}                            {yylval.intVal = atoi(yytext); return VALOR_INTEIRO;}
{FLOAT_VALUE}                          {yylval.floatVal = atof(yytext); return VALOR_FLOAT;}
{STRING_VALUE}                         {yylval.strVal = strdup(yytext); return VALOR_STRING;} 
{LOGICAL_VALUE}                        {yylval.strVal = strdup(yytext); return VALOR_LOGICO;}

{ID}                                   {strncpy(yylval.simbolo, yytext, 50); return ID;}		// Ex: a, a01, _a02
{VETOR}                                {strncpy(yylval.simbolo, yytext, 50); return VETOR;}		// Ex: a[2], _b01[5]

"="                                    {strncpy(yylval.simbolo, yytext, 50); return EQU;}

"\+"                                   {return ADD;}		/* Aritmética básica */
"\-"                                   {return SUB;}
"\*"                                   {return MUL;}
"/"                                    {return DIV;}

"\("                                   {return APAR;}
"\)"                                   {return FPAR;}
"\n"                                   {contador++; return EOL;}
"\t"                                   {strncpy(yylval.simbolo, yytext, 50); return IDENT;}

%%

int yywrap() {}
