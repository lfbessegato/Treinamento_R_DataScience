############ INTRODUÇÃO
# Aprenderá três idéias poderosas que ajudarão a trabalhar com um número grande de modelos com facilidade

# * Usar vários modelos simples para entender melhor conjunto de dados complexos.

# * Usar list-columns para armazenar estruturas de dados arbitrárias em um  data frame. Por exemplo, isso
#   permitirá ter uma coluna que contenha modelos lineares.

# * Usar o pacote broom, para transformar modelos em dados tidy. Essa é uma técnica poderosa para 
#   trabalhar com um número grande de modelos, porque uma vez que tenha dados tidy, pode aplicar todas
#   as técnicas.

########## PRÉ-REQUISITOS
# Trabalhar com vários modelos requer muitos pacotes de tidyverse (para exploração, data wrangling e 
# programação) e o modelr para facilitar a modelagem.
library(modelr)
library(tidyverse)

################## GAPMINDER
# Para motivar o poder de muitos modelos simples, conheceremos os dados "gapminder".
# Os dados gapminder resumem a progressão de países com o tempo, observando as estatísticas de 
# expectativa de vida e PIB. Os dados são fáceis de acessar em R.
#install.packages("gapminder")
library(gapminder)
gapminder

# Neste estudo de caso vamos focar em três variáveis para responder à pergunta "Como a expectativa de 
# vida (lifeExp) muda com o tempo (year)em cada país (Country)?"
# Iniciaremos com um gráfico:
gapminder %>%
  ggplot(aes(year, lifeExp, group = country)) +
  geom_line(alpha = 1/3)

# Parece que a expectativa de vida este melhorando constantemente. Contudo, se olhar mais de perto, 
# poderá notar alguns países que não seguem esse padrão. Como podemos facilitar a visualização desses
# países?

# Vamos desembaraçar esses fatores ajustando um modelo com uma tendência linear. Modelo captura o 
# crescimento constante ao longo do tempo, e os resíduos mostrarão o que restou:

# Sabe como fazer para fazer se tivéssemos um único país:
nz <- filter(gapminder, country == "New Zealand")
nz %>%
  ggplot(aes(year, lifeExp)) +
  geom_line() +
  ggtitle("Full Data = ")

nz_mod <- lm(lifeExp ~ year, data = nz)
nz %>%
  add_predictions(nz_mod) %>%
  ggplot(aes(year, pred)) +
  geom_line() +
  ggtitle("Linear Trend +")

nz %>%
  add_residuals(nz_mod) %>%
  ggplot(aes(year, resid)) +
  geom_hline(yintercept = 0, color = "white", size = 3) +
  geom_line() +
  ggtitle("Remaining pattern")

# Como podemos ajustar esse modelo para todos os países?

###################### DADOS ANINHADOS
# Extraia o código em comum com uma função e repita usando uma função map de purrr. Esse problema tem
# uma estrutura em pouco diferente do que já visto antes. Em vez de repetir uma ação para cada variável
# repetir uma ação para cada país, um subconjunto de linhas. Para fazer isso, precisamos de uma nova 
# estrutura de dados: o data frame aninhado. Para criá-lo, começamos com um data frame agrupado e o 
# "aninhamos":
by_country <- gapminder %>%
  group_by(country, continent) %>%
  nest
  
by_country

# Isso cria um data frame que tem uma linha por grupo(por país), e uma coluna bem incomum: data. 
# data é uma lista de data frames (tibbles). Nós temos um data frame com uma coluna que é uma lista
# de outros data frames!

# A coluna data é um pouco complicada de observar, porque é uma lista moderadamente complicada, e ainda
# estamos trabalhando em boas ferramentas para explorar esses objetos. Infelizmente, usar str() não é
# recomendado, pois produzirá com frequencia saídas muito longas. Mas se retirar um único elemento da 
# coluna data, verá que ele contém todos os dados para esse país. No exemplo (afeganistão)
by_country$data[[1]]

# Note a diferença: em um data frame agrupado, cada linha é uma observação; em um data frame aninhado, 
# cada linha é um grupo. Outra maneira de pensar sobre um conjunto de dados aninhado é que agora temos
# uma metaobservação: uma linha que representa o curso de tempo completo para um país, em vez de um 
# único ponto no tempo.

################ LIST-COLUMNS
# Agora que temos nosso data frame aninhado, estamos em uma boa posição para ajustar alguns modelos.
# Temos uma função para ajustar modelos:
country_model <- function(df) {
  lm(lifeExp ~ year, data = df)
}

# E queremos aplicá-la em cada data frame. Os data frames estão em uma lista, então podemos usar 
# purrr::map() para aplicar country_models a cada elemento:
models <- map(by_country$data, country_model)

# Em vez de criar um novo objeto no ambiente global, criaremos uma nova variável no data frame 
# by_country. Esse é um trabalho para dplyr::mutate():
by_country <- by_country %>%
  mutate(model = map(data, country_model))
by_country

# Isso apresenta uma grande vantagem: como todos os objetos relacionados estão armazenados juntos, não precisa
# mantê-los manualmente em sincronia quando filtrar ou arranjar. A semântica do data frame cuidará disso:
by_country %>%
  filter(continent == "Europe")

# view(by_country)

by_country %>%
  arrange(continent, country)
 
# Se sua lista de data frames e sua lista de modelos forem objetos separados, tem que lembrar que sempre que 
# reordenar ou fizer subconjuntos de um vetor, será preciso reordenar ou fazer subconjuntos de todos os outros
# para mentê-los em sincronia. Se esquecer disso, seu código continuará funcionando, mas lhe dará a resposta 
# errada!

############### DESANINHANDO
# Agora temos 142 data frames e 142 modelos. Para calcular os resíduos, precisamos chamar add_residuals() com cada
# par modelo-dados:
by_country <- by_country %>%
  mutate(
    resids = map2(data, model, add_residuals)
  )
by_country

# Como fazer um gráfico de uma lista de data frames? Em vez de lutar para responder a essa pergunta, vamos 
# transformar a lista de data frames de volta em um data frame normal. Antes usamos nest() para transformar um 
# data frame regular em um data frame aninhado, e agora fazemos o oposto com unnest():
resids = unnest(by_country, resids)
resids

# Note que cada coluna regular é repetida uma vez para cada linha na coluna aninhada
# Agora que temos um data frame regular, podemos fazer o gráfico dos resíduos:
resids %>%
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1/3) +
  geom_smooth(se = FALSE)

# Fazer facetas por continente é particularmente revelador:
resids %>%
  ggplot(aes(year, resid, group = country)) +
  geom_line(alpha = 1/3) +
  facet_wrap(~continent)

############### QUALIDADE DO MODELO
# Podemos olharpara algumas medidas gerais de qualidade do modelo. Aprendemos como calcular algumas medidas
# específicas. O pacote broom fornece um conjunto de funções gerais para transformar modelos em dados tidy.
# Usaremos broom::glance() para extrair algumas métricas de qualidade do modelo. Se aplicarmos a um modelo, 
# obtemos um data frame com uma única linha:
broom::glance(nz_mod)

# Podemos usar mutate() e unnest() para criar um data frame com uma linha para cada país:
by_country %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance)

# Essa não é a saída que queremos, porque ainda inclui todas as list-columns. Esse é o comportamento padrão quando
# unnest() trabalha em data frames de linha única. Para suprimir essas colunas, nós usamos .drop = TRUE:
glance <- by_country %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance, .drop = TRUE)
glance

# (Preste atenção às variáveis que não estão impressas: há muita coisa útil lá.)

# Com esse data frame em mãos, podemos começar a procurar modelos que não se encaixam bem:
glance%>%
  arrange(r.squared)

# Todos os piores modelos parecem estar na África. Verificaremos novamente isso com um gráfico. Aqui nós temos um
# número relativamente pequeno de observações e uma variável discreta, então geom_jitter() é eficaz:
glance %>%
  ggplot(aes(continent, r.squared)) +
  geom_jitter(width = 0.5)

# Poderíamos extrair os países com um R2 particularmente ruim e fazer o gráfico dos dados:
bad_fit <- filter(glance, r.squared < 0.25)

gapminder %>%
  semi_join(bad_fit, by = "country") %>%
  ggplot(aes(year, lifeExp, color = country)) +
  geom_line()

# Podemos observar dois efeitos principais: as tragédias da epidemia de HIV/AIDS e o genocídio em Ruanda.

################### LIST-COLUMNS
# Exploraremos a estrutura de dados list-columns um pouco mais detalhadamente. List-Columns estão implicítos na 
# definição do data frame; um data frame é uma lista nomeada de vetores de igual comprimento. Uma lista é um vetor
# então sempre foi legítimo usar um list como uma coluna de um data frame. No entanto, o R base não facilita criar
# list-columns, e data.frame() trata uma lista como uma lista de colunas.
data.frame(x = list(1:3, 3:5))

# Pode evitar que data.frame() faça isso com I(), mas o resultado não imprime particularmente bem:
data.frame(
  x = I(list(1:3, 3:5),
  y = c("1,2","3,4,5")
)

# O tibble minimiza esse problema sendo mais preguiçoso (tibble() não modifica suas entradas) e fornecendo um 
# método melhor de impressão:
tibble(
  x = list(1:3, 3:5),
  y = c("1:2", "3,4,5")
)

# É ainda mais fácil com tribble(), já que pode deduzir automaticamente que você precisa de uma lista:
tribble(
  ~x, ~y,
  1:3, "1:2",
  3:5, "3,4,5"
)

# Lista-columns são frequentemente mais úteis como uma estrutura de dados intermediária. É dificil de trabalhar
# diretamente com elas, porque a maioria das funções do R trabalha com vetores atômicos ou data frames, mas a 
# vantagem de manter relacionados juntos em um data frame vale o pequeno esforço.

# Geralmente há três partes para um pipeline list-columns eficaz:

# 1) Cria o list-column usando uma das funções nest(), summarize() + list() ou mutate() + uma função map.

# 2) Cria outras list-columns inermediárias transformando list-columns existentes em map(), map2() ou pmap().

# 3) Simplifica a list-column de volta a um data frame ou vetor atômico.

###################### CRIANDO LIST-COLUMNS
# Não cria list-columns com tibble(). Em vez disso, as criará a partir de colunas regulares, usando um dos três
# métodos:

# 1) Com tidy::nest() para converter um data frame agrupado em um data frame aninhado, no qual tem list-column
# de data frames

# 2) Com mutate() e funções vetorizadas que retornam uma lista.

# 3) Com summarize() e funções pode criá-las a partir de uma lista nomeada usando tibble:enframe()

# Ao criar list-columns, deve se certificar de que são homogêneas: cada elemento deve conter o mesmo tipo de coisa.
# Não há verificações para garantir que isso seja verdade, mas se usar purrr

############################# COM ANINHAMENTO
# nest() => Cria um data frame aninhado, ou seja, com uma list-column de data frames.
# Em um data frame aninhado, cada linha é uma meta observação: as outras colunas dão variáveis que definem a 
# observação, e a list-column de data frames dá as observações individuais que formam a meta observação.

# Há duas maneiras de usar o nest(). Até agora viu como usá-la com um data frame agrupado. Quando aplicada a um
# data frame agrupado nest() mantém as colunas agrupadas como são e junta todo o resto em uma list-column:
gapminder %>%
  group_by(country, continent) %>%
  nest()

# Também pode usá-la em um data frame desagrupado, especificando quais colunas quer aninhar:
gapminder %>%
  nest(year:gdpPercap)

################ A PARTIR DE FUNÇÕES VETORIZADAS
# Algumas funções úteis recebem um vetor atômico e retornam uma lista. Por exemplo no Cap. 11 aprendemos sobre 
# stringr::str_split(), que recebe um vetor de caracteres e retorna uma lista de vetores de caracteres. Se usar 
# dentro de um mutate, obterá um list-column:
df <- tribble(
  ~x1,
  "a,b,c",
  "d,e,f,g"
)

df %>%
  mutate(x2 = stringr::str_split(x1, ","))

# unnest() sabe como lidar com essas listas de vetores:
df %>%
  mutate(x2 = stringr::str_split(x1,",")) %>%
  unnest()

# Se perceber que está usando muito esse padrão, certifique-se de conferir tidyr:separate_rows(), que é um wrapper
# em torno desse padrão comun).

# Outro exemplo desse padrão é usar as funções map(), pmap() de purrr.

sim <- tribble(
  ~f, ~params,
  "runif",list(min = -1, max = -1),
  "rnorm", list(sd = 5),
  "rpois", list(lambda = 10)
)

sim %>%
  mutate(sims = invoke_map(f, params, n = 10) )

# Note que tecnicamente sim não é homogêneo, porque contém tanto vetores double quanto integer.Contudo, isso 
# provavelmente não causará muitos problemas, já que integers e doubles são, ambos, vetores numéricos.

##################### A PARTIR DE RESUMOS DE MÚLTIPLOS VALORES
# A restrição de summarize() é que ela só funciona com funções de resumo que retornam um único valor. Isso 
# significa que você não pode usá-la com funções como quantile(), que retorna um vetor de comprimento arbitrário:

mtcars %>%
  group_by(cyl) %>%
  summarize(q = quantile(mpg))

# No entanto, pode envolver o resultado em uma lista! Isso obedece o contrato de summarize(), porque casa resumo
# é agora uma lista(um vetor) de comprimento 1:
mtcars %>%
  group_by(cyl) %>%
  summarize(q = list(quantile(mpg)))

# Para fazer resultados úteis com unnest(), também precisará capturar as probabilidade:
probs <- c(0.01, 0.25, 0.5, 0.75, 0.99)
mtcars %>%
  group_by(cyl) %>%
  summarize(p = list(probs), q = list(quantile(mpg, probs))) %>%
  unnest()

############# A PARTIR DE UMA LISTA NOMEADA
# Data frames com list-columns fornecem uma solução para um problema comum: o que faz se quiser iterar sobre ambos
# os conteúdos de uma lista e seus elementos? Em vez de tentar misturar tudo em um objeto, muitas vezes é mais 
# fácil fazer um data frame: uma coluna pode conter os elementos, e a outra pode conter a lista. Uma maneira fácil
# de criar tal data frame a partir de uma lista é tibble::enframe():
x <- list(
  a = 1:5,
  b = 3:4,
  c = 5:6
)

df <- enframe(x)
df

# A vantagem dessa estrutura é que ela generaliza de maneira direta - nomes são úteis se tem um vetor de caracteres
# de metadados, mas não ajudam se tiver outros tipos de dados, ou vetores múltiplos.

# Agora, se quer iterar sobre nomes e valores em paralelo, pode usar map2():
df %>%
  mutate(
    smry = map2_chr(
      name, 
      value, 
      ~ stringr::str_c(.x, ": ", .y[1]))
    )
  )

############### SIMPLIFICANDO
# Para aplicar as técnicas de manipulação e visualização de dados, precisará simplificar a list-column de volta
# para uma coluna regular (um vetor atômico), ou um conjunto de colunas.A técnica que usará para colapsar de volta
# para uma estrutura mais simples dependerá se deseja um único valor por elemento ou vários valores:

# Se quiser um único valor, use mutate() com map_lgl(), map_int(), map_dbl() e map_chr() para criar um vetor
# atômico.

# Se quiser muitos valores, use unnest() para converter list-columns de volta para colunas regulares, repetindo 
# as linhas quantas vezes for necessário.

############# LISTA PARA VETOR
# Pode reduzir sua list-column para um vetor atômico, então usará uma coluna regular. POr exemplo, pode sempre
# resumir um objeto com seu tipo e comprimento, então esse código funcionará independente do tipo de list-column
# que tiver:
df <- tribble(
  ~x, 
  letters[1:5],
  1:3,
  runif(5)
)

df %>% mutate(
  type = map_chr(x, typeof),
  length = map_int(x, length)
)

# Essa é a mesma informação básica que obtém do método tblprint padrão, mas agora pode usá-la para filtrar. Essa 
# é uma técnica útil caso tenha uma lista heterogênea e queira filtrar as partes que não funcionam.

df <- tribble(
  ~x,
  list(a = 1, b = 2),
  list(a = 2, c = 4)
)

df %>% mutate(
  a = map_dbl(x, "a"),
  b = map_dbl(x, "b", .null = NA_real_)
)

############## DESANINHANDO
# unnest() funciona ao repetir as colunas regulares para cada elemento da list-column. No exemplo muito simples
# a seguir repetimos a primeira linha quatro vezes (pois neste caso o primeiro elemento de y tem comprimento quatro)
# e a segunda linha uma vez:
tibble(x = 1:2, y = list(1:4, 1)) %>% unnest(y)

# Isso significa que não pode desaninhar simultaneamente duas colunas que contenham um número diferente de 
# elementos
df1 <- tribble(
  ~x, ~y,
  ~z,
  1, c("a", "b"), 1:2,
  2, "c",
  3
)
df1

df2 <- tribble(
  ~x, ~y,
  ~z,
  1, "a",
  1:2,
  2, c("b", "c"),
  3
)
df2

# O mesmo príncipio se aplica ao desaninhar list-columns de data frames. Pode desaninhar várias list-columns, 
# contanto que todos os data frames em cada linha tenham o mesmo número de linhas.

#################### CRIANDO DADOS TIDY COM BROOM
# O pacote broom fornece três ferramentas gerais para transformar modelos em data frames tidy:

# 1) broom::glance(model) => Retorna uma linha para cada modelo. Cada coluna dá um resumo de modelo: ou medida de 
# qualidade do modelo, ou da complexidade, ou uma combinação de ambos.

# 2) broom:tidy(model) => Retorna uma linha para cada coeficiente no modelo. Cada coluna dá informações sobre a 
# estimativa ou variabilidade.

# 3) broom::augment(model, data) => Retorna uma linha para cada linha em data, adicionando valores extras como 
# resíduos e estatísticas de influência.
