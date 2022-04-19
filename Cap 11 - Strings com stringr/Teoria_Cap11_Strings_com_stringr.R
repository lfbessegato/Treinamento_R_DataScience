############ INTRODUÇÃO
# Este capítulo apresenta à manipulação de strings em R. 
# Aprenderá o básico sobre como funcionam as strings e como 
# criá-las à mão, mas o foco será expressões regulares, ou 
# regexps. Expressões regulares são úteis, porque as strings
# normalmente contém dados desestruturados ou semiestruturados,
# e regexps são uma linguagem concisa para descrever padrões
# em strings.

########## PRÉ-REQUISITOS
# Este capítulo focará no pacote stringr para manipulação de
# strings. O stringr não faz parte do núcleo do tidyverse, 
# porque nem sempre temos dados textuais, então precisamos
# carregá-los explicitamente.

library(tidyverse)
library(stringr)
library(tidyr)

# COMPRIMENTO DE STRING
# O R base contém muitas funções para trabalhar com strings, 
# mas vamos evitá-las porque podem ser inconsistentes, o que
# torna dificeis de lembrar.

# Usaremos funções do stringr(), tem nomes mais intuitivos
# e todas começam str_. Por exemplo str_length() lhe diz
# o número de caracteres de uma string.

str_length(c("a","R for data science", NA))

# O prefixo str_ em comum é particularmente útil se usa
# RStudio, porque digitar str_ acionará o autocompletar,
# permitindo que veja todas as funções do stringr:

# COMBINANDO STRINGS
# Para combinar duas ou mais strings, use str_c():

str_c("x", "y")
str_c("x", "y", "z")

# Use o argumento sep para controlar como serão separados:
str_c("x", "y", sep = ",")

# Como a maioria das outras funções em R, valores faltantes
# são contagiosos. Se você quer que sejam impressos como 
# "NA", use str_replace_na():
x <- c("abc", NA)
str_c("|-", x, "-|")
str_replace_na("abc", NA)
str_c("|-", str_replace_na(x),"-|")

# Como mostrado no código, str_c() é vetorizada e recicla
# automaticamente os vetores mais curtos para o mesmo 
# comprimento dos mais longos:
str_c("prefix-", c("a", "b", "c"), "-sufix")

# Objetos de comprimento 0 são deixados de lado 
# sileciosamente. Isso é particularmente útil em conjunto 
# com if:

name <- "Hadley"
time_of_day<- "morning"
birthday <- FALSE

str_c("Good ", time_of_day, " ", name, 
      if (birthday) " and HAPPY BIRTHDAY",
      ".")

# Para colapsar um vetor de strings em uma única string, use
# collapse:
str_c(c("x", "y", "z"), collapse = ",")

###### SUBCONJUNTOS DE STRINGS
# Você pode extrair partes de uma string usando o str_sub()
# Assim como a string str_sub() recebe os argumentos start e
# end, que dão a posição (inclusiva) da substring.

x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)

# Negative numbers count backwards from end
str_sub(x, -3, -1)

# Note que a str_sub() não falhará se a string for curta
# demais. Só retornará o máximo possível.
str_sub("abc", 1, 7)

# Também pode usar o formulário de atribuição de str_sub() para 
# modificar strings
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))
x 

####### LOCALIZAÇÕES
# Pode-se usar 
# str_to_lower => Para mudar tudo para minusculo
# str_to_upper => Para mudar tudo para maiúscula
# Mudar a tipografia é complicado, porque línguas diferentes
# tem regras diferentes para mudanças.
# Pode escolher um conjunto de regras para usar especifi-
# cando uma localização:

# Turkish has two i's: with and without a dot, and it
# has a different rule for capitalizing them:
str_to_upper(c("i","i"))
str_to_upper(c("i", "i"), locale="tr")

# A localização é especificada como um código de língua
# ISO 639, que é uma abreviação de duas ou três letras, se 
# ficar em branco será utilizado a localização pelo sistema.

# Outra operação importante é afetada pela localização, é
# a classificação. As funções sort() e order() do R base
# classificam strings usando a localização atual.

x <- c("apple", "eggplant", "banana")

str_sort(x, locale = "en")
str_sort(x, locale = "br")
str_sort(x, locale = "haw") # Hawaiian

##### COMBINAÇÃO PADRÕES COM EXPRESÕES REGULARES
# Regexps são uma linguagem bem concisa que permite que 
# você descreva padrões em strings. Elas demonstram um 
# pouco para ser entendidas, mas uma vez que consiga, você
# as achará extremamente úteis.

# Para aprender expressões regulares, usaremos:
# str_view(), str_view_all()
# Essas funções recebem um vetor de caracteres e uma 
# expressão regular, e lhe mostram como eles combinam.

# Combinações Básicas 
# Os padrões mais simples combinam strings exatas:

x <- c("apple", "banana", "pear")
str_view(x, "an")

# O próximo passo em complexidade é .. que combina qualquer
# caracteres (exceto um newline)
str_view(x,".a.")

# Para cria expressão regular \. precisamos da string \\.

# To create the regular expression, we need \\
dot <- "\\."

# But the expression itself only contains one:
writeLines(dot)

# And this tells R to look for an explicit
str_view(c("abc", "a.c", "bef"), "a\\.c")

# Isso significa que para combinar uma \ literal, você
# precisa escrever \\\\ - quatro barras invertidas para
# combinar uma!

x <- "a\\b"
writeLines(x)
x <- "a\\"

str_view(x, "\\\\")

# Âncoras
# Por padrão, expressões regulares combinarão qualquer
# parte de uma string.
# Muitas vezes é útil ancorar a expressão regular para 
# que ela combine a partir do começo ou do fim da string.
# Pode usar

# ^ => para combinar o começo da string
# $ => para combinar o fim da string

x <- c("apple", "banana", "pear")
str_view(x, "^a")
str_view(x, "a$")

# Para forçar uma expressão regular a combinar apenas com
# uma string completa, ancore-se com ambos, ^ e $
x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple")
str_view(x, "^apple$")

# Classes de Caracteres e Alternativas
# Há vários padrões especiais que combinam com mais de um 
# caractere. Que combina com qualquer caractere, exceto 
# newline. Há quatro outras ferramentas úteis:
# \d => combina qualquer dígito
# \s => combina qualquer espaço em branco
# [abc] => combina a, b, c
# [^abc] => combina qualquer coisa, exceto a, b, c

# lembre-se, para criar uma expressão regular contendo 
# \d ou \s, precisará escapar a \ para string, então
# digitará "\\d" ou "\\s"

str_view(c("grey", "gray"), "gr(e|a)y")

# Repetição
# O próximo degrau no poder envolve controlar quantas 
# vezes um padrão é combinado
# ? => 0 ou 1
# + => 1 ou mais
# * => 0 ou mais
x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?")
str_view(x, "CC+")
str_view(x, "C[LX]+")

# Também pode especificar o número de combinações precisamente:
# {n} => exatamente n
# {n,} => n ou mais
# {,m} => no máximo m
# {n,m} => entre n e m
str_view(x,"C{2}")
str_view(x,"C{2,}")
str_view(x,"C{2,3}")

# Pode torná-las preguiçosas, combinando com a string mais curta possível
# colocando um ? depois delas. Esse é um recurso avançado de expressões
# regulares.
str_view(x,'C{2,3}?')
str_view(x, 'C[LX]+?')

# Agrupamentos e Backreferences
# Definem "grupos" aos quais pode referir com o backreferences, como 
# \1 \2
# O Exemplo a expressão regular a seguir encontra todas as frutas que têm
# um par de letras repetido.
str_view(fruit, "(..)\\1", match = TRUE)

# Ferramentas
# variedade de funções stringr
  # Determinar quais strings combinam com um padrão
  # Encontrar as posições das combinações
  # Extrair o conteúdo das combinações
  # Substituir combinações por novos valores
  # Separar uma string com base em uma combinação

# Detectar Combinações
# Para Determinar se um vetor de caracteres combina com um padrão, use 
# str_detect() retorna um valor lógico do mesmo comprimento que a entrada

x <- c("apple", "banana", "pear")
str_detect(x, "e")

# Lembre-se quando usa um vetor lógico, em um contexto numérico, FALSE => 0, 
# e TRUE => 1. Isso torna sum() e mean() úteis, se quiser responder perguntas
# sobre combinações em um vetor maior

# How many common words start with a T?
sum(str_detect(words, "^t"))

# What proportion of common words end with a vawel?
mean(str_detect(words,"[aeiou]$"))

# Quando tem condições lógicas complexas (por exemplo, combinar a ou b, mas
# não c a não ser que d), muitas vezes é mais fácil combinar múltiplas
# chamadas str_detect() com operadores lógicos, em vez de tentar criar uma
# única expressão regular. Por exemplo: Aqui estão duas maneiras de encontrar
# todas as palavras que não contêm nenhuma vogal.

# Find all words containing at least on vowel, and negate
no_vowels_1 <- !str_detect(words,"[aeiou]")

# Find all words consisting only of consonants (non-vowels)
no_vowels_2 <- str_detect(words,"^[^aeiou]+$")
identical(no_vowels_1,no_vowels_2)

# Um uso comum de str_detect() é selecionar os elementos que combinam com um
# padrão. Pode fazer isso com subconjuntos lógicos ou com o conveniente 
# wrapper str_subset():

words[str_detect(words,"x$")]
str_subset(words,"x$")

# Normalmente, no entanto, suas strings serão uma coluna de um data frame e
# e vair querer usar filter:

df <- tibble(
  word = words,
  i = seq_along(word)
)
df %>%
  filter(str_detect(words,"x$"))
# Uma variação de str_detect é str_count(): em vez de um simples sim ou não
# ela lhe diz quantas combinações existem em uma string:

x <- c("apple", "banana", "pear")
str_count(x, "a")

# On average, how many vowels per word?
mean(str_count(words,"[aeiou]"))

# É natural usar o str_count() com mutate():
df %>%
  mutate(
    vowels = str_count(word,"[aeiou]"),
    consonants = str_count(word, "[^aeiou]")
  )

# Note que as combinações nunca se sobrepõem. Por exemplo, em "abababa", 
# quantas vezes o padrão "aba" combinará? Expressões regulares dizem duas
# não três:
str_count("abababa","aba")
str_view_all("abababa", "aba")

# Note: O uso de str_view_all(). Como você aprenderá em breve, funções 
# stringr vêm em pares: uma função trabalha com uma única combinação, e a 
# outra, com todas as combinações. A segunda função terá o sufixo _all.

#### EXTRAIR COMBINAÇÔES
# Para extrair o texto de uma combinação, use str_extract(). 
length(sentences)
head(sentences)

# Imagine que queiramos encontrar todas as frases que contenham uma cor.
# Primeiro criamos um vetor de nomes de cores, e então o transformamos em 
# uma única expressão regular:
colors <- c("red", "orange", "yellow", "green", "blue", "purple")

color_match <- str_c(colors, collapse = "|")
color_match

# Agora podemos selecionar as frases que contêm uma cor, então, extrair a
# cor para descobrir qual é: 
has_colors <- str_subset(sentences, color_match)
matches <- str_extract(has_colors, color_match)
head(matches)

# Note que str_extract() só extrai a primeira combinação. Podemos ver isso
# mais facilmente selecionando primeiro todas as frases que têm mais de uma 
# combinação:
more <- sentences[str_count(sentences, color_match) > 1]
str_view_all(more, color_match)

str_extract(more, color_match)

# Esse é um padrão comum para funções stringr, porque trabalhar como uma 
# única combinação lhe permite usar estruturas de dados muito mais simples.
# Para obter todas as combinações, use str_extract_all(). Ela retornará uma
# lista:
str_extract_all(more, color_match)

# Se usar simplify = TRUE, o str_extract_all() retornará uma matriz com 
# combinações curtas expandidas ao mesmo comprimento da mais longa:
str_extract_all(more,color_match, simplify = TRUE)
x <- c("a", "b", "a b c")
str_extract_all(x, "[a-z]", simplify = TRUE)

#### COMBINAÇÕES AGRUPADAS
# Imagine que queiramos extrair substantivos das frases. Como uma herística
# procuraremos por qualquer palavra que venha depois de um "a" ou "the".
# Definir uma "palavra" em uma expressão regular  é um pouco complicado, 
# então aqui eu uso uma aprximação simples - uma sequencia de pelo menos um
# caractere que não seja um espaço:
noum <- "(a|the)([^ ]+)"
has_noum <- sentences %>%
  str_subset(noum) %>%
  head(10)
has_noum %>%
  str_extract(noum)

# str_extract dá a combinação completa; str_match() dá cada componente 
# individual. Em vez de um vetor de caracteres, ela retorna uma matriz, com
# uma coluna para a combinação completa seguida por uma coluna para cada 
# grupo:
has_noum %>%
  str_match(noum)

# Se seus dados estiverem em um tibble, muitas vezes é mais fácil usar
# tiddyr::extract(), funciona como str_match(), mas requer que nomeie as 
# combinações, que são, então colocadas em novas colunas:
tibble(sentence = sentences) %>%
  tidyr::extract(
    sentence, c("article", "noum"), "(a|the) ([^ ]+)",
    remove = FALSE  
  )

#### SUBSTITUINDO COMBINAÇÕES
# str_replace() e str_replace_all() permitem que você substitua combinações
# com novas strings. O uso mais simples é substituir um padrão por uma 
# string fixa:
x <- c("apple", "pear", "banana")
str_replace(x, "[aeiou]", "-")
str_replace_all(x, "[aeiou]", "-")

# Com str_replace_all() você pode realizar várias substituições fornecedendo
# um vetor nomeado:
x <- c("1 house", "2 cars", "3 people")
str_replace_all(x, c("1" = "one", "2"= "two", "3" = "three"))

# Em vez de substituir por uma string fixa, pode usar backreferences para
# inserir componentes da combinação. No código a seguir, inverto a ordem
# da segunda e da terceira palavra:
sentences %>%
  str_replace("([^ ]+)([^ ]+)([^ ]+)", "\\1 \\3 \\2") %>%
  head(5)

##### SEPARAR
# Use str_split() para separar uma string em partes. Por exemplo, poderíamos
# separar as frases em palavras:
sentences %>%
  head(5) %>%
  str_split("")

# Como cada componente pode conter um número diferente de partes, isso 
# retorna uma lista. Se está trabalhando como um vetor de comprimento 1, o
# mais fácil é simplesmente extrair o primeiro elemento da lista.
"a|b|c|d" %>%
  str_split("\\|")

# Caso contrário, como as outras funções stringr que retornam uma lista, 
# pode usar o simplify = TRUE para retornar uma matriz:
sentences %>%
  head(5) %>%
  str_split("", simplify = TRUE)

# Você também pedir um número máximo de partes:
fields <- c("Name:Hadley", "Country:NZ", "Age:35")
fields %>% 
  str_split(":", n = 2, simplify = TRUE)

# Em vez de separar strings por padrões, é possível também separá-las pelos
# limites (boundary()) de caracteres, linhas, frases e palavras:
x <- "This is a sentence. This is another sentence."
str_view_all(x, boundary("word"))

str_split(x, "")[[1]]
str_split(x,boundary("word"))[[1]]

#### ENCONTRAR COMBINAÇÕES
# str_locate() e str_locate_all() lhe dão as posições inicial e final de 
# cada combinação.Pode usar o str_locate() para encontrar o padrão de combi-
# nação e str_sub() para extraí-los e/ou modificá-los.

# OUTROS TIPOS de PADRÔES
# Quando usa como padrão uma string, ela é automaticamente envolvida em uma
# chamada para regex():

# The regular call:
str_view(fruit, "nana")

# Is shorthand for
str_view(fruit, regex("nana"))

# Pode usar outros argumentos de regex() para controlar os detalhes da combinação

# * ignore_case = TRUE => Permite que os caracteres combinem ou com suas 
#   frases em caixa-alta ou em caixa-baixa. Sempre usará a localização atual:
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
str_view(bananas, regex("banana", ignore_case = TRUE))

# * multiline = TRUE => Permite que ^ e $ combinem com o início e o fim de 
#   cada linha, em vez de o início e o fim da string completa:
x <- "Line 1\nLine 2\nLine 3"
str_extract_all(x, "^Line")[[1]]
str_extract_all(x, regex("^Line",multiline = TRUE))[[1]]

# * comments = TRUE => Prmite que use comentários e espaço em branco para 
#   tornar as expressões regulares complexas mais compreensíveis. Espaços 
#   são ignorados, como tudo depois de #. Para combinar um espaço literal
#   precisa escapá-lo.
phone <- regex("
\\(? # optional opening parens
(\\d{3}) # area code
[)-]? # optional closing parens, dash, or space
(\\d{3}) # another three numbers
[-]? # optional space or dash
(\\d{3}) # three more numbers
", comments = TRUE)

str_match("514-791-8141", phone)

# dotall = TRUE => Permite que . combine com tudo, incluindo \n

# Há três outras funções que pode usar no lugar do regex()
# * fixed() => Combina exatamente a sequencia especificada de bytes. Ela 
#   ignora todas as expressões regulares e opera em um nível muito baixo.
#   Isso permite que evite escapadas complexas e pode ser muito mais rápido
#   do que expressões regulares.
microbenchmark::microbenchmark(
  fixed = str_detect(sentences, fixed("the")),
  regex = str_detect(sentences, "the"),
  time = 20
)

# Cuidado ao usar o fixed com dados que não pertencem ao inglês.Porque 
# frequentemente há várias maneiras de representar o mesmo caractere.
a1 <- "\u00e1"
a2 <- "a\u0301"
c(a1, a2)
a1 == a2

# Elas são idênticas, mas como são definidas de forma diferente, fixed() não 
# encontra uma combinação. Em seu lugar pode usar coll(), para respeitar as
# regras de comparação de caráter humano:
str_detect(a1, fixed(a2))
str_detect(a1, coll(a2))

# * coll() => Compara strings usando regras de collation. Isso é útil para
#   fazer combinação insensível à caixa. Note que coll() recebe um parâmetro
#   locale, que controla quais regras são usadas para comparar caracteres.

# Tanto fixed() quanto regex() têm argumentos ignore_case, mas não permitem
# que você escolha a localização: elas sempre usam a localização padrão.
# Pode conferir isso com o código a seguir (mais sobre a stringi na sequencia
stringi::stri_locale_info()

# A desvantagem de coll() é a velocidade, pois as regras para reconhecer 
# quais caracteres são os mesmos são complicadas, e coll() é relativamente
# lenta comparada a regex() e fixed().

# Como viu com o str_split(), você pode utilizar boundary() para combinar
# limites. Também pode usá-la com as outras funções:
x <- "This is a sentence."
str_view_all(x, boundary("word"))
str_extract_all(x, boundary("word"))

#### OUTROS USOS PARA EXPRESSÕES REGULARES
#  Há duas funções úteis no R base que também usam expressões regulares:
# * apropos() => busca todos os objetos disponíveis no ambiente global. 
#   Isso é útil se você não consegue se lembrar bem do nome da função:
apropos("replace")

# * dir() => lista todos os arquivos em um diretório. O argumento pattern
#   recebe uma expressão regular e só retorna nomes de arquivos que combinem
#   com o padrão. Por exemplo, você pode encontrar todos os arquivos de R
#   Markdown em um diretório atual com:
head(dir(pattern = "\\.Rmd$"))
