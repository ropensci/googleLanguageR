function(request){
  cat("httprequest")
  gsub_request(request, "https\\://(.+).googleapis.com/", "mock/")
}
