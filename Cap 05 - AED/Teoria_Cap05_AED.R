####### VISUALIZANDO DISTRIBUIÇÕES
library(tidyverse)
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))


# Calcular os valores manualmente das colunas dplyr::count()
diamonds %>%
  count(cut)

# Para examinar a distribuição de uma variável continua.
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.5)

# calcular isso à mão combinando dplyr::count() e ggplot2::cut_width
diamonds %>%
  count(cut_width(carat, 0.5))

# Focamos apenas nos diamantes com um tamanho menor que três quilates
# (carats) e escolhemos um binwidth menor:

smaller <-diamonds %>%
  filter(carat < 3)

ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.1)

# Sobrepor vários histogramas no mesmo gráfico usar o geom_freqpoly
# Onde realiza o mesmo cálculo do geom_histograma, mas ao invés de exibir
# em barras, exibe em linhas.

ggplot(data = smaller, mapping = aes(x = carat, color = cut)) +
  geom_freqpoly(binwidth = 0.1)

######## VALORES TÍPICOS
# Por que há mais diamantes em quilates inteiros e frações comuns de quilates?
# Por que há mais diamantes levemente à direita de cada pico do que levemente à esquerda de cada pico?
# Por que não existem diamantes com mais de três quilates?
ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

# clusters de valores similares sugerem que existem subgrupos em seus dados
# Para entender os subgrupos, pergunte
# 
# Quais são as semelhanças entre as observações dentro de cada cluster?
# Quais são as diferenças entre as observações de cluster separados?
# Como você pode explicar ou descrever os clusters?
# Por que a aparência dos clusters pode ser enganosa?
# Exemplo 
# Duração em minutos de erupções = 272
# erupções curtas (de cerca de 2 minutos)
# erupções longas (de 4 a 5 minutos)
ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_histogram(binwidth = 0.25)

###### VALORES INCOMUNS => Pontos fora da Curva
# Distribuição da variável y do conj de dados de diamantes.
# A única evidência dos pontos fora da curva são os limites 
# incomumente amplos no eixo y

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)

# Precisamos focar em valores pequenos do eixo y com coord_cartesian()
# 
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0,50))

unusual <- diamonds %>%
  filter(y < 3 | y > 20) %>%
  arrange(y)
unusual

##### VALORES FALTANTES
# Retirar toda a linha com valores estranhos
# não é recomendável essa abordagem, pois apenas uma medida é inválida.
diamonds2 <- diamonds %>%
  filter(between(y, 3, 20))

# o melhor é substituir os valores incomuns  por valores faltantes. A maneira mais fácil é utilizar
# mutate() para substituir a variável por uma cópia modificada.
# Pode utilizar o ifelse() para substituir os valores incomuns por NA
diamonds2 <- diamonds %>%
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

ggplot(data = diamonds2, mapping = aes(x = x, y = y)) +
  geom_point()

# Para suprimir o aviso de linhas removidas
# na.rm = TRUE
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) +
  geom_point(na.rm = TRUE)

# Por exemplo em nycflights13::flights, valores faltantes na variável dep_time indicam que o voo
# foi cancelado. 
# Caso desejecomparao cronograma de horas de decolagens para horários cancelados e não cancelados.
# Criar uma nova variável com is.na()
nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>%
  ggplot(mapping = aes(sched_dep_time)) + 
    geom_freqpoly(
      mapping = aes(color = cancelled),
      binwidth = 1/4
    )

####### CONVARIAÇÃO
# Descreve o comportamento entre variáveis
# A Covariação => É a tendẽncia que os valores de duas ou mais variáveis têm de variar juntos de 
# maneira relacionada.
# 
# Variável Categórica e Contínua
# Ex. Explorar como o preço de um diamante varia com sua qualidade
ggplot(data = diamonds, mapping = aes(x = price))+
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)

# é dificil de ver a diferença, porque as contagens gerais diferem muito 
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut))

# Para facilitar a comparação, é necessário modificar o que é exibido no eixo y
# Em vez de exibir count, exibiremos denosity (densidade) que é a contagem padronizada para que
# a área sob cada poligono de frequencia seja um
ggplot(
  data = diamonds,
    mapping = aes(x = price, y = ..density..)
) +
geom_freqpoly(mapping = aes(color = cut), binwidth = 500)

# boxplot 
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()

ggplot(data = mpg, mapping = aes(x = class, y = hwy ))+
  geom_boxplot()

# Reordenar variavel class com base no valor médio de hwy
ggplot(data = mpg) +
  geom_boxplot(
    mapping = aes(
      x = reorder(class, hwy, FUN = median),
      y = hwy
    )
  )
# Variaveis de nomes longos o geom_boxplot() funcionara melhor se 
# girá-lo em 90 graus, utilizando o coord_flip()
ggplot(data = mpg) +
  geom_boxplot(
    mapping = aes(
      x = reorder(class, hwy, FUN = median),
      y = hwy
    )
  ) +
  coord_flip()

####### Duas Variáveis Categóricas
# Para visualizar a covariação entre variáveis categóricas, precisa contar o número de observações
# de cada combinação. Maneira de fazer isso é confiar no geom_count() incorporado
ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color))

# O tamanho de cada círculo no gráfico, exibe quantas observações ocorreram em 
# cada combinação de valores.

# outra abordagem é calcular a contagem com dplyr

diamonds %>%
  count(color, cut)

# Depois visualizar com geom_title e a estética de preenchimento
diamonds %>%
  count(color, cut) %>%
  ggplot(mapping = aes(x = color, y = cut)) +
     geom_tile(mapping = aes(fill = n))

##### Duas Variáveis Contínuas
# Pode ver a covariação como um padrão nos pontos.
# Enxergar uma relação exponencial entre o tamanho dos quilates e o 
# preço de um diamante
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))

# Diagramas de dispersão se tornam menos úteis à medida que o tamanho de seu 
# conjunto de dados aumenta. Para contornar utilizar a estética alpha para
# adicionar transparência.
ggplot(data = diamonds) +
  geom_point(
    mapping = aes(x = carat, y = price),
    alpha = 1 / 100
  )

# Usar transparência é desafiador para conjunto de dados muito grande.
# Uma solução é usar bin. Já foi usado geom_histogram() e geom_freqpoly()
# para fazer bin em uma dimensão. Agora aprenderemos a usar o geom_bin2d() 
# e geom_hex() para fazer bin em duas dimensões
# geom_bin2d() e geom_hex(0 dividem o plano de coordenadas em bins 2D e 
# usamuma cor de preenchimento para exibir quantos caem em cada bin.
# geom_bin2d => cria bins retangulares 
#  geom_hex() => cria bins hexagonais
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price))

# install.packages("hexbin")
ggplot(data = smaller) +
  geom_hex(mapping = aes(x = carat, y = price))

# Podemos utilizar de outra maneira com o boxplot
# Exemplo: Criar o bin de carat, e então para cadagrupo, exibir um boxplot
ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

# cut_width(x, width) => divide x em bins de largura width.
# 

# Outra abordagem é exibir aproximadamente o mesmo número de ponto em cada bin
# Com isso utiliza o cut_number()
ggplot(data = smaller, mapping = aes(x = carat, y = price))+
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))

###### PADRÕES MODELOS
# Fornecem pistas sobre interações. Se existe relacionamento sistemático
# entre dua variáveis, aparecerá como padrão nos dados.
# Ex. Um diagrama de dispersão da duração de erupções do Old Faithful versus 
# o tempo de espera entre as erupções exibe um padrão.
ggplot(data = faithful) +
  geom_point(mapping = aes(x = eruptions, y = waiting))

# Modelos 
# são uma ferramenta para extrair padrões dos dados.
# Ex => Considera os dados sobre os diamantes. É dificil entender o 
# relacionamento entre corte e preço, porque corte e quilates e quilates e 
# preço são fortemente relacionados.

library(modelr)

mod <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>%
  add_residuals(mod) %>%
  mutate(resid = exp(resid))

ggplot(data = diamonds2) +
  geom_point(mapping = aes(x = cut, y = resid))

# uma vez removido o relacionamento forte entre carat e price, poderá 
# identificar o que espera do relacionamento entre cut e price - com 
# relação ao seu tamanho, diamantes de melhor qualidade são mais caros.
ggplot(data = diamonds2) +
  geom_boxplot(mapping = aes(x = cut, y = resid))

# chamadas ggplot2
ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_freqpoly(binwidth = 0.25)

### Reescrever o gráfico anterior mais concisamente produz
ggplot(data = faithful, aes(eruptions)) +
  geom_freqpoly(binwidth = 0.25)

### Transformação do pipeline

diamonds %>%
  count(cut, clarity) %>%
  ggplot(aes(clarity, cut, fill = n)) +
  geom_tile()

