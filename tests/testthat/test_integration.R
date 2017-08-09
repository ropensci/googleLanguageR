library(httptest)
local_auth <- Sys.getenv("GL_AUTH") != ""
if(!local_auth){
  cat("\nNo authentication file detected - skipping integration tests\n")
} else {
  cat("\nPerforming API calls for integration tests\n")
}

context("Integration tests - Auth")

## To run integration tests hitting the API, uncomment this chunk.  By default the API calls will
## be tested vai the saved mock API files in the same folder.
test_that("Local auth working", {

  skip_if_not(local_auth)
  token <- gl_auth(Sys.getenv("GL_AUTH"))

  expect_true("TokenServiceAccount" %in% class(token))

})

context("Integration tests - NLP")

test_that("NLP returns expected fields", {
  skip_on_cran()
  skip_if_not(local_auth)

  test_text <- "The cat sat on the mat"
  nlp <- gl_nlp(test_text)

  expect_s3_class(nlp[[1]]$sentences, "data.frame")
  expect_equal(nlp[[1]]$sentences$content, test_text)

})

context("Integration tests - Speech")

test_that("Speech recognise expected", {
  skip_on_cran()
  skip_if_not(local_auth)

  ## get the sample source file
  test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")

  result <- gl_speech_recognise(test_audio)

  test_result <- "to administer medicine to animals Is frequent give very difficult matter and yet sometimes it's necessary to do so"

  ## the API call varies a bit, so it passes if within 10 characters of expected transscript
  expect_true(stringdist::ain(result$transcript, test_result, maxDist = 10))

})

context("Integration tests - Translation")


test_that("Listing translations works", {
  skip_on_cran()
  skip_if_not(local_auth)

  gl_list <- gl_translate_languages()

  expect_s3_class(gl_list, "data.frame")

})

test_that("Translation detection works", {
  skip_on_cran()
  skip_if_not(local_auth)

  text <- "Der gives Folk, der i den Grad omgaaes letsindigt og skammeligt med Andres Ideer, de snappe op, at de burde tiltales for ulovlig Omgang med Hittegods."

  danish <- gl_translate_detect(text)

  expect_s3_class(danish, "data.frame")
  expect_equal(danish$language, "da")

})

test_that("Translation from Danish works", {
  skip_on_cran()
  skip_if_not(local_auth)

  text <- "Der gives Folk, der i den Grad omgaaes letsindigt og skammeligt med Andres Ideer, de snappe op, at de burde tiltales for ulovlig Omgang med Hittegods."

  danish <- gl_translate_language(text)

  expected <- "People who are soberly and shamefully opposed to the ideas of others are given to people that they should be accused of unlawful interference with the former."

  expect_true(stringdist::ain(danish$translatedText, expected, maxDist = 10))


})

test_that("Rate limiting works", {
  skip_on_cran()
  skip_if_not(local_auth)

})

