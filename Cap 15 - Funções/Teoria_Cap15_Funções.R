############ INTRODUÇÃO
# Uma das melhores maneiras de ampliar seu alcance como cientista de dados é
# escrever funções, pois elas permitem que automatize tarefas comuns de maneira
# mais poderosa e abrangente do que apenas copiar e colar.


########## PRÉ-REQUISITOS
# O foco deste capítulo está em escrever funções em base R, sendo assim, não 
# precisa de nenhum pacote extra.

########### QUANDO VOCÊ DEVERIA ESCREVER UMA FUNÇÃO?
# Considere escrever uma função sempre que copiar e colar um bloco de código
# mais de duas vezes.

df <- tibble::tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# Para deixar as entradas mais claras, reescreva o código usando variáveis 
# temporárias com nomes gerais. Aqui, este código só requer um único vetor 
# numérico, então o chamaremos de x:
x <- df$a
(x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))

# Há certa duplicação neste código. Estamos calculando três vezes a variação
# dos dados, mas faz sentido fazer isso nesta etapa:
rng <- range(x, na.rm = TRUE)
(x - rng[1]) / (rng[2] - rng[1])

# Extrair cálculos intermediários de variáveis nomeadas é uma boa prática, 
# pois deixa mais claro o que o código está fazendo. Agora que simplifiquei o 
# código, e verifiquei que ainda funciona, posso transformá-lo em uma função:
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(c(0, 5, 10))

# Há três passos-chave para criar uma nova função:
# 1. Escolher um nome para a função. Aqui usei rescale01 porque essa função
#    recalcula um vetor para que fique entre 0 e 1.
# 2. Listar as entradas, ou argumentos, para a função dentro de function. Aqui
#    Temos apenas um argumento. Se tivéssemos mais, a chamada ficaria parecida
#    com function(x, y, z)
# 3. Colocar o código que desenvolveu no corpo da função, 
#    um bloco { que vem imediatamente após function(..)}

# Neste ponto, é aconselhável verificar sua função com algumas entradas 
# diferentes:
rescale01(c(-10, 0, 10))
rescale01(c(1, 2, 3, NA, 5))

# Outra vantagem das funções é que, se nossas exigências mudarem, só 
# precisaremos fazer a mudança em um local. Por exemplo, podemos descobrir que
# algumas de nossas variáveis incluem valores infinitos, e rescale01() falha:
x <- c(1:10, Inf)
rescale01(x)

# Como extraímos o código para uma função, só precisamos fazer a correção em
# um lugar:
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(x)

############# FUNÇÕES SÃO PARA HUMANOS E COMPUTADORES
# É importante lembrar que funções não são apenas para computadores, mas 
# também para humanos. 
# O nome de uma função é importante. Idealmente, ele deve ser curto, mas 
# evocar claramente o que a função faz. 

############ EXECUÇÃO CONDICIONAL
# Uma declaração if permite que você execute um código condicionalmente. Ela
# se parece com isso:
if(condicao) {
  # code executed when condition is TRUE
} else {
  # code executed when condition is FALSE
}

# Aqui está uma função simples que usa uma declaração if. O objetivo dessa
# função é retornar um vetor lógico descrevendo se o elemento de um vetor está
# ou não nomeado:

has_nome <- function(x) {
  nms <- names(x)
  if (is.null(nms)){
    rep(FALSE, length(x))
  } else {
    !is.na(nms) & nms != ""
  }
}

# Essa função se aproveita da regra padrão de retorno: uma função retorna o
# último valor que calculou. Aqui isso é um dos dois ramos da declaração if.

############## CONDIÇÕES
# A condition (condição) deve ser avaliada como TRUE ou FALSE. Se for um 
# vetor, receberá uma mensagem de aviso; se for um NA, obterá um erro. Fique
# atento a essas mensagens em seu próprio código:
if (c(TRUE, FALSE)){}
if (NA){}

# CUIDADO ao testar por igualdade. () == é vetorizado, o que significa que é
# fácil obter mais de uma saída. Verifique se o comprimento já é 1, colapse
# com all() ou any(), ou use o identical() não vetorizado.O identical() é 
# bem rígido: sempre retorna ou um único valor TRUE ou um único FALSE, e não 
# força tipos. Isso significa que precisa ter cuidado quando comparar
# inteiros e doubles.
identical(0L,0)

# Também precisa estar ciente dos números de ponto flutuante:
x <- sqrt(2)^2
x
x == 2
x - 2

# Em seu lugar, use dplyr::near() para comparações.
# Lembre-se X == NA não faz nada útil!

##################### MÚLTIPLAS CONDIÇÕES
# Pode encadear várias declarações if:
if (this){
  # do that
} else if {
  # do something else
} else {
  #
}

# Uma técnica útil é a função switch(). Ela permite avaliar o código 
# selecionado com base na posição ou no nome:

#function(x, y, op){
# switch(op, 
#   plus = x + y, 
#   minus = x - y, 
#   times = x * y, 
#   divide = x / y,
#   stop("Unknown op!")
# )
#}

# Outra função útil que pode muitas vezes eliminar cadeias grandes de declarações if é cut(). Ela é
# usada para dividir variáveis contínuas.

################## ESTILO DE CÓDIGO
# Tanto if quanto function devem(quase) sempre ser seguidas por ({}), e os conteúdos devem ser 
# identadas por dois espaços. Isso facilita a visualização da hierarquia em seu código ao ler 
# rapidamente a margem esquerda.

# Good
if (y < 0 && debug) {
  message("Y is negative")
}

if (y == 0) {
  log(x)
} else {
  y ^ x
}

# Bad
if (y < 0 && debug)
  message("Y is negative")

if (y == 0)
  log(x)
}
else {
  y ^ x
}

################## ARGUMENTOS DE FUNÇÕES
# Os argumentos para uma função normalmente caem em dois conjuntos amplos: um conjunto fornece os 
# dados sobre os quais calcular, e o outro fornece argumentos que controlam os detalhes do cálculo.

# * Em log(), os dados são x, e o detalhe é a base do logaritmo.
# * Em mean(), os dados são x, e os detalhes são quantos dados aparar das pontas(trim) e como lidar
#   com os valores faltantes (na.rm)
# * Em t.test(), os dados são x e y, e os detalhes do teste são alternative, mu, paired, var.equal e 
#   conf.level.
# * em str_c() pode fornecer qualquer número de strings para ..., e os detalhes da concatenação são
#   controlados por sep e collapse.

# Geralmente os argumentos de dados devem vir primeiro.Argumentos de detalhes vão no fim e normalmente
# devem ter valores padrão. Especifica o valor padrão da mesma maneira que chama uma função com um 
# argumento nomeado:

# Compute confidence interval around
# mean using normal approximation
mean_c <- function(x, conf = 0.95){
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2,1 - alpha / 2))
}

x <- runif(100)
mean_c(x)
mean_c(x, conf = 0.99)

# O valor padrão deve quase sempre ser o valor mais comum. As poucas exceções a essa regra têm a ver
# com segurança. Por exemplo, faz sentido que na.rm seja FALSE por padrão, porque valores faltantes 
# são importantes. Mesmo embora na.rm = TRUE seja o que você normalmente coloca em seu código, não é 
# aconselhável  ignorar silenciosamente os valores faltantes como padrão.

# Good
mean(1:10, na.rm = TRUE)

# Bad
mean(x = 1:10,, FALSE)
mean(, TRUE, x = c(1:10, NA))

# Pode se referir a um argumento por seu prefixo único (por exemplo, mean(x, n = TRUE)),mas é evitado,
# dadas as possibilidades de confusão.

# Usar espaço em branco facilita a leitura rápida dos componentes importantes da função:

# Good 
average <- mean(feet / 12 + inches, na.rm = TRUE)

# Bad
average <-mean(feet /12+inches, na.rm=TRUE)

######################## ESCOLHENDO NOMES
# Os nomes dos argumentos também são importantes.Deve optar por nomes  mais longos  e descritivos, mas
# há um punhado de nomes bem curtos  muito comuns
# * x, y, z => vetores
# * w => um vetor de pesos
# * df => um data frame
# * i, j => indices numéricos(normalmente linhas e colunas)
# * n => comprimento ou número de linhas
# * p => número de colunas

# Caso contrário, considere usar nomes de argumentos de funções existentes. Por exemplo, use na.rm 
# para determinar se valores faltantes devem ser removidos.

################ VERIFICANDO VALORES
# A medida que começa a escrever mais funções, chegará finalmente ao ponto em que não se lembra 
# exatamente de como sua função funciona. Para evitar esse problema, muitas vezes é útil explicitar as
# restrições. Por exemplo, imagine que tenha escrito algumas funções para calcular estatísticas 
# resumidas ponderadas:
wt_mean <- function(x, w) {
  sum(x * w) / sum(x)
}

wt_var <- function(x, w) {
  mu <- wt_mean(x, w)
  sum(w * (x - mu) ^ 2) / sum(w)
}

wt_sd <- function(x, w) {
  sqrt(wt_var(x, w))
}

# O que acontece se x e w não tiverem o mesmo cumprimento?
wt_mean(1:6, 1:3)

# Neste caso, por causa das regras de reciclagem de vetor de R, não obteremos um erro.

# É uma boa prática verificar pré-condições importantes e lançar um erro (com stop()), se não forem 
# verdadeiras:
wt_mean <- function(x, w) {
  if (length(x) != length(w)) {
    stop("`x' and 'w' must be the same length", call. = FALSE)
  }
  sum(w * x) / sum(x)
  
  # Um compromisso útil é o stopinfnot() incorporado; ele verifica se cada argumento é TRUE e produz 
  # uma mensagem de erro genérica se não forem:
  wt_mean <- function(x, w, na.rm = FALSE) {
    stopifnot(is.logical(na.rm), length(na.rm) == 1)
    stopifnot(length(x) == length(w))
     
    if (na.rm) {
      miss <- is.na(x) | is.na(w)
      x <- x[!miss]
      w <- w[!miss]
    }
    sum(w * x) / sum(x)
  }
  
  wt_mean(1:6, 6:1, na.rm = "foo")
}

# Note que ao usar stopifnot() garante o que deve ser verdadeiro, em de verificar o que poderia estar
# errado.

####################### RETICÊNCIAS
# Muitas funções em R recebem um número arbitrário de entradas:
sum(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
stringr::str_c("a", "b", "c", "d", "e", "f")

# Elas dependem de um argumento especial: ... (reticências). Esse argumento especial captura qualquer
# número de argumentos que não forem combinados de outra forma.

# É útil porque pode então enviar essas ... para outra função. Esse é um catch-all útil se sua função
# for primariamente um wrapper ao redor de outra função. Por exemplo, normalmente cria essas funções
# auxiliares que envolvem str_c():
commas <- function(...) stringr::str_c(..., collapse = ",")
commas(letters[1:10])

rule <- function(..., pad = "-"){
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, "", stringr::str_dup(pad, width), "\n", sep = "")
}
rule("Important Output")

# Aqui ... permite que encaminhe quaisquer argumentos com os quais não queira lidar com str_c(). É uma
# técnica muito conveniente. Mas tem um preço: quaisquer argumentos escritos levantarão um erro. Isso
# facilita que erros de digitação passem despercebidos.
x <- x(1, 2)
sum(x, na.rm = TRUE)

# Se quiser apenas capturar os valores de ..., use list(...)

####################### AVALIAÇÃO PREGUIÇOSA (LAZY EVALUATION)
# Argumentos em R são avaliados preguiçosamente: não são calculados até que sejam necessários. Isso 
# significa que se nunca forem usados, nunca erão chamados. Essa é uma propriedade importante de R
# como linguagem de programação, mas geralmente não é relevante quando está escrevendo suas próprias
# funções para análise de dados.

###################### RETORNO DE VALORES
# Descobrir o que sua função deve retornar normalmente é algo direto: em primeiro lugar, foi para isso
# que criou a função! Há duas coisas que deve considerar ao retornar um valor:

# * Retornar antes facilita a leitura da sua função?
# * Consegue deixar sua função passível de um pipe?

###################### DECLARAÇÕES EXPLÍCITAS DE RETORNO
# O valor retornado pela função normalmente é a última declaração que ela avalia,mas pode escolher
# retornar mais cedo usando o return().
complicated_function <- function(x, y, z) {
  if (length(x) == 0 || length(y) == 0) {
    return(0)
  }
}

# Outra razão é porque tem uma declaração if com um bloco complexo e um bloco simples. Por exemplo
# pode escrever uma declaração if assim:
f <- function() {
  if (x) {
    # Do
    # something
    # that
    # takes
    # many
    # lines 
    # to
    # express
  } else {
    # return something short
  }
}

# Mas se o bloco for muito longo, ao chegar no else, já terá esquecido da condition. Uma maneira de 
# reescrever isso é usar um retorno antecipado para o caso simples.

f <- function(){
  if (!x) {
    return(something_short)
  }
  
  # Do
  # something
  # That
  # Takes
  # Many
  # Lines
  # To
  # Express
  
  # Essa ação tende a facilitar o entendimento do código, visto que não é necessário tendo contexto
  # para entendê-lo.
  
  ####################### ESCREVENDO FUNÇÕES PASSÍVEIS DE PIPE
  # Em funções de transformação, há um objeto "primário", que é passado como um primeiro argumento, e 
  # uma versão modificada é retornada pela função. Por exemplo, os objetos-chave para dplyr e tidyr
  # são data frames. Se puder identificar qual é o tipo de objeto para seu domínio, descobrirá que 
  # suas funções operam com o pipe.
  
  # Funções de efeito colateral são primeiramente chamadas para realizar uma ação, como desenhar um 
  # gráfico ou salvar um arquivo, não transformar um objeto. Essas funções devem retornar o primeiro 
  # argumento, portanto não são exibidas por padrão, mas ainda podem ser usadas em um pipeline. Por 
  # exemplo, esta função simples imprime o número de valores faltantes em um data frame.
  show_missing <- function(df) {
    n <- sum(is.na(df))
    cat("Missing values", n, "\n", sep = "")
    invisible(df)
  }
  
  # Se a chamarmamos interativamente, a invisible() significa que a entrada df não é impressa:
  show_missing(mtcars)

  # Mas ainda está lá, só não é impressa por padrão:
  x <- show_missing(mtcars)

  class(x)
  dim(x)

  # E ainda podemos usá-la em um pipe:
  mtcars %>%
    show_missing() %>%
    mutate(mpg = ifelse(mpg < 20, NA, mpg)) %>%
    show_missing()

  ################# AMBIENTE
  # O ambiente de uma função controla como o R encontra o valor associado a um nome. Por exemplo, 
  # veja esta função:
  f <- function(x) {
    x + y
  }
  
  # Em muitas linguagens de programação, isso seria um erro, porque y não é definido dentro da função.
  # Em R, este é um código válido, pois R usa escopo lexical para encontrar o valor associado a um 
  # nome. Já que y não está definido dentro da função, R procurá no ambiente onde a função foi definida
  y <- 100
  f(10)

  y <- 1000
  f(10)
  