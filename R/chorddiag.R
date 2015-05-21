#' Create a D3 Chord Diagram
#'
#' Based on http://bl.ocks.org/mbostock/4062006
#'
#' @import htmlwidgets
#'
#' @export
chorddiag <- function(data, groupcolors = NULL,
                      tickInterval = 100,
                      padding = list(groups = 0.05,
                                     groupnames = NULL),
#                       groupnamePadding = 0,
                      fontsize = list(groupnames = 18,
                                      ticklabels = 10),
                      width = NULL, height = NULL) {

    if (!is.matrix(data))
        stop("'data' must be a matrix class object.")
    groupnames <- colnames(data)

    d <- dim(data)
    if (d[1] != d[2] )
        stop("'data' must be a square matrix.")
    n <- d[1]

    if (is.null(groupcolors)) {
        groupcolors <- RColorBrewer::brewer.pal(n, "Set2")
    }

    params = list(matrix = data,
                  options = list(groupnames = groupnames,
                                 groupcolors = groupcolors,
                                 tickInterval = tickInterval,
#                                  groupnamePadding = groupnamePadding,
                                 fontsize = fontsize,
                                 padding = padding,
                                 height = height,
                                 width = width))
    params = Filter(Negate(is.null), params)

    # create widget
    htmlwidgets::createWidget(
        name = 'chorddiag',
        params,
        width = width,
        height = height,
        htmlwidgets::sizingPolicy(),
#         htmlwidgets::sizingPolicy(viewer.padding = 10,
#                                   browser.fill = TRUE),
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
