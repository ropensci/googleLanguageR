#' Perform Natural Language Analysis on text
#'
#' Analyse text entities, sentiment, and syntax using the Google Natural Language API
#'
#' @param string A length one character of text to detect language for, or Google Cloud Storage URI
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
#' @import assertthat
#' @importFrom googleAuthR gar_api_generator
gl_nlp <- function(string,
                   nlp_type = c("annotateText",
                                "analyzeEntities",
                                "analyzeSentiment",
                                "analyzeSyntax",
                                "analyzeEntitySentiment"),
                   type = c("PLAIN_TEXT", "HTML"),
                   language = c("en", "zh","zh-Hant","fr","de",
                                "it","ja","ko","pt","es"),
                   encodingType = c("UTF8","UTF16","UTF32","NONE"),
                   version = c("v1", "v1beta2", "v1beta1")){

  assert_that(is.string(string))
  myMessage(nlp_type, " for '", substring(string, 0, 50), "...'",
            level = 3)

  nlp_type      <- match.arg(nlp_type)
  version       <- match.arg(version)
  type          <- match.arg(type)
  language      <- match.arg(language)
  encodingType  <- match.arg(encodingType)

  call_url <- sprintf("https://language.googleapis.com/%s/documents:%s",
                      version, nlp_type)

  body <- list(
    document = list(
      type = jubox(type),
      language = jubox(language)
    ),
    encodingType = encodingType
  )

  if(is.gcs(string)){
    body$document$gcsContentUri <- jubox(string)
  } else {
    body$document$content = jubox(string)
  }

  if(nlp_type == "annotateText"){

    body <- c(body, list(
      features = list(
        extractSyntax = jubox(TRUE),
        extractEntities = jubox(TRUE),
        extractDocumentSentiment = jubox(TRUE)
      )))

    if(version == "v1beta2"){
      body$features$extractEntitySentiment = jubox(TRUE)
    }
  }

  f <- gar_api_generator(call_url,
                         "POST",
                         data_parse_function = function(x) x)

  f(the_body = body)


}
