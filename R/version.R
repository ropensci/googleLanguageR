#' Determine API endpoint version
#'
#' Used to specify the API endpoint: GitHub beta versions or CRAN stable.
#'
#' @param api Character, one of "nlp", "tts", "speech", "trans"
#' @return Character string of API version
#' @keywords internal
get_version <- function(api = c("nlp", "tts", "speech", "trans")) {

  api <- match.arg(api)

  # If using GitHub development version (version ending in .9xxx)
  if (grepl("\\.9\\d{3}$", as.character(utils::packageVersion("googleLanguageR")))) {

    version <- switch(api,
                      speech = "v1p1beta1",
                      nlp    = "v1beta2",
                      tts    = "v1beta1",
                      trans  = "v2")  # No beta for translation

  } else {
    # CRAN/stable release
    version <- "v1"
  }

  version
}
