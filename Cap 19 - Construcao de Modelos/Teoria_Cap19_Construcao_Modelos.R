############ INTRODUÇÃO
# Nesse capítulo focará em dados reais, mostrando como pode construir progressivamente um modelo que 
# auxilie na compreensão dos dados.


########## PRÉ-REQUISITOS
# Será usado as mesmas ferramentas dos capítulos anteriores, porém será adicionado alguns conj unto de 
# dados reais: diamonds de ggplot2 e flights de nycflights13. Também precisaremos de lubridate para 
# trabalhar com datas/horas em flights.
library(tidyverse)
library(modelr)
options(na.action = na.warm)

library(nycflights13)
library(lubridate)

############## POR QUE DIAMANTES DE BAIXA QUALIDADE SÃO MAIS CAROS
# Nos capítulos anteriores vimos um relacionamento surpreendente entre a qualidade dos diamantes e seu 
# preço: diamantes de baixa qualidade(cortes e cores ruins e clareza inferior)têm preços mais altos:

ggplot(diamonds, aes(cut, price)) + geom_boxplot()
ggplot(diamonds, aes(color, price)) + geom_boxplot()
ggplot(diamonds, aes(clarity, price)) + geom_boxplot()

# Note que a pior cor de diamante é J (levemente amarelo), e a pior clareza é I1 (inclusões visíveis a
# olho nu).


############# PREÇO E QUILATES
# Parece que diamantes de menor qualidade têm preços mais altos porque há uma variável de confusão
# importante: o peso (carat). O peso do diamante é o único fator mais importante para determinar seu
# preço, e diamantes de baixa qualidade tendem a ser maiores:
ggplot(diamonds, aes(carat, price)) +
  geom_hex(bins = 50)

# Podemos facilitar a visualização de como outros atributos de um diamante afetam seu preço (price)
# relativo ajustando um modelo para separar o efeito de carat. Mas primeiro vamos fazer alguns ajustes
# no conjunto de dados dos diamantes para simplificar o trabalho com eles:

# Focar em diamantes menores que 2,5 quilates (99,7% dos dados).
# Transformar em logaritmo as vriáveis carat e price:
diamonds2 <- diamonds %>%
  filter(carat <= 2.5) %>%
  mutate(lprice = log2(price), lcarat = log2(carat))

# Juntas, essas mudanças facilitam a visualização da relação entre carat  price:
ggplot(diamonds2, aes(lcarat, lprice)) +
  geom_hex(bins = 50)

# A transformação logarítmica é particularmente útil aqui porque torna o padrão linear, e padrões 
# lineares são os mais fáceis de trabalhar. Vamos dar o próximo passo e remover esse padrão linear 
# forte. Primeiro tornamos o padrão explícito ajustando um modelo:
mod_diamond <- lm(lprice ~ lcarat, data = diamonds2)

# Depois observamos o que o modelo nos fala sobre os dados. Note que foi transformado de volta as 
# previsões, desfazendo a transformação em logaritmo, para que possa sobrepor as previsões sobre os 
# dados brutos:
grid <- diamonds2 %>%
  data_grid(carat = seq_range(carat, 20)) %>%
  mutate(lcarat = log2(carat)) %>%
  add_predictions(mod_diamond, "lprice") %>%
  mutate(price = 2 ^ lprice)

ggplot(diamonds2, aes(carat, price)) +
  geom_hex(bins = 50) +
  geom_line(data = grid, color="red", size = 1)

# Isso nos diz algo interessante sobre nossos dados. Se acreditamos no nosso modelo, então os diamantes
# são muito mais baratos do que o esperado. Provavelmente porque nenhum diamante nesse conjunto de 
# dados custa mais de US$19.000

# Agora podemos observar os resíduos, que confirmam que removemos com sucesso o forte padrão linear:
diamonds2 <- diamonds2 %>%
  add_residuals(mod_diamond, "lresid")

ggplot(diamonds2, aes(lcarat, lresid)) +
  geom_hex(bins = 50)

# Importante, neste momento podemos refazer nossos gráficos motivadores usando aqueles resíduos, em 
# vez de price:

ggplot(diamonds2, aes(cut, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(color, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(clarity, lresid)) + geom_boxplot()

# Agora vemos o relacionamento que esperamos: à medida que a qualidade dos diamantes aumenta, o mesmo 
# ocorre com seu preço relativo.

################### UM MODELO MAIS COMPLICADO
# Se quiséssemos, poderíamos continuar a construir nosso modelo, movendo os efeitos que observamos 
# para o modelo e tornando-os explícitos. Por exemplo, poderíamos incluir color, cut e clarity no 
# modelo para que também tornássemos explícitos os efeitos dessas três varáveis categóricas:
mod_diamond2 <- lm(
  lprice ~ lcarat + color + cut + clarity,
  data = diamonds2
)

# Este modelo agora inclui quatro previsores, então está ficando difícil de visualizar. Felizmente, 
# todos eles são atualmente independentes, o que significa que podemos fazer quatro gráficos 
# individuais. Para facilitar um pouco o processo, usaremos o argumento .model para data_grid:
grid <- diamonds2 %>%
  data_grid(cut, .model = mod_diamond2) %>%
  add_predictions(mod_diamond2)

grid

ggplot(grid, aes(cut, pred)) +
  geom_point()

# Se o modelo precisa de variáveis que não tenha fornecido explicitamente, data_grid() as preencherá
# automaticamente com o valor "típico". Para variáveis contínuas, ela usa as mediana, e para as 
# categóricas, ela usa o valor mais comum (ou valores, se for um empate):
diamonds2 <- diamonds2 %>%
  add_residuals(mod_diamond2, "lresid2")

ggplot(diamonds2, aes(lcarat, lresid2)) +
  geom_hex(bins = 50)

# Esse gráfico indica que há alguns diamantes com resíduos bem grandes - lembre-se de que um resíduo
# de 2 indica que o diamante é 4x o preço que esperamos. Muitas vezes é útil observar valores 
# incomuns individualmente:
diamonds2 %>%
  filter(abs(lresid2) > 1) %>%
  add_predictions(mod_diamond2) %>%
  mutate(pred = round(2 ^ pred)) %>%
  select(price, pred, carat:table, x:z) %>%
  arrange(price)

################### O QUE AFETA O NÚMERO DE VOOS DIÁRIOS
# Vamos trabalhar em um processo similar para um conjunto de dados que parece ainda mais simples à 
# primeira vista: o número de voos que sai de NYC por dia. Esse é um conjunto de dados realmente 
# pequeno - apenas 365 linhas e 2 colunas -, e não acabaremos com um modelo completamente feito, mas,
# como verá, os passos nos ajudarão a entender melhor os dados. Começaremos contando o número de voos
# por dia e visualizando-os com ggplot2
daily <- flights %>%
  mutate(date = make_date(year, month, day)) %>%
  group_by(date) %>%
  summarize(n = n())
daily

ggplot(daily, aes(date, n)) +
  geom_line()

################### DIA DA SEMANA
# Entender a tendência de longo prazo é desafiador, pois há um efeito dia da semana muito forte que
# domina os padrões mais sutis. Iniciaremos observando a distribuição de números de voos por dia da
# semana:
daily <- daily %>%
  mutate(wday = wday(date, label = TRUE))

ggplot(daily, aes(wday, n)) +
  geom_boxplot()

# Há menos voos nos finais de semana porque a maioria das viagens é a negócio. O efeito é particular-
# mente no sábado: ás vezes pode viajar no domingo para uma reunião na segunda-feira de manhã, mas é
# muito raro que viage no sábado, pois preferiria estar em casa com a família.

# Uma maneira de remover esse padrão forte é usar um modelo. Primeiro ajustamos o modelo e exibimos 
# suas previsões sobrepostas aos dados originais:
mod <- lm(n ~ wday, data = daily)

grid <- daily %>%
  data_grid(wday) %>%
  add_predictions(mod, "n")

ggplot(daily, aes(wday, n)) +
  geom_boxplot() +
  geom_point(data = grid, color = "red", size = 4)

# Em seguida calculamos e visualizamos os resíduos:
daily <- daily %>%
  add_residuals(mod)
daily %>%
  ggplot(aes(date, resid)) +
  geom_ref_line(h = 0) +
  geom_line()

# Note a mudança no eixo y: agora estamos vendo o desvio do número esperado de voos, dado o dia da 
# semana. Esse gráfico é útil porque, agora que removemos boa parte do efeito dia da semana, podemos 
# ver alguns padrões mais sutis que restaram:

# * Nosso modelo parece falhar no começo de junho: ainda é possível ver um padrão regular forte que 
# nosso não capturou. Fazer um gráfico com uma linha para cada dia da semana facilita a visualização
# da causa:
ggplot(daily, aes(date, resid, color = wday)) +
  geom_ref_line(h = 0) +
  geom_line()

# Nosso modelo falha em prever precisamente o número de voos no sábado: durante o verão há mais voos
# do que o esperado, e durante o outono há menos. Na próxima seção veremos como podemos capturar 
# melhor esse padrão.

# Há alguns dias com muito menos voos do que esperado:
daily %>%
  filter(resid < 100)

# Parece haver uma tendência de longo prazo mais suae no curso de um ano.
# Podemos destacar essa tendência com geom_smooth():

daily %>%
  ggplot(aes(date, resid)) +
  geom_ref_line(h = 0) +
  geom_line(color = "grey50") +
  geom_smooth(se = FALSE, span = 0.20)

# Há menos voos em janeiro (e dezembro) e mais entre maio e setembro (verão nos Estados Unidos). Não
# podemos fazer muito com esse padrão quantitativamente, porque só temos um único ano de dados. Mas 
# podemos usar nosso conhecimento de domínio para pensar em possíveis explicações.

################### EFEITO DE SÁBADO SAZONAL
# Vamos primeiro atacar nossa falha para prever precisamente o número de voos no sábado. Um bom jeito
# de começar é voltar aos números brutos, focando nos sábados:

daily %>%
  filter(wday == "sáb") %>%
  ggplot(aes(date, n)) +
    geom_point() +
    geom_line() + 
  scale_x_date(
    NULL,
    date_breaks = "1 month",
    date_labels = "%b"
  )

# (Usado pontos e linhas para deixar mais claro o que são os dados e o que é a interpolação)

# Suspeito que esse padrão é causado pelas férias de verão: muitas pessoas viajam nessa época, 
# inclusive aos sábados Observando esse gráfico podemos supor que as férias de verão  vão do início de
# junho até o final de agosto.

# Vamos criar uma variável "term" (período) que capture aproximadamente os três períodos escolares e 
# vamos conferir nosso trabalho com um gráfico:
term <- function(date) {
  cut(date, 
      breaks = ymd(20130101, 20130605, 20130825, 20140101), 
      labels = c("Primavera", "Verão", "Falhou")
      )
}

daily <- daily %>%
  mutate(term = term(date))

daily %>%
  filter(wday == "sáb") %>%
  ggplot(aes(date, n, color = term)) +
  geom_point(alpha = 1/3) +
  geom_line() +
  scale_x_date(
    NULL, 
    date_breaks = "1 month", 
    date_labels = "%b"
  )

# Ajustado manualmente as datas para obter bons intervalos no gráfico. Usar uma visualização para
# ajudá-lo a entender o que sua função está fazendo é uma técnica muito comum e poderosa.
# É util ver como essa nova variável afeta os outros dias da semana.
daily %>%
  ggplot(aes(wday,n,color = term)) +
  geom_boxplot()

# Parece que há uma variação significativa entre os períodos (terms), então é razoável encaixar um
# efeito dia da semana separado para cada período. Assim melhoramos nosso modelo, mas não tanto 
# quanto esperaríamos:
mod1 <- lm(n ~ wday, data = daily)
mod2 <- lm(n ~ wday * term, data = daily)

daily %>%
  gather_residuals(without_term = mod1, with_term = mod2) %>%
  ggplot(aes(date, resid, color = model)) +
  geom_line(alpha = 0.75)

# Podemos ver o problema ao sobrepor as previsões do modelo sobre os dados brutos:
grid <- daily %>%
  data_grid(wday, term) %>%
  add_predictions(mod2, "n")

ggplot(daily, aes(wday, n)) +
  geom_boxplot() +
  geom_point(data = grid, color="red") +
  facet_wrap(~ term)

# Nosso modelo está encontrando o efeito média, mas temos vários dados enormemente discrepantes, 
# então a média tende a ficar bem longe do valor normal. Podemos aliviar esse problema usando um 
# modelo que seja robusto ao efeito dos outliers:MASS::rlm(). Isso reduz bastante o impacto dos 
# outliers em nossas estimativas e dá um modelo que faz um bm trabalho removendo o padrão dia da 
# semana:
mod3 <- MASS::rlm(n ~ wday * term, data = daily)

daily %>%
  add_residuals(mod3, "resid") %>%
  ggplot(aes(date, resid)) +
  geom_hline(yintercept = 0, size = 2, color = "white") +
  geom_line()

# Agora é muito mais fácil de ver a tendência de longo prazo e os outliers positivos e negativos

################### VARIÁVEIS CALCULADAS
# Se está experimentando vários modelos e muitas visualizações, é uma boa idéia juntar a criação de 
# variáveis em uma função para que não haja chance de aplicar acidentalmente uma transformação 
# diferente em lugares distintos. Por exemplo, poderiamos escrever:
compute_vars <- function(data) {
  data %>%
    mutate(
      term = term(date),
      wday = wday(date, label = TRUE)
    )
}

# Outra opção é colocar as transformações diretamente na fórmula do modelo:
wday2 <- function(x) wday(x, label = TRUE)
mod3 <- lm(n ~ wday2(date) * term(date), data = daily)

# Qualquer uma das abordagens é razoável. Tornar a variável transformada explícita é útil caso queira
# conferir o seu trabalho, ou usá-la em uma visualização. Mas você não pode usar transformações 
# facilmente(como splines) que retornam múltiplas colunas. Incluir as transformações na função do 
# modelo facilita a vida quando você está trabalhando com muitos conjuntos de dados diferentes porque
# o modelo é autônomo.

############## ÉPOCA DO ANO: UMA ABORDAGEM ALTERNATIVA
# Poderíamos usar um modelo mais flexível e permitir que ele capture o padrão no qual estamos 
# interessados. Uma tendência linear simples não é adequada, então poderíamos tentar um spline natural
# para encaixar uma curva suave ao longo do ano:

library(splines)
mod <- MASS::rlm(n ~ wday * ns(date, 5), data = daily)

daily %>%
  data_grid(wday, date = seq_range(date, n = 13)) %>%
  add_predictions(mod) %>%
  ggplot(aes(date, pred, color = wday)) +
    geom_line() +
    geom_point()

# Vemos um padrão forte no número de voos aos sábados. Isso é tranquilizador, porque também perce-
# bemos esse padrão nos dados brutos. É um bom indicador quando você obtém o mesmo sinal de aborda-
# gens diferentes.