# used to specify the API endpoint - on GitHub beta, on CRAN, stable
get_version <- function(){
  if(grepl("\\.9...$", utils::packageVersion("googleLanguageR"))){
    version <- "v1beta2"
  } else {
    version <- "v1"
  }

  version
}
