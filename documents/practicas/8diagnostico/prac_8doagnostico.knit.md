---
title: "Practica 8: Diagnóstico y Análisis de Sensibilidad"
subtitle: "Estadistica Multivariada - Sociología FACSO Universidad de Chile"
author: "Juan Carlos Castillo & Alejandro Plaza"
output:
  html_document:
    theme: flatly
    highlight: tango
    toc: true
    toc_float: true
    toc_depth: 2
    number_sections: true
---




## Introducción

La siguiente guía tiene como objetivo mostrar los comandos y funciones asociados al análisis de diagnóstico de un modelo de regresión lineal OLS.

Para realizar el diagnóstico al modelo de regresión lineal trabajaremos con una base de datos que evalua el efecto del comercio en el crecimiento económico.

**Frankel, Jeffrey A., and David Romer. 1999. "Does trade cause growth?", American Economic Review 89(3): 379–99.**

Se estudia los factores que predicen el PIB per capita (**logy**) en los paises, a partir de las siguientes variables independientes:

 - **open**: Apertura comercial.
 
 - **loglab**: la población económicamente activa
 
 - **Logland**: Área de la tierra.
 
Para consideraciones de este ejercicio sólo trabajaremos con los datos de 1985.

La base de datos la puedes descarcar desde [AQUI](https://www.dropbox.com/s/qde1gapk6bvo8x0/final.85.RData?dl=0)

## Preambulo de paquetes


```r
pacman::p_load(stargazer,tidyverse,gridExtra,ggplot2,gridExtra,broom,
car,lmtest,sandwich,interplot,ape,multiwayvcov)
```


##Motivación: el cuarteto de anscombe
Como motivación al analisis de diagnóstico, revisemos la base de datos de Anscombe


###Modelos de regresión

```r
a1<-lm(y1~x1,data=anscombe)
a2<-lm(y2~x2,data=anscombe)
a3<-lm(y3~x3,data=anscombe)
a4<-lm(y4~x4,data=anscombe)
```



```r
stargazer(a1, a2, a3, a4, type="text", no.space=TRUE,
model.names=FALSE, notes="Errores Estándares en Parentesis")
```

```
## 
## ====================================================================
##                                        Dependent variable:          
##                              ---------------------------------------
##                                 y1        y2        y3        y4    
##                                 (1)       (2)       (3)       (4)   
## --------------------------------------------------------------------
## x1                           0.500***                               
##                               (0.118)                               
## x2                                     0.500***                     
##                                         (0.118)                     
## x3                                               0.500***           
##                                                   (0.118)           
## x4                                                         0.500*** 
##                                                             (0.118) 
## Constant                      3.000**   3.001**   3.002**   3.002** 
##                               (1.125)   (1.125)   (1.124)   (1.124) 
## --------------------------------------------------------------------
## Observations                    11        11        11        11    
## R2                             0.667     0.666     0.666     0.667  
## Adjusted R2                    0.629     0.629     0.629     0.630  
## Residual Std. Error (df = 9)   1.237     1.237     1.236     1.236  
## F Statistic (df = 1; 9)      17.990*** 17.966*** 17.972*** 18.003***
## ====================================================================
## Note:                                    *p<0.1; **p<0.05; ***p<0.01
##                                     Errores Estándares en Parentesis
```


##Construcción de gráficos

```r
# 4 nubes de puntos con las rectas de regresión.
F1 <- ggplot(anscombe)+aes(x1,y1)+geom_point()+
geom_abline(intercept=3,slope=0.5)

F2 <- ggplot(anscombe)+aes(x2,y2)+geom_point()+
geom_abline(intercept=3,slope=0.5)

F3 <- ggplot(anscombe)+aes(x3,y3)+geom_point()+
  geom_abline(intercept=3,slope=0.5)

F4 <- ggplot(anscombe)+aes(x4,y4)+geom_point()+
  geom_abline(intercept=3,slope=0.5)

# Mostrar los 4 gráficos en una figura
grid.arrange(F1,F2,F3,F4, ncol = 2)
```

<img src="prac_8doagnostico_files/figure-html/unnamed-chunk-4-1.png" width="672" />

Si bien las estimaciones del modelo de regresión son las mismas, en los gráficos podemos observar que el comportamiento de las variables evidentemente es distinto.






##Diagnóstico

Cargamos la base de datos


```r
load("final.85.RData")
```

Producimos los estadísticos descriptivos.

```r
# produce formatted descriptive statistics in pwt7.final
stargazer(final.85, type="text", median = TRUE)
```

```
## 
## ================================================================================================
## Statistic  N     Mean       St. Dev.      Min    Pctl(25)    Median     Pctl(75)        Max     
## ------------------------------------------------------------------------------------------------
## year      152  1,985.000      0.000      1,985    1,985       1,985       1,985        1,985    
## rgdpwok   151 10,696.670    9,635.187   705.000 2,784.000   7,091.000  16,062.500   38,190.000  
## rgdpch    152  4,423.257    4,423.595     299    1,156.5      2,564      6,154.2      19,648    
## open      152   73.874       45.928     13.160    43.297     63.715      95.078       318.070   
## labor     150 13,314.110   56,733.470   29.314   653.713    2,547.374   7,247.569   612,363.100 
## landarea  140 704,040.600 1,653,479.000 260.000 28,087.500 194,690.000 591,900.000 9,388,250.000
## logy      152    7.891        1.042      5.700    7.053       7.849       8.725        9.886    
## loglab    150    7.663        1.931      3.378    6.482       7.843       8.888       13.325    
## logland   140   11.656        2.416      5.561    10.243     12.179      13.291       16.055    
## ------------------------------------------------------------------------------------------------
```

Estimamos el modelo de regresión lineal



```r
# estimate OLS model and create output object
model1 <- lm(logy ~ open + loglab + logland, data=final.85)
# show model output
summary(model1)
```

```
## 
## Call:
## lm(formula = logy ~ open + loglab + logland, data = final.85)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -2.08668 -0.84133 -0.06493  0.63543  2.10309 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  6.583916   0.721687   9.123 9.63e-16 ***
## open         0.008170   0.002589   3.156  0.00198 ** 
## loglab       0.152110   0.066359   2.292  0.02345 *  
## logland     -0.041203   0.056498  -0.729  0.46710    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.9886 on 134 degrees of freedom
##   (14 observations deleted due to missingness)
## Multiple R-squared:  0.09674,	Adjusted R-squared:  0.07652 
## F-statistic: 4.784 on 3 and 134 DF,  p-value: 0.003369
```

A partir de la función **tidy** y **augment_columns** de la librería **broom**, podemos extraer las estimaciones del modelo de regresión lineal en formato de base de datos. 

Lo que hacemos posteriormente, es armar una nueva base de datos final.85v2 la cual contiene las siguientes variables nuevas para necesarios últeriores análisis

  - .fitted = Valores predichos de model1
  
  - .resid  = Residuos de model1
  
  - .hat    = Hat values para análisis de casos influyentes
  
  - cooksd  = Distancia de Cook para análisis de casos influyentes


```r
# tidy regression output
tidy(model1)
```

```
## # A tibble: 4 x 5
##   term        estimate std.error statistic  p.value
##   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
## 1 (Intercept)  6.58      0.722       9.12  9.63e-16
## 2 open         0.00817   0.00259     3.16  1.98e- 3
## 3 loglab       0.152     0.0664      2.29  2.35e- 2
## 4 logland     -0.0412    0.0565     -0.729 4.67e- 1
```

```r
final.85v2 <- augment_columns(model1, final.85)

# show variables in new data
names(final.85v2)
```

```
##  [1] "wbcode"     "year"       "country"    "rgdpwok"    "rgdpch"    
##  [6] "open"       "labor"      "continent"  "landarea"   "region"    
## [11] "lat"        "long"       "logy"       "loglab"     "logland"   
## [16] ".fitted"    ".se.fit"    ".resid"     ".hat"       ".sigma"    
## [21] ".cooksd"    ".std.resid"
```

```r
# produce descriptive statistics for new data
stargazer(as.data.frame(final.85v2), type = "text", median = TRUE)
```

```
## 
## =========================================================================================
## Statistic   N     Mean       St. Dev.      Min   Pctl(25)  Median   Pctl(75)      Max    
## -----------------------------------------------------------------------------------------
## year       138  1,985.000      0.000      1,985   1,985     1,985     1,985      1,985   
## rgdpwok    138 10,469.480    9,493.923     705   2,761.5    6,968    15,805     38,190   
## rgdpch     138  4,275.442    4,352.505     299   1,143.5    2,437    5,546.8    19,648   
## open       138   73.936       44.758     13.800   44.760   64.735    95.968     318.070  
## labor      138 12,798.700   58,085.070   29.314  611.136  2,350.242 6,043.913 612,363.100
## landarea   138 647,872.900 1,498,439.000   320    28,680   194,690   578,440   9,388,250 
## logy       138    7.859        1.029      5.700   7.042     7.798     8.621      9.886   
## loglab     138    7.573        1.918      3.378   6.415     7.762     8.707     13.325   
## logland    138   11.669        2.348      5.768   10.263   12.179    13.268     16.055   
## .fitted    138    7.859        0.320      7.324   7.666     7.827     7.967      9.991   
## .se.fit    138    0.157        0.061      0.084   0.117     0.144     0.181      0.575   
## .resid     138   -0.000        0.978     -2.087   -0.841   -0.065     0.635      2.103   
## .hat       138    0.029        0.033      0.007   0.014     0.021     0.034      0.338   
## .sigma     138    0.989        0.004      0.975   0.986     0.990     0.992      0.992   
## .cooksd    138    0.007        0.016     0.00001  0.001     0.003     0.008      0.170   
## .std.resid 138   -0.002        1.003     -2.129   -0.859   -0.067     0.649      2.155   
## -----------------------------------------------------------------------------------------
```



## Linealidad y Especificación del modelo


Los residuos deben ser independientes de los valores predichos de las variables dependientes. Cualquier correlación entre los residuos y los valores predichos violarian este supuesto.

- Sí los residuos muestran una patrón no lineal, como una **relación curvilinea**, el modelo esta especificado incorrectamente.

- Si la variable dependiente está relacionada linealmente con las variables independientes, el gráfico no deberia mostrar una **relación sistematica entre valores predichos y residuos**.




```r
ggplot(final.85v2, aes(x=.fitted, y=.resid)) +
geom_hline(yintercept=0) +
geom_point() +
geom_smooth(method='loess', se=TRUE)
```

<img src="prac_8doagnostico_files/figure-html/unnamed-chunk-10-1.png" width="672" />


En el caso del gráfico anterior:

- La mayoría de los puntos están distribuidos aleatoriamente alrededor de la linea residual=0, y el intervalo de confianza de la curva ajustada se solapara con la línea residual=0.


También podemos hacer la observación por variable


```r
# residuals against trade
ropen <- ggplot(final.85v2, aes(x=open, y=.resid)) +
geom_hline(yintercept=0) +
geom_point() +
geom_smooth(method='loess', se=TRUE)
# residuals against land
rland <- ggplot(final.85v2, aes(x=logland, y=.resid)) +
geom_hline(yintercept=0) +
geom_point() +
geom_smooth(method='loess', se=TRUE)
# residuals against labor
rlab <- ggplot(final.85v2, aes(x=loglab, y=.resid)) +
geom_hline(yintercept=0) +
geom_point() +
geom_smooth(method='loess', se=TRUE)
# display plots together
grid.arrange(ropen, rland, rlab, ncol=3)
```

<img src="prac_8doagnostico_files/figure-html/unnamed-chunk-11-1.png" width="672" />


Si bien, los gráficos pueden ser ilustrativos, no reemplazan un posterior análisis estadístico. En este caso realizamos el test de la especificación del error de Ramsey o **RESET**.

En términos generales, a partir del modelo estimado, se estima otro "expandido" el cuál incluye términos cuadráticos ( $\hat{y^2}$ ) o cúbicos ( $\hat{y^3}$ )  (para modelar la no linealidad), y luego se compara este modelo expandido con el modelo original.

La comparación se realiza a partir de la prueba $F$ (recordar F para comparación de modelos), en donde se prueba la hipótesis nula de que el modelos original  el expandido explicación el mismo monto de variación sobre la variable dependiente.

Si la hipótesis nula es rechazada, entonces algunas de las variables independientes afectan a la variable dependiente de manera no-lineal.

Por lo que se espera que no exista diferencias estadísticamente significativas.


```r
model1.q1 <- lm(logy ~ open + loglab + logland + I(.fitted^2),
data = final.85v2)
# F test of model difference
anova(model1, model1.q1)
```

```
## Analysis of Variance Table
## 
## Model 1: logy ~ open + loglab + logland
## Model 2: logy ~ open + loglab + logland + I(.fitted^2)
##   Res.Df    RSS Df Sum of Sq     F Pr(>F)
## 1    134 130.97                          
## 2    133 129.58  1    1.3875 1.424 0.2349
```

En este caso se puede ver que $F=1.424$ con un valor $p=0.2349$. Por lo cual si trabajos como una significación del 5%, fallamos en rechazar la hipótesis nula de que los dos modelos son idénticos.


## Multicolinealidad perfecta y alta

Una segunda condición del teorema de Gauss-Markov es que las variables independientes no deben estar perfectamente correlacionadas.


Cuando dos variables están correlacionadas,la estimación por mínimos cuadrados se vuelve sensible a pequeños cambios en la muestra y en la especificación del modelo.

Además los errores estándar son más grandes que en situaciones con ausencia de multicolinealidad, por lo que las pruebas t son pequeñas, haciendo más dificil rechazar la hipótesis nula para las estimaciones de los Beta


Para ilustrar esta situación, crearemos una nueva variable **open4**, la cual es 4 veces la variable **open**, lo cual hace que estas dos variables esten perfectamente correlacionadas.


```r
# create a variable perfectly correlating with open
final.85v2$open4 <- 4 * final.85v2$open
# check correlation between two variables
cor(final.85v2$open, final.85v2$open4, use = "complete.obs")
```

```
## [1] 1
```

```r
# estimate model 1 adding open4 in two different orderings OLS model
lm(logy ~ open + open4 + loglab + logland, data = final.85v2)
```

```
## 
## Call:
## lm(formula = logy ~ open + open4 + loglab + logland, data = final.85v2)
## 
## Coefficients:
## (Intercept)         open        open4       loglab      logland  
##     6.58392      0.00817           NA      0.15211     -0.04120
```

Para análizar el supuesto de no multicolinealidad en R, usamos la función **vif** de la librería car.


```r
vif(model1)
```

```
##     open   loglab  logland 
## 1.881422 2.271540 2.465689
```


En este caso, ninguna de las variables independientes del modelo parece sufrir de serios problemas de multicolinealidad.


En caso de presencia de multicolinealidad, remover unos de los predictores del modelo.


##Error Constante de la Varianza u Homocedasticidad


El teorema Gauss-Markov asume que la varianza del error debe permanecer constante a través de todas las observaciones.

En presencia de no varianza constante de los errores (también conocido como Heterocedasticidad), los paramétros estimados en un modelo de mínimos cuadrados permanencen insesgodos y consistentes.


...No obstante, los errores estándar de los coeficientes beta son estimados incorrectamente, por lo cual la prueba $t$ que utiliza éstos errores éstandares se vuelve invalida.


Para detectar Heterocedasticidad, podemos realizar los test Breush-Pagan y Cook-Weisberg.

Para ambos test, se contrasta la hipótesis nula de que la varianza del error es constante, y la hipótesis alternativa de que el error de la varianza no es constante.



```r
# test heteroskedasticity,
# estimate OLS model and create output object
model1 <- lm(logy ~ open + loglab + logland, data = final.85v2)


# Cook/Weisberg score test of constant error variance
car::ncvTest(model1)
```

```
## Non-constant Variance Score Test 
## Variance formula: ~ fitted.values 
## Chisquare = 0.5913018, Df = 1, p = 0.44192
```

```r
# Breush/Pagan test of constant error variance

lmtest::bptest(model1)
```

```
## 
## 	studentized Breusch-Pagan test
## 
## data:  model1
## BP = 4.3377, df = 3, p-value = 0.2272
```

Los valores p de los test estadísticos son 0.44 (Cook-Weisberg) y 0.22 (Breusch-Pagan). Por lo que se falla en rechazar la hipótesis nula de que la varianza de los errores es contante, por lo que se puede concluir que se cumple el supuesto de **Homocedasticidad** del modelo.

##Correción Errores estándares robustos


En caso de encontrar problemas de heterocedasticidad, una de las formas más usuales de corregirla, es estimando un modelo de regresión con errores estándar robustos a heterocedasticidad (Errores Estándar Robustos de White).

Los errores estándar robustos solo tienen problemas en muestras pequeñas, donde el estadístico t no tendrá una distribución probabilística cercana a t, y la inferencia estadística podría ser errónea.

En R, existen diferentes variantes de errores estándar robustos, en relación a la matriz de varianza-covarianza. R por default ocupa HC3, no obstante también se recomienda revisar HC1, la cuál es la variante por Default que ocupa Stata.


```r
model1.hc3 <- coeftest(model1, vcov=vcovHC)
model1.hc3
```

```
## 
## t test of coefficients:
## 
##               Estimate Std. Error t value  Pr(>|t|)    
## (Intercept)  6.5839164  0.7295957  9.0241 1.689e-15 ***
## open         0.0081696  0.0027652  2.9544  0.003702 ** 
## loglab       0.1521105  0.0671644  2.2647  0.025133 *  
## logland     -0.0412026  0.0575590 -0.7158  0.475340    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
# report HC1 robust standard errors as Stata
# variants:"HC3","HC","HC0","HC1","HC2","HC4","HC4m","HC5"
model1.hc1 <- coeftest(model1, vcov=vcovHC(model1, type="HC1"))
model1.hc1
```

```
## 
## t test of coefficients:
## 
##               Estimate Std. Error t value  Pr(>|t|)    
## (Intercept)  6.5839164  0.6760143  9.7393 < 2.2e-16 ***
## open         0.0081696  0.0023359  3.4974 0.0006379 ***
## loglab       0.1521105  0.0625453  2.4320 0.0163359 *  
## logland     -0.0412026  0.0561258 -0.7341 0.4641629    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


## Observaciones influyentes

A partir de la librería car, podemos obtener el siguiente gráfico de influencia, el cuál nos presenta los siguientes estadísticos.

1. Residuo stundetizado para cada observación, la cual se basa en el error estándar de la regresión re-estimada sin la observación. Observaciones fuera del rango $\pm2$ son outliers residuales

2. *Hat Values* mide el nivel de apalancamiento. Es construído en base a la medida ponderada de la distancia de cada observación del promedio de diferentes variables independientes. Sus rangos van de $1/n$ a $1$

3. Distancia de Cook, la cual se formaliza a partir de: 

$$DCook=\frac{\sum(\hat{y_{j}}-\hat{y_{j(i)}})^2}{p*MSE}$$
Para cada observación i, $\hat{y_{j}}$ es la predicción para la observación j de la regresión, $\hat{y_{j(i)}}$ es la preducción para cada observación j de un nuevo modelo de regresión omitiendo la observación i. $p$ es el número de parametros en el modelo, y MSE es la media cuadrática del error.



```r
# influence plot for influential observations
influencePlot(model1)
```

<img src="prac_8doagnostico_files/figure-html/unnamed-chunk-17-1.png" width="672" />

```
##         StudRes        Hat        CookD
## 15  -2.15836103 0.01759566 2.030510e-02
## 28  -1.49604438 0.08185103 4.942487e-02
## 84   0.01656972 0.15454007 1.264069e-05
## 101  2.18471536 0.02520437 3.000771e-02
## 103 -1.15752266 0.33781389 1.704497e-01
```

Para tener un punto de orientación respecto a qué tan influyente es una observación se calcula un corte.

Este se basa en la D de Cook. y su punto de corte es $4/(n-k-1)$, donde n es la cantidad de observaciones,y k el número de variables independientes.


COn este cálculo podemos saber cuáles son los casos más influyentes

```r
# cutoff point
round(4/(138-3-1),3)
```

```
## [1] 0.03
```

```r
# create observation id
final.85v2$id <- as.numeric(row.names(final.85v2))
# identify obs with Cook's D above cutoff
ggplot(final.85v2, aes(id, .cooksd))+
geom_bar(stat="identity", position="identity")+
xlab("Obs. Number")+ylab("Cook's distance")+
geom_hline(yintercept=0.03)+
geom_text(aes(label=ifelse((.cooksd>0.03),id,"")),
vjust=-0.2, hjust=0.5)
```

<img src="prac_8doagnostico_files/figure-html/unnamed-chunk-18-1.png" width="672" />

con esta función podemos ver el detalle de estos casos.


```r
# list observations whose cook's D above threshold
final.85v2[final.85v2$.cooksd > 0.03, c("id", "country", "logy",
"open", ".std.resid", ".hat", ".cooksd")]
```

```
## # A tibble: 6 x 7
##      id country     logy  open .std.resid   .hat .cooksd
##   <dbl> <fct>      <dbl> <dbl>      <dbl>  <dbl>   <dbl>
## 1    28 Mauritania  6.71 142.       -1.49 0.0819  0.0494
## 2    51 Canada      9.65  54.5       1.91 0.0406  0.0386
## 3   101 Qatar       9.74  80.9       2.15 0.0252  0.0300
## 4   103 Singapore   9.06 318.       -1.16 0.338   0.170 
## 5   118 Iceland     9.41  81.8       1.95 0.0375  0.0372
## 6   131 Australia   9.52  35.3       2.00 0.0361  0.0375
```

una vez identificados los casos, podemos estimar distintos modelos de regresión, quitando de a poco estos casos, por un lado hacemos una regresión quitando el caso de Singapur, y luego los otros 5 casos.



```r
# re-estimate model 1 without Singapore
model1.no1 <- lm(logy ~ open + loglab + logland,
data=final.85v2[final.85v2$.cooksd<0.18,])
summary(model1.no1)
```

```
## 
## Call:
## lm(formula = logy ~ open + loglab + logland, data = final.85v2[final.85v2$.cooksd < 
##     0.18, ])
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -2.08668 -0.84133 -0.06493  0.63543  2.10309 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  6.583916   0.721687   9.123 9.63e-16 ***
## open         0.008170   0.002589   3.156  0.00198 ** 
## loglab       0.152110   0.066359   2.292  0.02345 *  
## logland     -0.041203   0.056498  -0.729  0.46710    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.9886 on 134 degrees of freedom
## Multiple R-squared:  0.09674,	Adjusted R-squared:  0.07652 
## F-statistic: 4.784 on 3 and 134 DF,  p-value: 0.003369
```

```r
# re-estimate model 1 without Singapore and five others
model1.no2 <- lm(logy ~ open + loglab + logland,
data=final.85v2[final.85v2$.cooksd<0.03,])
summary(model1.no2)
```

```
## 
## Call:
## lm(formula = logy ~ open + loglab + logland, data = final.85v2[final.85v2$.cooksd < 
##     0.03, ])
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -2.02882 -0.75016 -0.02606  0.59405  2.08401 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  6.032768   0.760186   7.936 9.13e-13 ***
## open         0.011553   0.002984   3.872 0.000171 ***
## loglab       0.228893   0.068419   3.345 0.001078 ** 
## logland     -0.068428   0.056719  -1.206 0.229870    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.9305 on 128 degrees of freedom
## Multiple R-squared:  0.1472,	Adjusted R-squared:  0.1272 
## F-statistic: 7.364 on 3 and 128 DF,  p-value: 0.0001363
```

## Normalidad

Si bien el teórema de Gauss-Markov, no requiere que los residuos estén distribuidos normalmente, las inferencias basadas en $z$ o $t$ sí lo requieren.

Para visualizar la normalidad de los residuos usamos el gráfico de comparación Cuartil-Cuartil (QQPlot). Este gráfico nos muestra la comparación de los cuartiles empiricos de los residuos stunderizados del modelo1 (casos), contra los cuartiles teóricos de una distribución $t$ o normal (línea azul)



```r
# Normality diagnostic plot

car::qqPlot(model1, distribution = "t", simulate = TRUE)
```

<img src="prac_8doagnostico_files/figure-html/unnamed-chunk-21-1.png" width="672" />

```
## [1]  15 101
```

Para testear la normalidad de los residuos, utilizamos la **prueba Shapiro-Wilks**. Esta prueba, testea la hipótesis nula de los residuos están normalmente distribuidos.


```r
# normality test
shapiro.test(final.85v2$.resid)
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  final.85v2$.resid
## W = 0.97594, p-value = 0.01527
```

En este caso, p<0.05, sugiriendo que la hipótesis nula de normalidad es rechazada.

##Reporte de resultados

en relación a los distintos modelos que hemos estimado, y todas las revisiones podemos mostrar la siguiente tabla, donde vemos cómo son las estimaciones considerando todos los aspectos anteriores.




```r
# robustness checks I
stargazer(model1, model1.hc3, model1.no2, type="html",column.labels = c("OLS","Robusto H.","Sin Influyentes",single.row=TRUE),
          model.names = FALSE)
```


<table style="text-align:center"><tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td colspan="3"><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="3" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>logy</td><td></td><td>logy</td></tr>
<tr><td style="text-align:left"></td><td>OLS</td><td>Robusto H.</td><td>Sin Influyentes</td></tr>
<tr><td style="text-align:left"></td><td>(1)</td><td>(2)</td><td>(3)</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">open</td><td>0.008<sup>***</sup></td><td>0.008<sup>***</sup></td><td>0.012<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.003)</td><td>(0.003)</td><td>(0.003)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">loglab</td><td>0.152<sup>**</sup></td><td>0.152<sup>**</sup></td><td>0.229<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.066)</td><td>(0.067)</td><td>(0.068)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">logland</td><td>-0.041</td><td>-0.041</td><td>-0.068</td></tr>
<tr><td style="text-align:left"></td><td>(0.056)</td><td>(0.058)</td><td>(0.057)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>6.584<sup>***</sup></td><td>6.584<sup>***</sup></td><td>6.033<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.722)</td><td>(0.730)</td><td>(0.760)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>138</td><td></td><td>132</td></tr>
<tr><td style="text-align:left">R<sup>2</sup></td><td>0.097</td><td></td><td>0.147</td></tr>
<tr><td style="text-align:left">Adjusted R<sup>2</sup></td><td>0.077</td><td></td><td>0.127</td></tr>
<tr><td style="text-align:left">Residual Std. Error</td><td>0.989 (df = 134)</td><td></td><td>0.931 (df = 128)</td></tr>
<tr><td style="text-align:left">F Statistic</td><td>4.784<sup>***</sup> (df = 3; 134)</td><td></td><td>7.364<sup>***</sup> (df = 3; 128)</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td colspan="3" style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
</table>




