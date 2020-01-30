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
ID                    [a-zA-Z_][a-zA-Z_0-9]*
VETOR                 [a-zA-Z][_a-zA-Z0-9]*(\[[0-9]+\])+
TIPO                  int|float|double|char|string

/* Início das Regras */
%%
{NUMBER}                               {strncpy(yylval.simbolo, yytext, 50); return NUM;}
{TIPO}                                 {strncpy(yylval.simbolo, yytext, 50); return TIPO;}
{ID}                                   {strncpy(yylval.simbolo, yytext, 50); return ID;}
";"                                    {strncpy(yylval.simbolo, yytext, 50); return PV;}

[\'][a-zA-Z][\']                       {printf("Caractere: %c", yytext[1]);}
[-+]?[0-9]+                            {printf("Inteiro: %d", atoi(yytext));}
[-+]?[0-9]*\.?[0-9]+                   {printf("Float: %f", atof(yytext));}
[a-zA-Z][_a-zA-Z0-9]*(\[[0-9]+\])+     {strncpy(yylval.simbolo, yytext, 50); return VETOR;} /*{printf("Vetor: %s", strdup(yytext));}*/


"="                                    {return EQU;}
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
