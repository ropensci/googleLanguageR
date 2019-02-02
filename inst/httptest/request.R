function(request){
   require(magrittr, quietly=TRUE)
   request %>%
       httptest::gsub_response(".googleapis.com", "", fixed=TRUE)
}
