#' Perform Natural Language Analysis on text
#'
#' Analyse text entites, sentiment, and syntax using the Google Natural Language API
#'
#' @param string A character vector of text to detect language for, or Google Cloud Storage URIs
#' @param nlp_type The type of Natural Language Analysis to perform.  The default \code{annotateText} will perform all features in one call.
#' @param type Whether input text is plain text or a HTML page
#' @param language Language of source, must be supported by API.
#' @param encodingType Text encoding that the caller uses to process the output
#' @param version the API version
#'
#' @details
#'
#' \code{string} can be a character vector, or a location of a file content on Google cloud Storage.
#'   This URI must be of the form \code{gs://bucket_name/object_name}
#'
#' Encoding type can usually be left at default \code{UTF8}.
#'   See here for details: \url{https://cloud.google.com/natural-language/docs/reference/rest/v1/EncodingType}
#'
#' The current language support is available here \url{https://cloud.google.com/natural-language/docs/languages}
#'
#' @return A list of analysis of the text
#' @seealso \url{https://cloud.google.com/natural-language/docs/reference/rest/v1/documents}
#'
#' @examples
#'
#' \dontrun{
#'
#' text <- "to administer medicince to animals is frequently a very difficult matter,
#'   and yet sometimes it's necessary to do so"
#' nlp_result <- gl_nlp(text)
#'
#' head(nlp_result$tokens$text)
#'
#' head(nlp_result$tokens$partOfSpeech$tag)
#'
#' nlp_result$entities
#'
#' nlp_result$documentSentiment
#'
#' }
#'
#' @export
gl_nlp <- function(string,
                   nlp_type = c("annotateText", "analyzeEntities", "analyzeSentiment", "analyzeSyntax","analyzeEntitySentiment"),
                   type = c("PLAIN_TEXT", "HTML"),
                   language = c("en", "zh","zh-Hant","fr","de","it","ja","ko","pt","es","de"),
                   encodingType = c("UTF8","UTF16","UTF32","NONE"),
                   version = c("v1", "v1beta2", "v1beta1")){

  nlp_type <- match.arg(nlp_type)

  myMessage(nlp_type, " for '", substring(string, 0, 100), "...'", level = 3)

  assertthat::assert_that(is.unit(string),
                          is.character(string))
  version <- match.arg(version)
  type <- match.arg(type)
  language <- match.arg(language)
  encodingType <- match.arg(encodingType)

  ## rate limits - 1000 requests per 100 seconds
  Sys.sleep(getOption("googleLanguageR.rate_limit"))

  call_url <- sprintf("https://language.googleapis.com/%s/documents:%s", version, nlp_type)

  if(is.gcs(string)){
    body <- list(
      document = list(
        type = jsonlite::unbox(type),
        language = jsonlite::unbox(language),
        gcsContentUri = jsonlite::unbox(string)
      ),
      encodingType = encodingType
    )
  } else {
    body <- list(
      document = list(
        type = jsonlite::unbox(type),
        language = jsonlite::unbox(language),
        content = jsonlite::unbox(string)
      ),
      encodingType = encodingType
    )
  }

  if(nlp_type == "annotateText"){

    if(version == "v1beta2"){
      body <- c(body, list(
        features = list(
          extractSyntax = jsonlite::unbox(TRUE),
          extractEntities = jsonlite::unbox(TRUE),
          extractDocumentSentiment = jsonlite::unbox(TRUE),
          extractEntitySentiment = jsonlite::unbox(TRUE)
        )))

    } else {
      body <- c(body, list(
        features = list(
          extractSyntax = jsonlite::unbox(TRUE),
          extractEntities = jsonlite::unbox(TRUE),
          extractDocumentSentiment = jsonlite::unbox(TRUE)
        )))

    }
  }

  f <- googleAuthR::gar_api_generator(call_url,
                                      "POST",
                                      data_parse_function = function(x) x)

  f(the_body = body)


}
