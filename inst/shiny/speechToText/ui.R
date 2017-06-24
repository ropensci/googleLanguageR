library(shiny)
library(shinysense) # https://github.com/nstrayer/shinysense

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  titlePanel("shinyearr demo"),
  p("Click on the button below to record audio from your microphone. After your recording is done a plot will display your data in terms of the fourier transformed signal decomposed into 256 sequential frequencies."),
  p("You can input a label for each recording and then export the results of all your recordings as a tidy csv, perfect for all your machine learning needs!"),
  hr(),
  fluidRow(
    div(style = "height:100%;",
        column(4, offset = 1,
               shinyearrUI("my_recorder")
        ),
        column(6,
               textInput("label", "recording label"),
               offset = 1
        )
    )
  ),
  plotOutput("frequencyPlot"),
  downloadButton('downloadData', 'download your data'),
  hr(),
  p("If this is exciting to you make sure to head over to the project's", a(href = "https://github.com/nstrayer/shinyearr/tree/master/demo", "github page"), "where you can find all the code.")

))
