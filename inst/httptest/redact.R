function(response){
  cat("httpredact")
  gsub_response(response, "https\\://(.+).googleapis.com/", "mock/")
}
