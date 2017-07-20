library(googleAuthR)
# cache to file system
gar_cache_setup(memoise::cache_filesystem(file.path("mock")))

on_travis <- Sys.getenv("CI") == "true"
if(on_travis){
  cat("\n#testing on CI\n")
} else {
  cat("\n#testing not on CI\n")
}

context("Unit tests - caching works")

test_that("Cache folder exists", {

  folder <- file.path("mock")
  expect_true(dir.exists(folder))
  cat("\n#cache files: ", list.files(folder), "\n")
  expect_true(length(list.files(folder)) > 0)
  cat(getwd())
  cat("\n#gar_cache_get_loc: ", gar_cache_get_loc()$keys())
  expect_equal(gar_cache_get_loc()$keys(), list.files(folder))

})

test_that("Memoise works on Travis at all", {

  f <- function() as.numeric(Sys.time())
  mf <- memoise::memoise(f, cache = memoise::cache_filesystem("mock"))

  cached_time <- mf()

  cat("\n#cache test time (1500547795): ", cached_time, "\n")

  expect_equal(cached_time, 1500547795)

})

test_that("Use memoise directly", {

  gar_cache_setup(NULL)
  test_text <- "The cat sat on the mat"

  mgl_nlp <- memoise::memoise(gl_nlp, cache = memoise::cache_filesystem("mock"))
  nlp <- mgl_nlp(test_text)

  expect_equal(nlp$sentences$text$content, test_text)

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



