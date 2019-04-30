# Estadística Multivariada. Profesores: Juan Carlos Castillo y Alejandro Plaza
# Taller n°1. Manejo de bases de datos (abrir, filtrar, recodificar, descriptivos básicos, creación de índices y correlación de Pearson)
# Fecha: Lunes 29 de Abril 2019
# Ayudantes: Anais Herrera, Francisco Meneses y Simón Varas

##### ------------------ 1° Establecer directorio -------------------------- #####

setwd("C:/Users/Anais/Desktop/ayudantia EM")

##### ------------------ 2° Abrir y Visualizar ---------------- #####
library(haven) #Este sirve para importar SPSS y Stata

base <- read_spss("ELSOC.sav") #Esto abre la base de datos, en formato SPSS.

base <- read_dta("https://juancarloscastillo.github.io/metsoc-facsouchile/documents/presentaciones/7inferencia/ELSOC_W01_v2.00_Stata13.dta")

dim(base)   #Esto nos entrega la cantidad de casos y de variables

names(base)       # Esto nos muestra los nombres de las variables (Columnas)
names (base[,7])  # [fila,columna] Si se coloca  [,7] nos indicara el nombre de la columna 7. 

#View(base)       # Esto nos permite ver la base de datos (Lo deje con # porque tarda mucho)

View(base[1,])   # Esto nos permite ver el valor de todas las variables del primer caso en una tabla(sujeto/Fila 1)
View(base[,28])  # Esto nos permite ver todos los valores de los sujetos para una variable en una tabla (Variable/Columna 28)

(base[4,29]) # Esto nos imprime en la consola el valor de una variable para un sujeto, indicando el nombre de dicha variable  [Sujeto 4, variable 5]

##### --------- 3° Manejar bases de datos -------- #####

library(dplyr) #Este paquete ayuda a manejar bases de datos

# 3A # Crearemos una base de datos con menos variables
Base_Elsoc <- select(base, t01, t02_01, t02_02, t02_03, t02_04)

# 3B # Ahora cambiaremos los nombres a estas variables. Recuerda siempre que Nombrenuevo=Nombreviejo
ELSOC <- rename(Base_Elsoc, Conf.Vecinos=t01, Ac.Barrio.ideal=t02_01, Ac.Integr.Barrio = t02_02, Ac.Barrio.ident=t02_03,Ac.Barrio.part=t02_04)

summary(ELSOC)

# 3AB # Tambien puede hacerse el cambio de nombres de las variables al mismo tiempo que se recorta la base.
ELSOC <- select(base, Conf.Vecinos=t01, Ac.Barrio.ideal=t02_01, Ac.Integr.Barrio = t02_02, Ac.Barrio.ident=t02_03,Ac.Barrio.part=t02_04)

# 3C # RECODIFICAR VARIABLES EN UNA NUEVA 
#Esto significa transformar una variable, sin sobre escribirla ni perder la orginal

#Variable: cu?nto conf?as en los vecinos

class(ELSOC$Conf.Vecinos) #Observamos que tipo de variable es
table(ELSOC$Conf.Vecinos) #Obsrevamos sus categor?as --> 1 = muy poco, 2 = poco, 3 = algo, 4 = bastante, 5 = mucho
ELSOC$Conf.Vecinos <- as.numeric(ELSOC$Conf.Vecinos) #convertimos a vector num?rico para poder convertir.

#Es importante quitar los casos perdidos ANTES de recodificar
ELSOC$Conf.Vecinos[ELSOC$Conf.Vecinos==-999]<-NA
ELSOC$Conf.Vecinos[ELSOC$Conf.Vecinos==-888]<-NA

#El comando "Mutate" permite recodificar en una variable nueva.
#Luego del recode se indica la variable original y las equivalencias de las categor?as.
ELSOC <- mutate(ELSOC, Conf.Vecinosrec = recode(ELSOC$Conf.Vecinos, "1" = "poco", "2" = "poco", "3" = "algo", "4" = "bastante", "5" = "bastante"))
class(ELSOC$Conf.Vecinosrec) #queda como objeto character
table(ELSOC$Conf.Vecinosrec) 

# 3D # Etiquetar variables (recuerden que este procedimiento es s?lo para las variables que no trataremos como intervalar)
ELSOC$Conf.Vecinos<-factor(ELSOC$Conf.Vecinos, levels=c(1,2,3,4,5), 
                           labels=c("Muy poco", "Poco", "Algo", "Bastante", "Mucho"))
View(ELSOC$Conf.Vecinos)
table(ELSOC$Conf.Vecinos)

##### --------- 4 Creacion de indices sumativos: satisfaccion con el barrio ------- #####

## Paso n°1: Quitar casos perdidos->-999, -888
#Opción 1 (sin librería dplyr)
ELSOC$Ac.Barrio.ideal[ELSOC$Ac.Barrio.ideal==-999]<-NA
ELSOC$Ac.Barrio.ideal[ELSOC$Ac.Barrio.ideal==-888]<-NA
ELSOC$Ac.Integr.Barrio[ELSOC$Ac.Integr.Barrio==-999]<-NA
ELSOC$Ac.Integr.Barrio[ELSOC$Ac.Integr.Barrio==-888]<-NA
ELSOC$Ac.Barrio.ident[ELSOC$Ac.Barrio.ident==-999]<-NA
ELSOC$Ac.Barrio.ident[ELSOC$Ac.Barrio.ident==-888]<-NA
ELSOC$Ac.Barrio.part[ELSOC$Ac.Barrio.part==-999]<-NA
ELSOC$Ac.Barrio.part[ELSOC$Ac.Barrio.part==-888]<-NA

#Opción 2 (utilizando la librería dplyr)
ELSOC$Conf.Vecinos <- as.numeric(ELSOC$Conf.Vecinos) #convertimos la variable en un vector numerico
ELSOC1 <- filter(ELSOC, Conf.Vecinos > 0, Ac.Barrio.ideal > 0, Ac.Integr.Barrio > 0, Ac.Barrio.ident > 0, Ac.Barrio.part > 0)

#Paso 2: visualizar las variables antes de construir el indice # conocer el valor min y max de cada variable que incorporaremos en el indice nos permite conocer el rango del mismo y ver si se borraron los perdidos
summary(ELSOC$Ac.Barrio.ideal)
summary(ELSOC$Ac.Integr.Barrio)
summary(ELSOC$Ac.Barrio.ident)
summary(ELSOC$Ac.Barrio.part)

#Paso 3: creación del índice
Ind.satisfaccion.barrio <- (ELSOC$Ac.Barrio.ideal + ELSOC$Ac.Integr.Barrio + ELSOC$Ac.Barrio.ident + ELSOC$Ac.Barrio.part) # / 4

View(Ind.satisfaccion.barrio) 

mean(Ind.satisfaccion.barrio, na.rm = TRUE)

##### --------- 5 Matriz de correlación de Pearson ------- #####
ELSOC$Conf.Vecinosrec <- as.numeric(ELSOC$Conf.Vecinosrec) #convertimos la variable en un vector numerico

#Omitimos los NA
ELSOC <- na.omit(ELSOC)# Elimina todas las filas que contengan algun valor nulo 

#Instalación de paquete para representar gráficos
install.packages("ggplot2")
library(ggplot2)

#Matriz de pearson
ELSOC <- select(ELSOC1, -Conf.Vecinosrec) #Eliminamos Variable Conf.Vecinosrec para calcular matriz de pearson
ELSOC.cor <- cor(ELSOC, method = "pearson")
View(ELSOC.cor)