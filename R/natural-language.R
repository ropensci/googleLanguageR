#' Perform Natural Language Analysis
#'
#' Analyse text entities, sentiment, syntax and categorisation using the Google Natural Language API
#'
#' @param string A vector of text to detect language for, or Google Cloud Storage URI(s)
#' @param nlp_type The type of Natural Language Analysis to perform.  The default \code{annotateText} will perform all features in one call.
#' @param type Whether input text is plain text or a HTML page
#' @param language Language of source, must be supported by API.
#' @param encodingType Text encoding that the caller uses to process the output
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
#' @return A list of the following objects, if those fields are asked for via \code{nlp_type}:
#'
#' \itemize{
#'  \item{sentences - }{\href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Sentence}{Sentences in the input document}}
#'  \item{tokens - }{\href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Token}{Tokens, along with their syntactic information, in the input document}}
#'  \item{entities - }{\href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Entity}{Entities, along with their semantic information, in the input document}}
#'  \item{documentSentiment - }{\href{https://cloud.google.com/natural-language/docs/reference/rest/v1/Sentiment}{The overall sentiment for the document}}
#'  \item{classifyText -}{\href{https://cloud.google.com/natural-language/docs/classifying-text}{Classification of the document}}
#'  \item{language - }{The language of the text, which will be the same as the language specified in the request or, if not specified, the automatically-detected language}
#'  \item{text - }{The original text passed into the API. \code{NA} if not passed due to being zero-length etc. }
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
#' nlp <- gl_nlp(text)
#'
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
#' @importFrom purrr map_chr
#' @importFrom purrr compact
gl_nlp <- function(string,
                   nlp_type = c("annotateText",
                                "analyzeEntities",
                                "analyzeSentiment",
                                "analyzeSyntax",
                                "analyzeEntitySentiment",
                                "classifyText"),
                   type = c("PLAIN_TEXT", "HTML"),
                   language = c("en", "zh","zh-Hant","fr","de",
                                "it","ja","ko","pt","es"),
                   encodingType = c("UTF8","UTF16","UTF32","NONE")){

  nlp_type      <- match.arg(nlp_type)
  type          <- match.arg(type)
  language      <- match.arg(language)
  encodingType  <- match.arg(encodingType)
  # global env set in version.R
  version       <- get_version()

  api_results <- map(string, gl_nlp_single,
      nlp_type = nlp_type,
      type = type,
      language = language,
      encodingType = encodingType,
      version = version)

  ## hack to avoid parser complaints
  .x <- NULL

  ## map api_results so all nlp_types in own list
  the_types    <- c("sentences", "tokens", "entities")
  the_types    <- setNames(the_types, the_types)
  ## create output shape
  out          <- map(the_types, ~ map(api_results, .x))
  out$language <- map_chr(api_results, ~ if(is.null(.x)){ NA } else {.x$language})
  out$text     <- map_chr(api_results, ~ if(is.null(.x)){ NA } else {.x$text})
  out$documentSentiment <- my_map_df(api_results,  out_documentSentiment)
  out$classifyText <- my_map_df(api_results, out_classifyText)

  out

}

out_documentSentiment <- function(x){

  out <- tibble(magnitude=NA_real_, score=NA_real_)

  if(!is.null(x)){
    out <- as_tibble(x$documentSentiment)
  }

  out
}

out_classifyText <- function(x){

  out <- tibble(name=NA_character_, confidence=NA_integer_)

  if(!is.null(x)){
    out <- as_tibble(x$classifyText)
  }

  out

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
                                       "analyzeEntitySentiment",
                                       "classifyText"),
                          type = c("PLAIN_TEXT", "HTML"),
                          language = c("en", "zh","zh-Hant","fr","de",
                                       "it","ja","ko","pt","es"),
                          encodingType = c("UTF8","UTF16","UTF32","NONE"),
                          version = c("v1", "v1beta2")){

  ## string processing
  assert_that(is.string(string))
  string <- trimws(string)
  if(nchar(string) == 0 || is.na(string)){
    my_message("Zero length string passed, not calling API", level = 2)
    return(NULL)
  }

  nlp_type      <- match.arg(nlp_type)
  version       <- match.arg(version)
  type          <- match.arg(type)
  language      <- match.arg(language)
  encodingType  <- match.arg(encodingType)

  my_message(nlp_type, " for '", substring(string, 0, 50), "'",
            level = 2)

  my_message(nlp_type, ": ", nchar(string), " characters", level = 3)

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
        extractDocumentSentiment = jubox(TRUE),
        extractEntitySentiment = jubox(TRUE),
        classifyText = jubox(TRUE)
      )))

    if(version == "v1beta2"){
      # put beta features here
      #body$features$extractEntitySentiment = jubox(TRUE)
    }
  }

  call_api <- gar_api_generator(call_url,
                                "POST",
                                data_parse_function = parse_nlp)


  out <- call_api(the_body = body)

  out$text <- string

  out

}

#' @importFrom tibble as_tibble
#' @importFrom tibble tibble
#' @importFrom purrr is_empty
#' @importFrom purrr compact
#' @importFrom magrittr %>%
#' @noRd
parse_nlp <- function(x){

  s <- t <- e <- d <- cats <- NULL

  if(!is_empty(x$sentences)){
    s <- my_cbind(as_tibble(x$sentences$text),
                   as_tibble(x$sentences$sentiment))
  }

  if(!is_empty(x$tokens)){
    t <- my_cbind(as_tibble(x$tokens$text),
                   as_tibble(x$tokens$partOfSpeech),
                   as_tibble(x$tokens$dependencyEdge),
                   as_tibble(x$tokens$lemma))
  }

  if(!is_empty(x$entities)){

    e <- x$entities[, c("name","type","salience")]

    if(!is_empty(x$entities$metadata)){
      e <- my_cbind(e, x$entities$metadata)
    } else {
      e <- my_cbind(e, data.frame(mid = NA_character_, wikipedia_url = NA_character_))
    }

    if(!is_empty(x$entities$sentiment)){
      e <- my_cbind(e, x$entities$sentiment)
    } else {
      e <- my_cbind(e, data.frame(magnitude = NA_real_, score = NA_real_))
    }

    ## needs to come last as mentions can hold more rows than
    ## passed in words as it matches multiple
    if(!is_empty(x$entities$mentions)){

      mentions <- my_map_df(x$entities$mentions,
                         ~ my_cbind(.x$text, tibble(mention_type = .x$type)))

      e <- merge(e, mentions, by.x = "name", by.y = "content", all = TRUE)

    } else {
      ## for v1beta2 will also add sentiment_ ?
      ## https://cloud.google.com/natural-language/docs/reference/rest/v1beta2/Entity#EntityMention
      e <- my_cbind(e, data.frame(beginOffset = NA_integer_, type = NA_character_))
    }

    e <- as_tibble(e)

  }

  if(!is_empty(x$documentSentiment)){
    d <- as_tibble(x$documentSentiment)
  }

  if(!is_empty(x$categories)){
    cats <- x$categories
  }

  compact(list(
    sentences = s,
    tokens = t,
    entities = e,
    documentSentiment = d,
    classifyText = cats,
    language = x$language
  ))



}
