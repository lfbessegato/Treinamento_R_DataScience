############ INTRODUÇÃO
# Este capítulo apresenta fatores são usados para trabalhar com variáveis
# categóricas, que têm um conjunto fixo e conhecido de valores possíveis.
# Eles também são úteis quando você quer exibir vetores de caracteres em 
# ordem não alfabética.

########## PRÉ-REQUISITOS
# Este capítulo trabalhará com fatores, será usado o pacote fatores, que 
# fornece ferramentas para lidar com variáveis categóricas(e é um anagrama de
# factors!). Forcats não faz parte do núcleo do tidyverse, então será 
# necessário carregá-lo especificamente.

library(tidyverse)
library(forcats)

##### CRIANDO FATORES
# Imagina uma variável que registra o mês

x1 <- c("Dez", "Abr", "Jan", "Mar")

# Usar uma string para registrar essa variável geram dois problemas:
# 1. Há apenas 12 meses possíveis, e não há nada que lhe salve de erros de 
# digitação
x2 <- c("Dez", "Abr", "Jam", "Mar")

# 2. Não dá para ordenar de maneira útil:
sort(x1)

# Pode corrigir ambos os problemas com um fator. Para criar um fator, deve´
# começar criando uma lista dos níveis válidos:
month_levels <- c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
                  "Jul", "Ago", "Set", "Out", "Nov", "Dez")

# Agora cria-se um fator:
y1 <- factor(x1, levels = month_levels)
y1
sort(y1)

# E quaisquer valores que não estiverem no conjunto serão sileciosamente 
# convertidos a NA:
y2 <- factor(x2, levels = month_levels)
y2

# se você quiser um erro, pode usar readr::parse_factor():
y2 <- parse_factor(x2, levels = month_levels)

# Se você omitir os níveis, eles serão retirados dos dados em ordem alfabética:
factor(x1)

# As vezes vai preferir que a ordem dos níveis combine com a ordem da primeira
# aparição nos dados. É possível fazer isso ao criar o fator configurando os
# níveis como unique(x), ou depois do fator, fct_inorder():
f1 <- factor(x1, levels = unique(x1))
f1

f2 <- x1 %>% factor() %>% fct_inorder()
f2

# Se algum dia precisar acessar diretamente o conjunto de níveis válidos, 
# poderá fazer isso com levels()
levels(f2)

########### GENERAL SOCIAL SURVEY
# A pesquisa tem milhares de perguntas, então co_m o gss_cat segue alguns 
# desafios comuns que encotrará ao trabalhar com fatores:
gss_cat

# Lembre-se já que esse conjuntos de dados é fornecido por um pacote, pode 
# obter mais informações sobre as variáveis com o ?gss_cat

# Quando os fatores são armazenados em um tibble, não é possível ver tão 
# facilmente seus níveis. Uma maneira de vê-los é com count():
gss_cat %>%
  count(race)

# Ou com gráfico de barras:
ggplot(gss_cat, aes(race)) + 
  geom_bar()

# Por padrão o ggplot2 deixará de lado os níveis que não têm nenhum valor.
# Pode forçar sua exibição com:
ggplot(gss_cat, aes(race)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)

# Esses níveis representam valores válidos que simplesmente não ocorrem 
# nesse conjunto de dados. Infelizmente, o dplyr não tem uma opção drop, mas 
# terá no futuro.
# Ao trabalhar com fatores, as duas operações mais comuns são mudar a ordem
# dos níveis e alterar os valores dos níveis.

#### MODIFICANDO A ORDEM DOS FATORES
# Muitas vezes é útil mudar a ordem dos níveis dos fatores em uma visualização
# Por exemplo, Imagine que queira explorar o número médio de horas por dia
# passadas assistindo TV entre as religiões:
relig <- gss_cat %>%
  group_by(relig) %>%
  summarize(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )
ggplot(relig, aes(tvhours, relig)) + geom_point()

# Díficil interpretar esse gráfico, porque não há um padrão geral. Podemos
# melhorá-lo reordenando os níveis de relig usando fct_reorder(). 
# A fct_reorder() recebe três argumentos:
# * f => o fator cujos níveis você quer modificar.
# * x => um vetor numérico para reordenar os níveis.
# Opcionalmente, fun, uma função que é usada se houver múltiplos valores
# de x para cada valor de f. O valor padrão é median.
ggplot(relig, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point()

# Reordenar as religiões facilita muito visualizar que as pessoas na 
# categoria "Don't Know" assistem muito mais TV, e que o Hinduísmo e outras
# religiões orientais assistem bem menos.

# A medida que você começa a fazer transformações mais complicadas, é 
# recomendável movê-las do aes() e colocá-las em um passo mutate() separado.
# Por exemplo, poderia reescrever o gráfico anterior como:
relig %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()

# E se criássemos um gráfico similar observando como a média de idade varia
# pelo nível de renda relatado?

rincome_summary <- gss_cat %>%
  group_by(rincome) %>%
  summarize(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(rincome_summary, aes(age, fct_reorder(rincome, age))) + geom_point()

# Aqui, reordenar os níveis arbitariamente não é uma boa idéia! Isso porque
# rincome_summary já tem uma ordem consistente com a qual não devemos mexer.
# Reserve fct_reorder() para fatores cujos níveis sejam arbitariamente 
# ordenados.

# No entanto, faz sentido colocar "Not applicable" na frente dos outros 
# Níveis especiais. Você pode usar fct_relevel(). Ela pega um fator, f, e
# depois qualquer número de niveis que você queira mover para a frente da 
# fila.
ggplot(
  rincome_summary, aes(age, fct_relevel(rincome, "Não Aplicável"))) + 
  geom_point()

# Por que vocẽ acha que a idade média para "Não Aplicável" é tão alta?
# Outro tipo de reordenação é útil quando você está colorindo as linhas
# de um gráfico. A fct_reorder2() reordena o fator pelos valores y associados
# com os maiores valores x. Isso facilita a leitura do gráfico porque as
# cores das linhas se alinham com a legenda:
by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  group_by(age, marital) %>%
  count() %>%
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop, color = marital)) +
  geom_line(na.rm = TRUE)

ggplot(by_age, aes(age, prop, color = fct_reorder2(marital, age, prop))) + 
         geom_line() + labs(color = "marital")

# Finalmente, para gráficos de barra, pode usar o fct_infreq() para ordenar
# os níveis em frequência crescente esse é o tipo mais simples de reordenação
# porque não precisa de nenhuma variável extra. Poderá combinar com fct_rev()
gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(marital)) + geom_bar()

###### MODIFICANDO NÍVEIS DE FATORES
##  Mais poderosos do que mudar as ordens dos níveis é mudar seus valores
# Isso permite que esclareça legendas para publicação e colapse níveis para
# exibições de alto nível. A ferramenta geral e poderosa é fct_recode(). Ela
# permite recodificar, ou mudar, o valor de cada nível. Por exemplo veja
# gss_cat$partyid:
gss_cat %>% count(partyid)

# Os níveiss são curtos e inconsistentes. Vamos ajustá-los para que sejam 
# mais longos e usem uma construção paralela:
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
     "Republican, strong"    = "Strong republican", 
     "Republican, weak"      = "Not str republican", 
     "Independent, near rep" = "Ind,near rep", 
     "Independent, near dem" = "Ind,near dem", 
     "Democrat, weak"        = "Not str democrat", 
     "Democrat, strong"      = "Strong democrat"
  )) %>%
  count(partyid)

# fct_recode() deixará os níveis que não são explicitamente mencionados como
# estão e os avisará se você se referir acidentalmente a um nível que não
# existe.

# Para combinar grupos, você pode atribuir múltiplos níveis antigos ao mesmo
# ao mesmo nível novo:
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican", 
                              "Republican, weak"      = "Not str republican", 
                              "Independent, near rep" = "Ind,near rep", 
                              "Independent, near dem" = "Ind,near dem", 
                              "Democrat, weak"        = "Not str democrat", 
                              "Democrat, strong"      = "Strong democrat",
                              "Other"                 = "No answer",
                              "Other"                 = "Don't know", 
                              "Other"                 = "Other party"
  )) %>%
  count(partyid)

# Essa técnica deve ser usada com cuidado: se agrupar categorias que sejam 
# realmente diferentes, acabará com resultados enganadores.

# Se quiser colapsar vários níveis, fct_collapse() é uma variante útil de 
# fct_recode(). Para cada nova variável, pode fornecer um vetor de níveis
# antigos:
gss_cat %>%
  mutate(partyid = fct_collapse(partyid, 
      other = c("No answer", "Don't know", "Other party"),
      rep = c("Strong republican", "Not str republican"), 
      ind = c("Ind,near rep", "Independent", "Ind,near dem"),
      dem = c("Not str democrat", "Strong democrat")
  )) %>%
  count(partyid)

# As vezes só quer juntar todos os grupos pequenos para simplificar um 
# gráfico ou tabela. Esse é um trabalho para fct_lump():
gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)

# O comportamento padrão é juntar progressivamente os grupos pequenos, 
# garantindo que o agregado ainda seja o menor grupo. Neste caso, não é muito
# útil: é verdade que a maioria dos norte-americanos nessa pesquisa são 
# protestantes, mas provavelmente colapsamos demais.

# Em vez disso, queremos usar o parâmetro n para especificar quantos grupos
# (excluindo outros) queremos manter:
gss_cat %>%
  mutate(relig = fct_lump(relig, n = 10)) %>%
  count(relig, sort = TRUE) %>%
  print(n = Inf)

