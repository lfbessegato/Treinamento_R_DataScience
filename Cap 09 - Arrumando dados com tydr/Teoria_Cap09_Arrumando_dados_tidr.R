#### DADOS ARRUMADOS (Tidy Data)
# O tydr é membro do pacote tidyverse
library(tidyverse)

# O exemplo a seguir mostra quatro maneiras diferentes de organiza-los. 
# Cada conjunto de dados exibe os mesmos valores de 4 variaveis: Country, Year, Populations 
# Cases.

# Exemplo 1
table1

# Exemplo 2
table2

# Exemplo 3
table3

# Exemplo 4
table4a # Cases

table4b # Population

# Há três regras inter-relacionadas que tornam um conjunto de dados tidy:

# 1. Cada variável deve ter sua própria coluna.
# 2. Cada Observação deve ter sua própria linha.
# 3. Cada valor deve ter sua própria célula.
# 
# dplyr e ggplot2 e todos os outros pacotes no tidyverse são projetados para trabalhar com 
# dados arrumados. Eis alguns pequenos exemplos mostrando como pode trabalhar com table1

# Compute rate per 10.000
table1 %>%
  mutate(rate = cases / population * 10000)

# Compute cases per year
table1 %>%
  count(year, wt = cases)

# Visualize changes over time
library(ggplot2)
ggplot(table1, aes(year, cases)) +
  geom_line(aes(group = country), color = "grey50") + 
  geom_point(aes(color = country))

#### ESPALHANDO E REUNINDO
# A maioria dos conjuntos de dados não estão arrumados, há duas razões principais:

# 1. A maioria das  pessoas não está familiarizada com os principios de dados tidy, e 
# é dificil derivá-los sozinho, a não ser que você passe muito tempo trabalhando com dados.
# 
# 2. Os dados frequentemente são organizados para facilitar algum outro uso que não seja 
# a análise. POr exemplo, facilitar o máximo possível a entrada.
# 
# Significa que, para a maioria das análises reais, precisará fazer algumas arrumação. 
# O primeiro passo é sempre descobrir quais são as variáveis e as observações. As vezes
# é fácil, e outras vezes precisará consultar as pessoas que originalmente geraram os dados.
# O segundo passo é resolver um dos dois problemas 
# 1. Uma variável pode estar espalhada por várias colunas
# 2. Uma observação pode estar espalhada por várias linhas.
# 
# Para corrigir um dos problemas, precisará das duas funções mais importantes do tidyr: 
# gather() e spread()
# 
####### REUNINDO
# Um problema comum é ter um conjunto de dados em que alguns dos nomes de colunas não são 
# nomes de variáveis, mas valores de uma variável. 
# Veja table4a => Os nomes das colunas 1999 e 2000 representam valores year, e cada linha 
# representa duas observações, não uma.
table4a

# Para arrumar um conjunto de dados como esse, precisa reunir essas colunas em um novo par
# de variáveis, Para descrever a operação, precisa de três parâmetros:
# 
# 1. O conjunto de colunas que representa valores, não variáveis. Nesse exemplo, são as 
# colunas 1999 e 2000.
# 2. O nome da variável cujos valores formam os nomes das colunas. Eu a chamo de key, e aqui
# é year.
# 3. O nome da variável cujos valores estão espalhados pelas células. Eu a chamo de value,
# e aqui é o número de cases.Juntos, esses parâmetros geram a chamada para gather()
# 
table4a %>%
  gather(`1999`, `2000`, key = "year", value = "cases")

# Podemos usar gather() para arrumar a table4b de maneira similar. Única diferença é a 
# variável armazenada nos valores das células.
table4b %>%
  gather(`1999`, `2000`, key = "year", value = "population")

# Para combinar as versões tidy de table4a e table4b em um único tibble, precisamos usar
# dplyr::left_join().
tidy4a <- table4a %>%
  gather(`1999`, `2000`, key = "year", value = "cases")

tidy4b <- table4b %>%
  gather(`1999`, `2000`, key = "year", value = "population")
left_join(tidy4a, tidy4b)

##### ESPALHANDO
# É o oposto de reunir, faz isso quando uma observação está espalhada por várias linhas.
# Por exemplo a table2 - uma observação é um país em um ano, mas cada observação está 
# espalhada por duas linhas.[
# 
table2

# Para arrumar, primeiro analisamos a representação de maneira similar a gather(), dessa
# vez só precisamos de dois parâmetros
# 
# 1) A coluna que contém os nomes de variáveis, a coluna key. Aqui é type.
# 2) A coluna que contém valores forma múltiplas variáveis, a coluna value. Aqui é count.
# 
# Uma vez entendido podemos usar o spread(.
# 
spread(table2, key = type, value = count)

# Argumentos comuns de key e value, spread() e gather() são complementos. gather() torna
# as tabelas amplas mais estreitas e longas, spread() torna as tabelas longas mais curta
# e largas.

##### SEPARANDO E UNINDO 
# A table3 tem um problema diferente: uma coluna (rate) que contém duas variáveis (cases e 
# population). Para corrigir esse problema, precisaremos da função separate(). Você também
# aprenderá sobre o complemento de separate(): unite(), que usa se uma única variável 
# estiver espalhada pro várias colunas.

# Separate() => separa uma coluna em várias outras ao dividir sempre que um caractere 
# separador aparece
table3

# A coluna rate contém ambas as variáveis, cases e population, é preciso sapará-la em duas
# variáveis, separate() recebe o nome da coluna a ser separada e os nomes das colunas que
# surgirão.
table3 %>%
  separate(rate, into = c("cases", "population"))

# Por padrão, separate() separará valores sempre que vir um caractere não alfanumérico (
# isto é, um caractere que não seja um número ou uma letra). Por exemplo: No código anterior
# separate() separa os valores de rate nos caracteres de barra. Se quiser usar um caractere
# específico para separar uma coluna, pode passar o caractere para o argumento sep de 
# separate(), por exemplo: podemos escrever o código anterior como:
table3 %>%
  separate(rate, into = c("cases", "population"), sep = "/")

# Esse é o comportamento padrão em separate(): ele não deixa o tipo de coluna como ele é.
# Aqui, no entanto, não é muito útil, já que eles são realmente números. Pode-se solicitar 
# que separate() tente converter para tipos melhores usando convert = TRUE
# 
table3 %>%
  separate(
    rate, 
    into = c("cases", "population"),
    convert = TRUE
  )
# Pode usar esse arranjo para separar os dois últimos dígitos de cada ano. Isso torna os 
# dados menos arrumados, mas é útil em outros casos
table3 %>%
  separate(rate, into = c("cases", "population"), sep = 2)

######## UNIR
# unite() é o inverso de separate(): ele combina várias colunas em uma única. Pode usar 
# unite() para recombinar as colunas century e year que criamos no último exemplo.
# O unite() recebe um data frame, o nome da nova variável a ser criada e um conjunto de 
# colunas a serem combinadas
table5 %>%
  unite(new, century, year)

# Nesse caso precisamos usar também o argumento sep. O padrão colocará um undescore (_)
# entre os valores de colunas diferentes. Aqui não queremos nenhum separador, então usamos
# ""
table5 %>%
  unite(new, century, year, sep = "")

####### VALORES FALTANTES
# Mudar a representação de um conjunto de dados traz à tona uma importante sutileza dos 
# valores faltantes. Um valor pode estar faltando de uma de duas maneiras possíveis
# Explicitamente => sinalizado com NA
# Implicitamente => siplesmente não aparece nos dados
# 
stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)

# Há dois valores faltantes nesse conjunto de dados
# O retorno do quarto trimestre de 2015 está faltando explicitamente, porque a célula onde
# seu valor deveria estar contém um NA.
# O retorno do primeiro trimestre de 2016 está faltando implicitamente, porque simplesmente
# não aparece no conjunto de dados.
# 
# A maneira pela qual um conjunto de dados é representado pode tornar explícitos os valores
# implícitos. Por exemplo, podemos tornar explícito o valor faltante implícito ao colocar
# os anos nas colunas
stocks %>%
  spread(year, return)

# Como esses valores faltantes explícitos podem não ser importantes em outras representações
# dos dados, você pode configurar na.rm = TRUE em gather() para tornar implícitos os 
# valores faltantes explícitos
stocks %>%
  spread(year, return) %>%
  gather(year, return, `2015`:`2016`, na.rm = TRUE)

# Outra ferramenta importante para tornar explícitos os valores faltantes em dados tidy é
# complete()
stocks %>%
  complete(year, qtr)

# Há outra ferramenta importante para trabalhar com valores faltantes. Às vezes, quando
# uma fonte de dados foi primeiramente usada para a entrada de dados, valores faltantes 
# indicam que o valor anterior deve ser levado adiante.
treatment <- tribble (
  ~person, ~treatment, ~response,
  "Derrick Whitmore", 1,            7, 
  NA,                 2,            10,
  NA,                 3,            9,
  "Katherine Burke",  1,            4
)

# Pode preencher os valores faltantes com fill(). Recebe um conjunto de colunas onde 
# quer que os valores faltantes sejam substituídos pelo valor não faltante mais recente
# (às vezes chamado de última observação levada adiante)
treatment %>%
  fill(person)


######## ESTUDO DE CASO
# O conjunto de caso tidy::who contém casos de tuberculose(TB) separados por ano, país,
# idade, gênero e método de diagnose.
# Há uma riqueza de informações epidemiológicas neste conjunto de dados, mas é desafiador 
# trabalhar com os dados na forma em que são fornecidos.
who

# Esse é um conjunto de dados real bem típico. Contém colunas redundantes, códigos estranhos
# de variáveis e muitos valores faltantes. Who é bagunçado. Como dplyr, o tidyr é projetado
# para cada função faça uma única coisa muito bem. Em situações reais, isso significa que 
# você normalmente precisa juntar vários verbos em um pipeline.

# O melhor lugar para começar é quase sempre reunindo as colunas que não são variáveis 

# * Parece que country, iso2 e iso3 são três variáveis que redundantemente especificam o
# país.
# * year também é claramente uma variável.
# * Não sabemos o que são todas as outras colunas, mas dada a estrutura dos nomes das 
# variáveis(por exemplo, new_sp_m014, new_ep_m014, new_ep_f014), provavelmente são valores,
# não variáveis.

# Então precisamos reunir todas as colunas de new_sp_m014 até newrel_f65. Não s, então lhe
# daremos o nome genérico "Key". Nós sabemos que as células representam a contagem de casos,
# então usaremos a variável cases. Há vários valores faltantes na representação atual. Por 
# enquanto, usaremos na.rm só para podermos focar nos valores que são apresentados.

who1 <- who %>%
  gather(
    new_sp_m014:newrel_f65, key = "key",
    value = "cases",
    na.rm = TRUE
  )
who1

# Podemos conseguir algumas dicas da estrutura dos valores na nova coluna key ao contá-los
who1 %>%
  count(key)

# 1. As primeiras três letras de cada coluna denotam se a coluna contém casos novos ou 
# antigos de TB. Nesse conjunto de dados, cada uma delas contém novos casos.
# 2. As duas letras seguintes descrevem o tipo de TB:
#   * rel => é para casos de relapsidade.
#   * ep => é para casos de TB extrapulmonar.
#   * sn => é para casos de TB pulmonar que não poderiam ser diagnosticados por uma amostra 
#   pulmonar (amostra negativa).
#   * sp => é para casos de TB pulmonar que poderiam ser diagnosticados por uma amostra
#   pulmonar (amostra positiva).
# 3. A sexta letra dá o gênero dos pacientes de TB. O conjunto de dados agrupa casos por 
# homens (m) e mulheres (f).
# 4. O restante dos números dá a faixa etária. O conjunto de dados agrupa os casos em sete
# faixas etárias
#   014 => 0 - 14 anos
#   1524 => 15 - 24 anos
#   2534 => 25 - 34 anos
#   3544 => 35 - 44 anos
#   4554 => 45 - 54 anos
#   5564 => 55 - 64 anos
#   65 => 65 ou mais
#   
# Substitua os caracteres "newrel por "new_rel. Isso torna consistentes todos os nomes de 
# variáveis.
who2 <- who1 %>%
  mutate(key = stringr::str_replace(key, "newrel", "new_rel"))
who2

# Podemos separar os valores em cada código com duas passagens de separate(). A primeira
# passagem separará os códigos em cada underscore:
who3 <- who2 %>%
  separate(key, c("new", "type", "sexage0"), sep = "_")
who3

# Depois podemos deixar de lado a coluna new, porque ela é constante neste conjunto de dados
# Enquanto estamos deixando colunas de lado, vamos deixar de lado também iso2 e iso3, já que
# são redundantes.
who3 %>%
  count(new)

who4 <- who3 %>%
  select(-new, -iso2, -iso3)

# Em seguida vamos separar sexage em sex e age ao separar depois do primeiro caractere
who5 <- who4 %>%
  separate(sexage0, c("sex", "age"), sep = 1)

# O conjunto de dados who agora está arrumado!
# Foi mostrado um pedaço do código de cada vez, atribuído cada resultado provisório a uma 
# nova variável. Normalemente não é assim que trabalharia interativamente. Em vez disso, 
# você construiria gradualmente um pipe complexo: 
who %>%
  gather(code, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>%
  mutate(
    code = stringr::str_replace(code, "newrel", "new_rel")
  ) %>%
  separate(code, c("new", "var", "sexage")) %>%
  select(-new, -iso2, -iso3) %>%
  separate(sexage, c("sex", "age"), sep = 1)
