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

  expect_equal(nlp$sentences$text$content, test_text)

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

  gl_list <- gl_translate_list()


  expect_equal(class(gl_list), "data.frame")

})

test_that("Translation detection works", {
  skip_on_cran()
  skip_if_not(local_auth)

  text <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  japan <- gl_translate_detect(text)

  expected <- "ja"

  expect_equal(japan[[1]]$language, expected)

})

test_that("Translation from Japanese works", {
  skip_on_cran()
  skip_if_not(local_auth)

  text <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  japan <- gl_translate_language(text)

  expected <- "Administration of medicines to animals is often a very difficult problem, but sometimes you need to do it"

  expect_true(stringdist::ain(japan$translatedText, expected, maxDist = 10))


})

