library(shiny)
library(chorddiag)

shinyUI(fluidPage(
    titlePanel("Hair Color Preferences"),

    sidebarLayout(

        sidebarPanel(
            sliderInput("margin", "Margin",  min = 0, max = 200, value = 100),
            sliderInput("groupnamePadding", "Group Name Padding",  min = 0, max = 100, value = 30),
            checkboxInput("showTicks", "Show Ticks", value = TRUE)
        ),

        mainPanel(
            chorddiagOutput('chorddiag', height = '600px'),
            verbatimTextOutput("shiny_return"),
            verbatimTextOutput("shiny_return2")
        )
    )
))
