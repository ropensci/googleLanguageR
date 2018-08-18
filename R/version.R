# used to specify the API endpoint - on GitHub beta, on CRAN, stable
get_version <- function(api = c("nlp","tts","speech","trans")){

  api <- match.arg(api)

  # github uses beta endpoints
  if(grepl("\\.9...$", utils::packageVersion("googleLanguageR"))){

    version <- switch(api,
                      speech = "v1p1beta1",
                      nlp = "v1beta2",
                      tts = "v1beta1",
                      trans = "v2") # no beta
  } else {
    version <- "v1"
  }

  version
}
