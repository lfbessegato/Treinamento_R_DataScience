### install.packages("dplyr")

library(nycflights13)
library(tidyverse)

#### nycflights13
flights

###### Visualizar todo o DataFrame
view(flights)

##### Funções do pacote dplyr
##### Filter()
filter(flights, month == 1, day == 1)

# Atribuir a uma variavel o resultado do filtro
jan1 <- filter(flights, month == 1, day == 1)

######## Comparações
######## near() para numeros flutuantes
near(sqrt(2) ^ 2, 2)

near(1 / 49 * 49, 1)

######### OPERADORES LÓGICOS
######### & => and, | => or, ! => not
nov_dec <- filter(flights, month == 11 | month == 12);nov_dec

# x %in% y
nov_dec1 <- filter(flights, month %in% c(11, 12)); nov_dec1


# voos nao atrasados em mais de duas horasa
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <=120)

##### VALORES FALTANTE 
NA > 5
10 == NA
NA + 10
NA / 2
NA == NA

# x é a idade de Maria, Nós não sabemos sua idade
x <- NA

# y é a idade de João, Nós não sabemos sua idade
y <- NA

# João e Maria tem a mesma idade?
x == y
# Nós não sabemos!
# 
# #### determinar se há um valor faltante, is.na()
is.na(x)
##### filter => só exibe a condição TRUE
df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)

filter(df, is.na(x) | x > 1)

###### ORDENAR Linhas com Arrange
### arrange => funciona similar ao Filter, com a diferença a mudança da ordem
### 

arrange(flights, year, month, day)

### desc() => reordenar por uma coluna descendente
arrange(flights, desc(arr_delay))

### Valores Faltantes sempre colocados no final
df <- tibble(x = c(5,2,NA))
arrange(df, x)

arrange(df, desc(x))

###### Selecionar colunas com select()
# seleciona colunas por nome
select(flights, year, month, day)

# seleciona todas as colunas entre ano e dia (com eles inclusos)
select(flights, year:day)

# seleciona todas as colunas, exceto aquelas de ano para dia (com eles inclusos)
select(flights, -(year:day))

# rename => renomear variaveis
rename(flights, tail_num = tailnum)

# select junto do auxiliar everything() => mover um punhado de variaveis 
# para o começo do dataframe
select(flights, time_hour, air_time, everything())

#### Adicionar Novas variaveis com mutate()
# mutate () => adiciona novas colunas ao final do conjunto de dados.
flights_sml <- select(flights,
    year:day,
    ends_with("delay"),
    distance, 
    air_time
)
mutate(flights_sml, 
  gain = air_delay - dep_delay,
  speed = distance / air_time * 60
)

view(flights_sml)
# transmute() => mantém apenas as novas variaveis
transmute(flights, 
    gain = arr_delay - dep_delay, 
    hours = air_time / 60,
    gain_per_hour = gain / hours
)
####### Resumos Agrupados com sumarize()
# summarize() => Reduz o dataframe em uma única linha
summarize(flights, delay = mean(dep_delay, na.rm = TRUE))

# group_by => utilizar o summarize, sem o group_by não terá sentido
by_day <- group_by(flights, year, month, day)
summarize(by_day, delay = mean(dep_delay, na.rm = TRUE))


# Combinando Várias Operações com o Pipe
by_dest <- group_by(flights, dest)
delay <- summarize(by_dest, 
                   count = n(), 
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE)
                   )
delay <- filter(delay, count > 20, dest != "HNL")

ggplot(data = delay, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)

# pipe %>%
delay <- flights %>%
  group_by(dest) %>%
  summarize(count = n(),
            dist = mean(distance, na.rm = TRUE), 
            delay = mean(arr_delay, na.rm = TRUE)
            )%>%
  filter(count > 20, dest != "HNL")

####### VALORES FALTANTES
# sem o argumento na.rm, apresenta vários valores faltantes
flights %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay))

# todas as funções de agregação têm um argumento na.rm que remove esses valores antes do cálculo

flights %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay, na.rm = TRUE))

not_cancelled <- flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay))

######### COUNTS
# Ex => observar avioes (identificados pelo número de cauda) que têm os maiores atrasos médios:

delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(
    delay = mean(arr_delay)
  )

ggplot(data = delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

# Obtendo mais insight se desenharmos um diagrama de dispersao do numero de voos versus atraso medio
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize (
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )
ggplot(data = delays, mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

# importante sempre filtrar oa grupos com os menores numeros de observacoes
delays %>%
  filter (n > 25) %>%
  ggplot(mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

############ PACOTE LAHMAN 
# Calcular a média de rebatidas (numero de acertos / numero de tentativas)

# Converta para um tibble para que seja bem impresso
# install.packages(Lahman)
library(Lahman)
batting <- as_tibble(Lahman::Batting)

batters <- batting %>%
  group_by(playerID) %>%
  summarize(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

batters %>%
  filter(ab > 100) %>%
  ggplot(mapping = aes(x = ab, y = ba))+
  geom_point() + 
  geom_smooth(se = FALSE)

# Pessoas com melhores médias de rabatidas serão sortudas

batters %>%
  arrange(desc(ba))

##### FUNÇÕES ÚTEIS DE RESUMOS

# Medidas de Localização => mean(x), ou median(x)
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    
    # average delay:
    avg_delay1 = mean(arr_delay),
    
    # average positive delay:
    avg_delay2 = mean(arr_delay[arr_delay > 0])
  )
# Medidas de Dispersão => sd (x), IQR(x), mad(x)
# sd = desvio Padrão
# IQR = Variação Interquartil
# mad = Desvio Padrão absoluto mediano

# Por que a distância para alguns destinos é mais variável
# do que outras?
not_cancelled %>%
  group_by(dest) %>%
  summarize(distance_sd = sd(distance)) %>%
  arrange(desc(distance_sd))

# Medidas de classificação => min(x),quantile(x,0.25), max(x)
# Quantis são uma generalização da mediana
# Por exemplo quantile(x, 0.25) achará uma valor de x que é maior
# do que 25% dos valores e menor do que os 75% restante
# 
# Quando o primeiro e o ultimo voos partiram a cada dia?
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    flrst = min(dep_time),
    last = max(dep_time)
  )

# Medidas de posição first(x), nth(x, 2), last(x)
# Funcionam de modo similar a x[1], x[2] e x[length(x)]
# mas permitem estabelecer um valor padrão se essa posição não existir
# 
# Encontrar o primeiro e o ultimo embraque em cada dia
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    first_dep = first(dep_time),
    last_dep = last(dep_time)
  )

# Essas funções são completamentares à filtragem de classificação.
# Filtrar lhe dá todas as variáveis, com cada observação em uma linha
# separada
# 
not_cancelled %>%
  group_by(year, month, day) %>%
  mutate(r = min_rank(desc(dep_time))) %>%
  filter(r %in% range(r))

# Contagem 
# n() => Tamanho do grupo atual
# Valores não faltantes => sum(!is.na(x))
# Valores Distintos (únicos) => n_distinct(x)
# 
# Quais distinos tem mais transportadoras
not_cancelled %>%
  group_by(dest) %>%
  summarize(carriers = n_distinct(carrier)) %>%
  arrange(desc(carriers))

# Contagens são tão uteis, que o dplyr fornece uma função auxiliar
# simples se tudo o que você quiser for uma contagem
# 
not_cancelled %>%
  count(dest)

# opcionalmente, pode fornecer uma variavel de peso. 
# 
# Usar a função contar (somar) o numero total de milhas que um 
# aviao fez
#
not_cancelled %>%
  count(tailnum, wt=distance)

# Contagens e proporções lógicos sum(x > 10), mean(y == 8)
# 
# Quantos voos partiram antes das 5H? (esses normalmente)
# indicam voos atrasados do dia anterior)
# 
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(n_early = sum(dep_time < 500))

# Qual proporcao de voos estao atrasados em mais 
# de uma hora?
# 
not_cancelled %>%
  group_by(day, month, year) %>%
  summarize(hour_per = mean(arr_delay > 60))

####### Agrupando por Múltiplas Variáveis
# Quando você agrupa por múltiplas variáveis, cada resumo descola
# um nível do agrupamento. Isso facilita fazer progressivamente o roll up
# de um conjunto de dados
# 
daily <- group_by(flights, day, month, year)

(per_day <- summarize(daily, flights = n()))
(per_mounth <- summarize(per_day, flights = sum(flights)))
(per_year <- summarize(per_mounth, flights = sum(flights)))

##### Desagrupando
# Se você precisar remover o agrupamento e voltar às operações nos
# dados desagrupados, use ungroup()
daily %>%
  ungroup() %>%  # no longer grouped by date
  summarize(flights = n()) # all flights

####### Mudanças Agrupadas (e Filtros)
# Agrupar é mais vantajoso em conjunção com summarize(), mas você também pode fazer operações convenientes com mutate() e filter ()
# 
# Encontre os piores membros de cada grupo:
flights_sml %>%
  group_by(day, month, year) %>%
  filter(rank(desc(arr_delay)) < 10)

# Encontre todos os grupos maiores do que um limiar
popular_dests <- flights %>%
  group_by(dest) %>%
  filter(n() > 365)
popular_dests

# Padronize para calcular métricas de grupo

popular_dests %>%
  filter(arr_delay > 0) %>%
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>%
  select(year:day, dest, arr_delay, prop_delay)