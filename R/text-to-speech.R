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
#' Supported voices are here \url{https://cloud.google.com/text-to-speech/docs/voices}
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
                    name = "en-US-Wavenet-C",
                    languageCode = "en",
                    gender = c("SSML_VOICE_GENDER_UNSPECIFIED", "MALE","FEMALE","NEUTRAL"),
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
    is.string(languageCode)
  )

  if(!is.null(name)){
    assert_that(is.string(name))
  }

  if(!is.null(sampleRateHertz)){
    assert_that(is.scalar(sampleRateHertz))
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

  my_message("Calling text-to-speech API with voice: ",name, " input: ", input, level = 3)

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
#' \notrun{
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

