############ INTRODUÇÃO
# Este capítulo mostra como trabalhar com datas e horas no R.


########## PRÉ-REQUISITOS
# Este capítulo focará no pacote lubridate, que facilita o trabalho com 
# datas e horas em R. O lubridate não faz parte do núcleo do tidyverse
# porque você só precisa dele quando trabalha com data/horas. Também 
# precisaremos do nycflights13 para dados de prática

library(tidyverse)

library(lubridate)
library(nycflights13)

##### CRIANDO DATA/HORAS
# Há três tipos de dados de data/hora que se referem a um instante no 
# tempo:
# * Uma data => Tibbles a imprimem como <date>
# * Uma hora dentro de um dia => Tibbles a imprimem como <time>
# * Uma data-hora => É uma data mais uma hora: Identifica unicamente um
# instante no tempo. Tibbles a imprimem como <dttm>.

# Aqui focaremos apenas em datas e datas-horas, já que o R não tem uma 
# classe nativa para armazenas horas. Se precisar, pode utilizar o 
# pacote hms.

# Para obter a data ou a data-hora atual, pode usar o today() ou o now()

today()
now()

# Caso contrário, há três maneiras de criar uma data/hora:

# -> A partir de uma string
# -> A partir de componentes individuais de data-hora.
# -> A partir de um objeto data/hora existente.

##### A PARTIR DE UMA STRING
# Dados de data/hora normalmente vêm como strings. Pode-se usar as 
# funções auxiliares fornecidas por lubridate.Elaboram o formato 
# automáticamente, uma vez que tenha especificado a ordem do componente.

ymd("2022-04-28")

mdy("Abril 28st, 2022")
dmy("31-Jan-2020")

# Essas funções também recebem números sem aspas. Essa é a maneira mais
# concisa de criar um único objeto data/hora, como você pode precisar 
# ao filtrar dados de data/hora. A ymd() é curta e sem ambiguidade.
ymd(20220428)

# ymd() cria datas. Para criar uma data-hora, adicione um underscore e 
# um ou mais de "h", "m" e "s" ao nome da função analisadora:
ymd_hms("2022-04-28 23:17:00")
mdy_hms("04/28/2022 23:17:40")

# Também pode forçar a criação de uma data-hora a partir de uma data 
# fornecendo um fuso horário:
ymd(20220428, tz = "UTC")

######## A PARTIR DE COMPONENTES INDIVIDUAIS 
# Ás vezes terá componentes individuais de data-hora espalhados por 
# várias colunas em vez de uma única string. 
# Justamente o que temos nos dados de voo:
flights %>%
  select(year, month, day, hour, minute)

# Para criar uma data/hora a partir desse tipo de entrada, use make_date()
# para datas ou make_datetime() para datas-horas:
flights %>%
  select(year, month, day, hour, minute) %>%
  mutate(
    departure = make_datetime(year, month, day, hour, minute)
  )

# Uma vez que tenha criado as variáveis de data-hora.
make_datetime_100 <- function(year, month,day,time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}
flights_dt <- flights %>%
  filter(!is.na(dep_time), !is.na(arr_time)) %>%
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(
      year, month, day, sched_dep_time
    ),
    sched_arr_time = make_datetime_100(
      year, month, day, sched_arr_time
    ) 
  ) %>%
select(origin, dest, ends_with("delay"), ends_with("time"))

flights_dt

# Com esses dados, podemos visualizar a distribuição de horas de
# decolagem por todo o ano:
flights_dt %>%
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 86400) # 86400 seconds = 1 day

# Ou em um único dia:
flights_dt %>%
  filter(dep_time < ymd(20130102)) %>%
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 600) # 600 = 10 minutos

# Note que quando usa data-horas em um contexto numérico (como em um 
# histograma), 1 significa e segundo,então binwidth de 86400 significa 
# 1 dia. Para datas, 1 significa 1 dia.

######## A PARTIR DE OUTROS TIPOS
# Caso queira mudar entre uma data-hora e uma data, opte por as_datetime()
# e as_date()
as_datetime(today())

as_date(now())

# Ás vezes obterá datas/horas como offsets numéricos de "Unix Epoch", 
# 1970-01-01, se o offset estiver em segundos, use as_datetime(); se 
# estiver em dias, use as_date():
as_datetime(60 * 60 * 10)
as_date(365 * 10 + 2)

###### COMPONENTES DE DATA-HORA
# Esta seção focará nas funções de acesso que permitem que você obtenha
# e configure componentes individuais.

##### OBTENDO COMPONENTES
# Pode puxar partes individuais da data com as funções de acesso year(), 
# month(), mday() (dia do mês), yday() (dia do ano), wday (dia da semana),
# hour(), minutes() e second().
datetime <- ymd_hms("2022-05-03 22:43:50")
year(datetime)
month(datetime)
mday(datetime)

yday(datetime)
wday(datetime)

# Para month() e wday() pode configurar label = TRUE para retornar o 
# nome abreviado do mês ou do dia da semana. Configure abbr = FALSE para
# retornar o nome completo:
month(datetime, label = TRUE)
wday(datetime, label = TRUE, abbr = FALSE)

# Pode usar o wday() para descobrir quais vooos decolam mais durante a 
# semana do que no final de semana:
flights_dt %>% 
  mutate(wday = wday(dep_time, label = TRUE)) %>%
  ggplot(aes(x = wday)) +
  geom_bar()

# Parece que os aviôes decolando nos minutos 20-30 e 50-60 têm atrasos
# muito mais baixo do que o restante da hora!
flights_dt %>%
  mutate(minute = minute(dep_time)) %>%
  group_by (minute) %>%
  summarize(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()) %>%
  ggplot(aes(minute, avg_delay)) +
  geom_line()

# Curiosamente, se olharmos o horário de decolagem agendado, não veremos
# um padrão tão forte:
sched_dep <- flights_dt %>%
  mutate(minute = minute(sched_dep_time)) %>%
  group_by(minute) %>%
  summarize(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )
ggplot(sched_dep, aes(minute, avg_delay)) +
  geom_line()

####### ARREDONDANDO
# Uma abrdagem alternativa para fazer gráficos de componentes individuais
# é arreendondar a data para uma unidade de tempo próxima, com floor_date()
# round_date() e celling_date(). Cada função celling_date recebe um vetor
# de datas para ajustar e, então, o nome da unidade para arrendondar para 
# baixo, para cima ou diretamente. Isso nos permite, por exemplo fazer um 
# gráfico do número de voos por semana:
flights_dt %>%
  count(week = floor_date(dep_time, "week")) %>%
  ggplot(aes(week, n)) +
  geom_line()

####### CONFIGRANDO COMPONENTES
# Pode usar cada função de acesso para configurar os componentes de uma 
# data/hora
(datetime <- ymd_hms("2016-07-08 12:34:56"))

year(datetime) <- 2020
datetime

month(datetime) <- 01
datetime

hour(datetime) <- hour(datetime) + 1
datetime

# Alternativamente, em vez de modificar no local, pode criar uma nova data
# hora com update(). Isso também permite que configure vários valores ao 
# mesmo tempo:
update(datetime, year = 2020, month = 2, mday = 2, hour = 2)

# Se os valores forem grandes demais, eles rolarão:
ymd("2015-02-01") %>%
  update(mday = 30)
ymd("2015-02-01") %>%
  update(hour = 400)

# Pode usar update() para mostrar a distribuição de voos pelo curso do dia
# em cada dia do ano:
flights_dt %>%
  mutate(dep_hour = update(dep_time, yday = 1)) %>%
  ggplot(aes(dep_hour)) +
  geom_freqpoly(binwidth = 300)

# Configurar componentes maiores de uma data como uma constante é uma 
# técnica poderosa que te permite explorar padrões nos componentes menores.

#########INTERVALOS
# A seguir aprenderá sobre como funciona a aritmética como datas, incluindo
# subtração, adição. Durante o caminho você aprenderá sobre três classes
# importantes que representam intervalos de tempo:

# * Durações => Que representam um número exato de segundos.
# * Períodos => Que representam unidades humanas como semanas e meses.
# * Intervalos => Que representam um ponto de ínicio e fim.

######## DURAÇÕES
# No R, quando subtrai duas datas, obtém um objeto difftime:

# How old is Luciano ?
h_age <- today() - ymd(19710126)
h_age

# Um objeto de classe difftime registra o intervalo de tempo em segundos, 
# minutos, horas, dias ou semanas. Essa ambiguidade pode fazer com que os
# difftimes sejam duros de se trabalhar, então lubridate, fornece uma 
# alternativa que sempre usa segundos - a duração:
as.duration(h_age)

# Durações vêm com um monte de construtores convenientes:
dseconds(15)
dminutes(10)
dhours(c(12,24))
ddays(0:5)
dweeks(3)
dyears(1)

# Durações sempre registram o intervalo de tempo em segundos. Unidades 
# maiores são criadas pela conversão de minutos, horas, dias, semanas e 
# anos em segundos pela taxa padrão(60 segundos em um minuto, 60 minutos
# em uma hora, 24 horas em um dia, 7 dias em uma semana, 365 dias em um ano).

# Pode adicionar e multiplicar durações:
2 * dyears(1)

dyears(1) + dweeks(12) + dhours(15)

# Pode também adicionar e subtrair durações de dias:
tomorrow <- today() - ddays(1)
tomorrow

last_year <- today() - dyears(1)
last_year

# Contudo, com as durações representam um número exato de segundos, às vezes
# você pode obter um resultado inesperado:
one_pm <- ymd_hms(
  "2016-03-12 13:00:00",
  tz = "America/New_York"
)
one_pm
 
one_pm + ddays(1)

# Por que um dia depois das 13h em 12 de março é 14h em 13 de março? 
# Se observar a data, poderá notar que os fusos horários mudaram. Por causa
# do horário de verão, 12 de março tem só 23 horas, então, se adicionarmos 
# um dia inteiro de segundos, acabaremos em um horário diferente.

############ PERÍODOS
# Para resolver esse problema, lubridate fornece períodos. Períodos são 
# intervalos de tempo, mas não têm comprimento fixo em segundos. Em vez disso
# eles funcionam com tempos "humanos", como dias e meses. Isso permite que
# funcionem de modo mais intuitivo.
one_pm
one_pm + days(1)

# Como as durações, os períodos podem ser criados com um número de funções
# construtoras amigáveis:
seconds(15)
minutes(10)
hours(c(12, 24))
days(7)
months(1:6)
weeks(3)
years(1)

# Pode adicionar e multiplicar períodos:
10 * (months(6) + days(1))
days(50) + hours(25) + minutes(2)

# Adicionar as datas, Comparados com durações, períodos têm mais propensão
# de fazer o que você espera:

# a leap year
ymd("2016-01-01") + dyears(1)
ymd("2016-01-01") + years(1)


# Daylight Saving Time
one_pm + ddays(1)
one_pm + days(1)

# Vamos usar períodos para corrigir uma estranheza relacionada ás nossas
# datas de voo. Alguns aviôes parecem ter chegado em seu destino antes de 
# partirem da cidade de Nova York:
flights_dt %>%
  filter(arr_time < dep_time)

# Esses são voos noturnos. Usados as mesmas informações de datas tanto para 
# os horários de partida quanto para os de chegada, mas esses voos chegaram
# no dia seguinte. Podemos corrigir isso adicionando days(1) à hora de
# chegada de cada voo noturno.
flights_dt <- flights_dt %>%
  mutate(
    overnight = arr_time < dep_time,
    arr_time = arr_time + days(overnight * 1),
    sched_arr_time = sched_arr_time + days(overnight * 1)
  )or

# Agora todos os voos obedecem às leis da física:
flights_dt %>%
  filter(overnight, arr_time < dep_time)

########## INTERVALOS
# É óbvio o que dyears(1) / ddays(365) deve retornar: primeiro, porque 
# durações são sempre representadas por um número de segundos, porque a
# duração de um ano é definida como o valor de 365 dias em segundos.

# O que years(1) / days(1) deveria retornar? Se o ano era 2015, deve-se 
# retornar 365, mas se era 2016, deve retornar 366! Não há informação 
# suficiente para que lubridate dê uma única resposta clara. O que ele
# faz, então, é dar uma estimativa com um aviso.
years(1) / days(1)

# Se quer uma medida mais exata, precisará usar um intervalo. Um intervalo
# é a duração com um ponto inicial, para que você possa determinar 
# exatamente o comprimento que ele tem:
next_year <- today() + years(1)
(today() %--% next_year) / ddays(1)

# Para descobrir quantos períodos caem em um intervalo, use divisão de
# inteiros
(today() %--% next_year) %/% days(1)

################ FUSO HORÁRIO 
Sys.timezone()

# Veja a lista completa de todos os nomes de fusos horários com 
# OlsonNames():
length(OlsonNames())
head(OlsonNames())

# No R, os fusos horários são um atributo de data-hora que só controla a 
# impressão. Por exemplo, esses três objetos representam o mesmo instante no
# tempo:
(x1 <- ymd_hms("2015-06-01 12:00:00", tz = "America/New_York"))
(x2 <- ymd_hms("2015-06-01 18:00:00", tz = "Europe/Copenhagen"))
(x3 <- ymd_hms("2015-06-02 04:00:00", tz = "Pacific/Auckland"))

# Pode verificar que são a mesma coisa usando a subtracao
x1 - x2
x1 - x3

# Operações que combinam data-hora, como c(), frequentemente deixarão o 
# fuso horário de lado. Nesse caso, as datas-horas serão exibidas em seu 
# horário local:
x4 <- c(x1, x2, x3)
x4

# Pode alterar o fuso horário de duas maneiras:
# * Mantenha o instante no tempo igual e mude como ele é exibido. Use isso 
# quando o instante estiver correto, mas você quer uma exibição mais natural.
x4a <- with_tz(x4, tzone = "Australia/Lord_Howe")
x4a

# Isso também ilustra outro desafio de fusos horários: eles não são todos 
# offsets de horas inteiras!)

# Mude o instante subjacente no tempo. Use isso quando tiver um instante que 
# tenha sido rotulado com o fuso horário incorreto e você precisar corrigi-lo
x4b <- force_tz(x4, tzone = "Australia/Lord_Howe")
x4b
