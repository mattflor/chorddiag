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

# default call; group arc length is determined by the row sums; here, this is
# the number of people with different hair colors asked what hair color they
# prefer; this reflects how many people there were with the different
# hair colors
chorddiag(m, showGroupnames = T)


# customization: colors, margin, padding
groupColors <- c("#000000", "#FFDD89", "#957244", "#F26223")
chorddiag(m, groupColors = groupColors, groupnamePadding = 50, margin = 100,
          tooltipGroupConnector = " prefer ")
# by transposing the matrix, group arc length is determined by how ofthen the
# different hair colors were prefered:
chorddiag(t(m), groupColors = groupColors, groupnamePadding = 50, margin = 100,
          tooltipGroupConnector = " prefered by ")
# we can also normalize preference by row sums thus expressing for each hair
# color their preference in percentages; this way, each hair color gets the same
# arc length
chorddiag(100*m/rowSums(m), groupColors = groupColors, groupnamePadding = 30,
          margin = 60, tickInterval = 5,
          tooltipGroupConnector = " prefer ", tooltipUnit = " %",
          precision = 2)

# Bipartite chord diagram with Titanic data
if (requireNamespace("dplyr", quietly = TRUE)) {
    library(dplyr)
    titanic_tbl <- tibble::as_tibble(Titanic)
    titanic_tbl <- titanic_tbl %>%
        mutate(across(where(is.character), as.factor))
    by_class_survival <- titanic_tbl %>%
        group_by(Class, Survived) %>%
        summarise(Count = sum(n)) %>%
        ungroup()
    titanic.mat <- matrix(by_class_survival$Count, nrow = 4, ncol = 2, byrow = TRUE)
    dimnames(titanic.mat ) <- list(Class = levels(titanic_tbl$Class),
                                   Survival = levels(titanic_tbl$Survived))
    print(titanic.mat)
    groupColors <- c("#2171b5", "#6baed6", "#bdd7e7", "#bababa", "#d7191c", "#1a9641")
    chorddiag(titanic.mat, type = "bipartite",
              groupColors = groupColors,
              tickInterval = 50)
}
