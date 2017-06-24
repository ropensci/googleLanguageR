library(shiny)
library(shinysense) # https://github.com/nstrayer/shinysense
library(googleLanguageR)
library(shinysense)
library(tidyverse)
library(forcats)

# Define server logic required to draw a histogram
function(input, output) {

  #object to hold all your recordings in to plot
  rvs <- reactiveValues(
    recordings = data_frame(value = numeric(), frequency = integer(), num = character(), label = character()),
    counter = 0
  )

  recorder <- callModule(shinyearr, "my_recorder")

  #initialize plot so it isnt just an empty space.
  output$frequencyPlot <- renderPlot({
    ggplot(rvs$recordings) +
      xlim(0,256) +
      labs(x = "frequency", y = "value") +
      labs(title = "Frequency bins from recording")
  })

  observeEvent(recorder(), {
    my_recording <- recorder()

    rvs$counter <- rvs$counter + 1
    rvs$recordings <- rbind(
      data_frame(value = my_recording, frequency = 1:256, num = paste("recording", rvs$counter), label = input$label),
      rvs$recordings
    ) %>% mutate(num = fct_inorder(num))

    # Generate a plot of the recording we just made
    output$frequencyPlot <- renderPlot({

      ggplot(rvs$recordings, aes(x = frequency, y = value)) +
        geom_line() +
        geom_text(aes(label = label), x = 255, y = 100,
                  color = "steelblue", size = 16, hjust = 1) +
        facet_wrap(~num) +
        labs(title = "Frequency bins from recording")

    })
  })

  output$downloadData <- downloadHandler(
    filename = "my_recordings.csv",
    content = function(file) {
      write.csv(rvs$recordings, file)
    }
  )

}
