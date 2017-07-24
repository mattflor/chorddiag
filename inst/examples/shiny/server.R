library(shiny)
library(chorddiag)

m <- matrix(c(11975,  5871, 8916, 2868,
              1951, 10048, 2060, 6171,
              8010, 16145, 8090, 8045,
              1013,   990,  940, 6907),
            byrow = TRUE,
            nrow = 4, ncol = 4)
groupNames <- c("black", "blonde", "brown", "red")
groupColors <- c("#000000", "#FFDD89", "#957244", "#F26223")

row.names(m) <- groupNames
colnames(m) <- groupNames

shinyServer(function(input, output) {
    output$chorddiag <- renderChorddiag(
        chorddiag(m,
                  groupColors = groupColors,
                  groupnamePadding = input$groupnamePadding,
                  showTicks = input$showTicks,
                  margin = input$margin,
                  clickAction = "Shiny.onInputChange('sourceIndex', d.source.index+1);
                                 Shiny.onInputChange('targetIndex', d.target.index+1);",
                  clickGroupAction = "Shiny.onInputChange('groupIndex', d.index+1);")
    )

    output$shiny_return <- renderPrint({
        paste0("Clicked chord: ", groupNames[input$sourceIndex], " <-> ", groupNames[input$targetIndex])
    })

    output$shiny_return2 <- renderPrint({
        paste0("Clicked group: ", groupNames[input$groupIndex])
    })

})
