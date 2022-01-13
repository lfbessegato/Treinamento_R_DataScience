#### PRE-REQUISITO
# Carregar arquivos simples em R com o pacote readr, que faz parte do núcleo tidyverse
library(tidyverse)

# a maioria das funções de readr é focada em transformar arquivos simples em data 
# frames
# 
# read_csv() => lê por arquivos delimitados por vírgulas.
# read_csv2() => lê arquivos separados por ponto e vírgula.
# read_tsv() => lê arquivos delimitados com tabulações.
# read_delim() => lê arquivos com qualquer delimitador.
# read_fwf() => lê arquivos de largura fixa.Você pode especificar campos por suas 
#               larguras com fwf_widths() ou por suas posições com fwf_positions().
# read_table() => lê uma variação comum de arquivos de largura fixa, onde colunas 
#                 são separadas por espaços em branco.
# read_log() => lê arquivos de registro do estilo Apache.

heights <- read_csv("data/heights.csv")

# Quando você executa read_csv(), ele imprime uma especificação de coluna que lhe dá # o nome e o tipo de cada uma.
# 
# Também pode fornecer um arquivo CSV em linha. Isso é útil para experimentar com 
# readr e para criar exemplos  reprodutíveis para compartilhar com outras pessoas.
read_csv("a, b, c
         1,2,3
         4,5,6")

# Em ambos os casos, read_csv() usa a primeira linha dos dados para nomes de colunas
# o que é uma convenção muito comum.

## * Ás vezes há algumas linhas de metadados no topo do arquivo. Você pode usar 
## skip = n para pular as primeiras n linhas, ou usar comment = "#" para deixar de 
## lado todas as linhas que começam, por exemplo, com #
## 
read_csv("The first line of metadata
         The second line of metadata
         x,y,z
         1,2,3", skip = 2)

read_csv("# A comment i want to skip
         x,y,z
         1,2,3", comment = "#")

## * Os dados podem não ter nomes de colunas. Nesse caso, use col_names = FALSE
## para dizer a read_csv() para não tratar a primeira linha como cabeçalhos e, 
## em vez dissom rotulá-las sequencialmente de X1 a Xn: 
## \n => para adicionar uma nova linha
read_csv("1,2,3\n4,5,6", col_names = FALSE)

# Alternativamente, pode passar para col_names um vetor de caracteres, que será
# usado como os nomes das colunas
read_csv("1,2,3\n4,5,6", col_name = c("x","y","z"))

# Outra opção que normalmente precisa de ajustes é na. Ela especifica o valor ou (valores) usado para representar valores faltantes em seu arquivo.
read_csv("a,b,c\n1,2,.", na = ".")


##### ANALISANDO UM VETOR
# Funções parse_*() => essas funções recebem um vetor de caracteres e retornam um
# vetor mais especializado com um lógico, inteiro ou data:
str(parse_logical(c("TRUE","FALSE","NA")))
str(parse_integer(c("1","2","3")))
str(parse_date(c("2010-01-01","1979-10-14")))

parse_integer(c("1","231",".","456"),na = ".")

# Se a análise falhar obterá um erro
x <- parse_integer(c("123","345","abc","123.45"))
# E as falhas estarão como faltantes na saída
x

# Se houver muitas falhas de análise, você precisará usar problems() para obter
# o conjunto completo. Ele retorna um tibble, que você pode então manipular com 
# dplyr()
problems(x)

# Há oito analisadores importantes
# parse_logical() e parse_integer() => são analisadores lógicos e inteiros 
#                                      respectivamente
# parse_double() => É um analisador numérico estrito.
# parse_integer() => É um analisador numérico flexível.
# parse_character() => Parece tão simples que não deveria ser necessário. Mas 
#                      a complicação o torna importante: codificação de caracteres.
# parse_factor() => Cria a fatores, a estrutura de dados que R usa para representar
#                   variáveis categóricas com valores fixos e conhecidos.
# parse_datetime(), parse_date() e parse_time() => Permitem que você análise várias 
# especificações de data e hora. São os mais complicados, porque há muitas maneiras
# diferentes de escrever datas.
# 
# NÚMEROS
# Há três problemas complicadores
# * Alguns países usam . entre as partes inteiras e fracional enquantos outros usam
#   ,.
# * Números são frequentemente cercados por outros caracteres que fornecem algum 
#   contexto como "$100", ou "10%"
# * Números contêm, constantemente, caracteres de "agrupamento" para facilitar
#   sua leitura, "1.000.000", e esses caracteres variam por todo mundo.
#   
# Primeiro problema => Ignorar o valor padrão de . ao criar um nova localização e 
# estabelecer o argumento decimal_mark()
parse_double("1.23")
parse_double("1,23", locale = locale(decimal_mark = ","))

# Segundo problema => parse_number(), ele ignora caracteres não numéricos antes e
# depois de número. Isso é particularmente útil para moedas e porcentagens, mas 
# também funciona para extrair números inseridos em textos:
parse_number("$1000")
parse_number("20%")
parse_number("It cost$123.45")

# Terceiro problema => É tratado pela combinação de parse_number() e a localização
# já que parse_number() ignorará a "marca de agrupamento".
# 
# Used in America
parse_number("$123,456,789")

# Used in many parts of Europe
parse_number("123.456.789", locale = locale(grouping_mark = "."))

#### STRINGS
# parse_character() => Deveria ser bem simples. Podemos obter ima representação
# subjacente de uma string usando charToRaw() onde cada número hexadecimal 
# representa um byte de informação.
charToRaw("Hadley")

# Codificação UTF-8 => Esse padrão pode codificar praticamente qualquer caractere
# usado por humanos hoje, bem como muitos símbolos extras (como emojis).
# 
# readr usa UTF-8 em toda parte: ele supôe que seus dados são codificados em UTF-8 # quando é lido, e sempre utiliza ao escrever. As vezes os caracteres podem ficar 
# bagunçados, se os dados foram produzidos por sistemas antigos.
# Para corrigir precisa especificar a codificação em parse_character()
x1 <- "El Ni\xf1o was particularly bad this year"
x2 <- "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"
parse_character(x1, locale = locale(encoding = "Latin1"))
parse_character(x2, locale = locale(encoding = "Shift-JIS"))

# readr fornece guess_encoding() para ajudá-lo a descobrir a codificação correta
guess_encoding(charToRaw(x1))

##### FATORES 
# O R usa fatores para representar variáveis categóricas que têm um conjunto. 
# conhecido de valores possíveis. 
# Dê a parse_factor() => um vetor de levels conhecidos para gerar um aviso sempre
# que um valor inesperado for apresentado:
fruit <- c("apple","banana")
parse_factor(c("apple","banana","bananana"), levels = fruit)

#### DATAS, DATAS-HORAS E HORAS
# Escolha um dos três analisadores caso queira uma data (o número de dias desde o 
# o dia 01-01-1970),uma data-hora(o número de segundos desde a meia-noite de
# 01-01-1970) ou uma hora(o número de segundos desde a meia-noite)
# 
# parse_datetime() => Espera uma data-hora ISO8601(ano,mês,dia,hora,minuto,segundo)
parse_datetime("2010-10-01T2010")

# If time is omitted, it will be set to midnight
parse_datetime("20101010")

# parse_date() => Prevê um ano de quatro dígitos, um - ou /, o mês, um - ou /, e
# então o dia.
parse_date("2010-10-01")

# parse_time() => Prevê a hora, :, minutos, opcionalmente : e segundos, e um 
# especificador adicional a.m./p..m (manhã/noite, no sistema de 12h).
# O R não tem uma base muito boa para dados de tempo, então usamos a fornecida
# pelo pacote hms.
library(hms)
parse_time("01:10 am")
parse_time("20:10:01")

# Você pode fornecer seu próprio formato de data-hora, construído pelas seguintes
# partes:
# 
# * ANO
#     %Y (4 dígitos)
#     %y (2 dígito: 00-69 -> 2000-2069,70-99 -> 1970-1999)
# * MÊS
#     %m (2 dígitos)
#     %b (nome abreviado, como 'Jan')
#     %B (nome completo, como 'Janeiro')
# * DIA
#     %d (2 dígito)
#     %e (espaço à esquerda opcional
# * HORA
#     %H (formato de hora 0-23)
#     %I (formato de hora 0-12, deve ser usado como %p)
#     %p (Indicador a.m./p.m.)
#     %M (Minutos)
#     %S (Segundos)
#     %OS (Segundos Reais)
#     %Z (Fuso Horário)
#     %z (como offset) do UTC)
#     
# * NÃO DÍGITOS
#     %. (Pula um caractere não dígito)
#     %* (Pula qualquer número não dígito)
parse_date("01/02/15", "%m/%d/%y")
parse_date("01/02/15", "%d/%m/%y")
parse_date("01/02/15", "%y/%m/%d")

parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))

#### ANALISANDO UM ARQUIVO
# * Como readr adivinha automaticamente o tipo de cada coluna;
# * Como Sobrescrever a especificação padrão;
# 
# Como Emular o processo com um vetor de caracteres usando o guess_parser() que retorna
# o melhor palpite do readr, e parse_guess() que usa esse palpite para analisar a coluna.
guess_parser("2010-10-01")
guess_parser("15:01")
guess_parser(c("TRUE","FALSE"))
guess_parser(c("1", "5", "9"))
guess_parser(c("12,352,561"))

str(parse_guess("2010-10-01"))

# A heurística experimenta cada um dos tipos a seguir, parando quando encontra uma 
# combinação
# 
# lógica
#   Contém apenas "F", "T", "FALSE", "TRUE"
# 
# inteiro
#   Contém apenas caracteres numéricos (e -)
#   
# double
#   Contém apenas doubles válidos (incluindo números como 4.5e-5)
# 
# número
#   Contém doubles válidos com a marca de agrupamento inserida
# 
# hora 
#   Combina o time_format padrão
# 
# data 
#   Combina o date_format padrão
# 
# data-hora
#   Qualquer data ISO8601
#   
# Se nenhuma dessas regras se aplicar, então ficará como um vetor de strings.
# 
#### PROBLEMAS
# Os padrões nem sempre funcionam para arquivos maiores, há dois problemas básicos
# 
# * As primeiras 1.000 linhas podem ser um caso especial, e readr advinha um tipo que não é
# geral o suficiente.Por exemplo pode ter uma coluna de doubles que só contém inteiros nas 
# primeiras 1.000 linhas
# 
# * A coluna pode conter vários valores faltantes. Se as primeiras 1.000 linhas contém 
# apenas NAs, o readr achará que é um vetor de caracteres, enquanto você provavelmente 
# quer analisá-la como algo mais específico.
# 
# O readr contém um CSV desafiador que ilustra ambos os problemas
challenge <- read_csv(readr_example("challenge.csv"))

problems(challenge)
# Uma boa prática é trabalhar coluna por coluna até que não haja problema restante.
# 
# Para corrigir o chamado, comece copiando e colando a especificação de colunas na sua 
# chamada original
challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_integer(),
    y = col_character()
  )
)
problems(challenge)

# Então pode ajustar o tipo da coluna x:
challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_character()
  )
)

# Isso corrige o primeiro problema, mas se olharmos nas últimas linhas, você verá que suas
# datas estão armazenadas em um vetor de caracteres
tail(challenge)

# Para corrigir isso especificando que y é uma coluna de datas:
challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)
 
tail(challenge)

# Toda função parse_xyz() tem uma função col_xyz() correspondente. Você usar parse_xyz()
# quando os dados já estão em um vetor de caracteres no R, e usa col_xyz() quando que 
# dizer ao readr() como carregar os dados.
# É recomendável sempre fornecer col_types, contruindo a partir da impressão fornecida por 
# readr. Isso garante que você tenha um script de importação de dados, consistente e 
# reprodutível. 

### Outras Estratégias
# Há algumas outras estratégias gerais para ajuda na análise do arquivo
challenge2 <- read_csv(
                readr_example("challenge.csv"),
                guess_max = 1001
)

# Ás vezes é mais fácil diagnosticar problemas se você ler todas as colunas como vetores de 
# caracteres
challenge3 <- read_csv(readr_example("challenge.csv"),
    col_types = cols(.default = col_character())
)
challenge3

# Isso é particularmente útil em conjunção com type_convert(), que aplica as heurística 
# de análise às colunas de caracteres em um data frame.
df <- tribble(
  ~x,  ~y,
  "1", "1.21",
  "2", "2.32",
  "3", "4.56"
)
df
# Note the column types
type_convert(df)

# * Se estiver lendo um arquivo muito grande, talvez queira configurar n_max como um 
# numero pequeno, como 10.000 ou 100.000. Isso acelerá suas iterações, enquanto elimina
# problemas comuns

# * Se estiver tendo problemas grandes de análise, talvez seja mais fácil ler um vetor
# de caracteres de linhas com read_lines(), ou até um vetor de caracteres de comprimento 1
# com read_file(). Dessa forma pode usar as hablidades de análise de strings - para analisar
# formatos mais exóticos.
# 
######### ESCREVENDO EM UM ARQUIVO
# O readr vem duas funções para escrever dados de volta no disco write_csv() e write_tsv(). 
# Ambas as funções aumentam as chances de o arquivo de saída ser lido corretamente devido a:
# 
# * Sempre codificar strings em UTF-8
# * Salvar datas e datas-horas em formato ISO8601 para que possam ser analisadas facilmente
# em qualquer lugar.
# 
# write_excel_csv => exporta um arquivo CSV para o Excel
# 
write_csv(challenge, "challenge.csv")
challenge

write_csv(challenge,"challenge-2.csv")
read_csv("challenge-2.csv")

# Isso torna os CSVs pouco confiáveis para fazer cache de resultados provisórios é 
# necessário recriar a especificação de coluna toda vez que carregá-los. Há duas 
# alternativas: 
# * write_rds() e read_rds() => são wrappers uniformes em torno das funções do R base 
# readRDS() e saveRDS(). Eles armazenam dados no formato binário customizado do R, chamado
# RDS:
write_rds(challenge, "challenge.rds")
read_rds("challenge.rds")

# O pacote feather implementa um formato do arquivo binário rápido que pode ser
# compartilhado por várias linguagens de programação
#install.packages("feather")
library(feather)
write_feather(challenge,"challenge.feather")
read_feather("challenge.feather")

# O feather tende a ser mais rápido que o RDS e é utilizável fora do R. O RDS suporta 
# colunas-listas e o feather atualmente não suporta.
# 
###### OUTROS TIPOS DE DADOS
# haven => Lê arquivos SPSS, Stata e SAS
# readxl => Lê arquivos Excel (.xls e .xlsx)
# DBI => junto de um backend específico de banco de dado (por exemplo, RMySQL, RSQLite, 
# RPostgreSQL), permite executar consultas SQL contra uma base de dados e retorna um data 
# frame