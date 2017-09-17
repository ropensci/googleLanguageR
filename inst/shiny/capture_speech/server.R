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

  })


  output$result_table <- renderTable({
    req(wav_name())

    wav_name <- wav_name()

    message("Calling API")
    me <- googleLanguageR::gl_speech(wav_name, sampleRateHertz = 44100L)

    me <- tidyr::unnest(me)

    if(nrow(me) == 0){
      me <- NULL
    }

    trans_name <- paste0("transcript_",wav_name,".rds")
    message("Result saved to: ", trans_name)
    saveRDS(me, file = trans_name)
    unlink(wav_name)

    me

  })


}
