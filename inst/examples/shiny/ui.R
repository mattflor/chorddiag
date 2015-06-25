library(shiny)

shinyUI(fluidPage(
    titlePanel("Hair Color Preferences"),

    sidebarLayout(

        sidebarPanel(
            sliderInput("margin", "Margin",  min = 0, max = 200, value = 100),
            sliderInput("groupnamePadding", "Group Name Padding",  min = 0, max = 100, value = 30),
            checkboxInput("showTicks", "Show Ticks", value = TRUE)
        ),

        mainPanel(
            chorddiagOutput('chorddiag', height = '500px')
        )
    )
))
