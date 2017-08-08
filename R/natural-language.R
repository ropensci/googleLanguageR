#' Perform Natural Language Analysis on text
#'
#' Analyse text entities, sentiment, and syntax using the Google Natural Language API
#'
#' @param string A vector of text to detect language for, or Google Cloud Storage URI(s)
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
#'   \href{https://cloud.google.com/natural-language/docs/reference/rest/v1/EncodingType}{Read more here}
#'
#' The current language support is available \href{https://cloud.google.com/natural-language/docs/languages}{here}
#'
#' @return A list of length equal to the number of elements in \code{string}, each element of which is a list of tibbles of the following objects, if those fields are asked for via \code{nlp_type}:
#'
#' \itemize{
#'  \item{sentences - }{\href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Sentence}{Sentences in the input document}}
#'  \item{tokens - }{\href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Token}{Tokens, along with their syntactic information, in the input document}}
#'  \item{entities - }{\href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Entity}{Entities, along with their semantic information, in the input document}}
#'  \item{documentSentiment - }{\href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Sentiment}{The overall sentiment for the document}}
#'  \item{language - }{The language of the text, which will be the same as the language specified in the request or, if not specified, the automatically-detected language}
#' }
#'
#'
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
#' nlp <- nlp_result[[1]]
#' nlp$sentences
#'
#' nlp$tokens
#'
#' nlp$entities
#'
#' nlp$documentSentiment
#'
#' ## vectorised input
#' texts <- c("The cat sat one the mat", "oh no it didn't you fool")
#' nlp_results <- gl_nlp(texts)
#'
#'
#'
#' }
#'
#' @export
#' @import assertthat
#' @importFrom googleAuthR gar_api_generator
#' @importFrom purrr map
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

  map(string, gl_nlp_single,
      nlp_type = nlp_type,
      type = type,
      language = language,
      encodingType = encodingType,
      version = version)

}

#' Used to vectorise gl_nlp
#' @import assertthat
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble enframe
#' @noRd
gl_nlp_single <- function(string,
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
  nlp_type      <- match.arg(nlp_type)

  myMessage(nlp_type, " for '", substring(string, 0, 50), "...'",
            level = 3)

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
                         data_parse_function = parse_nlp)

  me <- f(the_body = body)

  # enframe(me, name = "object")
  me

}

#' @importFrom tibble as_tibble
#' @importFrom tibble tibble
#' @importFrom dplyr bind_cols
#' @importFrom dplyr select
#' @importFrom dplyr full_join
#' @importFrom purrr map_df
#' @importFrom purrr is_empty
#' @importFrom purrr compact
#' @importFrom magrittr %>%
#' @noRd
parse_nlp <- function(x){

  s <- t <- e <- d <- NULL

  if(!is_empty(x$sentences)){
    s <- bind_cols(as_tibble(x$sentences$text),
                   as_tibble(x$sentences$sentiment))
  }

  if(!is_empty(x$tokens)){
    t <- bind_cols(as_tibble(x$tokens$text),
                   as_tibble(x$tokens$partOfSpeech),
                   as_tibble(x$tokens$dependencyEdge),
                   as_tibble(x$tokens$lemma))
  }

  if(!is_empty(x$entities)){

    name <- type <- salience <- NULL

    ent <- x$entities %>%
      select(name, type, salience)

    metadata <- x$entities$metadata

    mentions <- map_df(x$entities$mentions, ~ bind_cols(.x$text, tibble(mention_type = .x$type)))

    e <- ent %>%
      full_join(mentions, by = c(name = "content")) %>%
      bind_cols(metadata)

    if(!is_empty(x$entities$sentiment)){
      e <- bind_cols(e, x$entities$sentiment)
    }

  }

  if(!is_empty(x$documentSentiment)){
    d <- as_tibble(x$documentSentiment)
  }

  compact(list(
    sentences = s,
    tokens = t,
    entities = e,
    documentSentiment = d,
    language = x$language
  ))

}
