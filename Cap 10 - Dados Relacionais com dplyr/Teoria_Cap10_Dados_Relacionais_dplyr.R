###### INTRODUÇÃO
# Várias tabelas de dados são chamadas de dados relacionais, porque são relações, não apenas
# os conjuntos de dados individuais, que são importantes.
# 
# Para trabalhar com dados relacionais, você precisa de verbos que funcionem com pares de 
# tabelas. Há três famílias de verbos projetados com os quais você pode trabalhar.
# 
# * Mutating joins => que adiciona novas variáveis a um data frame a partir de observações
# correspondentes em outro
# 
# * Filtering joins => Que filtra observações de um data frame baseado em se elas combinam ou # não com uma observação em outra tabela.
# 
# * Set operations => Que trata observações com se fossem um conjunto de elementos.
# 
# O lugar mais comum de se encontrar dados relacionais é um sistema de gerenciamento de banco
# de dados relacional
# 
# Pŕe-requisitos
# Será explorado dados relacionais de nycflights13 usando os verbos de duas tabelas de dplyr.
# install.packages(nycflights13)
library(tidyverse)
library(nycflights13)

##### NYCFLIGHTS13
# Usaremos o pacote nycflights13 para aprender sobre dados relacionados. O nycflights13 contém quatro tibbles que estão relacionados à tabela flights
# 
# * airlines (linhas aéreas)  => Lhe permite procurar o nome completo da operadora a partir
# de seu código abreviado
airlines

# * airports (aeroportos) => Lhe dá informações sobre cada aeroporto, identificado pelo código faa do 
# aeroporto
airports

# * planes (aviões) => Lhe dá informações sobre cada avião, identificados por seus tailnum
planes

# * weather (clima) => Lhe dá o clima de cada aeroporto de Nova York por hora
weather


###### CHAVES
# As variáveis usadas para conectar cada par de tabelas são chamadas de chaves (keys). Uma chave é uma
# variável (ou conjunto de variáveis) que identifica unicamente uma observação.
# 
# Há dois tipos de chaves:
# 
# * Primary key (chave primária) => Identifica unicamente uma observação em sua própria tabela. 
# Por exemplo => planes$tailnum é uma chave primária, porque identifica somente cada avião na tabela 
# planes.
# 
# * Foreign key (Chave estrangeira) => Identifica unicamente uma observação em outra tabela. 
# Por exemplo => flights$tailnum é uma chave estrangeira porque aparece na tabela de flights, onde combina
# cada voo com um único avião.
# 
# Uma vez identificado as primary key em suas tabelas, é uma boa prática verificar se elas realmente
# identificam unicamente cada observação.Utilizando count() das primery keys e procurar entradas onde
# n seja maior do que um
# 
planes %>%
  count(tailnum) %>%
  filter(n > 1)

weather %>%
  count(year, month, day, hour, origin) %>%
  filter( n > 1)

# Às uma tabela não tem uma primary key explicita: cada linha é uma observação, mas nenhuma combinação 
# de variáveis a identifica confiavelmente.
# Por exemplo, qual é a primery key da tabela flights? Pode achar que seria a data mais o número de voo
# ou da cauda, mas nenhuma delas é única.

flights %>%
  count(year, month, day, flight) %>%
  filter (n > 1)

flights %>% 
  count(year, month, day, tailnum) %>%
  filter(n > 1)

# Se uma tabela não tem uma primary key, às vezes é útil adicionar uma com mutate() e row_number(). Isso
# facilita combinar observações se fez alguma filtragens e quer verificar nos dados originais. Isso é 
# chamado de surrogate key (chave substituta).
# 
######### MUTATING JOINS
# Mutating Joins => Permite combinar variáveis de duas tabelas. Primeiro ele combina observações por suas
# keys, depois copia as variáveis de uma tabela para a outra.
# 
# Como mutate() as funções joins adicionam variáveis à direita, então, se já tem diversas variáveis, as 
# novas não serão impressas.
flights2 <- flights %>%
  select(year:day, hour, origin, dest, tailnum, carrier)
flights2. 

# Quer adicionar o nome completo da linha aérea aos dados flights2, pode combinar os data frames 
# airlines e flights2 com left_join()
flights2 %>%
  select(-origin, -dest) %>%
  left_join(airlines, by = "carrier")

# O resultado de juntar as linhas aéreas em flights2 é uma variável adicional name. É por isso chamada
# de tipo de join de mutating joins. Nesse caso, poderia ter chego aos mesmo resultado usando mutate()
# e a criação de subconjuntos básica do R
flights2 %>%
  select(-origin, -dest) %>%
  mutate(name = airlines$name[match(carrier, airlines$carrier)])

####### ENTENDENDO JOINS
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)

y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)

# A coluna numérica representa a variável "key": estas são usadas para combinar as linhas entre as
# tabelas. A coluna cinza representa a coluna "value", que é levada junto. Um join é uma maneira de 
# conectar cada coluna em x a zero, uma ou mais linhas em y.

####### INNER JOIN
# O tipo mais simples de join é o inner join. Ele combina pares de observações sempre que suas keys forem
# iguais.
# 
# A saída de um inner join é um novo data frame que contém a key, os valores x e os valores y. Usamos
# by para dizer ao dplyr qual a variável é a key:
x %>%
  inner_join(y, by = "key")

####### OUTER JOINS
# Um inner join mantém as observações que aparecem em ambas as tabelas. Já um outer join mantém as que
# aparecem em pelo menos uma das tabelas. Há três tipos de outer joins:
# 
# 1) Um left join => Mantém todas as observações em x.
# 
# 2) Um right join => Mantém todas as observações em y.
# 
# 3) Um full join => Mantém todas as observações em x e y.
# 
# Esses joins funcionam ao adicionar-se uma observação "virtual" a cada tabela. Essa observação tem uma
# key que sempre combina (se nenhuma outra key combinar) e um valor preenchido com NA.
# 
######## KEYS DUPLICADAS
# Até agora, todos os diagramas supuseram que as keys são únicas. Mas esse nem sempre é o caso. Esta
# seção explica o que acontece quando elas não são únicas. Há duas possibilidades:
# 
# 1) Uma tabela keys duplicadas. Isso é útil quando quer adicionar uma informação adicional, já que 
# normalmente há um relacionamento em para muitos:
x <- tribble (
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  1, "x4"
)

y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2"
)
left_join(x, y, by = "key")

# 2) Ambas as tabelas têm keys duplicadas. Isso normalmente é um erro, porque em nenhuma tabela as keys
# identidicam uma observação de modo único. Quando você faz join de keys duplicadas, obtêm todas as 
# combinações possíveis, o produto Cartesiano:
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  3, "x4"
) 
y <- tribble(
  ~key, ~val_y,
  1, "y1", 
  2, "y2",
  2, "y3",
  3, "y4"
)
left_join(x, y, by = "key")

####### DEFININDO AS COLUNAS KEYS
# Até agora, os pares de tabelas sempre foram juntados por uma única variável, e essa variável tem o [
# mesmo nome em ambas as tabelas. Essa restrição foi codificada por by = "key". Pode usar outros valores
# para que by conecte as tabelas de outros jeitos:
# 
# 1) O padrão, by = NULL => Usa todas as variáveis que aparecem em ambas as tabelas, o chamado natural
# join. Por exemplo, as tabelas de voos e clima se combinam em suas variáveis comuns: year, month, day, 
# hour e origin:
flights2 %>%
  left_join(weather)

# 2) Um vetor de caractere, by = "x" => É como um natural join, mas usa apenas algumas das variáveis
# em comum. Por exemplo, flights e planes têm variáveis year, mas significam coisas diferentes, então
# só queremos fazer join por tailnum:
flights2 %>%
  left_join(planes, by = "tailnum")
# NOTE => Que as variáveis year (que aparecem em ambos os data frames de entrada, mas não são 
# restringidas por igualdade) são desambíguadas na saída com um sufixo.
# 
# 3) Um vetor de caracteres nomeados by = c("a" = "b") => Isso combinará a variável a na tabela x á 
# variável b na tabela y. As variáveis de x serão usadas na saída.
# Por exemplo, se quisermos desenhar uma mapa, precisaremos combinar os dados de voo aos dados de 
# aeroportos, que contêm a localização (lat, e long) de cada aeroporto. Cada voo tem um aeroporto de 
# origem e de destino, então precisaremos especificar as quais queremos fazer join:
flights2 %>%
  left_join(airports, c("dest" = "faa"))

flights2 %>%
  left_join(airports, c("origin" = "faa"))

######### OUTRAS INFORMAÇÕES
# base::merge() pode realizar todos os quatro tipos de mutating join:
# dplyr                        merge
# inner_join(x, y)             merge(x, y)
# left_join(x, y)              merge(x, y, all.x = TRUE)
# right_join(x, y)             merge(x, y, all.y = TRUE)
# full_join(x, y)              merge(x, y, all.x = TRUE, all.y = TRUE)

# As vantagens dos verbos especificos do dplyr é que eles transmitem mais claramente a intenção do seu 
# código: a diferença entre os joins é muito importante, mas fica oculta nos argumentos de merge(). Os
# joins do dplyr são consideravelmente mais rápidos e não bagunçam a ordem das linhas.
# 
# O SQL é a inspiração para as convenções do dplyr, então a tradução é direta:
# 
# dplyr                             SQL
# inner_join(x, y, by = "z")        SELECT * FROM x INNER JOIN y USING(z)
# left_join(x, y, by = "z")         SELECT * FROM x LEFT JOIN y USING(z)
# right_join(x, y, by = "z")        SELECT * FROM x RIGHT JOIN y USING(z)
# full_join(x, y, by = "z")         SELECT * FROM x FULL OUTER JOIN y USING(z)
# 
# Note => Que INNER e OUTER são opcionais e frequentemente omitidos.
# 
# Fazer join em variáveis diferentes entre as tabelas, por exemplo, inner_join(x, y, by = c("a" = "b")),
# usa uma sintaxe levemente diferente em SQL: SELECT * FROM x INNER JOIN y ON x.a = y.b. Como essa 
# sintaxe sugere, o SQL suporta uma gama mais ampla de tipos do que dplyr, porque pode conectar as tabe-
# las usando restrições diferentes da igualdade(ás vezes chamadas de não-equijoins)
# 
########## FILTER JOINS
# Filtering joins combinam observações do mesmo modo que mutating joins, mas afetam as observações, não
# as variáveis. Há dois tipos:
# 
# 1) semi_join(x, y) => Mantém todas as observações em x que tenham uma combinação em y.
# 
# 2) anti_join(x, y) => Deixa de lado todas as observações em x que tenham uma combinação em y.
# 
# Semijoins => São úteis para combinar tabelas de resumo filtradas com as linhas originais
# Por exemplo, imagine que tenha descoberto os top 10 destinos mais populares
top_dest <- flights %>%
  count(dest, sort = TRUE) %>%
  head(10)
top_dest

# Agora quer descobrir cada voo que foi para um desses destinos.

flights %>%
  filter(dest %in% top_dest$dest)

flights %>%
  semi_join(top_dest)

flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = TRUE)

# Por exemplo, altitude e a longitude identificam unicamente cada aeroporto, mas não são bons identifica-
# dores
# 
airports %>%
  count(alt, lon) %>%
  filter (n > 1)

######## OPERADORES DE CONJUNTOS
# São ocasionalmente úteis quando quer separar um único filtro complexo em partes mais simples. 
# Todas essas operações funcionam com uma linha completa, comparando os valores de cada variável. Elas
# esperam que as entradas de x e y tenham as mesmas variáveis e tratem as observações como conjuntos
# 
# intersect(x, y) => Retorna apenas observações em ambos x e y
# 
# union(x, y) => Retorna observações únicas em x e y
# 
# setdiff(x, y) => Retorna observações em x, mas não em y
# 
# Dados estes dados simples:
df1 <- tribble(
  ~x, ~y,
  1, 1,
  2, 1
)

df2 <- tribble(
  ~x, ~y, 
  1, 1,
  1, 2
  
)

# As quatro possibilidades são:
intersect(df1, df2)

# note that we get 3 rows, not 4
union(df1, df2)

setdiff(df1, df2)

setdiff(df2, df1)
