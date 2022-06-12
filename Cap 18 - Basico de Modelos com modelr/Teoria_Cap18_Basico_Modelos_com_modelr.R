############ INTRODUÇÃO
# O objetivo de um modelo é fornecer um resumo simples de baixa dimensão de um conjunto de dados.

# Há duas partes em um modelo:
# 1) Primeiro define uma família de modelos que expressa um padrão preciso, mas genérico, e que deseja
# capturar. Ex: O Padrão pode ser uma linha reta, ou uma curva quadrática. Expressará a família de 
# modelo como uma equeção.

# 2) Depois gera um modelo ajustado ao encontrar o modelo da família que seja mais próximo de seus
# dados. Isso pega a família genérica do modelo e a torna específica.

# É importante entender que um modelo ajustado é apenas o modelo mais próximo de uma família de 
# modelos.
# O objetivo de um modelo não é descobrir a verdade, mas descobrir uma aproximação simples que ainda
# seja útil.

########## PRÉ-REQUISITOS
# Nesse capítulo será usado o pacote modelr, que envolve as funções de modelagem do R base para fazê-lo
# naturalmente em um pipe.
library(tidyverse)

library(modelr)
options(na.action = na.warn)

##################### UM MODELO SIMPLES
# Dar uma olhada no conjunto de dados simulados sim1. Contém duas variáveis contínuas, x e y
# Construiremos um gráfico para verificar como estão relacionadas:
ggplot(sim1, aes(x,y)) +
  geom_point()

# Para esse caso simples, podemos usar geom_abline(), que recebe uma inclinação e uma interseção como 
# parâmetros. Mais tarde aprenderemos mais técnicas gerais que funcionam com qualquer modelo:
models <- tibble(
  a1 = runif(250, -20, 40),
  a2 = runif(250, -5, 5)
)

ggplot(sim1, aes(x, y))+
  geom_abline(
    aes(intercept = a1, slope = a2),
    data = models, alpha = 1/4
  ) + 
  geom_point()

# Uma maneira fácil de começar é encontrando a distância vertical entre cada ponto e o modelo.
# Essa distância é apenas a diferença entre o valor de y dado pelo modelo (a previsão) e o valor real
# de y nos dados (a resposta).

# Para calcular a distância, primeiro transformamos nossa família de modelos em uma função R. Recebe
# os parâmetros do modelo e os dados como entradas, e dá valores previstos pelo modelo como saída:
model1 <- function(a, data) {
  a[1] + data$x * a[2]
}
model1(c(7, 1, 5), sim1)

# Em seguida, precisamos de uma maneira de calcular a distância geral entre os valores previstos e 
# reiais. O gráfico mostra 30 distâncias como colapsar isso em um único número?

# Uma maneira comum de fazer isso em estatística é usar o "desvio da raiz do valor quadrático médio".
# Nós calculamos a diferença entre real e previsto,elevamos ao quadrado, tiramos sua média e, então 
# determinamos a raiz quadrada. Essa distância tem várias propriedades matemáticas atraentes.
measure_distance <- function(mod, data){
  diff <- data$y - model1(mod, data)
  sqrt (mean(diff ^ 2))
}
measure_distance(c(7, 1, 5), sim1)

# Agora podemos usar o purrr para calcular a distância para todos os modelos definidos anteriormente
# Precisamos de uma função auxiliar, já que nossa função de distância espera o modelo como um vetor
# numérico de comprimento 2:
sim1_dist <- function(a1, a2){
  measure_distance(c(a1, a2), sim1)
}

models <- models %>%
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))
models

# Em seguida vamos sobrepor os 10 melhores modelos sobre os dados. Colori os modelos com -dist: essa
# é a maneira mais eficaz de garantir que os melhores modelos(isto é, os que têm a menor distância),
# recebam as cores mais brilhantes:
# www.altabooks.com.br 
ggplot(sim1, aes(x, y)) +
  geom_point(size = 2, color = "grey30") +
  geom_abline(
    aes(intercept = a1, slope = a2, color = -dist),
    data = filter(models, rank(dist) <= 10)
  )

# Também podemos pensar sobre esses modelos como observações e visualizá-los com um diagrama de 
# dispersão de a1 versus a2, novamente colorido por -dist.Não será possível ver diretamente como o 
# modelo se compara aos dados, mas podemos ver muitos modelos ao mesmo tempo. Novamente, destaquei os
# 10 melhores modelos, desta vez desenhando círculos abaixo deles:
ggplot(models, aes(a1, a2))+
  geom_point(
    size = 4, color = "red"
  ) + 
  geom_point(aes(colour = -dist))

# Em vez de tentar vários modelos aleatórios, poderíamos ser mais sistemáticos e gerar uma grade 
# igualmente espaçada de pontos (isso é chamado de b)usca em grade).
grid <- expand.grid(
  a1 = seq(-5, 20, length = 25),
  a2 = seq(1, 3, length = 25)
) %>%
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

grid %>%
  ggplot(aes(a1, a2)) +
  geom_point(
    data = filter(grid, rank(dist) <= 10),
    size = 4, colour = "red"
  ) +
  geom_point(aes(color = -dist))

# Quando sobrepôe os 10 melhores modelos de volta sobre os dados originais, todos eles parecem muito
# bons.
ggplot(sim1, aes(x, y)) +
  geom_point(size = 2, color = "grey30") +
  geom_abline(
    aes(intercept = a1, slope = a2, color = -dist),
    data = filter(grid, rank(dist) <= 10)
  )

# Poderia imaginar tornar essa grade cada vez melhor interativamente até que tenha afunilado até o 
# melhor modelo. Há uma maneira mais adequada de atacar esse problema: com uma ferramenta de minimi-
# zação numérica chamada busca Newton-Raphson. A intuição de Newton-Raphson é bem simples: escolhe 
# um ponto inicial e procura pela inclinação mais íngreme. Então desce um pouco dessa inclinação e 
# repete a ação várias vezes, até o limite. Em R, podemos fazer isso com optim():
best <- optim(c(0, 0), measure_distance, data = sim1)
best$par

ggplot(sim1, aes(x, y)) +
  geom_point(size = 2, color="grey30") +
  geom_abline(intercept = best$par[1], slope = best$par[2])

# Então esse simples modelo é equivalente a um modelo linear geral onde n é 2 é x_1 é x. R tem uma 
# ferramenta especificamente projetada para ajustar modelos lineares chamada lm()
sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)

###################### VISUALIZANDO MODELOS 
# Aqui, no entanto, seguirá um caminho diferente. Focaremos em entender um modelo ao observar suas 
# previsõe. Isso tem uma grande vantagem: todo tipo de modelo preditivo faz previsões.

##################### PREVISÕES 
# Para visualizar as previsões de um modelo, começamos gerando uma grande igualmente espaçada  de 
# valores que cobrem a região onde nossos dados estão. A maneira mais fácil de fazer isso é usar
# modelr::data_grid().Seu primeiro argumento é um data frame, e para cada argumento subsequente ele 
# encontra variáveis únicas, e, então, gera todas as combinações:
grid <- sim1 %>%
  data_grid(x)
grid

# Em seguida adicionamos previsões. Usaremos modelr::add_predictions(), que recebe um data frame e 
# um modelo. Ela adiciona as previsões do modelo a uma nova coluna no data frame:
grid <- grid %>%
  add_predictions(sim1_mod)
grid

# Em seguida fazemos os gráficos das previsões. Pode ficar surpreso com todo esse trabalho extra 
# comparado a só usar_abline(). Mas a vantagem dessa abordagem é que ela funcionará com qualquer 
# modelo em R, do mais simples ao mais complexo.
ggplot(sim1, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(
    aes(y = pred),
    data = grid, 
    colour = "red",
    size = 1
  )

################# RESIDUOS
# O outro lado das previsões os resíduos.As previsões lhe dizem o padrão que o modelo capturou, e os 
# resíduos lhe dizem o que o modelo perdeu. Os resíduos são apenas as distâncias entre os valores
# observados e previstos que calculamos antes.

# Adicionamos resíduos aos dados com add_residuals(), que funciona como add_predictions(). Note, no
# entanto, que usamos o conjunto de dados original, não a grade manufaturada. Isso porque para 
# calcular resíduos precisamos dos valores reais de y:
sim1 <- sim1 %>%
  add_residuals(sim1_mod)
sim1

# Há algumas maneiras diferentes de entender o que os resíduos nos contam sobre o modelo, Uma delas
# é simplesmente desenhar um polígono de frequencia para nos ajudar a compreender a dispersão dos 
# resíduos:
ggplot(sim1, aes(resid)) + 
  geom_freqpoly(binwidth = 0.5)

# Isso lhe ajuda a calibrar a qualidade do modelo: quão distantes etão as previsões com relação aos 
# valores observados? Note que a média dos resíduos será sempre 0.
ggplot(sim1, aes(x, resid)) + 
  geom_ref_line(h = 0) +
  geom_point()

################## FORMULAS E FAMILIAS DE MODELOS
# Em R, as foŕmulas fornecem uma maneira geral de obter "comportamento especial". Em vez de avaliar
# logo os valores das variáveis, elas os capturam para que possam ser interpretados pela função.

# Se desejar ver o que o R realmente faz, use a função model_matrix(). Ela recebe um data frame e uma
# fórmula e retorna um tibble que define a equação modelo:
df <- tribble(
  ~y, ~x1, ~x2,
  4, 2, 5,
  5, 1, 6
)
model_matrix(df, y ~ x1)

# A maioria pelo qual o R adiciona inerseção (intercept) ao modelo é simplesmente tendo uma coluna
# cheia de uns. Por padrão, o R sempre adicionará essa coluna. Se você não quer isso, precisa
# explicitar, para que ela seja deixada de lado com -1:
model_matrix(df, y ~ x1 - 1)

# A matriz do modelo aumenta de maneira nada surpreendente quando adicionamos mais variáveis ao modelo
model_matrix(df, y ~ x1 + x2)

############## VARIÁVEIS CATEGÓRICAS
# Gerar uma função a partir de uma fórmula é algo bem direto quando o previsor é contínuo, mas as 
# coisas ficam um pouco mais complicadas quando o previsor é categórico.
df <- tribble(
  ~ sex, ~ response, 
  "male", 1,
  "female", 2,
  "male", 1
)
model_matrix(df, response ~ sex)

# Se você focar em visualizar previsões, não precisará se preocupar com a parametrização exata.
# Vamos observar alguns dados e modelos para concretizar o assuneto. Aqui está o conjunto de dados
# sim2 de modelr:
ggplot(sim2) +
  geom_point(aes(x, y))

# Podemos ajustar nele um modelo e gerar previsões:
mod2 <- lm(y ~ x, data = sim2)
grid <- sim2 %>%
  data_grid(x) %>% 
  add_predictions(mod2)
grid

# Efetivamente, um modelo com um x categórico irá prever o valor médio para cada categoria. (Por quê? 
# Porque a média minimiza a distância da raiz quadrática média)
# Podemos ver claramente se sobrepusermos as previsões sobre os dados originais:
ggplot(sim2, aes(x)) +
  geom_point(aes(y = y)) +
  geom_point(
    data = grid,
    aes(y = pred),
    color = "red",
    size = 4
  )

# Não pode fazer previsões sobre níveis que não observou. Áz vezes fará isso por acidente, então é
# bom reconhecer esta mensagem de erro:
tribble(x = "e") %>%
  add_predictions(mod2)

################## ITERAÇÕES (CONTÍNUA E CATEGÓRICA)
# O que acontece quando você combina uma variável contínua e uma categórica? O sim3 contém um previsor
# categórico e um previsor contínuo. Podemos visualizá-lo com um gráfico simples:
ggplot(sim3, aes(x1, y)) +
  geom_point(aes(color = x2))

# Há dois modelos possíveis de encaixar nesses dados:
mod1 <- lm(y ~ x1 + x2, data = sim3)
mod2 <- lm(y ~ x1 * x2, data = sim3)

# Quando adiciona variáveis com +, o modelo estimará cada efeito independentemente de todos os outros
# É possivel ajustar a chamada interação usando *. Por exemplo, y ~ x1 * x2 é traduzida para 
# y = a_0 + a_1 * a1 + a_2 + a_12 * a1 * a2. Note que sempre que usa *, ambos, a interação e os 
# componentes indiciduais, são incluídos no modelo:
grid <- sim3 %>%
  data_grid(x1, x2) %>%
  gather_predictions(mod1, mod2)
grid

# Podemos visualizar os resultados de ambos os modelos em um gráfico usando facetas:
ggplot(sim3, aes(x1, y, color = x2)) +
  geom_point() +
  geom_line(data = grid, aes(y = pred)) +
  facet_wrap(~ model)

# Note que o modelo que usa + tem a mesma inclinação para cada linha, mas interseções diferentes.
# O modelo que usa * tem um declive e uma interseção diferente para cada linha.

# Qual modelo é melhor para esses dados? Podemos observar os resíduos. Aqui fiz facetas de ambos os 
# modelos e x2, pois isso facilita a visualização do padrão dentro de cada grupo:
sim3 <- sim3 %>%
  gather_residuals(mod1, mod2)

ggplot(sim3, aes(x1, resid, color = x2))+
  geom_point() +
  facet_grid(model ~ x2)

# Há um padrão pouco óbvio nos resíduos de mod2. Os resíduos de mod1 mostram que o modelo perdeu 
# claramente algum padrão em b, e um pouco menos, mas ainda presente, está o padrão em c e d. 

#####################INTERAÇÕES (DUAS CONTÍNUAS)
# Vamos dar uma olhada no modelo equivalente para duas variáveis contínuas. Inicialmente as coisas
# procedem quase idênticas ao exemplo anterior:
mod1 <- lm(y ~ x1 + x2, data = sim4)
mod2 <- lm(y ~ x1 * x2, data = sim4)

grid <- sim4 %>%
  data_grid(
    x1 = seq_range(x1, 5),
    x2 = seq_range(x2, 5)
  ) %>%
  gather_predictions(mod1, mod2)
grid

# Note a aplicação seq_range() dentro de data_grid(). Em vez de utilizar cada valor único de x,
# foi usado uma grade regularmente espaçada de cinco valores entre os números mínimo e máximo.

# pretty = TRUE => gerará uma sequencia "bonita", isto é, algo que pareça bonito aos olhos humanos
# será bonito se quiser produzir tabelas de saída:
seq_range(c(0.0123, 0.923423), n = 5)
seq_range(c(0.0123, 0.923423), n = 5, pretty = TRUE)

# trim = 0.1 => vai aparar 10% dos valores da cauda. Terá utilidade se a variável tiver uma 
# distribuição de cauda longa e quiser focar focar em gerar valores próximos do centro:
x1 <- rcauchy(100)

seq_range(x1, n = 5)
seq_range(x1, n = 5, trim = 0.10)
seq_range(x1, n = 5, trim = 0.25)
seq_range(x1, n = 5, trim = 0.50)

# expand = 0.1 => é de certa forma, o oposto de trim(), ele expande a faixa em 10%:
x2 <- c(0, 1)

seq_range(x2, n = 5)
seq_range(x2, n = 5, expand = 0.10)
seq_range(x2, n = 5, expand = 0.25)
seq_range(x2, n = 5, expand = 0.50)

# Em seqguida vamos tentar visualizar esse modelo. Temos dois provisores continuos, sendo assim, é 
# possível imaginar o modelo como uma superficie 3D. Poderiamos exbir usando geom_tile():
ggplot(grid, aes(x1, x2)) +
  geom_tile(aes(fill = pred)) +
  facet_wrap(~ model)

# Isso não sugere que os modelos são muito diferentes! Mas é parcialmente uma ilusão. Em vez de olhar
# a superficie de cima, poderiamos olhá-la de qualquer um dos lados, exibindo várias fatias:
ggplot(grid, aes(x1, pred, color = x2, group = x2)) + 
  geom_line() + 
  facet_wrap(~ model)
ggplot(grid, aes(x2, pred, color = x1, group = x1)) + 
  geom_line() +
  facet_wrap(~ model)

# Isso mostra que a interação entre duas variáveis contínuas funciona basicamente da mesma maneira
# que para uma variável categórica e para uma contínua.

#################TRANSFORMAÇÕES
# Também pode realizar transformações dentro da fórmula do modelo. Por exemplo, log(y) ~ sqrt(x1) + x2
# é transformada em y = a_1 + a_2 * x1 * sqrt(x) + a_3 * x2. Se a transformação envolve +, *, ^ ou ~. 
# Precisará envolvê-la com I() para que o R não a trate como parte da especificação do modelo.

# Caso se confunda com o que o seu modelo está fazendo, pode sempre usar model_matrix() para ver 
# exatamente qual equação lm() está ajustando:
df <- tribble(
  ~y, ~x,
  1,  1,
  2,  2,
  3,  3
)
model_matrix(df, y ~ x^2 + x)

model_matrix(df, y ~ I(x^2) + x)

# Transformação são úteis, porque você pode usá-la para aproximar funções não lineares.Isso significa 
# que poderá usar uma função linear para chegar arbitrariamente próximo de uma função suave 
# encaixando uma equação como y = a_1 + a_2 * x + a_3 * x ^ 2 + a_4 * x_3. Digitar esse sequencia à 
# mão é entediante, então o R, fornece uma função auxiliar, poly():
model_matrix(df, y ~ poly(x, 2))

# Contudo, há um grande problema no uso de poly(): fora da faixa dos dados, os polínômios disparam 
# rapidamente para o infinito positivo ou negativo. A alternativa mais segura é usar o spline
# natural, splines::ns():
library(splines)
model_matrix(df, y ~ ns(x, 2))

# Vejamos como isso fica quando tentamos nos aproximar de uma função não linear:
sim5 <- tibble(
  x = seq(0,3.5 * pi,length = 50),
  y = 4 * sin(x) + rnorm(length(x))
)

ggplot(sim5, aes(x, y))+
  geom_point()

# Vou austar cinco modelos nestes dados:
mod1 <- lm(y ~ ns(x, 1), data = sim5)
mod2 <- lm(y ~ ns(x, 2), data = sim5)
mod3 <- lm(y ~ ns(x, 3), data = sim5)
mod4 <- lm(y ~ ns(x, 4), data = sim5)
mod5 <- lm(y ~ ns(x, 5), data = sim5)

grid <- sim5 %>%
  data_grid(x = seq_range(x, n = 50, expand = 0.1)) %>%
  gather_predictions(mod1, mod2, mod3, mod4, mod5, .pred = "y")

ggplot(sim5, aes(x, y)) +
  geom_point() +
  geom_line(data = grid, color = "red") +
  facet_wrap(~ model)

# Note que a extrapolação fora da faixa dos dados é claramente ruim. Essa é a desvantagem de aproximar
# uma função com um polinômio. Mas é um problema muito real com todos os modelos: o modelo nunca pode
# lhe dizer se o comportamento é verdadeiro quando você começa a extrapolar fora da faixa dos dados 
# determinada. Deve-se apoiar na teoria e na ciência.

#################### VALORES FALTANTES
# Valores faltantes obviamente não podem transmitir qualque informação sobre o relacionamento entre 
# as variáveis, então as funções de modelagem deixarão de lado qualquer linha que contenha valores
# faltantes. O comportamento padrão do R é deixá-las de lado discretamente, mas
# options(na.action = na.warm)(executado nos pré-requisitos) garante que receba uma aviso:
df <- tribble(
  ~x, ~y,
  1,  2.2,
  2,  NA,
  3,  3.5,
  4,  8.3,
  NA, 10
)

mod <- lm(y ~ x, data = df)

# Para suprimir o aviso, configure na.action = na.exclude:
mod <- lm(y ~ x, data = df, na.action = na.exclude)

# Pode ver sempre exatamente quantas observações foram usadas com nobs():
nobs(mod)
