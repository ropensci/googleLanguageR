#' Call Google Speech API
#'
#' Turn audio into text
#'
#' @param audio_source File location of audio data, or Google Cloud Storage URI
#' @param encoding Encoding of audio data sent
#' @param sampleRateHertz Sample rate in Hertz of audio data. Valid values \code{8000-48000}. Optimal \code{16000}
#' @param languageCode Language of the supplied audio as a \code{BCP-47} language tag
#' @param maxAlternatives Maximum number of recognition hypotheses to be returned. \code{0-30}
#' @param profanityFilter If \code{TRUE} will attempt to filter out profanities
#' @param speechContexts An optional character vector of context to assist the speech recognition
#'
#' @details
#'
#' Google Cloud Speech API enables developers to convert audio to text by applying powerful
#' neural network models in an easy to use API.
#' The API recognizes over 80 languages and variants, to support your global user base.
#' You can transcribe the text of users dictating to an application’s microphone,
#' enable command-and-control through voice, or transcribe audio files, among many other use cases.
#' Recognize audio uploaded in the request, and integrate with your audio storage on Google Cloud Storage,
#' by using the same technology Google uses to power its own products.
#'
#' @section AudioEncoding:
#'
#' Audio encoding of the data sent in the audio message. All encodings support only 1 channel (mono) audio.
#' Only FLAC and WAV include a header that describes the bytes of audio that follow the header.
#' The other encodings are raw audio bytes with no header.
#' For best results, the audio source should be captured and transmitted using a
#' lossless encoding (FLAC or LINEAR16).
#' Recognition accuracy may be reduced if lossy codecs, which include the other codecs listed in this section,
#' are used to capture or transmit the audio, particularly if background noise is present.
#'
#' Read more on audio encodings here \url{https://cloud.google.com/speech/docs/encoding}
#'
#' @examples
#'
#' \dontrun{
#'
#' test_audio <- system.files("googleLanguageR", "woman1_wb.wav")
#' result <- gl_speech_recognise(test_audio)
#'
#' result2 <- gl_speech_recognise(test_audio, maxAlternatives = 2L)
#'
#' result_brit <- gl_speech_recognise(test_audio, languageCode = "en-GB")
#'
#' }
#'
#' @seealso \url{https://cloud.google.com/speech/reference/rest/v1/speech/recognize}
#' @export
gl_speech_recognise <- function(audio_source,
                                encoding = c("LINEAR16","FLAC","MULAW","AMR",
                                             "AMR_WB","OGG_OPUS","SPEEX_WITH_HEADER_BYTE"),
                                sampleRateHertz = 16000L,
                                languageCode = "en-US",
                                maxAlternatives = 1L,
                                profanityFilter = FALSE,
                                speechContexts = NULL){

  assertthat::assert_that(is.character(audio_source),
                          is.unit(audio_source),
                          is.numeric(sampleRateHertz),
                          is.character(languageCode),
                          is.unit(languageCode),
                          is.numeric(maxAlternatives),
                          is.logical(profanityFilter))

  encoding <- match.arg(encoding)

  if(is.gcs(audio_source)){
    recognitionAudio <- list(
      uri = audio_source
    )
  } else {
    assertthat::is.readable(audio_source)
    recognitionAudio <- list(
      content = base64enc::base64encode(audio_source)
    )
  }

  body <- list(
    config = list(
      encoding = encoding,
      sampleRateHertz = sampleRateHertz,
      languageCode = languageCode,
      maxAlternatives = maxAlternatives,
      profanityFilter = profanityFilter,
      speechContexts = speechContexts
    ),
    audio = recognitionAudio
  )

  f <- googleAuthR::gar_api_generator("https://speech.googleapis.com/v1/speech:recognize",
                                      "POST",
                                      data_parse_function = function(x) x$results$alternatives[[1]])

  f(the_body = body)

}
