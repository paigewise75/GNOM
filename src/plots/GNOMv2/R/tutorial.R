 # assign variables (variables are case sensitive)
a =1 + 2
b <- 1 + 8

# types
mynumeric1 <- 0.02
mynumeric2 <- 10

mylogical <- TRUE

mychar <- "Hi World!" # "\" if you want to do a special character

myfactor <- as.factor("female")

vector <- c(1,2,3,4,5,6) # vector needs "c"
vec <-c(1:6)

vec1 = as.factor(c("female","male","female","male","female")) # Factor with 2 levels 

# list
mylist = list(vector,vec,vec1)
newlist = list(mylist, vec1, vec, vector)

# Data Frame (must be same length)
df=data.frame(vec,vector)
df[[2]][4:5]
df1 = data.frame("A" = vec, "B" = vector)
df1$A # Access column in df with "$"

# Matrix
mat = matrix(vector,2,3) 

# Index vectors w/ [ ]
idx1 = vector[3]
# R starts at 1 
idx2 = vector[2:4]
idx3 = vector[-1] #all values except the first one

vector[c(F,T,F,F,F,F)]

# Assign name to column in list
list1 = list("a" = vec, "b" = vector, "c" = vec1)
# Access column in list with "$"
list1$c


# Define a function w/ curly brackets
new_sum <- function(val1,val2) {
  results <- val1 + val2
  return(results)
}

new_sum(2,3)
new_sum(val2 = 4, val1 = 9)

# Packages
# In console: " install.packages("ggplot2") "

# In script:
library(ggplot2)
ggplot(df1,aes(A,B))+geom_point()



library(wesanderson)
# ggplot2 tutorial 
df = data.frame(lat = seq(2,90,4), val1 = rnorm(23), val2 = rnorm(23, mean = 0.5))
# make sure to include library at the beginning of script

ggplot(df)+ # specify df in ggplot(), if not then specify dataframe later
  geom_point(aes(x = lat,y = val1,color = as.factor(val1)),
           stat = "identity", pch = 16) +
  geom_point(aes(x= lat, y = val2), stat = "identity", color = "#7294D4", fill = "#7294D4") +
  scale_x_continuous("Latitude", breaks = seq(0,90,5), labels = c(seq(10,180,10),"equator")) +
  scale_color_manual(values = c(wes_palette(n=5, "FantasticFox1"),
                                      wes_palette(n=5, "FantasticFox1"),
                                      wes_palette(n=5, "FantasticFox1"),
                                      wes_palette(n=5, "FantasticFox1"),
                                      wes_palette(n=5, "FantasticFox1")[1:3]))+
  theme_light() +
  theme(legend.position = "none",
        panel.background = element_rect(fill = "#E6A0C4"))+
  coord_polar()
  
  
  # theme goes last

$FantasticFox1
[1] "#DD8D29" "#E2D200" "#46ACC8" "#E58601" "#B40F20"
$GrandBudapest2
[1] "#E6A0C4" "#C6CDF7" "#D8A499" "#7294D4"


library(ggOceanMaps)

dt <- data.frame(lon = c(-30, -30, 30, 30), lat = c(50, 80, 80, 50))

basemap(data = dt, bathymetry = TRUE) + 
  geom_polygon(data = transform_coord(dt), aes(x = lon, y = lat), 
               color = "red", fill = NA)
