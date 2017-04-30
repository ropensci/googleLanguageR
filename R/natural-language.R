#' Get Entities from a string
#'
#' @param string A character vector of text to detect language for
#' @param type Whether its text or a HTML page
#' @param language Language of source, must be supported.
#'
#' @return A list of entities of the text
#' @seealso \url{https://cloud.google.com/natural-language/docs/reference/rest/v1/documents/analyzeEntities}
#' @export
gl_nlp_entity <- function(string,
                          type = c("PLAIN_TEXT", "HTML"),
                          language = c("en", "es", "ja")){

  myMessage("Finding entities for ", substring(string, 0, 100), "...", level = 3)

  type <- match.arg(type)
  language <- match.arg(language)
  assertthat::assert_that(length(string) == 1,
                          is.character(string))

  ## rate limits - 1000 requests per 100 seconds
  Sys.sleep(getOption("googleLanguageR.rate_limit"))

  call_url <- paste0("https://language.googleapis.com/v1/documents:analyzeEntities")

  body <- list(
    document = list(
      type = jsonlite::unbox(type),
      language = jsonlite::unbox(language),
      content = jsonlite::unbox(string)
    ),
    encodingType = "UTF8"
  )

  f <- googleAuthR::gar_api_generator(call_url,
                                      "POST",
                                      data_parse_function = function(x) x)

  f(the_body = body)

}
