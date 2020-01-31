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

Primeiramente o FlEX realiza a leitura das especificações, gera um output C com o nome lex.yy.c; posteriormente, este arquivo é compilado e relacionado com a biblioteca “-lfll” para produzir o executável a.out. Por último, o a.out analiza o input e o transforma em uma sequência de tokens.

