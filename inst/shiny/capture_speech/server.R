library(shiny)

# Define server logic required to draw a histogram
function(input, output, session){

  output$wav <- renderText({
    req(input$audio)

    browser()
  })

}
