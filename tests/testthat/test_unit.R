library(googleAuthR)
# cache to file system
gar_cache_setup(memoise::cache_filesystem("mock"))

context("Unit tests - can find cache folder")

test_that("Cache folder exists", {

  expect_true(file.exists(file.path("mock")))
})

context("Unit tests - NLP")

test_that("NLP returns expected fields", {

  test_text <- "The cat sat on the mat"
  nlp <- gl_nlp(test_text)

  expect_equal(nlp$sentences$text$content, test_text)

})

context("Unit tests - Speech")

test_that("Speech recognise expected", {

  test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")

  result <- gl_speech_recognise(test_audio)

  test_result <- "to administer medicine to animals Is frequent give very difficult matter and yet sometimes it's necessary to do so"
  ## the API call varies a bit, so it passes if within 10 characters of expected transscript
  expect_true(stringdist::ain(result$transcript, test_result, maxDist = 10))

})

context("Unit tests - Translation")

test_that("Listing translations works", {
  skip_on_cran()

  gl_list <- gl_translate_list()

  expect_equal(class(gl_list), "data.frame")

})

test_that("Translation detection works", {

  text <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  japan <- gl_translate_detect(text)

  expected <- "ja"

  expect_equal(japan[[1]]$language, expected)

})

test_that("Translation from Japanese works", {

  text <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  japan <- gl_translate_language(text)

  expected <- "Administration of medicines to animals is often a very difficult problem, but sometimes you need to do it"

  expect_true(stringdist::ain(japan$translatedText, expected, maxDist = 10))

})



