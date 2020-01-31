/* Escreva uma analisador capaz de extrair os tokens de uma expressão
 * aritimética simples, incluindo parenteses.*/

%{

/* Código Global C que será copiado para o fonte */
/* #includes, variáveis globais e constantes vão aqui... */

#include "parser_py.tab.h"
int contador = 0;
%}

/* Definições */
NUMBER                [0-9]+

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
			// NÃO ESQUECER DE IMPLEMENTAR O 'NOT'

%%
{TIPO}                                 {strncpy(yylval.simbolo, yytext, 50); return TIPO;}

{OP_COMPAR}                            {yylval.strVal = strdup(yytext); return OP_COMPAR;}
{OP_LOGICA}                            {yylval.strVal = strdup(yytext); return OP_LOGICA;}
":"                                    {strncpy(yylval.simbolo, yytext, 50); return DP;}
";"                                    {strncpy(yylval.simbolo, yytext, 50); return PV;}

{CHAR_VALUE}                           {yylval.strVal = strdup(yytext); return VALOR_CARACTERE;}        // {printf("Caractere: %c", yytext[1]);}
{INT_VALUE}                            {yylval.intVal = atoi(yytext); return VALOR_INTEIRO;}        // {printf("Inteiro: %d", atoi(yytext));}
{FLOAT_VALUE}                          {yylval.floatVal = atof(yytext); return VALOR_FLOAT;}        // {printf("Float: %f", atof(yytext));}
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
"\t"                                   {return IDENT;}

%%
/* Fim das Regras */
/* Código C abaixo será incluído nos fontes. */

int yywrap() {}
