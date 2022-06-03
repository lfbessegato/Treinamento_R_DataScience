############ INTRODUÇÃO
# Nesse capítulo aprenderá sobre dius importantes paradigmas de programação: Programação imperativa e 
# Programação funcional.

########## PRÉ-REQUISITOS
# Uma vez que tenha dominado os loops for fornecidos pelo R base, apredenrá algumas ferramentas de 
# programação poderosas fornecidas pelo purrr, um dos pacotes do núcleo do tidyverse:
library(tidyverse)

############# LOOPS FOR
# Imagine que tenhamos este tibble simples
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# Queremos calcular a mediana de cada coluna, Poderia fazer isso com copiar e colar:
median(df$a)
median(df$b)
median(df$c)
median(df$d)

# Porém, quebraria nossa regra de ouro: nunca copiar e colar mais de duas vezes. Em vez disso,
# poderíamos usar um loop for:
output <- vector("double", ncol(df)) # 1. output
for(i in seq_along(df)) {            # 2. sequence
  output[[i]] <- median(df[[i]])     # 3. Body
}
output

# Cada loop for tem três componentes:

# * saída output <- vector("double", length(x)) => Antes de começar o loop, deve-se sempre alocar 
# espaço suficiente para a saída(output). Uma maneira abrangente de criar um vetor vazio de dado 
# comprimento é a função vector(). Ela tem dois argumentos # o tipo vetor ("logical","integer", 
# "double", "character", etc) e o comprimento do vetor.

# * sequência i in seq_along(df) => Determina sobre o que fazer o loop: cada execução do loop for 
# atribuirá a i um valor diferente de seq_along(df). Pode não ter visto seq_along() antes, trata-se 
# de uma versão segura do familiar 1:length(l) com uma diferença importante; se tem um vetor de 
# comprimento zero, seq_along() faz a coisa certa
y <- vector("double", 0)
seq_along(y)
1:length(y)

# * corpo output[[i]] <- median(df[[i]]) => Esse é o código que faz o trabalho. É executado 
# repetidamente, cada vez com um valor diferente para i. A primeira iteração executará 
# output[[1]] <- median([[1]]), a segunda executará output[[2]] <- median([[2]]), e assim por diante.

########### VARIAÇÕES DO LOOP FOR
# Essas variações são importantes, independentemente de como faça a iteração, então não se esqueça 
# delas, uma vez que tenha dominado as técnicas de FP que aprenderá na próxima seção.

# Há quatro variações do tema básico do loop for:
# * Modificar um objeto existente, em vez de criar um novo.
# * Fazer loops sobre nomes ou valores, em vez de índices.
# * Lidar com saídas de comprimento desconhecido.
# * Lidar com sequências de comprimentos desconhecidos.

############ MODIFICANDO UM OBJETO EXISTENTE
# As vezes quer usar um loop for para modificar um objeto existente.
# Queremos reescalar todas as colunas em um data frame:
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

df$a <- rescale01(df$a)
df$b <- rescale01(df$b)
df$c <- rescale01(df$c)
df$d <- rescale01(df$d)

# Para resolver isso com um loop for, pensamos novamente nos três componentes:

# * Saída => Nós já temos a saída - é igual à entrada

# * Sequencia => Podemos pensar sobre um data frame como uma lista de colunas, então podemos iterar
# sobre cada coluna com seq_along(df)

# * Corpo => Aplicar rescale01()

# Isso nos dá: 
for (i in seq_along(df)){
  df[[i]] <- rescale01(df[[i]])
}

# Normalmente modificará uma lista ou um data frame com esse tipo de loop, então lembre-se de usar
# [[, e não [. Talvez tenha percebido que foi usado [[ em todos os loops: melhor usar [[ até para 
# vetores atômicos, pois assim fica claro que queremos trabalhar com um único elemento.

################### PADRÕES DE LOOPS
# Há três maneiras básicas de fazer um loop sobre um vetor. Foi mostrado a mais geral: fazer loop 
# sobre índices numéricos com for (i in seq_along(x$)) e extrair valor com x[[i]]. Há duas formas:

# * Loop sobre elementos: for (x in x$) => Esse é a mais útil se você se preocupa com efeitos 
# colaterais, como fazer um gráfico ou salvar um arquivo, já que é díficil salvar a saída de maneira
# efeciente.

# * Loop sobre nomes: for (nm in names(x$)) => Esse lhe dá um nome, que você pode usar para acessar
# o valor com x[[nm]]. É eficaz se você quiser usar o nome em um título de gráfico ou em um arquivo.

# Se está criando uma saída nomeada, certifique-se de nomear o vetor de resultados da seguinte 
# maneira:

results <- vector("list", length(x))
names(results) <- names(x)

# A iteração sobre os índices numéricos é a forma mais abrangente, porque, dada a posição, você pode
# extrair tanto o nome quanto o valor:
for (i in seq_along(x)){
  name <- names(x)[[i]]
  value <- x[[i]]
}

############# COMPRIMENTO DE SAÍDA DESCONHECIDO
# Ás vezes pode não saber qual será o comprimento da saída. Por exemplo, imagine que queira simular 
# alguns vetores aleatórios de comprimentos aleatórios. Possivelmente ficará tentado a resolver esse
# problema ao aumentar o vetor progressivamente.
means <- c(0,1,2)

output <- double()
for (i in seq_along(means)){
  n <- sample(100,1)
  output <- c(output, rnorm(n, means[[i]]))
}
str(output)

# Mas isso não é muito eficaz, pois em cada iteração o R tem que copiar todos os dados das iterações
# anteriores. Em termos técnicos, obtém um comportamento "quadrático", o que significa que num loop 
# com três vezes mais elementos levaria nove vezes mais para executar.

# Uma solução melhor é salvar os resultados em uma lista e, então, combiná-los em um único vetor 
# depois que o loop terminar:
out <- vector("list", length(means))
for (i in seq_along(means)){
  n <- sample(100,1)
  out[[i]] <- rnorm(n, means[[i]])
}

str(out)
str(unlist(out))

# Aqui foi usado unlist() para colocar uma lista de vetores em um único vetor. Uma opção mais rigorosa
# é usar purrr::flatten_dbl() - ela lançará um erro se a entrada não for uma lista de doubles.

# Essa padrão ocorre em outros lugares também: 
# * Pode gerar uma string longa. Em vez de juntar com paste() cada iteração com a anterior, salve a
# saída em um vetor de caracteres e, então combine esse vetor em uma única string com
# paste(output, collapse = "").

# * Pode gerar um data frame grande. Em vez de fazer rbind() sequencialmente em cada iteração, salve
# a saída em uma lista e, então, use dplyr::bind_rows(output) para combinar a saída em único data 
# frame.

################ COMPRIMENTO DE SEQUENCIA DESCONHECIDO
# Algumas vezes não sabe nem qual deveria ser o tamanho da sequencia de entrada, isso é comum ao 
# fazer simulações.
# Não pode fazer esse tipo de iteração com o loop for. Em vez disso, pode usar o loop while. 
# Um loop while é mais simples que um loop for, porque só tem dois componentes, uma condição e um 
# corpo.
while(condition) {
  # body
}

# Um loop while também é mais geral que um loop for, pois permite reescrever qualquer loop for como 
# um loop while, mas não pode reescrever todo loop while como um loop for:
for (i in seq_along(x)){
  # body
}

# Equivalent to
i <- -1
while(i <= length(x)){
  # body
  i <- i + 1
}

# Eis como podemos usar um loop while para encontrar quantas tentativas demora para obter três caras
# seguidas:
flip <- function() sample(c("T", "H"), 1)
flips <- 0 
nheads <- 0

while (nheads < 3){
  if (flip() == "H"){
    nheads = nheads + 1
  } else {
    nheads <- 0
  }
  flips <- flips + 1
}
flips

############## LOOPS FOR VERSUS FUNCIONAIS
# Loops for não são tão importantes em R como são em outras linguagens, pois R é uma linguagem de 
# programação funcional. Isso significa que é possível envolver loops for em uma função e chamar 
# essa função, em vez de usar o loop for diretamente.

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# Imagine que queira calcular a média de cada coluna. Seria possível fazer isso com um loop for:
output <- vector("double", length(df))
for (i in seq_along(df)){
  output[[i]] <- mean(df[[i]])
}
output

# Percebe que vai querer calcular as médias de cada coluna com bastante frequencia então as extrai 
# para uma função
col_mean <- function(df){
  output <- vector("double", length(df))
  for (i in seq_along(df)){
    output[i] <- mean(df[[i]])
  }
  output
}

# Porém, você pensa que também seria útil calcular a mediana, e o desvio-padrão, então copia e cola 
# sua função  col_mean() e substitui a mean() por median() e sd().
col_median <- function(df){
  output <- vector("double", length(df))
  for (i in seq_along(df)){
    output[i] <- median(df[[i]])
  }
  output
}

col_sd <- function(df){
  output <- vector("double", length(df))
  for (i in seq_along(df)){
    output[i] <- sd(df[[i]])
  }
  output
}

# O que você faria se visse um conjunto de funções como este?
f1 <- function(x) abs(x - mean(x)) ^ 1
f2 <- function(x) abs(x - mean(x)) ^ 2
f3 <- function(x) abs(x - mean(x)) ^ 3

# Com sorte, você notaria que há uma duplicação e a extrairia para um argumento adicional
f <- function(x, i) abs(x - mean(x)) ^ i

# Assim, reduziu as chances de bugs (porque agora tem 1/3 a menos de código) e facilitou a generali-
# zação para novas situações

# Podemos fazer exatamente o mesmo com col_mean(), col_median() e col_sd() adicionando um argumento
# que forneça a função para aplicar a cada coluna:
col_summary <- function(df, fun){
  out <- vector("double", length(df))
  for (i in seq_along(df)){
    out[i] <- fun(df[[i]])
  }
  out
}
col_summary(df, median)

# A família de funções apply do R base (apply(), tapply(), etc) resolve um problema similar, mas o 
# purrr é mais consistente e, portanto mais fácil de aprender.

# O objetivo de usar funções purrr, em vez de loops for, é possibilitar que você desmembre desafios 
# comuns de manipulação de listas em partes independentes:

# * Como resolveria o problema para um único elemento da lista? Uma vez que tenha elucidado esse 
# problema, o purrr cuida de generalizar sua solução para cada elemento da lista.

# * Com o purrr, pode obter vários pedaços pequenos que pode juntar com o pipe.

# Essa estrutura facilita a resolução de novos problemas. Também possibilita entender suas soluções
# de velhos problemas quando você lê seu código antigo.

################# AS FUNÇÕES MAP
# O padrão de fazer loop sobre um vetor, fazer algo a cada elemento e, então, salvar os resultados
# é tão comum que o pacote purrr oferece uma família  de funções para fazer isso por você. Há uma
# função para cada tipo de saída:

# map()     => Faz uma lista.
# map_lgl() => Faz um vetor lógico.
# map_int() => Faz um vetor integer.
# map_dbl() => Faz um vetor double.
# map_chr() => Faz um vetor de caracteres

# Podemos usar essas funções para realizar os mesmos cálculos que os do último loop for. Essas funções
# de resumo retornaram doubles, então precisamos usar map_dbl():
map_dbl(df, mean)
map_dbl(df, median)
map_dbl(df, sd)

# Isso é mais aparente se usarmos o pipe:
df %>% map_dbl(mean)
df %>% map_dbl(median)
df %>% map_dbl(sd)

# Há algumas diferenças entre map_*() e col_summary():

# * Todas as funções purrr são implementadas em C. Isso as torna um pouco mais rápidas ao custo da
# legibilidade.
# 
# * O segundo argumento, .f, a função para aplicar, pode ser uma fórmula, um vetor de caracteres ou 
#  vetor integer.
#
# * map_*() usa ...("Reticências (...)) para passar argumentos adcionais a .f sempre que for chamada.
map_dbl(df, mean, trim = 0.5)
# 
# As funções map também preservam os nomes:
z <- list(x = 1:3, y = 4:5)
map_int(z, length)

################### ATALHOS
# Há alguns atalhos que pode usar com .f para digitar um pouco menos. 
models <- mtcars %>%
  split(.$cyl) %>%
  map(function(df) lm(mpg ~ wt, data = df))

# A sintaxe para criar uma função anônima em R é bem prolixa, então o purrr fornece um atalho 
# conveniente - uma fórmula de uma lado:
models <- mtcars %>%
  split(.$cyl) %>%
  map(~ lm(mpg ~ wt, data = .))

# Com um pronome: ele se refere à lista mesma de elementos (da mesma maneira que i se referiu ao
# índice atual no loop for)

# Quando observa muitos modelos, pode querer extrair um resumo estatístico como o R2. Para fazer isso
# precisamos primeiro executar summary() e, então, extrair o componente chamado r.squared. Poderíamos
# fazer isso usando o atalho para funções anônimas
models %>%
  map(summary) %>%
  map_dbl(~ .$r.squared)

# Mas extrair componentes nomeados é uma operação comum, então o purrr fornece um atalho ainda mais
# curto: usar uma string:
models %>%
  map(summary) %>%
  map_dbl("r.squared")

# Você também pode usar um integer para selecionar elementos por posição:
x <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))
x %>% map_dbl(2)

########################## R BASE
# Se já está acostumado com a família de funções apply no R base, pode ter notado algumas similiari-
# dades com as funções purrr:

# * lapply() => Basicamente idêntica a map(), exceto que map() é consistente com todas as outras 
# funções em purrr, e pode usar os atalhos para .f.

# * sapply() => base é um wrapper em torno de lapply() que simplifica automaticamente a saída. Isso é
# útil para trabalho interativo, mas problemático em uma função, porque nunca sabe que tipo de saída
# obterá:
x1 <- list(
  c(0.27, 0.37, 0.57, 0.91, 0.20),
  c(0.90, 0.94, 0.66, 0.63, 0.06),
  c(0.21, 0.18, 0.69, 0.38, 0.77)
)

x2 <- list(
  c(0.50, 0.72, 0.99, 0.38, 0.78),
  c(0.93, 0.21, 0.65, 0.13, 0.27),
  c(0.39, 0.01, 0.38, 0.87, 0.34)
)

threshold <- function(x, cutoff = 0.8) x(x > cutoff)
x1 %>% sapply(threshold) %>% str()
x1 %>% sapply(threshold) %>% str()

# vapply() => é uma alternativa segura a sapply(), porque fornece um argumentos adicional que define
# o tipo.

#######################################LIDANDO COM FALHAS
# Quando usamos as funções map para repetir muitas operações, as chances de uma dessas operações 
# falhar são muito altas. Nesta seção aprenderá como lidar com essa situação com uma nova função:
# safely(). O safely() é um advérbio: ele recebe uma função (um verbo) e retorna uma versão modificada
# nunca lançará um erro. Em vez disso, sempre retornará uma lista com dois elementos:

# result => O resultado original. Se houvesse um erro, ele seria NULL.

# error => um objeto de erro. Se a operação tivesse sucesso, ela seria NULL.

# Vamos ilustrar isso com um exemplo simples, log():
safe_log <- safely(log)
str(safe_log(10))
str(safe_log("a"))

# Quando a função tem sucesso, o elemento result contém o resultado, e o elemento erro é NULL. 
# Quando a função falha, o elemento result é NULL, e o elemento error contém um objeto de erro.

# safely() => É projetada para trabalhar com map:
x <- list(1, 10, "a")
y <- x %>% map(safely(log))
str(y)

# Seria mais fácil de trabalhar se tivéssemos duas listas: uma de todos os erros e outra de todas as 
# saídas. Isso é fácil de conseguir com purrr::transpose():
x <- y %>% transpose()
str(y)

# Você decide como lidar com os erros, mas normalmente ou vai olhar os valores de x, no qual y é um
# erro, ou vai trabalhar com os valores de y que estão OK:
is_ok <- y$error %>% map_lgl(is_null)
x[!is_ok]
y$result[is_ok] %>% flatten_dbl()

# purrr fornece dois outros advérbios úteis:

# * Como safely(), possibly() sempre tem sucesso. É mais simples do que safely(), pois dá a ele um 
# valor padrão para retornar quando há um erro:
x <- list(1,10,"a")
x %>% map_dbl(possibly(log, NA_real_))

# quietly() => Tem um papel similar a safely(), mas em vez de capturar erros, ele captura saídas, 
# mensagens e avisos impressos:
x <- list(1, -1)
x %>% map(quietly(log)) %>% str()

################# FAZENDO MAPS COM VÁRIOS ARGUMENTOS
# Frequentemente terá várias entradas relacionadas que precisará iterar em paralelo. Esse é o trabalho
# das funções map2() e pmap(). Imagine que queira simular algumas normais aleatórias com médias 
# diferentes. Sabe como fazer isso com map()
mu <- list(5, 10, -3)
mu %>% 
  map(rnorm, n = 5) %>%
  str()

# E se também quisesse variar o desvio-padrão? Uma maneira de fazer isso seria iterar sobre os índices
# e resumir em vetores de médias e desvios padrão:
sigma <- list(1, 5, 10)
seq_along(mu) %>%
  map(~rnorm(5, mu[[.]], sigma[[.]])) %>%
  str()

# Contudo, pode confundir a intenção do código. Em vez disso, podemos usar map2(), que itera sobre 
# dois vetores em paralelo:
map2(mu, sigma, rnorm, n = 5) %>% str()

# Note que os argumentos que variam para cada chamada vêm antes da função; argumentos iguais para 
# todas as chamadas vêm depois.

# Como map(), map2() é apenas um wrapper ao redor de um loop for: 
map2 <- function(x,y, f, ...) {
  out <- vector("list", length(x))
  for (i in seq_along(x)){
    out[[i]] <- f(x[[i]], y[[i]], ...)
  }
  out
}

# Você também poderia imaginar map3(), map4(), map5(), map6() etc..., mas ficaria rapidamente
# entediante. Em vez disso, o purrr fornece pmap(), que recebe uma lista de argumentos. Você pode
# usá-lo se quiser variar a média, o desvio-padrão e o número de amostras:
n <- list(1, 3, 5)
args1 <- list(n, mu, sigma)
args1 %>%
  pmap(rnorm) %>%
  str()

# Se não nomear os elementos da lista, a pmap() usará a combinação posicional ao chamar a função. Isso
# é um pouco frágil e dificulta a leitura do código, então é melhor nomear os argumentos:
arg2 <- list(mean = mu, sd = sigma, n = n)
arg2 %>%
  pmap(rnorm) %>%
  str()

# Já que os argumentos são todos do mesmo comprimento, faz sentido armazená-los em um data frame:
params <- tribble(
  ~mean, ~sd, ~n, 
     5,    1,  1,
    10,    5,  3,
    -3,   10,  5
)
params %>%
  pmap(rnorm)

# Quando o código, ficar complicado, opte por um data frame, pois assim garantirá que cada coluna
# tenha um nome e o mesmo comprimento de todas as outras.

############## INVOCANDO FUNÇÕES DIFERENTES
# Há mais um passo além na complexidade. Bem como variar os argumentos d função, também pode variar
# a própria função:
f <- c("runif", "rnorm", "rpois")
param <- list(
  list(min = -1, mrguax = 1),
  list(sd = 5),
  list(lambda = 10)
)

# Para lidar com esse caso, pode usar invoke_map():
invoke_map(f, param, n = 5) %>% str()

# O primeiro argumento é uma lista de funções ou um vetor de caracteres de nomes de funções. O segundo
# é uma lista de listas. O segundo é uma lista  de listas, dando os argumentos que variam para cada
# função. Os argumentos subsequentes são passados para cada função.

# E novamente pode usar tribble() para facilitar um pouco a criação desses pares combinados:
sim <- tribble(
  ~f,        ~params,
  "runif",   list(min = -1, max = 1),
  "rnorm",   list(sd = 5),
  "rpois",   list(lambda, n = 10)
)
sim %>%
  mutate(sim = invoke_map(f, params, n = 10))

################## WALK
# Walk => É uma alternativa a map que usa quando quer chamar uma função pelos seus efeitos colaterais,
# em vez de por seu valor de retorno. Normalmente faz isso quando quer enviar a saída para a tela ou
# salvar arquivos no disco - o importante é a ação, não o valor retornado. Um exemplo simples:
x <- list(1, "a", 3)
x %>%
  walk(print)

# Walk() geralmente não é tão útil quando comparado a walk2() ou pwalk(). Por exemplo, se você tivesse
# uma lista de gráficos e um vetor de nomes de arquivos, poderia usar pwalk() para salvar cada arquivo
# no local correspondente no disco:
library(ggplot2)
plots <- mtcars %>%
  split(.$cyl)
  map(~ggplot(., aes(mpg, wt)) + geom_point()

paths <- stringr::str_c(names(plots), ".pdf")
  
pwalk(list(paths, plots), ggsave, path = tempdir())
  
# walk()m walk2() e pwalk() retornam .x invisilvemente, o primeiro argumento. Isso os torna 
# compatíveis para uso no meio de pipelines.


############## OUTROS PADRÕES PARA LOOPS FOR
# O purrr fornece várias funções que abstraem sobre outros tipos de loops for. O Objetivo é ilustrar 
# cada função, então, elas virão à cabeça se você vir um problema similar no futuro.

############# FUNÇÕES PREDICADAS
# Várias funções trabalham com funções predicadas que retornam um único TRUE ou FALSE.

# keep() e discard() mantêm os elementos da entrdada onde o predicado é TRUE ou FALSE, respectivamente
iris %>%
  keep(is.factor) %>%
  str()

iris %>%
  discard(is.factor) %>%
  str()

# some() e every() => Determinam se o predicado é verdadeiro para qualquer ou para todos os elementos
x <- list(1:5, letters, list(10))

x %>%
  some(is_character)

x %>%
  every(is_vector)

# detect() => Encontra o primeiro elemento no qual o predicado é verdadeiro; detect_index() retorna
# sua posição:
x <- sample(10)

x %>%
  detect(~ . > 5)

x %>% 
  detect_index(~ . > 5)
# head_while() e tail_while() => Pegam elementos do começo ou do final de um vetor enquanto um 
# predicado for verdadeiro:
x %>% 
  head_while(~ . > 5)

x %>% 
  tail_while(~ . > 5)

############# REDUCE E ACCUMULATE
# Ás vezes tem uma lista complexa e deseja reduzir a uma lista simples aplicando repetidamente uma 
# função que reduza um par a algo individual. Isso é útil caso queira aplicar um verbo dplyr de duas
# tabelas a várias tabelas. Por exemplo, pode ter uma lista de data frames e querer reduzi-la a um 
# único data frame juntando elementos
library(dplyr)
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tiblle(name = "Mary", treatment = "A")
)
