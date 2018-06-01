#' Perform text to speech
#'
#' Synthesizes speech synchronously: receive results after all text input has been processed.
#'
#' @param input The text to turn into speech
#' @param output Where to save the speech audio file
#' @param languageCode The language of the voice as a \code{BCP-47} language code
#' @param name Name of the voice, see list via \link{gl_talk_languages} for supported voices.  Set to \code{NULL} to make the service choose a voice based on \code{languageCode} and \code{gender}.
#' @param gender The gender of the voice, if available
#' @param audioEncoding Format of the requested audio stream
#' @param speakingRate Speaking rate/speed between \code{0.25} and \code{4.0}
#' @param pitch Speaking pitch between \code{-20.0} and \code{20.0} in semitones.
#' @param volumeGainDb Volumne gain in dB
#' @param sampleRateHertz Sample rate for returned audio
#'
#' @details
#'
#' Requires the Cloud Text-To-Speech API to be activated for your Google Cloud project.
#'
#' Supported voices are here \url{https://cloud.google.com/text-to-speech/docs/voices} and can be imported into R via \link{gl_talk_languages}
#'
#' To play the audio in code via a browser see \link{gl_talk_player}
#'
#' @seealso \url{https://cloud.google.com/text-to-speech/docs/}
#'
#' @return The file output name you supplied as \code{output}
#' @examples
#'
#' \dontrun{
#'
#' gl_talk("The rain in spain falls mainly in the plain",
#'         output = "output.wav")
#'
#' gl_talk("Testing my new audio player") %>% gl_talk_player()
#'
#' }
#'
#' @export
#' @importFrom googleAuthR gar_api_generator
#' @import assertthat
gl_talk <- function(input,
                    output = "output.wav",
                    languageCode = "en",
                    gender = c("SSML_VOICE_GENDER_UNSPECIFIED", "MALE","FEMALE","NEUTRAL"),
                    name = NULL,
                    audioEncoding = c("LINEAR16","MP3","OGG_OPUS"),
                    speakingRate = 1,
                    pitch = 0,
                    volumeGainDb = 0,
                    sampleRateHertz = NULL){

  gender        <- match.arg(gender)
  audioEncoding <- match.arg(audioEncoding)

  assert_that(
    is.string(input),
    nchar(input) <= 5000L,
    is.string(output),
    is.string(languageCode),
    speakingRate >= 0.25,
    speakingRate <= 4.0,
    pitch >= -20.0,
    pitch <= 20.0
  )

  if(!is.null(name)){
    assert_that(is.string(name))
    languageCode <- substr(name, 1,2)
    gender <- NULL
  }

  if(!is.null(sampleRateHertz)){
    assert_that(is.scalar(sampleRateHertz))
  }

  ## change fileextension of output based on audioEncoding
  file_ext <- switch(audioEncoding,
                     LINEAR16 = "wav",
                     MP3 = "mp3",
                     OGG_OPUS = "ogg|opus|mka|mkv|webm")

  if(!grepl(paste0("\\.",file_ext,"$"), output)){
    warning("Output file extension (",
            output,
            ") does not match audio encoding (",
            audioEncoding,")")
  }

  body <- list(
    input = list(
      text = input
    ),
    voice = list(
      languageCode = languageCode,
      name = name,
      ssmlGender = gender
    ),
    audioConfig = list(
      audioEncoding = audioEncoding,
      speakingRate = speakingRate,
      pitch = pitch,
      volumeGainDb = volumeGainDb,
      sampleRateHertz = sampleRateHertz
    )
  )

  body <- rmNullObs(body)

  my_message("Calling text-to-speech API:", input, level = 3)

  call_api <- gar_api_generator("https://texttospeech.googleapis.com/v1beta1/text:synthesize",
                                "POST",
                                data_parse_function = audio_decode)
  o <- call_api(the_body = body)

  ## write the file
  writeBin(o, con = output)

  output
}

audio_decode <- function(x){
  jsonlite::base64_dec(x$audioContent)
}

#' Get a list of voices available for text to speech
#'
#' Returns a list of voices supported for synthesis.
#'
#' @param languageCode A \code{BCP-47} language tag.  If specified, will only return voices that can be used to synthesize this languageCode
#'
#' @import assertthat
#' @importFrom googleAuthR gar_api_generator
#' @export
gl_talk_languages <- function(languageCode = NULL){

  if(!is.null(languageCode)){
    assert_that(is.string(languageCode))
    pars <- list(languageCode = languageCode)
  } else {
    pars <- NULL
  }


  call_api <- gar_api_generator("https://texttospeech.googleapis.com/v1beta1/voices",
                                "GET",
                                pars_args = pars,
                                data_parse_function = parse_talk_language)
  call_api()

}

parse_talk_language <- function(x){

  if(length(x) == 0){
    my_message("No languages found")
    return(tibble())
  }
  o <- x$voices
  lc <- map_chr(o$languageCodes, 1)

  tibble(languageCodes = lc,
         name = o$name,
         ssmlGender = o$ssmlGender,
         naturalSampleRateHertz = o$naturalSampleRateHertz)

}

#' Play audio in a browser
#'
#' This uses HTML5 audio tags to play audio in your browser
#'
#' @param audio The file location of the audio file.  Must be supported by HTML5
#' @param html The html file location that will be created host the audio
#'
#' @details
#'
#' A platform neutral way to play audio is not easy, so this uses your browser to play it instead.
#'
#' @examples
#'
#' \dontrun{
#'
#' gl_talk("Testing my new audio player") %>% gl_talk_player()
#'
#' }
#'
#' @export
#' @importFrom utils browseURL
gl_talk_player <- function(audio = "output.wav",
                           html = "player.html"){

  writeLines(sprintf('<html><body>
    <audio controls autoplay>
                     <source src="%s">
                     </audio>
                     </body></html>',
              audio),
      html)

  utils::browseURL(html)

}

#' Speak in Shiny module (ui)
#'
#' @param id The Shiny id
#'
#' @details
#'
#' Shiny Module for use with \link{gl_talk_shiny}.
#'
#' @export
gl_talk_shinyUI <- function(id){
  ns <- shiny::NS(id)

  shiny::htmlOutput(ns("talk"))

}

#' Speak in Shiny module (server)
#'
#' Call via \code{shiny::callModule(gl_talk_shiny, "your_id")}
#'
#' @param input shiny input
#' @param output shiny output
#' @param session shiny session
#' @param transcript The (reactive) text to talk
#' @inheritDotParams gl_talk
#' @param autoplay passed to the HTML audio player - default \code{TRUE} plays on load
#' @param controls passed to the HTML audio player - default \code{TRUE} shows controls
#' @param loop passed to the HTML audio player - default \code{FALSE} does not loop
#' @param keep_wav keep the generated wav files if TRUE.
#' @export
#' @import assertthat
gl_talk_shiny <- function(input, output, session,
                          transcript, ...,
                          autoplay = TRUE, controls = TRUE, loop = FALSE,
                          keep_wav = FALSE){

  assert_that(
    is.flag(autoplay),
    is.flag(controls),
    is.flag(keep_wav)
  )

  # to deal with TRUE = NA, FALSE = NULL
  if(autoplay){
    autoplay <- NA
  } else {
    autoplay <- NULL
  }

  if(controls){
    controls <- NA
  } else {
    controls <- NULL
  }

  if(loop){
    loop <- NA
  } else {
    loop <- NULL
  }

  # make a www folder to host the audio file
  talk_file <- shiny::reactive({

    # to ensure this fires each new transcript
    shiny::req(transcript())
    # make www folder if it doesn't exisit
    if(!dir.exists("www")){
      dir.create("www")
    }

    # clean up any existing wav files
    if(!keep_wav){
      unlink(list.files("www", pattern = ".wav$", full.names = TRUE))
    }

    # to prevent browser caching its new every time
    paste0(basename(tempfile(fileext = ".wav")))

  })

  output$talk <- shiny::renderUI({

    shiny::req(talk_file())

    gl_talk(transcript(),
            output = file.path("www", talk_file()),
            ...)

    ## the audio file sits in folder www, but the audio file must be referenced without www
    shiny::tags$audio(autoplay = autoplay,
                      controls = controls,
                      loop = loop,
                      shiny::tags$source(src = talk_file()))

  })

}
