#' Create a D3 Chord Diagram
#'
#' Create an interactive chord diagram using the JavaScript visualization
#' library D3 (\url{http://d3js.org}). More specifically, the chord diagram
#' layout is based on \url{http://bl.ocks.org/mbostock/4062006}. Chord diagrams
#' show directed relationships among a group of entities.
#'
#' @param data A matrix containing the data. Must be square for the
#'   "directional" type. Column names of the matrix (if existing) will be used
#'   as group labels unless the \code{groupNames} argument is explicitely set.
#'   For the "bipartite" type, the column names label the groups on the left
#'   side of the chord diagram whereas the row names label the groups on the
#'   right side.
#' @param type A character string for the type of chord diagram. Either
#'   "directional" (default) or "bipartite" (chord diagrams can be helpful for
#'   visualising symmetric relations between two categories of groups, i.e.
#'   contingency tables).
#' @param width Width for the chord diagram's frame area in pixels (if NULL then
#'   width is automatically determined based on context).
#' @param height Height for the chord diagram's frame area in pixels (if NULL
#'   then height is automatically determined based on context).
#' @param margin Numeric margin in pixels between the outer diagram radius and
#'   the edge of the display.
#' @param palette A character string. The name of the colorbrewer palette to be
#'   used. For bipartite diagrams, the palette is used for the column groups.
#' @param palette2 A character string. Only used for bipartite diagrams where it
#'   is the name of the colorbrewer palette to be used for the row groups.
#' @param showGroupnames A logical scalar.
#' @param groupNames A vector of character strings to be used for group
#'   labeling.
#' @param groupColors A vector of colors to be used for the groups. Specifying
#'   \code{groupColors} overrides any \code{palette} given. For bipartite
#'   diagrams, the colors used for the row groups must precede the colors for
#'   the column groups.
#' @param groupThickness Numeric thickness for the groups as a fraction of the
#'   total diagram radius.
#' @param groupPadding Numeric padding in degrees between groups.
#' @param groupnamePadding Numeric padding in pixels between diagram (outer
#'   circle) and group labels. Use this argument if group labels overlap with
#'   tick labels. Either a scalar value to be applied to all group labels or a
#'   numeric vector specifying padding for each group label separately.
#' @param groupnameFontsize Numeric font size in pixels for the group labels.
#' @param groupedgeColor Color for the group edges. If NULL group colors will be
#'   used.
#' @param chordedgeColor Color for the chord edges.
#' @param categoryNames A length-2 vector of character strings to be used for
#'   category labels (left and right side of a bipartite chord diagram).
#' @param categorynamePadding Numeric padding in pixels between diagram (outer
#'   circle) and category labels in bipartite diagrams. Use this argument if
#'   category labels overlap with tick or group labels.
#' @param categorynameFontsize Numeric font size in pixels for the category
#'   labels in a bipartite diagram.
#' @param showTicks A logical scalar.
#' @param tickInterval A numeric value.
#' @param ticklabelFontsize Numeric font size in pixels for the tick labels.
#' @param fadeLevel Numeric chord fade level (opacity value between 0 and 1,
#'   defaults to 0.1).
#' @param showTooltips A logical scalar (defaults to TRUE).
#' @param showZeroTooltips A logical scalar (defaults to TRUE). If set to FALSE,
#'   tooltips for the value zero are hidden.
#' @param tooltipNames A vector of character strings to be used for group
#'   labeling in tooltips. By default equal to \code{groupNames}.
#' @param tooltipUnit A character string for the units to be used in tooltips.
#' @param tooltipFontsize Numeric font size in pixels for the tooltips.
#' @param tooltipGroupConnector A character string to be used in tooltips:
#'   "<source group> <tooltipGroupConnector> <target group>". Defaults to a
#'   triangle pointing from source to target.
#' @param precision Integer number of significant digits to be used for tooltip
#'   display.
#' @param clickAction character string containing JavaScript code to be executed
#'   on a mouse click so that shiny can get the sourceIndex and targetIndex for the purpose of filtering the data on other visualizations
#'
#' @source Based on \url{http://bl.ocks.org/mbostock/4062006} with several
#'   modifications.
#'
#' @examples
#' m <- matrix(c(11975,  5871, 8916, 2868,
#'                1951, 10048, 2060, 6171,
#'                8010, 16145, 8090, 8045,
#'                1013,   990,  940, 6907),
#'                byrow = TRUE,
#'                nrow = 4, ncol = 4)
#' groupnames <- c("black", "blonde", "brown", "red")
#' row.names(m) <- groupnames
#' colnames(m) <- groupnames
#' chorddiag(m)
#'
#' @export
chorddiag <- function(data,
                      type = "directional",
                      width = NULL, height = NULL,
                      margin = 100,
                      palette = "Dark2",
                      palette2 = "Greys",
                      showGroupnames = TRUE,
                      groupNames = NULL,
                      groupColors = NULL, groupThickness = 0.1,
                      groupPadding = 2,
                      groupnamePadding = 30, groupnameFontsize = 18,
                      groupedgeColor = NULL,
                      chordedgeColor = "#808080",
                      categoryNames = NULL,
                      categorynamePadding = 100, categorynameFontsize = 28,
                      showTicks = TRUE, tickInterval = NULL,
                      ticklabelFontsize = 10,
                      fadeLevel = 0.1,
                      showTooltips = TRUE,
                      showZeroTooltips = TRUE,
                      tooltipNames = NULL,
                      tooltipUnit = NULL,
                      tooltipFontsize = 12,
                      tooltipGroupConnector = " &#x25B6; ",
                      precision = NULL,
                      clickAction = NULL) {

    if (!is.matrix(data))
        stop("'data' must be a matrix class object.")

    d <- dim(data)
    if (type == "bipartite") {
        g1 <- d[1]
        g2 <- d[2]
        n <- g1 + g2
        m <- matrix(0, nrow = n, ncol = n)
        m[1:g1, (g1+1):n] <- data
        m[(g1+1):n, 1:g1] <- t(data)
        g1.names <- row.names(data)
        g2.names <- colnames(data)
        m.names <- c(g1.names, g2.names)
        row.names(m) <- m.names
        colnames(m) <- m.names
        if (is.null(categoryNames)) {
            # get categoryNames from data dimnames
            categoryNames <- names(dimnames(data))
        }
        data <- m
    } else if (type == "directional") {
        if (d[1] != d[2] ) stop("'data' must be a square matrix.")
        n <- d[1]
    }

    if (!is.null(categoryNames) & type != "bipartite") {
        warning("category names are only used for bipartite chord diagrams.")
    }

    if (!is.null(groupNames)) {
        g <- length(groupNames)
        if (g != n)
            stop(paste0("length of 'groupNames' [", g, "] not equal to matrix extent [", n, "]."))
    } else {
        groupNames <- colnames(data)
    }
    rnames <- row.names(data)
    if (!is.null(rnames)) {
        if (!identical(rnames, groupNames))
            warning("row names of the 'data' matrix differ from its column names or the 'groupNames' argument.")
    }

    if (length(groupnamePadding) == 1) {
        groupnamePadding <- rep(groupnamePadding, n)
    }

    if (is.null(groupColors)) {
        if (type == "directional") {
            groupColors <- RColorBrewer::brewer.pal(n, palette)
        } else if (type == "bipartite") {
            groupColors <- c(
                RColorBrewer::brewer.pal(g1, palette2),
                RColorBrewer::brewer.pal(g2, palette)
            )
        }
    }

    if (is.null(tickInterval)) {
        tickInterval <- 10^(floor(log10(max(data))) - 1)
    }

    if (is.null(tooltipNames)) {
        tooltipNames = groupNames
    }

    if (is.null(tooltipUnit)) {
        tooltipUnit <- ""
    }

    if (is.null(precision)) {
        precision <- "null"
    }

    params = list(matrix = data,
                  options = list(type = type,
                                 width = width, height = height,
                                 margin = margin,
                                 showGroupnames = showGroupnames,
                                 groupNames = groupNames,
                                 groupColors = groupColors,
                                 groupThickness = groupThickness,
                                 groupPadding = pi * groupPadding / 180,
                                 groupnamePadding = groupnamePadding,
                                 groupnameFontsize = groupnameFontsize,
                                 groupedgeColor = groupedgeColor,
                                 chordedgeColor = chordedgeColor,
                                 categoryNames = categoryNames,
                                 categorynamePadding = categorynamePadding,
                                 categorynameFontsize = categorynameFontsize,
                                 showTicks = showTicks,
                                 tickInterval = tickInterval,
                                 ticklabelFontsize = ticklabelFontsize,
                                 fadeLevel = fadeLevel,
                                 showTooltips = showTooltips,
                                 showZeroTooltips = showZeroTooltips,
                                 tooltipNames = tooltipNames,
                                 tooltipFontsize = tooltipFontsize,
                                 tooltipUnit = tooltipUnit,
                                 tooltipGroupConnector = tooltipGroupConnector,
                                 precision = precision,
                                 clickAction = clickAction))
    params = Filter(Negate(is.null), params)

    # create widget
    htmlwidgets::createWidget(
        name = 'chorddiag',
        params,
        width = width,
        height = height,
        htmlwidgets::sizingPolicy(padding = 0,
                                  browser.fill = TRUE),
        package = 'chorddiag'
    )
}

#' Widget output function for use in Shiny
#'
#' @export
chorddiagOutput <- function(outputId, width = '90%', height = '350px'){
    htmlwidgets::shinyWidgetOutput(outputId, 'chorddiag', width, height, package = 'chorddiag')
}

#' Widget render function for use in Shiny
#'
#' @export
renderChorddiag <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    htmlwidgets::shinyRenderWidget(expr, chorddiagOutput, env, quoted = TRUE)
}
