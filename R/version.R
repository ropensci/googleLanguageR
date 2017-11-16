# used to specify the API endpoint - on GitHub beta, on CRAN, stable
get_version <- function(){
  if(grepl("\\.9...$", packageVersion("googleLanguageR"))){
    my_message("Using v1beta2 API endpoint", level = 3)
    version <- "v1beta2"
  } else {
    version <- "v1"
  }

  version
}
