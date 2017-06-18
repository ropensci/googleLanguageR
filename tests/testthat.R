library(googleAuthR)
gar_cache_setup("googleLanguageR", location = "mock")
library(testthat)
library(googleLanguageR)

test_check("googleLanguageR")
