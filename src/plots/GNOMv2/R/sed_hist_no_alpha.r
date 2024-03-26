library(ggplot2)
library(gridExtra)
library(viridis) 

plot_gnomv2_r <- function() {
    # Read the data from the test2.csv file
    data1 <- read.csv("no_alpha.csv", header = TRUE)
    data2 <- read.csv("test2.csv", header = TRUE)

    color = viridis(5)

    plot1 <- ggplot(data2, aes(x = as.factor(r_0), y = n_0)) +
        geom_bar(stat = "identity", fill = color[1]) +
        labs(x = "εNd Released from Sediment", y = "Total Flux (pmol/yr)") +
        scale_y_continuous(labels = function(x) sprintf("%s", x)) +
        theme_light()

    plot2 <- ggplot(data2, aes(x = as.factor(r_0), y = a_0)) +
        geom_bar(stat = "identity", fill = color[2]) +
        labs(x = "εNd Released from Sediment", y = "Total Sediment Area (u)") +
        scale_y_continuous(labels = function(x) sprintf("%s", x)) +
        theme_light()

    plot3 <- ggplot(data2, aes(x = as.factor(r_0), y = j_0)) +
        geom_bar(stat = "identity", fill = color[3]) +
        labs(x = "εNd Released from Sediment", y = "Average Flux (pmol/yr)") +
        scale_y_continuous(labels = function(x) sprintf("%s", x), limits = c(0, 3E-13)) +
        theme_light()

    plot4 <- ggplot(data2, aes(x = as.factor(r_0), y = m_0)) +
        geom_bar(stat = "identity", fill = color[4]) +
        labs(x = "εNd Released from Sediment", y = "Average Flux without GRL Mask") +
        scale_y_continuous(labels = function(x) sprintf("%s", x), limits = c(0, 3E-13)) +
        theme_light()

    plot5 <- ggplot(data1, aes(x = as.factor(r_0), y = n_0)) +
        geom_bar(stat = "identity", fill = color[5]) +
        labs(x = "εNd Released from Sediment", y = "Total Flux without Alpha Parameter") +
        scale_y_continuous(labels = function(x) sprintf("%s", x)) +
        theme_light()

    # Arrange the plots side by side
    grid.arrange(plot5, plot1, plot3, plot4, plot2, ncol = 5)
}

# Call the plot_gnomv2_r function
plot_gnomv2_r()
