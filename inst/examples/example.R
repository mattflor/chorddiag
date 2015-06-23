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
rowSums(m)
m/rowSums(m)
colSums(m)

# default call; group arc length is determined by the row sums; here, this is
# the number of people with different hair colors asked what hair color they
# prefer; this probably reflects how many people there were with the different
# hair colors
chorddiag(m)

# customization: colors, margin, padding
groupColors <- c("#000000", "#FFDD89", "#957244", "#F26223")
chorddiag(m, groupColors = groupColors, groupnamePadding = 30, margin = 100,
          tooltipGroupConnector = " prefer ")
# by transposing the matrix, group arc length is determined by the hair color
# numbers prefered:
chorddiag(t(m), groupColors = groupColors, groupnamePadding = 30, margin = 100,
          tooltipGroupConnector = " prefered by ")
# we can also normalize preference by row sums thus expressing for each hair
# color their preference in percentages; this way, each hair color gets the same
# arc length
chorddiag(100*m/rowSums(m), groupColors = groupColors, groupnamePadding = 20,
          margin = 60, tickInterval = 5,
          tooltipGroupConnector = " prefer ", tooltipUnit = " %",
          precision = 2)

m2 <- matrix(0, nrow = 8, ncol = 8)
m2[5:8, 1:4] <- m
m2[1:4, 5:8] <- t(m)
row.names(m2) <- rep(c("black", "blonde", "brown", "red"), 2)
colnames(m2) <- rep(c("black", "blonde", "brown", "red"), 2)
groupColors <- c("#000000", "#FFDD89", "#957244", "#F26223")
chorddiag(m2, groupColors = groupColors, groupnamePadding = 30, margin = 100,
          tooltipGroupConnector = " prefer ")



# uber data
uber <- read.table(system.file("extdata", "uber.csv", package = "chorddiag"),
                   header = TRUE, sep = ",")
uber <- as.matrix(uber)
uber
chorddiag(uber*100000, showTicks = TRUE, tickInterval = 1000,
          groupnamePadding = -10, margin = 150)


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
titanic_mat
groupColors <- c("#2171b5", "#6baed6", "#bdd7e7", "#bababa", "#d7191c", "#1a9641")
chorddiag(titanic_mat, type = "directional", groupColors = groupColors, tickInterval = 50)

dimnames(m) <- list(Class = levels(titanic_tbl$Class),
                    Survival = levels(titanic_tbl$Survived))
chorddiag(m, type = "bipartite", tickInterval = 50)
