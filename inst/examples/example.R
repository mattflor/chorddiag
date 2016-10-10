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
# prefer; this probably reflects how many people there were with the different
# hair colors
chorddiag(m, showGroupnames = T)


# customization: colors, margin, padding
groupColors <- c("#000000", "#FFDD89", "#957244", "#F26223")
chorddiag(m, groupColors = groupColors, groupnamePadding = 50, margin = 100,
          tooltipGroupConnector = " prefer ")
# by transposing the matrix, group arc length is determined by the hair color
# numbers prefered:
chorddiag(t(m), groupColors = groupColors, groupnamePadding = 50, margin = 100,
          tooltipGroupConnector = " prefered by ")
# we can also normalize preference by row sums thus expressing for each hair
# color their preference in percentages; this way, each hair color gets the same
# arc length
chorddiag(100*m/rowSums(m), groupColors = groupColors, groupnamePadding = 30,
          margin = 60, tickInterval = 5,
          tooltipGroupConnector = " prefer ", tooltipUnit = " %",
          precision = 2)


# world migrant stocks
library(migration.indices)
library(RColorBrewer)
data("migration.world")   # this 226x226 matrix has migrant stock numbers from 1990
                          # where row name gives the country of origin and column
                          # name gives the destination country
sort.by.orig <- sort(rowSums(migration.world), decreasing = TRUE, index.return = TRUE)
mig.sorted.by.orig <- migration.world[sort.by.orig$ix, sort.by.orig$ix]
row.names(mig.sorted.by.orig) <- names(sort.by.orig$x)

n <- dim(mig.sorted.by.orig)[1]
groupColors <- rep(brewer.pal(12, "Set3")[c(1:8, 10:12)], length.out = n)
groupNames <- rep("", n)
ix <- c(1:50, seq(52, 100, by = 2),
        seq(105, 150, by = 5),
        160, 180, 226)
groupNames[ix] <- colnames(mig.sorted.by.orig)[ix]
tooltipNames <- colnames(mig.sorted.by.orig)
chorddiag(mig.sorted.by.orig, groupPadding = 0,
          showTicks = FALSE, margin = 120,
          chordedgeColor = NULL, groupColors = groupColors,
          groupnameFontsize = 10,
          groupNames = groupNames,
          groupnamePadding = 10,
          tooltipNames = tooltipNames,
          fadeLevel = 0)

mig.transposed <- t(migration.world)
sort.by.dest <- sort(rowSums(mig.transposed), decreasing = TRUE, index.return = TRUE)
mig.sorted.by.dest <- mig.transposed[sort.by.dest$ix, sort.by.dest$ix]
row.names(mig.sorted.by.dest) <- names(sort.by.dest$x)

n <- dim(mig.sorted.by.dest)[1]
groupColors <- rep(brewer.pal(12, "Set3")[c(1:8, 10:12)], length.out = n)
groupNames <- rep("", n)
ix <- c(1:40, seq(42, 60, by = 2),
        seq(65, 100, by = 5),
        110, 130, 150, 226)
groupNames[ix] <- colnames(mig.sorted.by.dest)[ix]
tooltipNames <- colnames(mig.sorted.by.dest)
chorddiag(mig.sorted.by.dest, groupPadding = 0,
          showTicks = FALSE, margin = 120,
          chordedgeColor = NULL, groupColors = groupColors,
          groupnameFontsize = 10,
          groupNames = groupNames,
          groupnamePadding = 10,
          tooltipNames = tooltipNames,
          tooltipGroupConnector = " &#x25c0; ",
          fadeLevel = 0)


# Bipartite chord diagram with Titanic data
if (requireNamespace("dplyr", quietly = TRUE)) {
    titanic_tbl <- dplyr::tbl_dt(Titanic)
    titanic_tbl <- titanic_tbl %>%
        mutate_each(funs(factor), Class:Survived)
    by_class_survival <- titanic_tbl %>%
        group_by(Class, Survived) %>%
        summarize(Count = sum(N))
    m <- matrix(by_class_survival$Count, nrow = 4, ncol = 2)
    dimnames(m) <- list(Class = levels(titanic_tbl$Class),
                        Survival = levels(titanic_tbl$Survived))
    m
    groupColors <- c("#2171b5", "#6baed6", "#bdd7e7", "#bababa", "#d7191c", "#1a9641")
    chorddiag(m, type = "bipartite", groupColors = groupColors,
              tooltipGroupConnector = " in ",
              tickInterval = 50)
}
