############ INTRODUÇÃO
# Precisa comunicar sua compreensão para os outros. Nesse capítulo foca nas ferramentas necessárias para a criação
# de bons gráficos 

########## PRÉ-REQUISITOS
# Neste caṕitulo será dado ênfase mais uma vez no ggplot2. Também será usado um pouco do dplyr para manipulação de 
# dados, e alguns pacotes de extensão de ggplot2, incluindo o ggrepel e viridis.
library(tidyverse)
# install.packages("viridis")
library(viridis)

######### RÓTULO
# O modo mais fácil de começar ao transformar um gráfico exploratório em um gráfico expositório é com bons rótulos.
# Adiciona rótulos com a função labs().
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    title = paste(
      "Fuel efficiency generally decreases with",
      "engine size"
    )
  )

# O propósito de um título de gráfico é resumir a descoberta principal.Evitar títulos que só descrevam o que é o 
# gráfico.

# Se pecisar adicionar mais texto, há dois outros rótulos úteis que pode usar em ggplot2 
# subtitle => Insere detalhes adicionais em uma fonte menor abaixo do título.
# caption => Insere texto no canto inferior direito do gráfico, frequentemente usado para descrever a fonte de
# dados:

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    title = paste(
      "Fuel efficiency generally decreases with",
      "engine size"),
    
    subtitle = paste(
      "Two seaters (sports cars) are an exception",
      "because of their light weight"),
    
    caption = "Data from fueleconomy.gov"
  )

# Também pode usar labs() para substituir os títulos dos eixos e da legenda. Normalmente é uma boa idéia substituir
# nomes curtos de variáveis por descrições mais detalhadas, e incluir as unidades:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  )

# É possível usar equações matemáticas, em vez de strings de texto. Só troque "" por quote()
df <- tibble(
  x = runif(10),
  y = runif(10)
)
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    x = quote(sum(x[i] ^ 2, i == 1, n)),
    y = quote(alpha + beta + frac(delta, theta))
  )

################### ANOTAÇÕES
# Além de rotular os componentes principais de seu gráfico, muitas vezes é importante rotular observações 
# individuais ou grupo de observações. A primeira ferramenta que tem à disposição é geom_text()
# geom_text() => É parecida com geom_point(), mas tem uma estética extra: label. Ela possibilita adicionar rótulos
# textuais aos gráficos.

best_in_class <- mpg %>%
  group_by(class) %>%
  filter(row_number(desc(hwy)) == 1)

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_text(aes(label = model), data = best_in_class)

# Dessa forma é dificil de ler, porque os rótulos se sobrepõem uns aos outros e aos pontos. Podemos deixar as coisas
# um pouco melhores trocando o geom_label(), que desenha um retângulo atrás do texto. Também podemos usar o 
# parâmetro nudge_y para mover os rótulos levemente para cima dos pontos correspondentes:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_label(
    aes(label = model),
    data = best_in_class, 
    nudget_y = 2,
    alpha = 0.5
  )

# Esse modo ajuda um pouco, mas se observar de perto o canto superior esquerdo, notará que há dois rótulos
# praticamente um em cima do outro Isso acontece porque a milhagem  de rodovia e o deslocamento paa os melhores
# carros nas categorias compacto e subcompacto são exatamente as mesmas. Não há como corrigir isso aplicando a 
# mesma transformação para cada rótulo. Em vez disso, podemos usar o pacote ggrepel, que ajustará automaicamente
# os rótulos para que não se sobreponham:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_point(size = 3, shape = 1, data = best_in_class) +
  ggrepel::geom_label_repel(
    aes(label = model),
    data = best_in_class
  )

# Note outra técnica útil usada aqui: a adição de uma segunda camada de pontos grandes e ocos para destacar os 
# pontos que foi rotulado.

# As vezes é possível usar a mesma ideia para substituir a legenda com rótulos posicionados diretamente no gráfico
# Não é ótimo para esse gráfico, mas não é muito ruim.
# (theme(legend.position = "none")) desabilita a legenda 

class_avg <- mpg %>%
  group_by(class) %>%
  summarize(
    displ = median(displ),
    hwy = median(hwy)
  )

ggplot(mpg, aes(displ, hwy, color = class)) +
  ggrepel::geom_label_repel(aes(label = class),
                            data = class_avg,
                            size = 6,
                            label.size = 0,
                            segment.color = NA
  ) +
  geom_point() +
  theme(legend.position = "none")

# Alteranativamente pode só querer adicionar um único rótulo ao gráfico, mas ainda precisa criar um data frame.
# Talvez queira que o rótulo fque no cant do gráfico, então é conveniente criar um novo data frame summarize()
# para calcular os valores máximos e x e y:
label <- mpg %>%
  summarize(
    displ = max(displ),
    hwy = max(hwy),
    label = paste(
      "Increasing engine size is \nrelated to",
      "decreasing fuel economy."
    )
  )

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(
    aes(label = label),
    data = label,
    vjust = "top",
    hjust = "right"
  )

# Caso queira colocar o texto exatamente nas bordas do gráfico, use +inf e -Inf. Já que não estamos mais calculando
# posições de mpg, podemos usar o tibble() para criar o data frame:
label <- tibble(
  displ = Inf,
  hwy = Inf,
  label = paste(
    "Increasing engine size is \nrelated to",
    "decreasing fuel economy."
  )
)
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(
    aes(label = label),
    data = label,
    vjust = "top",
    hjust = "right"
  )


# Nestes exemplos foi quebrado manualmente os rótulos em linhas usando "\n". Outra abordagem é usar 
# stringr::str_wrap() para adicionar quebras de linha automaticamente, dado o número de caracteres que deseja por 
# linha:

"Increasing engine size related to decreasing fuel economy." %>%
  stringr::str_wrap(width = 40) %>%
  writeLines()

# Lembre-se, além de geom_text(), tem muitos outros geoms disponíveis emm ggplot2 para ajudá-lo a anotar seu plot.
# algumas ideias:

# 1) Use o geom_hline() e geom_vline() para adicionar linhas de referência. Frequentemente deixo grossas (size = 2)
# e brancas(color = white), e as desenho abaixo da primeira camada de dados. Isso facilita vê-las sem tirar a 
# atenção dos dados.

# 2) Use o geom_rect() para desenhar um retângulo em volta dos pontos de interesse. Os limites do retêngulo são 
# definidos pelas estéticas xmin, xmax, ymin e ymax.

# 3) Use o geom_segment() com o argumento arrow para chamar a atenção para um ponto com uma flecha. Use as estéticas
# x e y para definir o ponto de início, xend e yend para definir o ponto final.

# O único limite é sua imaginaginação (e a sua paciência para posicionar as anotações de forma a serem 
# estaticamente agradáveis)


################## ESCALAS
# A terceira maneira de tornar seu gráfico melhor para a comunicação é ajustando as escalas.Elas controlam o 
# mapeamento dos valores de dados para coisas que você pode perceber. Normalmente o ggplot2 adiciona escalas 
# automaticamente. Por exemplo, quando digita:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class))

# o ggplot2 adiciona automaticamente escalas nos bastidores:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  scale_x_continuous() +
  scale_y_continuous() +
  scale_color_discrete()

# As escalas padrão foram cuidadosamente escolhidas para fazer um bom trabalho para uma ampla gama de entradas.
# Porém pode querer substituí-las por duas razões:

# 1) Ajustar => Alguns dos parâmetros da escala padrão. Isso permite que faça coisas como mudar as quebras nos 
# eixos ou os rótulos principais na legenda.

# 2) Substituir => a escala toda e usar um algoritmo completamente diferente. Muitas vezes pode fazer melhor que o
# padrão, porque conhece mais os dados.

################### MARCAS DOS EIXOS E CHAVES DE LEGENDA
# Há dois argumentos primários que afetam a aparência das marcas nos eixos e as chaves na legenda. breaks e labels

# breaks => Controla a posição das marcas, ou os valores associados às chaves.
# labels => Controla o rótulo de texto associado a cada marca/chave.

# O uso mais comum para breaks é substituir a escolha padrão:
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  scale_y_continuous(breaks = seq(15, 40, by = 5))

# Pode usar labels da mesma maneira (um vetor de caracteres do mesmo comprimento de breaks), mas também pode
# Configurá-lo como NULL para suprimir todos os rótulos. Isso é útil para mapas, ou para publicar gráficos em que 
# não pode compartilhar os números absolutos:
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  scale_x_continuous(labels = NULL) +
  scale_y_continuous(labels = NULL)

# Também pode usar breaks e labels para controlar a aparência das legendas. Coletivamente, eixos e legendas são 
# chamados de guias. Eixos são usados para as estéticas x e y: legendas são usadas para todo o resto.

# Outro uso do breaks é quando tem relativamente poucos pontos de dados e quer destacar exatamente onde as 
# observações ocorreram. Por exemplo, veja este gráfico que mostra quando cada presidente norte-americano 
# começou e terminou seu mandato:
presidential %>%
  mutate(id = 33 + row_number()) %>%
  ggplot(aes(start, id)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_x_date(
    NULL,
    breaks = presidential$start,
    date_labels = "'%y"
  )

# Perceba que a especificação de breaks e labels para escalas de data e data-hora é um pouco diferente:

# data_labels() => Recebe uma especificação de formato, na mesma forma que parse_datetime().
# date_breaks(não exibido aqui) => Recebe uma string como "2 days" ou "1 month"

#################### LAYOUT DE LEGENDA
# Usará principalmente breaks e labels para ajustar os eixos. Enquanto ambas também funcionam para legendas, há
# algmas outras técnicas que terá mais propensão de usar.

# Para controlar a posição geal da legeda, pecisa usar uma configuração  theme(). Eles controlam as partes sem
# dados do gráfico. A configuração de tema legend.position controla onde a legenda é desenhada:
base <- ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class))

base + theme(legend.position = "left")
base + theme(legend.position = "top")
base + theme(legend.position = "bottom")
base + theme(legend.position = "right") # The default

# Também pode usar legend.position = "none" para suprimir completamente a exibição da legenda.

# Para controlar a exibição de legendas individuais use guides() junto a guide_legend() ou guide_colorbar(). O
# exemplo a seguir mostra duas configurações importante: controlar o número de linhas que a legenda usa com nrow,
# substituir uma das estéticas para aumentar os pontos. Isso é particularmente útil se usou um alpha baixo para 
# exibir muitos pontos em um gráfico:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme(legend.position = "bottom") +
  guides(
    color = guide_legend(
      nrow = 1,
      override.aes = list(size = 4)
    )
  )
#> `geom_smooth()` using method = 'loess'

############## SUBSTITUINDO UMA ESCALA
# Em vez de só ajustar um pouco os detalhes, pode substituir completamente a escala. Há dois tipos de escala que 
# provavelmente vai querer trocar: escalas de posição contínua e escalas de cor. Felizmente, os mesmos príncipios
# se aplicam a todas as outras estéticas, então, uma vez que tenha dominado posição e cor, será capaz de fazer 
# rapidamente outras substituições de escalas.

# É muito útil fazer gráficos de transformações de sua variável. Por exemplo, como observamos.

ggplot(diamonds, aes(carat, price)) +
  geom_bin2d()
ggplot(diamonds, aes(log10(carat), log10(price))) +
  geom_bin2d()

# Contudo, a desvantagem dessa transformação é que os eixos estão agora rotulados com os valores transformados, 
# dificultando a interpretação do gráfico. Em vez de fazer a transformação no mapeamento estético, podemos fazê-la
# com a escala. Isso é visualmente idêntico, exceto que os eixos estão rotulados com a escala original dos dados:
ggplot(diamonds, aes(carat, price)) +
  geom_bin2d() +
  scale_x_log10() +
  scale_y_log10()

# Outra escala que é frequentemente customizada é a de cor. A escala categórica padrão escolhe cores que são 
# igualmente espaçadas pela roda de cores. Alternativas úteis são as escalas ColorBrewer, que foram ajustadas à 
# mão para funcionarem melhor para pessoas com tipos comuns de daltonismo. Os dois gráficos a seguir se parecem, 
# mas há diferença suficiente nos tons de vermelho e verde para que os pontos à direita possam ser distinguidos 
# mesmo por pessoas com daltonismo vermelho-verde:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv))

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  scale_color_brewer(palette = "Set1")

# Não se esqueça de técnicas simples. Se há apenas algumas cores, pode adicionar um mapeamento redundante com 
# formas. Assim ajudará a garantir que o gráfico seja interpretável também em preto e branco:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv, shape = drv)) +
  scale_color_brewer(palette = "Set1")

# As escalas ColorBrewer estão documentadas online em http://colorbrewer2.org/ e disponíveis no R através do 
# pacote RColorBrewer. As paletas sequencial(superior) e divergente (inferior) são particularmente úteis se seus
# valores categóricos estiverem ordenados, ou tenham um "meio". Isso surge com frequencia se foi usado cut() para
# transformar uma variável contínua em uma variável categórica.

# Quando tem um mapeamento predefenido entre valores e cores, use scale_color_manual(). Por exemplo, se mapearmos
# os partidos políticos norte-americanos com cores, usaremos o mapeamento padrão de vermelho para Republicanos e 
# Azul para Democratas
presidential %>%
  mutate(id = 33 + row_number()) %>%
  ggplot(aes(start, id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_colour_manual(
    values = c(Republican = "red", Democratic = "blue")
  )

# Para cores contínuas, pode usar o scale_color_gradient() ou o scale_fill_gradient(). Se tiver uma escala 
# divergente, pode usar o scale_color_gradient2(). Isso te permite dar, por exemplo, cores diferentes para valores
# positivos e negativos.

# Outra opção é scale_color_viridis(), fornecidas pelo pacote viridis. É uma escala contínua análoga às escalas
# categóricas ColorBrewer.
df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed()

#> Loading required package: methods
ggplot(df, aes(x, y)) +
  geom_hex() +
  viridis::scale_fill_viridis() +
  coord_fixed()

# Note que todas as escalas de cor vêm em duas variedadess: scale_color_x() e scale_fill_x() para as estéticas
# color e fill, respectivamente (as escalas de cor estão disponíveis tanto com a escrita norte-americana quanto 
# com a britânica)

################### DANDO ZOOM
# Há três maneiras de controlar limites de gráficos

# 1) Ajustando os dados do gráfico
# 2) Configurando limites em cada escala
# 3) Configurando xlim e ylim em coord_cartesian()

# Para dar zoom em uma região do gráfico, geralmente é melhor coord_cartesian(), compare os dois gráficos a seguir:
ggplot(mpg, mapping = aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth() +
  coord_cartesian(xlim = c(5, 7), ylim = c(10, 30))

mpg %>%
  filter(displ >= 5, displ <= 7, hwy >= 10, hwy <= 30) %>%
  ggplot(aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth()

# Geralmente é mais útil se você expandir os limites, por exemplo, para combinar escalas entre gráficos diferentes
# Por exemplo, se extrairmos duas classes de carros e fizermos gráficos delas separadamente, será difícil comparar
# os gráficos, porque todas as três escalas (o eixo x, o eixo y e a estética de cor) têm faixas diferentes:
suv <- mpg %>% filter(class == "suv")
compact <- mpg %>% filter(class == "compact")

ggplot(suv, aes(displ, hwy, color = drv)) +
  geom_point()

ggplot(compact, aes(displ, hwy, color = drv)) +
  geom_point()

# Uma maneira de superar esse problema é compartilhar escalas entre vários gráficos, formatando as escalas com os
# limites de todos os dados:
x_scale <- scale_x_continuous(limits = range(mpg$displ))
y_scale <- scale_y_continuous(limits = range(mpg$hwy))
col_scale <- scale_color_discrete(limits = unique(mpg$drv))

ggplot(suv, aes(displ, hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

ggplot(compact, aes(displ, hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

# Nesse casoem particular, poderia ter simplesmente usado facetas, mas essa técnica é geralmente mais útil se, por
# exemplo, quiser espalhar os gráficos por várias páginas de um relatório.

################### TEMAS
# Finalmente, pode customizar os elementos que não são dados do seu gráfico com um tema:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme_bw()

# O ggplot2 inclui oito temas por padrão. Muitos outros estão inclusos em pacotes adicionando como o ggthemes

############### SALVANDO SEUS GRÁFICOS
# Há duas maneiras principais de tirar seus gráficos do R e colocá-los em seu documento final:ggsave() e knitr
# A ggsave() salvará seu gráfico mais recente no disco:
ggplot(mpg, aes(displ, hwy)) + geom_point()

ggsave("my-plot.pdf")
#> Saving 6 x 3.71 in image
# Se não especificar width e height, eles terão as dimensões do dispositivo atual de plotagem.

