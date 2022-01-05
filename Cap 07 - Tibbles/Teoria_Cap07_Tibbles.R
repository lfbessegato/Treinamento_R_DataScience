###### TIBBLES com tibble
# tibbles => São dataframes, mas eles ajustam alguns
# comportamentos antigos para facilitar a vida.

# Pré-requisitos
# tibble são parte do núcleo tidyverse
library(tidyverse)

# Criando Tibbles
# Quase todas as funções que usará nesse livro 
# produzem tibbles, já que eles são um dos 
# recursos unificadores do tidyverse.
# 
# Forçar um data frame em um tibble, para isso
# utilize as_tibble()
as_tibble(iris)

# Criar novo tibble a partir de vetores individuais com tibble()
# O tibble() reciclará automaticamente as entradas de comprimento 1 e permitirá
# que você se refira a variáveis que acabou de criar.
tibble(
  x = 1:5,
  y = 1, 
  z = x ^ 2 + y
)

# os tibbles fazem muito menos que um data frame, por exemplo (nunca converte 
# strings em fatores!), não altera os nomes das variáveis e jamais cria nomes de 
# linhas.
# 
# É possível ter nomes de colunas que não sejam nomes de variáveis válidos em R.
# 
tb <- tibble(
  `:` = "smile",
  ` ` = "space",
  `2000` = "number"
)
tb

# Também precisará de backticks ao trabalhar com essas variáveis em outros pacotes
# como ggplot2, dplyr e tidyr
# 
# Outra maneira de criar tibble é com tribble() => abreviação de 
# transposed tibble (tibble transposto).
# O tribble() é customizado para a entrada de dados por códigos
tribble(
  ~x, ~y, ~z,
  #--/--/----
  "a", 2, 3.6,
  "b", 1, 8.5
)

# Tibbles versus data.frame
# Há duas diferenças principais no uso de um tibble versus um data.frame clássico:
# impressão e subconjuntos
# 
# Impressão 
# Tibbles têm um método de impressão refinado, que mostra apenas as 10 primeira
# linhas e todas as colunas que cabem na tela.
tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)
# Tibbles são projetados para que você não sobrecarregue acidentalmente seu 
# controle ao imprimir data frames grandes.
# Algumas saídas necessárias fora do padrão
# Fazer print() explicitamente do data frame e controlar o número de linhas (n) e
# largura width() da exibição, width = Inf exibirá todas as colunas.
nycflights13::flights %>%
  print(n = 10, width = Inf)

# Controlar o comportamento de impressão padrão estabelecendo opções
### options(tibble.print_max = n, tibble.print_min = m) => se mais m linhas imprimir
### apenas n linhas. Use options(dplyr.print_min = Inf) para sempre mostrar todas as
### linhas
### 
### Use options(tibble,width = Inf) para imprimir sempre todas as colunas, 
### independente da largura da tela.
# 
# Para obter uma lista completa de opções ver a ajuda de pacote com package?tibble
# Uma última opção é usar o visualizador de dados interno do RStudio para obter uma
# visualização do conjunto de dados completo em uma lista contínua.
nycflights13::flights %>%
  view()


### SUBCONJUNTOS
# Se quiser puxar uma única variável, precisa de algumas ferramentas novas
# $ e [[. O [[ pode extrair por nome ou posição, e o $ só extrai por nome, mas 
# tem um pouco nemons de digitação.
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)
# Extract by name
df$x
df[["x"]]

# Extract by position
df[[1]]

# Para usá-los em um pipe, você precisará utilizar o marcador de posição especial
# .:
df %>% .$x

df %>% .[["x"]]

# Comparados a um data.frame, tibbles são mais rígidos: eles nunca fazem 
# combinações parciais, gerarão um aviso se a coluna que você está tentando
# acessar não existir.

#### INTERAGINDO COM CÒDIGOS MAIS ANTIGOS
# Algumas funções mais antigas não funcionam com tibbles. Se você encontrar algumas
# dessas funções, use as.data.frame() para transformar um tibble de volta em um 
# data.frame:
class(as.data.frame(tb))

# 