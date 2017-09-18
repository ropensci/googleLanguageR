library(shiny)

shinyUI(
  fluidPage(
    includeCSS("www/style.css"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),

  titlePanel("Capture Speech"),

  a("Adapted from Web Audio Demos",
    href="https://webaudiodemos.appspot.com/AudioRecorder/index.html"),

  sidebarLayout(
    sidebarPanel(
      helpText("Click on the microphone to record, click again to send to Cloud Speech API"),
      img(id = "record", src = "mic128.png", onclick = "toggleRecording(this);"),
      div(id = "viz",
          tags$canvas(id = "analyser"),
          tags$canvas(id = "wavedisplay")
      )
    ),

    mainPanel(
      h3("Transcription"),
      tableOutput("result_table")
    )
  )
))
