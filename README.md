# Introdução

Um compilador é o programa que é capaz de realizar uma leitura de um determinado código, o código-fonte, e traduzi-lo para um programa semelhante em outro código, o código-alvo. Uma das principais funções do compilador é a indicação de erros encontrada durante o processo de tradução. Se o código-alvo for de linguagem de máquina, pode ser selecionado pelo usuário para inserção de dados e produções de saídas.
Outra forma de processamento de linguagens é por um interpretador. Diferentemente do compilador, o interpretador já executa as operações inseridas pela usuário de acordo com o código-fonte.

As etapas de um compilador podem ser divididas em duas fases: análise e síntese. A primeira fase é composta pelas análises léxica, sintática e semântica. Já a segunda fase é composta pela geração de código intermediário, otimização e geração de código. Além dessas, destacam-se as fases do gerenciamento de tabelas e do tratamento de erros. Seguem abaixo características destas fases:

* Análise léxica: os tipos de palavras são divididos, como identificadores, palavras reservadas, números reais, entre outros. Este tipo de análise define se um identificador é ou não uma palavra reservada. Os itens léxicos a serem reconhecidos pelo analisador são definidos de acordo com a gramática do código fonte; caso um item léxico não seja definido pela gramática, um erro léxico é encontrado;

* Análise sintática: procura verificar se as frases estão escritas de maneira correta, analisando a ordem das palavras (tokens). O analisador sintático recebe e analise a seqüência de tokens extraídas do código-fonte de acordo com a gramática na qual o código foi baseada. O Parser é o responsável por agrupar os símbolos em unidades sintáticas, este gera uma exibição da árvore do analisador do código, que expressa a estrutura hierárquica dos inputs e mapeia a lista de símbolos. Os nós das árvores representam os símbolos, terminais e não-terminais, e as conexões representam os passos de derivação.

* Análise semântica garante as regras semânticas;

* A geração de código intermediário cria uma abstração do código;

* Ao fim temos a otimização do código e por fim, a geração do código objeto que tem como objetivo gerar o código de baixo nível baseado na arquitetura da máquina que executará o código-alvo.

# Ferramentas
## Bison
É um parser que busca converter uma gramática livre de contexto em um autômato determinístico de linguagem regular. Apenas as linguagens regulares Look-Ahead podem ser manipuladas pelo Bison, isso significa que é possível verificar como acontece o parse em qualquer parte da string do input com apenas um token do look-ahead.

## Flex
Fast Lexical Analyzer Generator, é uma ferramenta para criação de scanners, os quais realizam a análise léxica de um código; ao invés de criar um scanner do zero, são necessárias a identificação do vocabulário da linguagem na qual o código será analisado e os padrões de especificação usando as linguagens regulares.

Primeiramente o Flex realiza a leitura das especificações, gera um output C com o nome lex.yy.c; posteriormente, este arquivo é compilado e relacionado com a biblioteca “-lfll” para produzir o executável a.out. Por último, o a.out analiza o input e o transforma em uma sequência de tokens.

# Implementação
O _parser_ foi feito se baseando na sintaxe da linguagem python, com algumas exceções para propósitos de avaliação. As principais características da linguagem reconhecida pelo _parser_ são:
* Uso opcional do ';'.
* Identação forte, usada para marcar blocos de código.
* Declaração de variáveis e vetores presentes, porém, assim como em python, a criação de novas variáveis é feita automaticamente utilizando a atribuição.
* Todas as palavras reservadas, com exceção de 'char' foram retiradas da sintaxe de python.


## Identificadores e a Tabela de Símbolos
Os tipos de variáveis suportadas são: _int_, _float_, _bool_, _str_ e _char_. Esta última, na sintaxe de python, é tratada da mesma forma que o tipo 'str', por ambos serem apenas texto. No _parser_, o tipo 'char' só foi implementado por questão de declaração de variáveis.

### Declarando variáveis
Uma vez que uma variável é declarada, ou quando se atribui um valor a ela, a Tabela de Símbolos é atualizada, inserindo a nova variável ou atualizando seus atributos. A Tabela de Símbolos possui todos os lexemas das variáveis, seus respectivos tokens, tipos e a memória inicial onde estão localizadas. 

Vetores também podem ser declarados utilizando a sintaxe mesma sintaxe de C, porém o _parser_, em sua versão atual, não suporta matrizes.

### Atribuição
Toda vez que um valor novo é atribuido a uma variável já criada, seu tipo e endereços são atualizados na Tabela de Símbolos.

É importante notar que uma peculiaridade na maneira que variáveis funcionam em python. Quando ocorre uma atribuição de um valor constante (um inteiro, por exemplo), um objeto é criado e a referência desse objeto é atribuída à variável, como pode ser visto em mais detalhe neste [link](https://realpython.com/python-variables/). Assim, quando se atribui uma variável a outra, só o que se faz é apontar ambas as variáveis para o mesmo lugar. 

Este mesmo princípio foi implementado no _parser_. Quando uma variável qualquer recebe um novo valor, só o que se faz é alterar sua entrada na Tabela de Símbolos para que seu endereço e tipo correspondam ao novo dado.

Uma grande limitação do _parser_ é não suportar atribuições de expressões (aritméticas e lógicas) atribuição de vetores.


## Expressões Aritméticas e Lógicas
Outro aspecto do projeto é a implementação de expressões aritméticas e lógicas. Assim como o interpretador de python, o _parser_ aceita expressões soltas porém, ao invés de retornar seu resultado, ele retorna uma árvore sintática na notação _Labelled Bracketing Notation_, que pode ser visualizada de uma forma mais clara neste [site](http://mshang.ca/syntree/).

As expressões aritméticas básicas envolvem adição, subtração, multiplicação e divisão. Já as expressões lógicas possuem operadores de comparação (<, >, <=, etc.) e operadores lógicos propriamente ditos (como **and** e **or**). 

Quando se utiliza identificadores dentro de expressões aritméticas, é necessário verificar seus respectivos tipos. Em python, não se pode utilizar textos em expressões aritméticas e o mesmo acontece neste _parser_. Por outro lado, pode-se utilizar variáveis de qualquer tipo em expressões lógicas, os resultados da expressão e seu sentido dependem dos tipos utilizados como, por exemplo, duas strings podem ser comparadas utilizando o operador '<'. Por causa disso, as expressões lógicas não necessitam de verificação.

## Estruturas de Seleção e Repetição
As estruturas de seleção e repetição implementadas no _parser_ foram o IF/ELSE e o WHILE, ambos com a mesma sintaxe de python. O IF e o WHILE possuem a mesma estrutura demostrada no exemplo abaixo:

> if condição:  
>  <bloco de código identado>  
>
> while condição:  
>  <bloco de código identado>  

Nota-se novamente o uso da identação para delimitar o bloco de código que se segue. Na versão atual, o _parser_ aceita apenas comandos de atribuição e declaração dentro do bloco de código, porém não podem have mais de um comando desses por linha devido a uma limitação na lógica utilizada para implementar essas estruturas. Expressões também não são suportadas, pois não faria sentido possuir expressões soltas dentro de um IF/ELSE ou WHILE, e IFs e WHILEs aninhados não foram implementados.

A estrutura do ELSE é parecida com as vistas anteriormente, porém sem a necessidade de uma condição:

> else:  
>   <bloco de código identado>  

# Executando o código
Para compilar o código, utilize os comandos abaixo:  
> $ bison -d parser_py.y  
> $ flex lex_analyzer.l  
> $ gcc -o interpretador.x parser_py.tab.c lex.yy.c -ll  
> $ ./interpretador.x  
