function(request){
   require(magrittr, quietly=TRUE)
   request %>%
       gsub_response(".googleapis.com", "", fixed=TRUE)
}
