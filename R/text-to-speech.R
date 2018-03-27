#' Perform text to speech
#'
#' Synthesizes speech synchronously: receive results after all text input has been processed.
#'
#' @param input The text to turn into speech
#' @param output Where to save the speech audio file
#' @param languageCode The language of the voice as a \code{BCP-47} language code
#' @param name Name of the voice, see list of supported voices in details.  Set to \code{NULL} to make the service choose a voice based on \code{languageCode} and \code{gender}.
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
#' }
#'
#' @export
#' @importFrom googleAuthR gar_api_generator
#' @import assertthat
gl_talk <- function(input,
                    output = "output.wav",
                    languageCode = "en-GB",
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
    is.string(languageCode),
    is.string(output)
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
