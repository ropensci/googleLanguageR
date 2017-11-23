library(httptest)
library(rvest)
library(magrittr)

.mockPaths("..")

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

## Generate test text and audio

# HTML testing
my_url <- "http://www.dr.dk/nyheder/indland/greenpeace-facebook-og-google-boer-foelge-apples-groenne-planer"

html_result <- read_html(my_url) %>%
  html_node(css = ".wcms-article-content") %>%
  html_text

test_text <- "The cat sat on the mat"
test_text2 <- "How much is that doggy in the window?"
trans_text <- "Der gives Folk, der i den Grad omgaaes letsindigt og skammeligt med Andres Ideer, de snappe op, at de burde tiltales for ulovlig Omgang med Hittegods."
expected <- "People who are soberly and shamefully opposed to the ideas of others are given to people that they should be accused of unlawful interference with the former."
# a lot of text
lots <- rep(paste(html_result, trans_text, expected),35)



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

  nlp <- gl_nlp(test_text)

  expect_equal(length(nlp), 6)
  expect_true(all(names(nlp) %in%
                     c("sentences","tokens","entities","documentSentiment","language", "text")))
  expect_s3_class(nlp$sentences[[1]], "data.frame")
  expect_equal(nlp$sentences[[1]]$content, test_text)
  expect_true(all(names(nlp$sentences[[1]]) %in% c("content","beginOffset","magnitude","score")))
  expect_true(all(names(nlp$tokens[[1]]) %in% c("content", "beginOffset", "tag", "aspect", "case",
                                         "form", "gender", "mood", "number", "person", "proper",
                                         "reciprocity", "tense", "voice", "headTokenIndex",
                                         "label", "value")))
  expect_true(all(names(nlp$entities[[1]]) %in%
                    c("name","type","salience","mid","wikipedia_url",
                      "beginOffset","magnitude", "score", "mention_type")))
  expect_true(all(names(nlp$documentSentiment) %in% c("magnitude","score")))
  expect_equal(nlp$language, "en")
  expect_s3_class(nlp$tokens[[1]], "data.frame")
  expect_s3_class(nlp$entities[[1]], "data.frame")
  expect_s3_class(nlp$documentSentiment, "data.frame")



  nlp2 <- gl_nlp(c(test_text, test_text2))
  expect_equal(length(nlp2), 6)
  expect_true(all(names(nlp2) %in%
               c("sentences","tokens","entities","text","documentSentiment","language")))
  expect_equal(length(nlp2$sentences), 2)

})

context("Integration tests - Speech")

test_that("Speech recognise expected", {
  skip_on_cran()
  skip_if_not(local_auth)
  test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")
  result <- gl_speech(test_audio)

  test_result <- "to administer medicine to animals Is frequent give very difficult matter and yet sometimes it's necessary to do so"

  expect_true(inherits(result, "list"))
  expect_true(all(names(result$transcript) %in% c("transcript","confidence","words")))

  ## the API call varies a bit, so it passes if within 10 characters of expected transscript
  expect_true(stringdist::ain(result$transcript$transcript, test_result, maxDist = 10))

  expect_equal(names(result$timings), c("startTime","endTime","word"))

})

test_that("Speech asynch tests", {
  skip_on_cran()
  skip_if_not(local_auth)

  test_gcs <- "gs://mark-edmondson-public-files/googleLanguageR/a-dream-mono.wav"

  async <- gl_speech(test_gcs, asynch = TRUE, sampleRateHertz = 44100)
  expect_true(inherits(async, "gl_speech_op"))

  Sys.sleep(45)
  result2 <- gl_speech_op(async)
  expect_true(stringdist::ain(result2$transcript$transcript[[1]],
                              "a Dream Within A Dream Edgar Allan Poe",
                              maxDist = 10))


})

context("Integration tests - Translation")


test_that("Listing translations works", {
  skip_on_cran()
  skip_if_not(local_auth)

  gl_list <- gl_translate_languages()

  expect_s3_class(gl_list, "data.frame")
  expect_gt(nrow(gl_list), 100)
  expect_equal(names(gl_list), c("language","name"))

  gl_list_dansk <- gl_translate_languages("da")

  expect_true("Arabisk" %in% gl_list_dansk$name)

})

test_that("Translation detection works", {
  skip_on_cran()
  skip_if_not(local_auth)

  danish <- gl_translate_detect(trans_text)

  expect_s3_class(danish, "data.frame")
  expect_equal(danish$language, "da")
  expect_true(all(names(danish) %in% c("confidence","isReliable","language","text")))

  two_lang <- gl_translate_detect(c(trans_text, "The owl and the pussycat went to sea"))

  expect_equal(nrow(two_lang), 2)
  expect_equal(two_lang$language, c("da","en"))

})

test_that("Translation works", {
  skip_on_cran()
  skip_if_not(local_auth)

  danish <- gl_translate(trans_text)
  expected <- "There are people who are soberly and shamefully opposed to the ideas of others, who make it clear that they should be charged with unlawful interference with the former."

  expect_true(stringdist::ain(danish$translatedText, expected, maxDist = 10))

  trans_result <- gl_translate(html_result, format = "html")

  expect_true(grepl("There are a few words spoken to Apple", trans_result$translatedText))

  # expect_equal(sum(nchar(lots)), 115745L)
  #
  # big_r <- gl_translate(lots)
  #
  # expect_equal(nrow(big_r), 35)

})

