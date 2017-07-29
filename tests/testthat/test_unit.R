library(httptest)
local_auth <- Sys.getenv("GL_AUTH") != ""
if(!local_auth){
  cat("\nNo authentication file detected - skipping integration tests\n")
} else {
  cat("\nPerforming API calls for integration tests\n")
}

on_travis <- Sys.getenv("CI") == "true"
if(on_travis){
  cat("\n#testing on CI\n")
  .mockPaths("tests/testthat/mock")
} else {
  cat("\n#testing not on CI\n")
  .mockPaths("mock")
}


context("API Mocking")

test_that("Record requests if online", {
  skip_if_disconnected()
  skip_if_not(local_auth)

  ## test reqs
  test_text <- "The cat sat on the mat"
  test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")
  text <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  capture_requests(
    path = "mock", {
      nlp <- gl_nlp(test_text)
      result <- gl_speech_recognise(test_audio)
      gl_list <- gl_translate_list()
      japand <- gl_translate_detect(text)
      japant <- gl_translate_language(text)
    })

})


with_mock_API({
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

})
