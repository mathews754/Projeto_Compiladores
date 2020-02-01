/*
Comandos para executar o parser
- bison -d parser_py.y
- flex lex_analyzer.l
- gcc -o interpretador.x parser_py.tab.c lex.yy.c -ll

OU

- yacc -d parser_py.y
- lex lex_analyzer.l
- cc lex.yy.c y.tab.c -o output
*/

%{

/* CÓDIGO EM C */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yywrap(void);
int yylex(void);


typedef struct No {
    char token[50];
    int num_filhos;
    struct No** filhos;
} No;

char ultimo_erro[1024];
typedef struct registro_da_tabela_de_simbolo {
    char token[50];
    char lexema[50];
	char tipo[15];
    int endereco;
} RegistroTS;

#define TAM_TABELA_DE_SIMBOLOS 1024
RegistroTS tabela_de_simbolos[TAM_TABELA_DE_SIMBOLOS];
int prox_posicao_livre = 0;
int prox_mem_livre = 0;
    

No* allocar_no();
void liberar_no(No* no);
void imprimir_arvore(No* raiz);
No* novo_no(char[50], No**, int);
void imprimir_tabela_de_simbolos(RegistroTS*);
int verifica_entrada_na_tabela_de_simbolos(char*);
void inserir_na_tabela_de_simbolos(RegistroTS);
void remover_da_tabela_de_simbolos(RegistroTS*);
RegistroTS* getVariavelDaTabela(char*);


/* UTIL */
int getTamanhoPorTipo(char*);
int getTamanhoVetor(char*, char*);
char* getVetorPorNome(char*);
int charToInt(char);
int strToInt(char*);
int pow(int, int);

char* intToStr(int, char*);
char* floatToStr(float, char*);


/* FUNÇÕES DE ERRO */
void yyerror(char*);
void zeroDivisionError(void);

%}

/* Declaração de Tokens no formato %token NOME_DO_TOKEN */
%union 
{
	int number;
	char simbolo[50];
	struct No* no;

	int intVal;
	float floatVal;
	char charVal;
	char* strVal;
}
%token ADD SUB MUL DIV				/* ARITMÉTICA */
%token OP_COMPAR OP_LOGICA			/* OPERAÇÕES LÓGICAS*/
%token EQU

%token EOL
%token PV
%token DP
%token IDENT

%token TIPO
%token ID
%token VETOR

%token IF ELSE
%token WHILE
%token APAR FPAR

%token<intVal>   VALOR_INTEIRO
%token<floatVal> VALOR_FLOAT
%token<strVal>   VALOR_CARACTERE
%token<strVal>   VALOR_STRING
%token<strVal>   VALOR_LOGICO

%type<no> TERMO
%type<no> FATOR
%type<no> CONST

%type<no> TERMO_LOG
%type<no> FATOR_LOG
%type<no> CONST_LOG

%type<no> EXPRESSAO_ARIT
%type<no> EXPRESSAO_LOG
%type<number> DECLARACAO
%type<number> ATTR
%type<number> ESTRUTURA_SELECAO

%type<simbolo> ADD SUB
%type<simbolo> MUL DIV
%type<strVal> OP_COMPAR
%type<strVal> OP_LOGICA

%type<simbolo> TIPO

%type<simbolo> IF ELSE
%type<simbolo> WHILE
%type<simbolo> ID
%type<simbolo> VETOR
%type<simbolo> PV
%type<simbolo> DP
%type<simbolo> IDENT
%type<simbolo> EQU

%%
/* Regras de Sintaxe */

PROG: PROG EOL {imprimir_tabela_de_simbolos(tabela_de_simbolos);}
	| EXPRESSAO_ARIT EOL | EXPRESSAO_LOG EOL
	| PROG EXPRESSAO_ARIT EOL
	| PROG EXPRESSAO_LOG EOL

	| ATTR EOL | ATTR PV | PROG ATTR EOL
	| PROG ATTR PV EOL

	| DECLARACAO EOL | DECLARACAO PV | PROG DECLARACAO PV
	| PROG DECLARACAO EOL | PROG DECLARACAO PV EOL
	| ESTRUTURA_SELECAO | PROG ESTRUTURA_SELECAO
	| ESTRUTURA_REPETICAO | PROG ESTRUTURA_REPETICAO;


DECLARACAO: TIPO ID					{
										int var_existe = verifica_entrada_na_tabela_de_simbolos($2);
										int size;
										if (!var_existe) { 
											RegistroTS registro;
											strncpy(registro.token, "ID", 50);
											strncpy(registro.lexema, $2, 50);
											strncpy(registro.tipo, $1, 15);
											registro.endereco = prox_mem_livre;
											size = getTamanhoPorTipo($1);
											prox_mem_livre += size;
											inserir_na_tabela_de_simbolos(registro);
											$$ = 1;
										}
										else {
											printf("Erro! Múltiplas declarações de variável\n");
											exit(1);
										}
									}

	| TIPO VETOR					{
										int var_existe = verifica_entrada_na_tabela_de_simbolos($2);
										int size;
										if (!var_existe) { 
											RegistroTS registro;
											strncpy(registro.token, "VETOR", 50);
											size = getTamanhoVetor($1, $2);
											strncpy(registro.lexema, getVetorPorNome($2), 50); // NOTA: A PARTE DE INDICE SE PERDE A PARTIR DAQUI
											if (strcmp($1, "char") == 0 && size > 1) strncpy(registro.tipo, "str", 15);
											else strncpy(registro.tipo, $1, 15);
											registro.endereco = prox_mem_livre;
											prox_mem_livre += size;
											inserir_na_tabela_de_simbolos(registro);
											$$ = 1;
										}
										else {
											printf("Erro! Múltiplas declarações de variável\n");
											exit(1);
										}
									};

ATTR: ID EQU ID						{
										RegistroTS* var1 = getVariavelDaTabela($1);
										RegistroTS* var2 = getVariavelDaTabela($3);
										if (var2 == NULL) {printf("Variável %s não declarada;\n", $1); exit(1);}
										if (var1 == NULL) {
											RegistroTS registro;
											strncpy(registro.token, "ID", 50);
											strncpy(registro.lexema, $1, 50);
											strncpy(registro.tipo, var2->tipo, 15);
											registro.endereco = var2->endereco;
											inserir_na_tabela_de_simbolos(registro);
											$$ = 1;
										}
										else {
											strcpy(var1->tipo, var2->tipo);
											var1->endereco = var2->endereco;
											$$ = 1;
										}
									}
	| ID EQU VALOR_LOGICO			{
										RegistroTS* var1 = getVariavelDaTabela($1);
										if (var1 == NULL) {
											RegistroTS registro;
											strncpy(registro.token, "ID", 50);
											strncpy(registro.lexema, $1, 50);
											strncpy(registro.tipo, "bool", 15);
											registro.endereco = prox_mem_livre;
											prox_mem_livre += 1;
											inserir_na_tabela_de_simbolos(registro);
										}
										else {
											strncpy(var1->token, "ID", 50);
											strncpy(var1->lexema, $1, 50);
											strncpy(var1->tipo, "bool", 15);
											var1->endereco = prox_mem_livre;
											prox_mem_livre += 1;
										}
										$$ = 1;
									}
	| ID EQU VALOR_INTEIRO			{
										RegistroTS* var1 = getVariavelDaTabela($1);
										if (var1 == NULL) {
											RegistroTS registro;
											strncpy(registro.token, "ID", 50);
											strncpy(registro.lexema, $1, 50);
											strncpy(registro.tipo, "int", 15);
											registro.endereco = prox_mem_livre;
											prox_mem_livre += 4;
											inserir_na_tabela_de_simbolos(registro);
										}
										else {
											strncpy(var1->token, "ID", 50);
											strncpy(var1->lexema, $1, 50);
											strncpy(var1->tipo, "int", 15);
											var1->endereco = prox_mem_livre;
											prox_mem_livre += 4;
										}
										$$ = 1;
									}
	| ID EQU VALOR_FLOAT			{
										RegistroTS* var1 = getVariavelDaTabela($1);
										if (var1 == NULL) {
											RegistroTS registro;
											strncpy(registro.token, "ID", 50);
											strncpy(registro.lexema, $1, 50);
											strncpy(registro.tipo, "float", 15);
											registro.endereco = prox_mem_livre;
											prox_mem_livre += 8;
											inserir_na_tabela_de_simbolos(registro);
										}
										else {
											strncpy(var1->token, "ID", 50);
											strncpy(var1->lexema, $1, 50);
											strncpy(var1->tipo, "float", 15);
											var1->endereco = prox_mem_livre;
											prox_mem_livre += 8;
										}
										$$ = 1;
									}
	| ID EQU VALOR_CARACTERE		{
										RegistroTS* var1 = getVariavelDaTabela($1);
										if (var1 == NULL) {
											RegistroTS registro;
											strncpy(registro.token, "ID", 50);
											strncpy(registro.lexema, $1, 50);
											strncpy(registro.tipo, "str", 15);
											registro.endereco = prox_mem_livre;
											prox_mem_livre += 1;
											inserir_na_tabela_de_simbolos(registro);
										}
										else {
											strncpy(var1->token, "ID", 50);
											strncpy(var1->lexema, $1, 50);
											strncpy(var1->tipo, "str", 15);
											var1->endereco = prox_mem_livre;
											prox_mem_livre += 1;
										}	
										$$ = 1;
									}
	| ID EQU VALOR_STRING			{
										RegistroTS* var1 = getVariavelDaTabela($1);
										if (var1 == NULL) {
											RegistroTS registro;
											strncpy(registro.token, "VETOR", 50);
											strncpy(registro.lexema, $1, 50);
											strncpy(registro.tipo, "str", 15);
											registro.endereco = prox_mem_livre;
											prox_mem_livre += strlen($3)-2;
											inserir_na_tabela_de_simbolos(registro);
										}
										else {
											strncpy(var1->token, "VETOR", 50);
											strncpy(var1->lexema, $1, 50);
											strncpy(var1->tipo, "str", 15);
											var1->endereco = prox_mem_livre;
											prox_mem_livre += strlen($3)-2;
										}
										$$ = 1;
									};

EXPRESSAO_ARIT: TERMO				{
										imprimir_arvore($1);printf("\n\n");
									}
	| EXPRESSAO_ARIT TERMO			{ 
										imprimir_arvore($2);printf("\n\n");
									};

TERMO: FATOR
	| TERMO ADD FATOR				{ 
										No** filhos = (No**) malloc(sizeof(No*)*3);
										filhos[0] = $1;
										filhos[1] = novo_no("+", NULL, 0);
										filhos[2] = $3;
										No* raiz_exp = novo_no("termo", filhos, 3); 
										$$ = raiz_exp;
									}
	| TERMO SUB FATOR				{ 
										No** filhos = (No**) malloc(sizeof(No*)*3);
										filhos[0] = $1;
										filhos[1] = novo_no("-", NULL, 0);
										filhos[2] = $3;
										No* raiz_exp = novo_no("termo", filhos, 3); 
										$$ = raiz_exp;
									};

FATOR: CONST
	| FATOR MUL CONST				{ 
										No** filhos = (No**) malloc(sizeof(No*)*3);
										filhos[0] = $1;
										filhos[1] = novo_no("*", NULL, 0);
										filhos[2] = $3;
										No* raiz_termo = novo_no("fator", filhos, 3); 
										$$ = raiz_termo;
									}
	| FATOR DIV CONST				{  
										No** filhos = (No**) malloc(sizeof(No*)*3);
										char denom[15];
										strncpy(denom, $3, 15);
										if (strcmp(denom, "0") == 0) {zeroDivisionError();}
										filhos[0] = $1;
										filhos[1] = novo_no("/", NULL, 0);
										filhos[2] = $3;
										No* raiz_termo = novo_no("fator", filhos, 3); 
										$$ = raiz_termo;
									};

CONST: VALOR_INTEIRO				{ 
										char buffer[50];
										intToStr($1, buffer);
										$$ = novo_no(buffer, NULL, 0); 
									}
	| VALOR_FLOAT					{ 
										char buffer[50];
										floatToStr($1, buffer);
										$$ = novo_no(buffer, NULL, 0); 
									}
	| ID							{ 
										int var_existe = verifica_entrada_na_tabela_de_simbolos($1);
										if(var_existe) {
											RegistroTS* var = getVariavelDaTabela($1);
											if (strcmp(var->tipo, "str") == 0 || strcmp(var->tipo, "char") == 0){
												printf("ERROR: operando type(%s) não suportado para esta operação;\n", var->tipo);
												exit(1);
											}
											$$ = novo_no($1, NULL, 0);  
										}
										else {
											printf("Variável %s não declarada;\n", $1);
											exit(1);
										}
									};

EXPRESSAO_LOG: TERMO_LOG			{
										imprimir_arvore($1);printf("\n\n");
									}
	| EXPRESSAO_LOG TERMO_LOG		{
										imprimir_arvore($1);printf("\n\n");
									};

TERMO_LOG: FATOR_LOG
	| TERMO_LOG OP_LOGICA FATOR_LOG	{
										No** filhos = (No**) malloc(sizeof(No*)*3);
										filhos[0] = $1;
										filhos[1] = novo_no($2, NULL, 0);
										filhos[2] = $3;
										No* raiz_exp = novo_no("termo_log", filhos, 3); 
										$$ = raiz_exp;
									};

FATOR_LOG: CONST_LOG
	| FATOR_LOG OP_COMPAR CONST_LOG	{ 
										No** filhos = (No**) malloc(sizeof(No*)*3);
										filhos[0] = $1;
										filhos[1] = novo_no($2, NULL, 0);
										filhos[2] = $3;
										No* raiz_termo = novo_no("fator_log", filhos, 3); 
										$$ = raiz_termo;
									};

CONST_LOG: VALOR_LOGICO				{ $$ = novo_no($1, NULL, 0); }
	| VALOR_CARACTERE				{ $$ = novo_no($1, NULL, 0); }
	| VALOR_INTEIRO					{ char buffer[50]; intToStr($1, buffer); $$ = novo_no(buffer, NULL, 0); }
	| VALOR_FLOAT					{ char buffer[50]; floatToStr($1, buffer); $$ = novo_no(buffer, NULL, 0); }
	| VALOR_STRING					{ $$ = novo_no($1, NULL, 0); }
	| ID							{ 
										int var_existe = verifica_entrada_na_tabela_de_simbolos($1);
										if(var_existe) {
											$$ = novo_no($1, NULL, 0);  
										}
										else {
											printf("Variável %s não declarada;\n", $1);
											exit(1);
										}
									};

ESTRUTURA_SELECAO: IF EXPRESSAO_LOG DP EOL IDENT_CORPO							{printf("---------FIM DO IF----------\n\n");}
	| IF APAR EXPRESSAO_LOG FPAR DP EOL IDENT_CORPO								{printf("---------FIM DO IF----------\n\n");}
	| IF EXPRESSAO_LOG DP EOL IDENT_CORPO ELSE DP EOL IDENT_CORPO				{printf("---------FIM DO IF----------\n\n");}
	| IF APAR EXPRESSAO_LOG FPAR DP EOL IDENT_CORPO ELSE DP EOL IDENT_CORPO		{printf("---------FIM DO IF----------\n\n");};


ESTRUTURA_REPETICAO: WHILE EXPRESSAO_LOG DP EOL IDENT_CORPO		{printf("---------FIM DO WHILE----------\n\n");}
	| WHILE APAR EXPRESSAO_LOG FPAR DP EOL IDENT_CORPO			{printf("---------FIM DO WHILE----------\n\n");};

IDENT_CORPO: IDENT COMANDO
	| IDENT_CORPO IDENT COMANDO;

COMANDO: ATTR EOL | ATTR PV EOL 
	| DECLARACAO EOL | DECLARACAO PV EOL;

%%

/* ********************************************************************************************* */
/* ******************************** *//* CÓDIGO EM C *//* ************************************** */
/* ********************************************************************************************* */

No* allocar_no(int num_filhos) {
    No* no = (No*) malloc(sizeof(No));
    no->num_filhos = num_filhos;
    if (no->num_filhos == 0) {
        no->filhos = NULL;
    }

    return no;
}

void liberar_no(No* no) {
    free(no);
}

No* novo_no(char token[50], No** filhos, int num_filhos) {
   No* no = allocar_no(num_filhos);
   no->filhos = filhos;
   snprintf(no->token, 50, "%s", token);

   return no;
}

void imprimir_arvore(No* raiz) {
    if(raiz->filhos != NULL) {
        printf("[%s", raiz->token);
        for(int i = 0; i < raiz->num_filhos; i++) {
            imprimir_arvore(raiz->filhos[i]);
        }
        printf("]");
    }
    else {
        printf("[%s]", raiz->token);
    }
}

int verifica_entrada_na_tabela_de_simbolos(char *variavel) {
    for(int i = 0; i < prox_posicao_livre; i++) {
            if( strncmp(tabela_de_simbolos[i].lexema, variavel, 50) == 0) {
            return 1;
        }
    }
    return 0;
}

RegistroTS* getVariavelDaTabela(char* variavel){
	int check = verifica_entrada_na_tabela_de_simbolos(variavel);
	for(int i = 0; i < prox_posicao_livre; i++) {
            if( strncmp(tabela_de_simbolos[i].lexema, variavel, 50) == 0) {
            return &tabela_de_simbolos[i];
        }
    }
    return NULL;
}

void inserir_na_tabela_de_simbolos(RegistroTS registro) {
    if (prox_posicao_livre == TAM_TABELA_DE_SIMBOLOS) {
        printf("Erro! Tabela de Símbolos Cheia!\n");
        return;
    }
    tabela_de_simbolos[prox_posicao_livre] = registro;
    prox_posicao_livre++;
}

void imprimir_tabela_de_simbolos(RegistroTS *tabela_de_simbolos) {
    printf("----------- Tabela de Símbolos ---------------\n");
    for(int i = 0; i < prox_posicao_livre; i++) {
        printf("{%s} -> {%s} -> {%s} -> {%x}\n", tabela_de_simbolos[i].token, \
                                               tabela_de_simbolos[i].lexema, \
                                               tabela_de_simbolos[i].tipo, \
                                               tabela_de_simbolos[i].endereco);
        printf("---------\n");
    }
    printf("----------------------------------------------\n");
}

char* getVetorPorNome(char* str){
	int i = 0;
	while (str[i] != '[') i++;
	str[i] = '\0';
	return str;
}

int getTamanhoPorTipo(char* tipo){
	if (strcmp(tipo, "bool") == 0) return 1;
	else if (strcmp(tipo, "char") == 0) return 1;
	else if (strcmp(tipo, "int") == 0) return 4;
	else if (strcmp(tipo, "float") == 0) return 8;
	return 0;
}

int charToInt(char a){
	int i = a - 48;
	if (i < 10) return i;
	else return 0;
}

int pow(int a, int b){
	int i;
	int n = a;
	if (b == 0) return 1;
	else if (b == 1) return a;
	else for (i=0;i<b-1;i++) n*=a;
	return n;
}

int strToInt(char* str){
	int i;
	int n = 0;
	int idx = 0;
	while(str[idx] >= '0' && str[idx] <= '9') idx++;
	for (i=0;i<idx;i++) n += (str[i] - 48) * pow(10,idx-i-1);
	return n;
}

int getTamanhoVetor(char* tipo, char* vetor){
	int somaTam = 0;
	char* idx;
	idx = strchr(vetor, '[') + 1;
	somaTam += getTamanhoPorTipo(tipo) * strToInt(idx);
	return somaTam;
}

char* intToStr(int i, char* str){
	snprintf(str, 50, "%d", i);
	return str;
}

char* floatToStr(float f, char* str){
	snprintf(str, 50, "%f", f);
	return str;
}

int main(int argc, char** argv) {
    yyparse();
}


/* ERROR CODES */

void yyerror(char *s) {
    fprintf(stderr, "error: %s\n", s);
}

void zeroDivisionError() {
    printf("ERROR: divisão por zero\n");
	exit(0);
}



