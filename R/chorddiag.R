#' Create a D3 Chord Diagram
#'
#' Create an interactive chord diagram using the JavaScript visualization
#' library D3 (\url{http://d3js.org}). More specifically, the chord diagram
#' layout is based on \url{http://bl.ocks.org/mbostock/4062006}. Chord diagrams
#' show directed relationships among a group of entities.
#'
#' @import htmlwidgets
#'
#' @param data A square matrix containing the data. Column names (if existing)
#'   will be used as group labels unless the \code{groupNames} argument is
#'   explicitely set. labels must be set via \code{colnames}
#' @param width Width for the chord diagram's frame area in pixels (if NULL then
#'   eidth is automatically determined based on context).
#' @param height Height for the chord diagram's frame area in pixels (if NULL
#'   then height is automatically determined based on context).
#' @param margin Numeric margin in pixels between the outer diagram radius and
#'   the edge of the display.
#' @param palette A character string. The name of the colorbrewer palette to be
#'   used.
#' @param groupNames A vector of character strings to be used for group
#'   labeling.
#' @param groupColors A vector of colors to be used for the groups. Providing
#'   \code{groupColors} overrides any \code{palette} given.
#' @param groupThickness Numeric thickness for the groups as a fraction of the
#'   total diagram radius.
#' @param groupPadding Numeric padding between groups.
#' @param groupnamePadding Numeric padding between diagram and group labels. Use
#'   this argument if group labels overlag with tick labels.
#' @param groupnameFontsize Numeric font size in pixels for the group labels.
#' @param groupedgeColor Color for the group edges. If NULL group colors will be
#'   used.
#' @param chordedgeColor Color for the chord edges.
#' @param showTicks A logical scalar.
#' @param tickInterval A numeric value.
#' @param ticklabelFontsize Numeric font size in pixels for the tick labels.
#'
#' @source \url{http://bl.ocks.org/mbostock/4062006}
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
                      width = NULL, height = NULL,
                      margin = 100,
                      palette = "Set2",
                      groupNames = NULL,
                      groupColors = NULL, groupThickness = 0.1,
                      groupPadding = 0.05,
                      groupnamePadding = NULL, groupnameFontsize = 18,
                      groupedgeColor = NULL,
                      chordedgeColor = "#808080",
                      showTicks = TRUE, tickInterval = NULL,
                      ticklabelFontsize = 10) {

    if (!is.matrix(data))
        stop("'data' must be a matrix class object.")

    d <- dim(data)
    if (d[1] != d[2] )
        stop("'data' must be a square matrix.")
    n <- d[1]

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

    if (is.null(groupColors)) {
        groupColors <- RColorBrewer::brewer.pal(n, palette)
    }

    if (is.null(tickInterval)) {
        tickInterval <- 10^(floor(log10(max(data))) - 1)
    }

    params = list(matrix = data,
                  options = list(width = width, height = height,
                                 margin = margin,
                                 groupNames = groupNames,
                                 groupColors = groupColors,
                                 groupThickness = groupThickness,
                                 groupPadding = groupPadding,
                                 groupnamePadding = groupnamePadding,
                                 groupnameFontsize = groupnameFontsize,
                                 groupedgeColor = groupedgeColor,
                                 chordedgeColor = chordedgeColor,
                                 showTicks = showTicks,
                                 tickInterval = tickInterval,
                                 ticklabelFontsize = ticklabelFontsize))
    params = Filter(Negate(is.null), params)

    # create widget
    htmlwidgets::createWidget(
        name = 'chorddiag',
        params,
        width = width,
        height = height,
        # htmlwidgets::sizingPolicy(),
        htmlwidgets::sizingPolicy(padding = 0,
                                  browser.fill = TRUE),
        package = 'chorddiag'
    )
}

#' Widget output function for use in Shiny
#'
#' @export
chorddiagOutput <- function(outputId, width = '100%', height = '400px'){
    shinyWidgetOutput(outputId, 'chorddiag', width, height, package = 'chorddiag')
}

#' Widget render function for use in Shiny
#'
#' @export
renderChorddiag <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    shinyRenderWidget(expr, chorddiagOutput, env, quoted = TRUE)
}
