library(shiny)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    includeCSS("www/style.css"),


  # Application title
  titlePanel("Capture Speech"),
  a("Adapted from Web Audio Demos", href="https://webaudiodemos.appspot.com/AudioRecorder/index.html"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      tags$div(id = "controls",
        tags$img(id = "record", src = "mic128.png", onclick = "toggleRecording(this);"),
        tags$a(tags$img(src="save.svg"), id = "save", href="#")
      ),
      textOutput("wav")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tags$div(id = "viz",
        tags$canvas(id = "analyser"),
        tags$canvas(id = "wavedisplay")
      )
    )
  ),
  includeScript("www/speech.js"),
  includeScript("www/main.js"),
  includeScript("www/audiodisplay.js")
))
