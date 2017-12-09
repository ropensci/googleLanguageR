library(shiny)
library(tuneR)
library(googleLanguageR)
library(shinyjs)

function(input, output, session){

  output$result_text <- renderText({
    req(get_api_text())

    get_api_text()

  })

  output$result_translation <- renderText({
    req(translation())

    translation()
  })

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

  get_api_text <- reactive({
    req(wav_name())
    req(input$language)

    if(input$language == ""){
      stop("Must enter a languageCode - default en-US")
    }

    wav_name <- wav_name()

    if(!file.exists(wav_name)){
      return(NULL)
    }

    message("Calling Speech API")
    shinyjs::show(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)

    # make API call
    me <- gl_speech(wav_name,
                    sampleRateHertz = 44100L,
                    languageCode = input$language)

    ## remove old file
    unlink(wav_name)

    message("API returned: ", me$transcript$transcript)
    shinyjs::hide(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)

    me$transcript$transcript
  })

  translation <- reactive({

    req(get_api_text())
    req(input$translate)

    if(input$translate == "none"){
      return("No translation required")
    }

    message("Calling Translation API")
    shinyjs::show(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)

    ttt <- gl_translate(get_api_text(), target = input$translate)

    message("API returned: ", ttt$translatedText)
    shinyjs::hide(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)

    ttt$translatedText

  })

  observe({

    req(translation())

    if(!isNamespaceLoaded("rsay")){
      message("For talk back on MacOS, needs 'rsay' package https://github.com/sellorm/rsay")
    }

    if (!isTRUE(grepl("^darwin", R.version$os))){
      message("Talk back only supported on MacOS")
      return(NULL)
    }

    ## if a translation, we speak that, else the input language
    if(input$translate == "none"){

      voice <- switch(input$language,
                      "en-GB" = "Daniel",
                      "en-US" = "Agnes",
                      "da-DK" = NULL,
                      "fr-FR" = "Thomas",
                      "de-DE" = "Anna",
                      "es-ES" = "Monica",
                      "es-CL" = "Monica",
                      "nl-NL" = "Xander",
                      "ro-RO" = "Ioana",
                      "it-IT" = "Alice",
                      "nb-NO" = "Nora",
                      "sv-SE" = "Alva"
      )

      speak_me <- get_api_text()

    } else {

      voice <- switch(input$translate,
                      "en" = "Daniel",
                      "da" = NULL,
                      "fr" = "Thomas",
                      "de" = "Anna",
                      "es" = "Monica",
                      "nl" = "Xander",
                      "ro" = "Ioana",
                      "it" = "Alice",
                      "nb" = "Nora",
                      "sv" = "Alva"
      )

      speak_me <- translation()
    }


    if(is.null(voice)){
      message("Unsupported language to speak")
      return(NULL)
    }

    rsay::speak(speak_me, voice = voice)

  })



}
