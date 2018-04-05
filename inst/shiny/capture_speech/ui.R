library(shiny)
library(shinyjs)

shinyUI(
  fluidPage(
    useShinyjs(),
    includeCSS("www/style.css"),
    includeScript("www/main.js"),
    includeScript("www/speech.js"),
    includeScript("www/audiodisplay.js"),

  titlePanel("Shiny Babelfish"),

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
      selectInput("language", "Language input", choices = c("English (UK)" = "en-GB",
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
      helpText("You can also add a call to the Google Translation API by selecting an output below"),
      selectInput("translate", "Translate output", choices = c("No Translation" = "none",
                                                                       "English" = "en",
                                                                       "Danish" = "da",
                                                                       "French" = "fr",
                                                                       "German" = "de",
                                                                       "Spanish" = "es",
                                                                       "Dutch" = "nl",
                                                                       "Romainian" = "ro",
                                                                       "Italian" = "it",
                                                                       "Norwegian" = "nb",
                                                                       "Swedish" = "sv")),
      helpText("Send the text to the Natural Language API for NLP analysis below."),
      selectInput("nlp", "Perform NLP", choices = c("No NLP" = "none",
                                                    "NLP" = "input"
                                                    #,
                                                    #"On Translated Text" = "trans"
                                                    )
                  ),
      helpText("Many more languages are supported in the API but I couldn't be bothered to put them all in - see here:",
               a(href="https://cloud.google.com/speech/docs/languages", "Supported languages"))
    ),

    mainPanel(
      helpText("Transcription will appear here when ready. (Can take 30 seconds +).  Streaming support not implemented yet."),
      shinyjs::hidden(
        div(id = "api",
            p("Calling API - please wait", icon("circle-o-notch fa-spin fa-fw"))
        )),
      h2("Transcribed text"),
      p(textOutput("result_text")),
      h2("Translated text"),
      p(textOutput("result_translation")),
      h2("NLP"),
      tableOutput("nlp_sentences"),
      tableOutput("nlp_tokens"),
      tableOutput("nlp_entities"),
      tableOutput("nlp_misc"),
      htmlOutput("talk")
    )
  ),
  helpText(
    a("Adapted from Web Audio Demos",
      href="https://webaudiodemos.appspot.com/AudioRecorder/index.html"))
))
