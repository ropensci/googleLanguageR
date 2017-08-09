library(httptest)
.mockPaths(path.expand(file.path(getwd(),"mock")))

local_auth <- Sys.getenv("GL_AUTH") != ""
if(!local_auth){
  cat("\nNo authentication file detected - skipping integration tests\n")
} else {
  cat("\nPerforming API calls for integration tests\n")
}

on_travis <- Sys.getenv("CI") == "true"
if(on_travis){
  cat("\n#testing on CI - working dir: ", path.expand(getwd()), "\n")
} else {
  cat("\n#testing not on CI\n")
}

context("API Mocking")

test_that("Record requests if online", {
  skip_if_disconnected()
  skip_if_not(local_auth)

  ## test reqs
  test_text <- "The cat sat on the mat"
  test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")
  text <- "Der gives Folk, der i den Grad omgaaes letsindigt og skammeligt med Andres Ideer, de snappe op, at de burde tiltales for ulovlig Omgang med Hittegods."

  capture_requests(
    path = "mock", {
      gl_nlp(test_text)
      gl_speech_recognise(test_audio)
      gl_translate_languages()
      gl_translate_detect(text)
      gl_translate_language(text)
    })

})


with_mock_API({
  context("Unit tests - NLP")


  test_that("NLP returns expected fields", {

    test_text <- "The cat sat on the mat"
    nlp <- gl_nlp(test_text)

    expect_s3_class(nlp[[1]]$sentences, "data.frame")
    expect_equal(nlp[[1]]$sentences$content, test_text)

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

})
