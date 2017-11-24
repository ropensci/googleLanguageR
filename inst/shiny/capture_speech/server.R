library(shiny)
library(tuneR)
library(googleLanguageR)
library(shinyjs)

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

    ## split two channel audio
    audio_split <- length(a)/2
    a1 <- a[1:audio_split]
    a2 <- a[(audio_split+1):length(a)]

    # construct wav object that the API likes
    Wobj <- Wave(a1, a2, samp.rate = 44100, bit = 16)
    Wobj <- normalize(Wobj, unit = "16", pcm = TRUE)
    Wobj <- mono(Wobj)

    wav_name <- paste0("audio",gsub("[^0-9]","",Sys.time()),".wav")

    writeWave(Wobj, wav_name, extensible = FALSE)

    wav_name


  })


  output$result_text <- renderText({
    req(wav_name())
    req(input$language)

    if(input$language == ""){
      stop("Must enter a languageCode - default en-US")
    }

    wav_name <- wav_name()

    if(!file.exists(wav_name)){
      return(NULL)
    }

    message("Calling API")
    shinyjs::show(id = "api", anim = TRUE, animType = "fade", time = 1)

    # make API call
    me <- gl_speech(wav_name,
                    sampleRateHertz = 44100L,
                    languageCode = input$language)

    ## remove old file
    unlink(wav_name)

    message("API returned: ", me$transcript$transcript)
    shinyjs::hide(id = "api", anim = TRUE, animType = "fade", time = 1)

    as.character(me$transcript$transcript)

  })



}
