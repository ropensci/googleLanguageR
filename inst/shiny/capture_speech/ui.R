library(shiny)
library(shinyjs)

shinyUI(
  fluidPage(
    useShinyjs(),
    includeCSS("www/style.css"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),

  titlePanel("Capture audio and send to Google Speech API"),

  sidebarLayout(
    sidebarPanel(
      helpText("Click on the microphone to record, click again to send to Cloud Speech API and wait for results."),
      img(id = "record",
          src = "mic128.png",
          onclick = "toggleRecording(this);",
          style = "display:block; margin:1px auto;"),
      hr(),
      div(id = "viz",
          tags$canvas(id = "analyser"),
          tags$canvas(id = "wavedisplay")
      ),
      br(),
      hr(),
      selectInput("language", "Add a languageCode", choices = c("English (UK)" = "en-GB",
                                                                "English (Americans)" = "en-US",
                                                                "Danish" = "da-DK",
                                                                "French (France)" = "fr-FR",
                                                                "German" = "de-DE",
                                                                "Spanish (Spain)" = "es-ES",
                                                                "Spanish (Chile)" = "es-CL",
                                                                "Dutch" = "nl-NL",
                                                                "Romainian" = "ro-RO",
                                                                "Italian" = "it-IT",
                                                                "Norwegian" = "nb-NO",
                                                                "Swedish" = "sv-SE")),
      helpText("Many more languages are supported in the API but I couldn't be bothered to put them all in - see here:",
               a(href="https://cloud.google.com/speech/docs/languages", "Supported languages"))
    ),

    mainPanel(
      helpText("Transcription will appear here when ready. (Can take 30 seconds +).  Streaming support not implemented yet."),
      shinyjs::hidden(
        div(id = "api",
            p("Calling API - please wait", icon("circle-o-notch fa-spin fa-fw"))
        )),
      h3(textOutput("result_text"))
    )
  ),
  helpText(
    a("Adapted from Web Audio Demos",
      href="https://webaudiodemos.appspot.com/AudioRecorder/index.html"))
))
