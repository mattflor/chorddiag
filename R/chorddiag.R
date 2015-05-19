#' Create a D3 Chord Diagram
#'
#' Based on http://bl.ocks.org/mbostock/4062006
#'
#' @import htmlwidgets
#'
#' @export
chorddiag <- function(data, groupcolors = NULL,
                      tickInterval = 100,
                      groupnamePadding = 0,
                      width = NULL, height = NULL) {

    if (!is.matrix(data))
        stop("'data' must be a matrix class object.")
    groupnames <- colnames(data)

    params = list(matrix = data,
                  options = list(groupnames = groupnames,
                                 groupcolors = groupcolors,
                                 tickInterval = tickInterval,
                                 groupnamePadding = groupnamePadding,
                                 height = height,
                                 width = width),
                  width = width,
                  height = height)
    params = Filter(Negate(is.null), params)

    # create widget
    htmlwidgets::createWidget(
        name = 'chorddiag',
        params,
        width = width,
        height = height,
        htmlwidgets::sizingPolicy(viewer.padding = 10,
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
