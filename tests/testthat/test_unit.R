context("Unit tests - NLP")

test_that("NLP returns expected fields", {

  library(googleAuthR)
  gar_cache_setup("googleLanguageR", location = "mock")
  test_text <- "The cat sat on the mat"
  nlp <- gl_nlp(test_text)

  expect_equal(nlp$sentences$text$content, test_text)

})

context("Unit tests - Speech")

test_that("Speech recognise expected", {

  ## get the sample source file
  library(googleAuthR)
  gar_cache_setup("googleLanguageR", location = "mock")
  test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")

  result <- gl_speech_recognise(test_audio)

  test_result <- "to administer medicine to animals Is frequent give very difficult matter and yet sometimes it's necessary to do so"

  expect_equal(result$transcript, test_result)

})

context("Unit tests - Translation")

test_that("Listing translations works", {
  skip_on_cran()

  library(googleAuthR)
  gar_cache_setup("googleLanguageR", location = "mock")

  gl_list <- gl_translate_list()


  expect_equal(class(gl_list), "data.frame")

})

test_that("Translation detection works", {

  library(googleAuthR)
  gar_cache_setup("googleLanguageR", location = "mock")
  text <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  japan <- gl_translate_detect(text)

  expected <- "ja"

  expect_equal(japan[[1]]$language, expected)

})

test_that("Translation from Japanese works", {
  library(googleAuthR)
  gar_cache_setup("googleLanguageR", location = "mock")

  text <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  japan <- gl_translate_language(text)

  expected <- "Administration of medicines to animals is often a very difficult problem, but sometimes you need to do it"

  expect_true(stringdist::ain(japan$translatedText, expected, maxDist = 10))

})



