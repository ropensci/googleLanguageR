function(request){
  gsub_request(request, "https\\://(.+).googleapis.com/", "api/")
}
