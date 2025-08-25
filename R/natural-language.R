if(getRversion() >= "2.15.1")  utils::globalVariables(c(
  "gl_nlp_single", "out_documentSentiment", "out_classifyText"
))

#' Perform Natural Language Analysis
#'
#' Analyse text for entities, sentiment, syntax and classification using the Google Natural Language API.
#'
#' @param string Character vector. Text to analyse or Google Cloud Storage URI(s) in the form \code{gs://bucket_name/object_name}.
#' @param nlp_type Character. Type of analysis to perform. Default \code{annotateText} performs all features in a single call. Options include: \code{analyzeEntities}, \code{analyzeSentiment}, \code{analyzeSyntax}, \code{analyzeEntitySentiment}, \code{classifyText}.
#' @param type Character. Whether the input is plain text (\code{PLAIN_TEXT}) or HTML (\code{HTML}).
#' @param language Character. Language of the source text. Must be supported by the API.
#' @param encodingType Character. Text encoding used to process the output. Default \code{UTF8}.
#'
#' @details
#' Encoding type can usually be left at the default \code{UTF8}.
#' \href{https://cloud.google.com/natural-language/docs/reference/rest/v1/EncodingType}{Further details on encoding types.}
#'
#' Current language support is listed \href{https://cloud.google.com/natural-language/docs/languages}{here}.
#'
#' @return A list containing the requested components as specified by \code{nlp_type}:
#' \item{sentences}{Sentences in the input document. \href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Sentence}{API reference.}}
#' \item{tokens}{Tokens with syntactic information. \href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Token}{API reference.}}
#' \item{entities}{Entities with semantic information. \href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Entity}{API reference.}}
#' \item{documentSentiment}{Overall sentiment of the document. \href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Sentiment}{API reference.}}
#' \item{classifyText}{Document classification. \href{https://cloud.google.com/natural-language/docs/classifying-text}{API reference.}}
#' \item{language}{Detected language of the text, or the language specified in the request.}
#' \item{text}{Original text passed to the API. Returns \code{NA} if input is empty.}
#'
#' @seealso \url{https://cloud.google.com/natural-language/docs/reference/rest/v1/documents}
#'
#' @examples
#' \dontrun{
#' library(googleLanguageR)
#'
#' text <- "To administer medicine to animals is frequently difficult, yet sometimes necessary."
#' nlp <- gl_nlp(text)
#'
#' nlp$sentences
#' nlp$tokens
#' nlp$entities
#' nlp$documentSentiment
#'
#' # Vectorised input
#' texts <- c("The cat sat on the mat.", "Oh no, it did not, you fool!")
#' nlp_results <- gl_nlp(texts)
#' }
#'
#' @export
#' @import assertthat
#' @importFrom googleAuthR gar_api_generator
#' @importFrom purrr map map_chr compact
gl_nlp <- function(string,
                   nlp_type = c("annotateText",
                                "analyzeEntities",
                                "analyzeSentiment",
                                "analyzeSyntax",
                                "analyzeEntitySentiment",
                                "classifyText"),
                   type = c("PLAIN_TEXT", "HTML"),
                   language = c("en", "zh", "zh-Hant", "fr", "de",
                                "it", "ja", "ko", "pt", "es"),
                   encodingType = c("UTF8", "UTF16", "UTF32", "NONE")) {

  nlp_type      <- match.arg(nlp_type)
  type          <- match.arg(type)
  language      <- match.arg(language)
  encodingType  <- match.arg(encodingType)
  version       <- get_version("nlp")

  api_results <- map(string, gl_nlp_single,
                     nlp_type = nlp_type,
                     type = type,
                     language = language,
                     encodingType = encodingType,
                     version = version)

  .x <- NULL  # avoid parser complaints

  the_types <- setNames(c("sentences", "tokens", "entities"), c("sentences", "tokens", "entities"))
  out <- map(the_types, ~ map(api_results, .x))

  out$language <- map_chr(api_results, ~ if(is.null(.x) || is.null(.x$language)) NA_character_ else .x$language)
  out$text <- map_chr(api_results, ~ if(is.null(.x) || is.null(.x$text)) NA_character_ else .x$text)
  out$documentSentiment <- my_map_df(api_results, out_documentSentiment)
  out$classifyText <- map(api_results, out_classifyText)

  out
}
