library(httptest)
library(rvest)
library(magrittr)
library(xml2)
library(rvest)

.mockPaths("..")

local_auth <- Sys.getenv("GL_AUTH") != ""
if(!local_auth){
  cat("\nNo authentication file detected - skipping integration tests\n")
} else {
  cat("\nFound local auth file\n")
}

on_travis <- Sys.getenv("CI") == "true"
if(on_travis){
  cat("\n#testing on CI - working dir: ", path.expand(getwd()), "\n")
} else {
  cat("\n#testing not on CI\n")
}

## Generate test text and audio
context("Setup test files")
# HTML testing
my_url <- "http://www.dr.dk/nyheder/indland/greenpeace-facebook-og-google-boer-foelge-apples-groenne-planer"


html_result <- tryCatch({
  xml2::read_html(my_url) %>%
    rvest::html_node(css = ".wcms-article-content") %>%
    html_text
}, error = function(ex){
  NULL
})

test_text <- "The cat sat on the mat"
test_text2 <- "How much is that doggy in the window?"
trans_text <- "Der gives Folk, der i den Grad omgaaes letsindigt og skammeligt med Andres Ideer, de snappe op, at de burde tiltales for ulovlig Omgang med Hittegods."
expected <- "There are people who are soberly and shamefully opposed to the ideas of others, who make it clear that they should be charged with unlawful interference with the former."

test_gcs <- "gs://mark-edmondson-public-files/googleLanguageR/a-dream-mono.wav"

test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")
