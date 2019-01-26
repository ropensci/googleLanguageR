function(response){
  require(magrittr, quietly=TRUE)
  response %>%
    httptest::gsub_response(".googleapis.com", "", fixed=TRUE)
}
