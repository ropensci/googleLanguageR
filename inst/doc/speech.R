## ---- include=FALSE------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ---- message=TRUE, warning=FALSE----------------------------------------
library(googleLanguageR)
## get the sample source file
test_audio <- system.file("woman1_wb.wav", package = "googleLanguageR")

## its not perfect but...:)
gl_speech(test_audio)$transcript

## get alternative transcriptions
gl_speech(test_audio, maxAlternatives = 2L)$transcript

gl_speech(test_audio, languageCode = "en-GB")$transcript

## help it out with context for "frequently"
gl_speech(test_audio, 
            languageCode = "en-GB", 
            speechContexts = list(phrases = list("is frequently a very difficult")))$transcript

