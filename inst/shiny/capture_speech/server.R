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

  output$nlp_sentences <- renderTable({
    req(nlp())

    nlp()$sentences[[1]]

  })

  output$nlp_tokens <- renderTable({
    req(nlp())

    ## only a few otherwise it breaks formatting
    nlp()$tokens[[1]][, c("content","beginOffset","tag","mood","number")]

  })

  output$nlp_entities <- renderTable({
    req(nlp())

    nlp()$entities[[1]]

  })

  output$nlp_misc <- renderTable({
    req(nlp())

    data.frame(
      language = nlp()$language,
      text = nlp()$text,
      documentSentimentMagnitude = nlp()$documentSentiment$magnitude,
      documentSentimentScore = nlp()$documentSentiment$score
    )

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

  nlp <- reactive({
    req(get_api_text())
    req(input$nlp)

    nlp_lang <- switch(input$nlp,
        none = NULL,
        input = substr(input$language, start = 0, stop = 2),
        trans = input$translate # not activated from ui.R dropdown as entity analysis only available on 'en' at the moment
    )

    if(is.null(nlp_lang)){
      return(NULL)
    }

    ## has to be on supported list of NLP language codes
    if(!any(nlp_lang %in% c("en", "zh", "zh-Hant", "fr",
                       "de", "it", "ja", "ko", "pt", "es"))){
      message("Unsupported NLP language, switching to 'en'")
      nlp_lang <- "en"
    }

    message("Calling NLP API")
    shinyjs::show(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)

    nnn <- gl_nlp(get_api_text(), language = nlp_lang)

    message("API returned: ", nnn$text)
    shinyjs::hide(id = "api",
                  anim = TRUE,
                  animType = "fade",
                  time = 1,
                  selector = NULL)
    nnn

  })

  talk_file <- reactive({
    req(get_api_text())
    req(translation())
    req(input$translate)

    # clean up any existing wav files
    unlink(list.files("www", pattern = ".wav$", full.names = TRUE))

    # to prevent browser caching
    paste0(input$language,input$translate,basename(tempfile(fileext = ".wav")))

  })

  output$talk <- renderUI({

    req(get_api_text())
    req(translation())
    req(talk_file())

    # to prevent browser caching
    output_name <- talk_file()

    if(input$translate != "none"){
      audio_file <- gl_talk(translation(),
                            languageCode = input$translate,
                            name = NULL,
                            output = file.path("www", output_name))
    } else {
      audio_file <- gl_talk(get_api_text(),
                            languageCode = input$language,
                            output = file.path("www", output_name))
    }

    ## the audio file sits in folder www, but the audio file must be referenced without www
    tags$audio(autoplay = NA, controls = NA, tags$source(src = output_name))

  })

}
