context("Auth")

## to run tests, you currently need to add the file location of your
## Google project service JSON file to an environemnt variable GL_AUTH
# test_that("Local auth working", {
#
#   gl_auth(Sys.getenv("GL_AUTH"))
#
# })

context("NLP")

test_that("NLP returns expected fields", {
  # skip_on_cran()
  library(googleAuthR)
  gar_cache_setup("googleLanguageR", location = "mock")
  test_text <- "The cat sat on the mat"
  nlp <- gl_nlp(test_text)

  expect_equal(nlp$sentences$text$content, test_text)

})

context("Speech")

test_that("Speech recognise expected", {
  # skip_on_cran()
  ## get the sample source file
  library(googleAuthR)
  gar_cache_setup("googleLanguageR", location = "mock")
  test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")

  result <- gl_speech_recognise(test_audio)

  test_result <- "to administer medicine to animals Is frequent give very difficult matter and yet sometimes it's necessary to do so"

  expect_equal(result$transcript, test_result)

})

context("Translation")

test_that("Translation works", {
  # skip_on_cran()
  library(googleAuthR)
  gar_cache_setup("googleLanguageR", location = "mock")
  text <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  japan <- gl_translate_detect(text)

  expected <- "ja"

  expect_equal(japan[[1]]$language, expected)

})

