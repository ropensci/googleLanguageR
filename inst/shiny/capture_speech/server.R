library(shiny)
library(audio)
library(googleLanguageR)
library(tidyr)

# Define server logic required to draw a histogram
function(input, output, session){

  input_audio <- reactive({
    req(input$audio)
    a <- input$audio
    if(length(a) > 0){
      return(a)
    } else {
      NULL
    }

  })

  wav_name <- reactive({
    req(input_audio())

    a <- input_audio()
    wav_name <- paste0("audio",gsub("[^0-9]","",Sys.time()),".wav")
    save.wave(audioSample(a), wav_name)
    message("saved wav to ", wav_name)
    wav_name
    # "audio20171123132816.wav"

  })


  output$result_text <- renderText({
    req(wav_name())

    wav_name <- wav_name()

    message("Calling API")
    me <- googleLanguageR::gl_speech(wav_name, sampleRateHertz = 44100L)

    if(nrow(me$transcript) == 0){
      return(NULL)
    }

    message("API returned: ", me$transcript$transcript[[1]])
    unlink(wav_name)

    as.character(me$transcript$transcript[[1]])

  })

  output$the_time <- renderText({as.character(Sys.time())})


}
