
##### Realizar a instalação
#install.packages("tidyverse")

###### Carregar a Bibilioteca
library(tidyverse)

#### Executar o data frame mpg
mpg

##### Criando um ggplot
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

#### Template
ggplot(data = <DATA>)+
<GEOM_FUNCTION>(mapping = aes(<MAPPING>))

####### EXERCICIOS 
# 1. Execute ggplot(data = mpg). o que você vê?
ggplot(data = mpg)
# R: Um gráfico em Branco

# 2. Quantas linhas existem em mtcars? Quantas colunas?
count(mtcars)
# R: 32 linhas e 11 colunas

# 3. O que a variavel drv descreve? Leia a ajuda de ?mpg para descobrir
?mpg

# R: o tipo de trem de força, onde f = tração dianteira, r = tração traseira, 4 = 4wd

# 4. Faça um grafico de dispersao de hwy versus cyl
ggplot(data = mpg) +
  geom_point(mapping = aes(x = hwy, y = cyl))

####### Mapeamento Estético
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, colour = class))


ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy, size = class))

  # TOP
ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

  # BOTTOM
ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))

  # Deixar os pontos em Azul

ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue") 

############ EXERCICIOS
# 1. O que esta errado com este codigo? Por que os pontos não estão pretos?
# ggplot (data = mpg)+
#   geom_point(mapping = ares(x = displ, y = hwy, color = "blue"))

# R: Não tem valores diferentes, devido o uso da color = blue.

# 2. Quais as variaveis em mpg sao categoricas? Quais as variaveis sao continuas? 
# ?mpg
?mpg 

# R: Categorias = class, drv, trans, fl
#    constantes = displ, cyl, cty, hwy

# 3. Mapeie uma variavel continua para color, size e shape. Como essas 
# esteticas comportam de maneira diferente para variaveis categoricas e 
# continuas?

# TOP
# ggplot(data = mpg)+
#  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

# BOTTOM
# ggplot(data = mpg)+
#  geom_point(mapping = aes(x = displ, y = hwy, shape = class))

# Deixar os pontos em Azul

# ggplot(data = mpg)+
#  geom_point(mapping = aes(x = displ, y = hwy), color = "blue") 

#4. O que acontece se algo voce mapear uma estetica a algo diferente de um
# nome de variavel, como aes(color = displ < 5)
# ggplot(data = mpg)+ 
#  geom_point(mapping = aes(x = displ, y = hwy), color = displ < 5) 
# R: Apresenta erro informando que o objeto displ não foi encontrado

####### PROBLEMAS COMUNS

ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy)) 

# HELP DA FUNCAO
?ggplot

###### FACETAS
# facet_wrap
ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy))+
  facet_wrap(~ class, nrow = 2)

# facet_grid
ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy))+
  facet_grid(drv ~ cyl)

ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy))+
  facet_grid(. ~ cyl)

######## OBJETOS GEOMETRICOS

#### LEFT 
ggplot(data = mpg) +
  geom_point(mapping = aes ( x = displ, y = hwy))

#### RIGHT
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

#### GEOM_SMOOTH agrupando pelo drv com tipos de linhas diferentes
ggplot(data = mpg)+
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

?geom_smooth

##### Geom => Group
ggplot (data = mpg)+
  geom_smooth(mapping = aes(x = displ, y = hwy))

##### Agrupando pelo group = drv, com o mesmo tipo de linha
ggplot((data = mpg))+
  geom_smooth(mapping = aes(x = displ, y = hwy, group=drv))

#### Agrupando pelo grupo = drv, com cores diferentes nas linhas, 
#### sem legenda
ggplot(data = mpg)+
  geom_smooth(mapping = aes(x = displ, y = hwy, color = drv),
show.legend=FALSE)

##### Exibindo varios geoms no mesmo gráfico
ggplot(data = mpg)+
  geom_point(mapping = aes(x = displ, y = hwy))+
  geom_smooth(mapping = aes(x = displ, y = hwy))

##### Exibindo varios geoms no mesmo gráfico, com tratamento GLOBAL
ggplot(data = mpg, mapping = aes(x = displ, y = hwy))+
  geom_point()+
  geom_smooth()

#### Mapeamentos dos geoms em uma Função
ggplot(data = mpg, mapping = aes(x = displ, y = hwy))+
  geom_point(mapping = aes(color = class))+
  geom_smooth()

#### Mapeamentos com Filtros
ggplot(data = mpg, mapping = aes(x = displ, y = hwy))+
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(
    data = filter(mpg, class == "subcompact"),
    se = FALSE
  )


###### TRANSFORMACAO ESTATISTICAS
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))

# Help geom_bar
?geom_bar
##### STAT_COUNT, fazendo o mesmo gráfico anterior
ggplot(data = diamonds)+
  stat_count(mapping = aes(x = cut))

###### Grafico de Barras stat padrao
demo <- tribble(
  ~a, ~b,
  "bar_1", 20,
  "bar_2", 30,
  "bar_3", 40
)

ggplot(data = demo)+
  geom_bar(mapping = aes (x = a, y = b), stat="identity")


##### Grafico de barras proportion
ggplot(data = diamonds)+
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))

##### Grafico utilizando o stat_summary
# que resume os valores de y, para cada vlr individual de x
ggplot(data = diamonds)+
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

#### Ver uma lista completa de stats
?stat_bin

##### Ajustes de Posicao
# COLOR
ggplot(data = diamonds)+
  geom_bar(mapping = aes (x = cut, color = cut))

# FILL
ggplot(data = diamonds)+
  geom_bar(mapping = aes(x = cut, fill = cut))

# FILL na variavel clarity
ggplot(data = diamonds)+
  geom_bar(mapping = aes(x = cut, fill=clarity))

# POSITION = iddentity
# EX. 1
ggplot(
  data = diamonds, 
  mapping = aes(x = cut, fill=clarity)
) +
  geom_bar(alpha = 1/5, position = "identity")

# EX. 2
ggplot(
  data = diamonds, 
  mapping = aes(x = cut, color=clarity)
) +
  geom_bar(fill = NA, position = "identity")

# POSITION = fill
ggplot(data = diamonds)+
  geom_bar(
    mapping = aes(x = cut, fill=clarity),
    position = "fill"
  )

# POSITION = dodge
ggplot(data = diamonds)+
  geom_bar(
    mapping = aes (x = cut, fill = clarity),
    position = "dodge"
  )

# POSITION = jitter
ggplot(data = mpg)+
  geom_point(
    mapping = aes (x = displ, y = hwy),
    position = "jitter"
  )

?position_dodge
?position_fill
?position_identity
?position_jitter
?position_stack


##### SISTEMAS DE COORDENADAS

ggplot(data = mpg, mapping = aes(x = class, y = hwy))+
  geom_boxplot()

# coord_flip() troca x pelo y
ggplot(data = mpg, mapping = aes(x = class, y = hwy))+
  geom_boxplot() +
  coord_flip()

# Mapas

nz <- map_data("nz")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color="black")

# coord_quickmap = ajusta o mapa conforme a proporcao da tela
ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color="black")+
  coord_quickmap()

##############
# coord_polar - conexão entre graf. de barras e graf. de setores
bar <- ggplot(data = diamonds)+
  geom_bar(
    mapping = aes(x = cut, fill = cut),
    show.legend = FALSE, 
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()
