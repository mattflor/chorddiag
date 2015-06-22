library(chorddiag)

# data matrix
m <- matrix(c(11975,  5871, 8916, 2868,
              1951, 10048, 2060, 6171,
              8010, 16145, 8090, 8045,
              1013,   990,  940, 6907),
            byrow = TRUE,
            nrow = 4, ncol = 4)
groupNames <- c("black", "blonde", "brown", "red")
row.names(m) <- groupNames
colnames(m) <- groupNames
m


# default call
chorddiag(m)

# customization: colors, margin, padding
groupColors <- c("#000000", "#FFDD89", "#957244", "#F26223")
chorddiag(m, groupColors = groupColors, groupnamePadding = 30, margin = 100)


# uber data
uber <- read.table(system.file("extdata", "uber.csv", package = "chorddiag"),
                   header = TRUE, sep = ",")
uber <- as.matrix(uber)
chorddiag(uber, showTicks = FALSE, groupnamePadding = -10, margin = 150)


# Titanic data
library(dplyr)
library(data.table)
titanic_tbl <- tbl_dt(Titanic)
titanic_tbl <- titanic_tbl %>%
    mutate_each(funs(factor), Class:Survived)
by_class_survival <- titanic_tbl %>%
    group_by(Class, Survived) %>%
    summarize(Count = sum(N))
groupNames <- c(levels(titanic_tbl$Class), levels(titanic_tbl$Survived))
m <- matrix(by_class_survival$Count, nrow = 4, ncol = 2)
titanic_mat <- matrix(0, nrow = 6, ncol = 6)
titanic_mat[1:4, 5:6] <- m
titanic_mat[5:6, 1:4] <- t(m)
row.names(titanic_mat) <- groupNames
colnames(titanic_mat) <- groupNames
groupColors <- c("#2171b5", "#6baed6", "#bdd7e7", "#bababa", "#d7191c", "#1a9641")
chorddiag(titanic_mat, type = "CR", groupColors = groupColors, tickInterval = 50)
