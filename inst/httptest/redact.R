function(response){
  gsub_response(response, "https\\://(.+).googleapis.com/", "api/")
}
