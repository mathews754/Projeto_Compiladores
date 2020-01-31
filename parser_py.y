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
//#include <math.h>

int yywrap(void);
int yylex(void);


typedef struct No {
    char token[50];
    int num_filhos;
    struct No** filhos;
} No;

char ultimo_erro[1024];

enum tipos{INT, FLOAT, CHAR, STRING};

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
%token NUM
%token ADD SUB MUL DIV /* ARITMÉTICA */
%token LOGICAL_OP      /* OPERAÇÕES LÓGICAS*/
%token EQU

%token EOL
%token PV
%token DP
%token IDENT

%token TIPO
%token ID
%token VETOR

%token APAR FPAR

%token<intVal>   VALOR_INTEIRO
%token<floatVal> VALOR_FLOAT
%token<charVal>  VALOR_CARACTERE
%token<strVal>   VALOR_STRING
%token<strVal>   VALOR_LOGICO

/*%type<no> termo
%type<no> fator
%type<no> exp
%type<no> const*/

%type<no> TERMO
%type<no> FATOR
%type<no> CONST

%type<no> TERMO_LOG
%type<no> FATOR_LOG
%type<no> CONST_LOG

%type<no> EXPRESSAO_ARIT
%type<number> DECLARACAO

%type<number> attr
%type<number> FLO

%type<simbolo> TIPO  
%type<simbolo> NUM
%type<simbolo> MUL
%type<simbolo> DIV
%type<simbolo> SUB
%type<simbolo> ADD
%type<simbolo> ID
%type<simbolo> VETOR
%type<simbolo> PV
%type<simbolo> DP
%type<simbolo> IDENT
%type<simbolo> EQU

%%
/* Regras de Sintaxe */

PROG: EXPRESSAO_ARIT EOL 
	| PROG EXPRESSAO_ARIT EOL
	| DECLARACAO EOL | DECLARACAO PV | PROG DECLARACAO PV
	| PROG DECLARACAO EOL
	| PROG DECLARACAO PV EOL;

/*EXPRESSAO_ARIT: VALOR_INTEIRO {printf("INTEIRO = %d\n", $1);}
	|  VALOR_CARACTERE {printf("CHAR = %c\n", $1);}
	|  VALOR_STRING {printf("STRING = %s\n", $1);};*/

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
										imprimir_tabela_de_simbolos(tabela_de_simbolos);
									}

	| TIPO VETOR					{
										int var_existe = verifica_entrada_na_tabela_de_simbolos($2);
										int size;
										if (!var_existe) { 
											RegistroTS registro;
											strncpy(registro.token, "ID", 50);
											size = getTamanhoVetor($1, $2);
											strncpy(registro.lexema, getVetorPorNome($2), 50); // NOTA: A PARTE DE INDICE SE PERDE A PARTIR DAQUI
											strncpy(registro.tipo, $1, 15);
											registro.endereco = prox_mem_livre;
											prox_mem_livre += size;
											inserir_na_tabela_de_simbolos(registro);
											$$ = 1;
										}
										else {
											printf("Erro! Múltiplas declarações de variável\n");
											exit(1);
										}
										imprimir_tabela_de_simbolos(tabela_de_simbolos);
									};

EXPRESSAO_ARIT: TERMO				{
										imprimir_arvore($1);printf("\n\n");
										imprimir_tabela_de_simbolos(tabela_de_simbolos);
									}
	| EXPRESSAO_ARIT TERMO			{ 
										imprimir_arvore($2);printf("\n\n");
										imprimir_tabela_de_simbolos(tabela_de_simbolos);
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
										   $$ = novo_no($1, NULL, 0);  
										}
										else {
										   printf("Variável %s não declarada;\n", $1);
										   exit(1);
										}
									};




/*
attr: ID EQU ID EOL       {
                          int var1_existe = verifica_entrada_na_tabela_de_simbolos($1);
                          int var2_existe = verifica_entrada_na_tabela_de_simbolos($3);
                          if (!var2_existe){
                          printf("VAR_2 NÃO EXISTE\n"); exit(-1);
                          }
                          };
*/
/*
attr: ID EQU ID           {
                          char a[15], b[15], c[15];
                          strncpy(a, $1, 15);
                          strncpy(b, $2, 15);
                          strncpy(c, $3, 15);
                          printf("%s %s %s", $1, $2, $3)
                          };
    | ID EQU exp          {
                          char a[15], b[15];
                          strncpy(a, $1, 15);
                          strncpy(b, $2, 15);
                          printf("%s %s", $1, $2)
                          }
*/

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
	if (strcmp(tipo, "char") == 0) {return 1;}
	else if (strcmp(tipo, "int") == 0) {return 4;}
	else if (strcmp(tipo, "float") == 0) {return 8;} // Falta Strings
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

int strToInt(char* str){							// FUNÇÃO PODE DAR PROBLEMA EM SITUAÇÕES DIFERENTES
	int i;
	int n = 0;
	int idx = 0;
	while(str[idx] >= '0' && str[idx] <= '9') idx++;
	for (i=0;i<idx;i++) n += (str[i] - 48) * pow(10,idx-i-1);
	return n;
}

int getTamanhoVetor(char* tipo, char* vetor){		// No estado atual, essa função só calcula o tamanho para um vetor de tamanho < 10;
	int somaTam = 0;
	char* idx;
	idx = strchr(vetor, '[') + 1;
	somaTam += getTamanhoPorTipo(tipo) * strToInt(idx);
	return somaTam;
}

/*id = strchr(idx, ']') + 1;
	id[0] = '\0';
	id = id + 1;
	printf("idx = %s\n", idx);*/			/*Lembrando que o indice mais a esquerda é multiplicado pelo tamanho do tipo*/
	/*printf("idx[1] = %c\n", idx[1]);
	printf("id = %s\n", id);*/
	//while(idx[i]!=']') i++;
	/*somaTam += atoi(idx[1]) * getTamanhoPorTipo(tipo);
	idx[0] = ']';*/
	/*while(strchr(idx, '[') != NULL) {
		idx = strchr(idx, '[');
		somaTam += atoi(idx[1]) * 8;
	}
*/
/*
[2]
[2][3]
[2][3][4]
*/

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



