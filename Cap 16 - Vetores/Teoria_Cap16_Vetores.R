############ INTRODUÇÃO
# Até agora focamos em tibbles e pacotes que funcionam com eles. Mas à medida que começa a escrever
# sua prórias funções e mergulhar mais fundo no R, precisará aprender sobre vetores, os objetos que 
# sustentam os tibbles.0 


########## PRÉ-REQUISITOS
# O foco deste capítulo está nas estruturas de dados de base R, então não é essencial carregar nenhum
# pacote.No entanto será usado apenas algumas funções do pacote purrr para evitar inconsistências no 
# R base.

library(tidyverse)

########## O BÁSICO DE VETORES
# Há dois tipos de vetores
# 
# * Vetores Atômicos => Do qual há seis tipos: logical, integer, double, character, complex e raw.
#                     Vetores integer e double são coletivamente conhecidos como vetores numéricos.
# 
# * Listas => Que são às vezes chamadas de vetores recursivos, porque as listas podem conter outras
#   Listas.

# A principal diferença entre vetores atômicos e listas é que os vetores atômicos são homogêneos, 
# enquanto as listas podem ser heterogêneas.

# Cada vetor tem duas propriedades principais:

# Seu tipo, que pode determinar com typeof()
typeof(letters)
typeof(1:10)

# Seu comprimento, que pode determinar com length():
x <- list("a", "b", 1:10)
length(x)

# Há quatro tipos importantes de vetores aumentados:
# Fatores qye são construídos sobre vetores integer.
# Datas e data-horas, que são construídos sobre vetores numéricos.
# Data frames e tibbles, que são construídos sobre listas.

############## TIPOS IMPORTANTES DE VETORES ATÔMICOS
# Os quatro tipos mais importantes de vetores atômicos são: (logical, integer, double e character).
# Raw e complex raramente são usados durante análises de dados.

######### LOGICAL
# Vetores logical são o tipo mais simples de vetores atômicos, porque só podem receber três valores 
# possíveis: FALSE, TRUE e NA:
1:10 %% 3 == 0

c(TRUE, TRUE, FALSE, NA)

######## NUMÉRICOS
# Vetores integer e double são conhecidos coletivamente como vetores numéricos. Em R, números são 
# doubles por padrão. Para torná-lo um integer, coloque um L depois do número:
typeof(1)
typeof(1L)

# A distinção entre integers e doubles normalmente não é importante, mas há duas diferenças importantes
# das quais devemos ficar cientes:
# * Doubles são aproximações
x <- sqrt(2) ^ 2
x
x - 2

# Esse comportamento é comum com números de ponto flutuante: a maioria dos cálculos inclui algum erro 
# de aproximação. Em vez de comparar números de ponto flutuante com ==, deve-se usar "dplyr::near()", 
# que permite alguma tolerância numérica.

# * Integers tem um valor especial, NA, enquanto doubles tem quatro: NA, NaN, Inf e -Inf. Todos os três
# valores especiais podem surgir durante a divisão:
c(-1, 0, 1) / 0

# Evite usar == para verificar esses outros valores especiais. Em vez disso, use as funções auxiliares
# is.finite(), is.infinite() e is.nan().

######## CARACTERE
# Vetores de caracteres são o tipo mais complexo de vetores atômicos, porque cada elemento de um vetor,
# de caracteres é uma string, e uma string pode conter uma quantidade arbitrária de dados.O R usa um 
# pool global de strings. Isso significa que cada string individual só é armazenada uma vez na memória,
# e cada uso da string aponta para essa representação. Isso reduz a quantidade de memória necessária
# para strings duplicadas. Veja esse comportamento na prática com pryr::object_size():

x <- "This is reasonably long string."
pryr::object.size(x)

######## VALORES 
# Note que cada tipo de vetor atômico tem seu próprio valor faltante:
NA            # logical
NA_integer_   # Integer
NA_real_      # double
NA_character_ # character

################# USANDO VETORES ATÔMICOS
# Agora que entendemos os diferentes tipos de vetores atômicos, é necessário rever algumas das 
# ferramentas importantes para trabalhar com eles. Elas incluem:

# * Como converter de um tipo para outro, e quando isso acontece automaticamente.
# * Como dizer se um objeto é um tipo específico de vetor.
# * O que acontece quando trabalha com vetores de comprimentos diferentes.
# * Como nomear os elementos de um vetor.
# * Como retirar os elementos de seu interesse.

################## COERÇÂO
# Há duas maneiras de converter, ou coagir, um tipo de vetor para outro:

# A coerção explícita => Acontece quando você chama uma função como as.logical(), as.integer(), 
# as.double(), ou as.character(). Sempre que estiver usando a coerção explícita, deve verificar se 
# pode fazer a coerção antes, para que o vetor nunca tenha o tipo errado em primeiro lugar. Exemplo
# Pode precisar ajustar sua especificação col_types do readr.

# A coerção implícita => Acontece quando usa um vetor em um contexto específico que espera um certo
# tipo de vetor. Por exemplo, quando usa um vetor lógico com uma função de resumo numérico, ou quando
# usa um vetor double onde se espera um vetor integer.
 
# Já viu o tipo mais importante de coersão implícita: usar um vetor lógico em um contexto numérico. 
# Neste caso, TRUE é convertido para 1, e FALSE é convertido para 0. Isso significa que a soma de um
# vetor lógico é o número de verdadeiros, e sua média é a proporção de verdadeiros:

x <- sample(20, 100, replace = TRUE)
y <- x > 10
sum(y) # how many are greater than 10?
mean(y) # What proportion are greater than 10?

# Também é importante entender o que acontece quando tenta criar um vetor contendo vários tipos com
# c() - o tipo mais complexo sempre ganha:
typeof(c(TRUE, 1L))
typeof(c(1L, 1.5))
typeof(c(1.5, "a"))

############### FUNÇÕES DE TESTE
# Ás vezes deseja fazer coisas diferentes com base no tipo do vetor. Uma opção é usar o typeof(). 
# Outra é usar uma função de teste que retorne TRUE ou FALSE. O R base fornece muitas funções como
# is.vetor() e is.atomic(), mas elas frequentemente retornam resultados surpreendentes. Em vez disso,
# é mais seguro usar as funções is_* fornecidas por purrr.

################# ESCALARES E REGRAS DE RECICLAGEM
# Assim como coagir implicitamente os tipos dos vetores para serem compatíveis, o R também coage 
# implicitamente o comprimento dis vetore. Isso é chamado de reciclagem de vetor, pois o vetor mais
# curto é repetido, ou reciclado, para o mesmo comprimento do vetor mais longo.

sample(10) + 100
runif(10) > 0.5

# Em R, as operações matemáticas básicas funcionam com vetores. Isso significa que nunca deve precisar
# realizar uma iteração explícita ao fazer cálculos matemáticos simples.

# É intuitivo o que acontecer se adicionar dois vetores de mesmo comprimento, ou um vetor e um "escalar"
# mas o que acontece se você adicionar dois vetores de comprimentos diferentes?

1:10 + 1:12
1:10 + 1:3

# A reciclagem de vetores pode ser usada para criar um código muito suscinto e inteligente, mas também
# pode ocultar problemas silenciosamente. Por essa razão, as funções vetorizadas no tidyverse lançarão
# erros quando reciclar qualquer coisa diferente de um escalar. Caso queira reciclar, precisará fazer
# você mesmo com rep():

tibble(x = 1:4, y = 1:2)
tibble(x = 1:4, y = rep(1:2, 2))
tibble(x = 1:4, y = rep(1:2, each = 2))

##################### NOMEANDO VETORES
# Todos os tipos de vetores podem ser nomeados, inclusive durante a criação, com c():
c(x = 1, y = 2, z = 4)

# ou depois do fato, com purrr::set_names():
set_names(1:3, c("a", "b", "c"))

# Vetores nomeados são mais úteis para criar subconjuntos.

#################### SUBCONJUNTOS
# Há quatro tipos de ações com as quais, pode fazer subconjuntos de um vetor

# Um vetor numérico contendo apenas integers. Os integers devem ser ou todos positivos, ou todos 
# negativos, ou zero.

# Fazer subconjuntos com integers positivos mantém os elementos nessas posições: 
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]

# Ao repetir uma posição, pode realmente fazer uma saída maior que uma entrada:
x[c(1,1,5,5,5,2)]

# Valores negativos deixam de lado os elementos das posições especificadas:
x[c(-1, -3, -5)]

# É um erro misturar valores positivos e negativos:
x[c(1, -1)]

# A mensagem de erro menciona fazer subconjuntos com zero, o que não retorna valores:
x[0]

# Isso não é frequentemente útil, mas pode ser, caso queira criar estruturas de dados incomuns
# para testar suas funções.

# Fazer subconjuntos com um vetor lógico mantém todos os valores correspondentes a um valor TRUE
# Isso é frequentemente mais produtivo em conjunção com as funções de comparação:
x <- c(10, 3, NA, 5, 8, 1, NA)

# All non-missing values of x
x[!is.na(x)]

# All even (or missing!) values of x
x[x %% 2 == 0]

# Se tem um vetor nomeado, pode criar um subconjunto dele com um vetor de caracteres:
x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]

# Como com integers positivos, também pode usar um vetor de caracteres para duplicar entradas 
# individuais

# O tipo mais simples de subconjuntos é o nada, x[], que retorna o x completo. Isso não é útil para
# fazer  subconjuntos de vetores, mas é ao fazer subconjuntos de matrizes (e outras estruturas de 
# alta dimensão), porque lhe permite selecionar todas as linhas ou colunas, deixando o índice em 
# branco. Por exemplo, se x é 2D, 1[1, ] seleciona a primeira linha e todas as colunas, e x[, 1]
# seleciona todas as linhas e todas as colunas, exceto a primeira.

############### VETORES RECURSIVOS (LISTAS)
# Listas são um passo a mais na complexidade em relação aos vetores atômicos, pois podem conter 
# outras listas. Isso as torna adequadas para representar estruturas hierárquicas ou em árvores
# Cria uma lista com list():

x <- list(1, 2, 3)
x

# Uma ferramenta muito útil para trabalhar com listas é str(), porque ela foca na estrutura, não 
# nos conteúdos:
str(x)
x_named <- list(a = 1, b = 2, c = 3)
str(x_named)

# Diferente de vetores atômicos, lists() podem conter uma mistura de objetos:
y <- list("a", 1L, 1.5, TRUE)
str(y)

# Listas podem até conter outras listas:
z <- list(list(1, 2), list(3, 4))
z

############## VISUALIZANDO LISTAS
# Para explicar funções mais complicadas de manipulação de listas, é útil ter uma representação 
# visual de listas. Por exemplo:
x1 <- list(c(1,2), c(3,4))
x2 <- list(list(1,2), list(3,4))
x3 <- list(1, list(2,list(3)))

# Há três principios:

# 1) Listas têm cantos arrendondados. Vetores atômicos têm cantos quadrados.

# 2) Filhos são desenhados dentro dos pais e têm um fundo levemente mais escuro, para facilitar a 
# visualização da hierarquia.

# 3) A orientação dos filhos(isso pe, linhas ou colunas) não é importante, então escolherei uma 
# orientação de linha ou coluna para economizar espaço ou para ilustrar uma propriedade 
# importante no exemplo.

################# SUBCONJUNTOS
# Há três maneiras de fazer subconjuntos de uma lista, que é ilustrado:

a <- list(a = 1:3, b = "a string", c = pi, d = list(-1, -5))

# [extrai uma sublista. O resultado sempre será uma lista:
str(a[1:2])
str(a[4])

# Assim como ocorre com vetores, você pode criar um subconjunto usando um vetor lógico, ou de
# inteiros ou de caracteres.

# [[ extrai um único componente de uma lista. Ele remove um nível da hierarquia da lista:
str(y[[1]])
str(y[[4]])

# $ é um atalho para retirar elementos nomeados de uma lista. Ele funciona de maneira similar a[[, 
# exceto que você não precisa usar aspas:
a$a
a[["a"]]

# A distinção entre [ e [[ é realmente importante para listas, porque [[ examina a lista, enquanto
# [ retorna uma nova lista menor.

################### LISTAS DE CONDIMENTOS
# A diferença entre [ e [[ é muito importante, mas é fácil se confundir. 

################### ATRIBUTOS
# Qualquer vetor pode conter metadados adicionais arbitrários por meio de seus atributos. Pode 
# pensar nos atributos como uma lista nomeada de vetores que podem ser anexados a qualquer objeto
# Pode também obter e configurar valores individuais de atributos como attr() ou ver todos de uma 
# vez com attributes():
x <- 1:10
attr(x, "greeting")
attr(x, "greeting") <- "Hi!"
attr(x, "farewell") <- "Bye!"
attributes(x)

# Há três atributos muito importantes que são usados para implementar partes fundamentais de R:

# * Nomes => são usados para nomear os elementos de um vetor.

# * Dimensões(dims, para abreviar) => fazem o vetor se comportar como uma matriz ou array.

# * Classe => é usada para implementar o sistema orientado a objetos S3.

# Funções genéricas são a chave para a programação orientada a objetos em R, pois fazem as funções
# se comportarem de maneira diferente para diferentes classes de entradas.

# Ex um função genérica típica:
as.Date

# A chamada para "UseMethod" significa que essa é uma função genérica, e ela chamará um método 
# específico, uma função, com base nas classes do primeiro argumento.
# (Todos os métodos são funções; nem todas as funções são métodos.) É possível listar todos os 
# métodos de uma genérica com methods():
methods("as.Date")

# Por exemplo, se x for um vetor de caracteres, as.Date() chamará as.Date.character(); se for um 
# fator, chamará as.Date().factor()

# Pode observar a implementação específica de um método com getS3method():
getS3method("as.Date", "default")
# A genérica mais importante em S3 é print(): ela controla como o objeto é impresso quando você 
# digita seu nome no console. Outras genéricas importantes são as funções de subconjuntos [,[[ e $.

############# VETORES AUMENTADOS
# Vetores atômicos e listas são os blocos de construção para outros vetores importantes, como 
# fatores e datas. Porque são vetores com atributos adicionais, incluindo classe.
# Como os vetores aumentados têm uma classe, eles se comportam de maneira diferente do vetor atômico.

# Fatores
# Datas-horas e horas
# Tibbles

############# FATORES
# Fatores são projetados para representar dados categóricos que podem receber um conjunto fixo de 
# possíveis valores. São construídos sobre integers, e têm um atributo de níveis:
x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
typeof(x)
attributes(x)
levels

################# DATAS E DATAS-HORAS
# Datas em R são vetores numéricos que representam o número de dias desde 1. de janeiro de 1970.
x <- as.Date("1971-01-01")
unclass(x)
typeof(x)
attributes(x)

# Datas-horas são vetores numéricos com classe POSIXct que representam o número de segundos desde 
# 1. de janeiro de 1970
x <- lubridate::ymd_hm("1970-01-01 01:00")
unclass(x)
typeof(x)
attributes(x)

# o atributo tzone é opcional. Ele controla como o tempo é impresso, não a qual tempo absoluto ele 
# se refere:
attr(x,"tzone") <- "US/Pacific"
x

attr(x, "tzone") <- "US/Eastern"
x

# Há outro tipo de data-horas chamado POSIXlt. Esse é construído sobre listas nomeadas:
y <- as.POSIXlt(x)
typeof(y)
attributes(y)

# POSIXlts são raros dentro do tidyverse. Eles surgem no R base, porque são necessários para extrair
# componentes de uma data, como o ano ou o mês.

################### TIBBLES
# Tibbles => são listas aumentadas. Eles têm três classes: tbl_df e data.frame, e dois atributos: 
# names(de colunas) e row.names.
rb <- tibble::tibble(x = 1:5, y = 5:1)
typeof(rb)
attributes(rb)

# data.frames tradicionais têm uma estrutura muito similar:
df <- data.frame(x = 1:5, y = 5:1)
typeof(df)
attributes(df)

# A principal diferença é a classe. A classe de tibble incluir "data.frame", o que significa que, 
# por padrão, os tibbles herdam o comportamento do data frame regular.

# O que diferencia um tibble, ou um data frame, de uma lista é que todos os elementos de um tibble,
# ou data frame, devem ser vetores com o mesmo comprimento. Todas as funções que trabalham com 
# tibbles aplicam essa restrição.
