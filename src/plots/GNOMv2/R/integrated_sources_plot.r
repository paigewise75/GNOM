# FILEPATH: Untitled-1

# Load required libraries
library(ggplot2)
library(dplyr)

# Read the data from CSV file
data <- read.csv("/Users/paigewise/Projects/GNOM/data/fe47ba4f_run28_Int.csv")

# Get the column names
column_names <- colnames(data)

# Group columns with the same ending together
grouped_columns <- split(column_names, sub(".*_", "", column_names))

# Separate the "_ATL" and "_PAC" groups
atl <- data[, intersect(colnames(data), grouped_columns[["ATL"]])]
pac <- data[, intersect(colnames(data), grouped_columns[["PAC"]])]

# Plot the "_ATL" data
ggplot(atl, aes(x = depth)) +
    geom_bar(stat = "identity") +
    labs(title = "ATL Data")

# Plot each column of pac as a bar graph
for (col in colnames(pac)) {
    ggplot(pac, aes(x = depth, y = .data[[col]])) +
        geom_bar(stat = "identity") +
        labs(title = paste0(col, " Data"))
}
