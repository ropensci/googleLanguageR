library(shiny)
library(tuneR)
library(googleLanguageR)

# Define server logic required to draw a histogram
function(input, output, session){

  input_audio <- reactive({
    req(input$audio)
    a <- input$audio

    saveRDS(a, "raw_audio.rds")
    if(length(a) > 0){
      return(a)
    } else {
      NULL
    }

  })

  wav_name <- reactive({
    req(input_audio())

    a <- input_audio()

    ## split two channel audio
    audio_split <- length(a)/2
    a1 <- a[1:audio_split]
    a2 <- a[(audio_split+1):length(a)]

    Wobj <- Wave(a1, a2, samp.rate = 44100, bit = 16)
    Wobj <- normalize(Wobj, unit = "16", pcm = TRUE)
    Wobj <- mono(Wobj)

    wav_name <- paste0("audio",gsub("[^0-9]","",Sys.time()),".wav")

    writeWave(Wobj, wav_name, extensible = FALSE)
    message("saved wav to ", wav_name)

    # "audio20171123132816.wav"
    wav_name


  })


  output$result_text <- renderText({
    req(wav_name())

    wav_name <- wav_name()

    message("Calling API")
    me <- googleLanguageR::gl_speech(wav_name, sampleRateHertz = 44100L)
str(me)

    message("API returned: ", me$transcript$transcript)
    unlink(wav_name)

    as.character(me$transcript$transcript)

  })

  output$the_time <- renderText({as.character(Sys.time())})


}
