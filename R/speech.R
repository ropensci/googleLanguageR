#' Call Google Speech API
#'
#' Turn audio into text
#'
#' @param audio_source File location of audio data bytes in base64-encoded string, or Google Cloud Storage URI
#' @param encoding Encoding of audio data sent
#' @param sampleRateHertz Sample rate in Hertz of audio data. Valid values \code{8000-48000}. Optimal \code{16000}
#' @param languageCode Language of the supplied audio as a \code{BCP-47} language tag
#' @param maxAlternatives Maximum number of recognition hypotheses to be returned. \code{0-30}
#' @param profanityFilter If \code{TRUE} will attempt to filter out profanities
#' @param speechContexts An optional character vector of context to assist the speech recognition
#'
#' @details
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
#' @export
gl_speech_recognise <- function(audio_source,
                                encoding = c("LINEAR16","FLAC","MULAW","AMR","AMR_WB","OGG_OPUS","SPEEX_WITH_HEADER_BYTE"),
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
                                      data_parse_function = function(x) x)

  f(the_body = body)

}
