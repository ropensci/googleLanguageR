# used to specify the API endpoint - on GitHub beta, on CRAN, stable
get_version <- function(){

  version <- "v1"

  # github uses beta endpoints
  if(grepl("\\.9...$", utils::packageVersion("googleLanguageR"))){
    version <- "v1p1beta1"
  }

  version
}
