source("prep_tests.R")

context("NLP")

test_that("NLP returns expected fields", {
  skip_on_cran()
  skip_on_travis()
  nlp <- gl_nlp(test_text)

  expect_equal(length(nlp), 7)
  expect_true(all(names(nlp) %in%
                    c("sentences","tokens","entities",
                      "documentSentiment","language", "text", "classifyText")))
  expect_s3_class(nlp$sentences[[1]], "data.frame")
  expect_equal(nlp$sentences[[1]]$content[[1]],
               "Norma is a small constellation in the Southern Celestial Hemisphere between Ara and Lupus, one of twelve drawn up in the 18th century by French astronomer Nicolas Louis de Lacaille and one of several depicting scientific instruments.")
  expect_true(all(names(nlp$sentences[[1]]) %in% c("content","beginOffset","magnitude","score")))
  expect_true(all(names(nlp$tokens[[1]]) %in% c("content", "beginOffset", "tag", "aspect", "case",
                                                "form", "gender", "mood", "number", "person", "proper",
                                                "reciprocity", "tense", "voice", "headTokenIndex",
                                                "label", "value")))
  expect_true(all(names(nlp$entities[[1]]) %in%
                    c("name","type","salience","mid","wikipedia_url", "value",
                      "beginOffset","magnitude", "score", "mention_type")))
  expect_true(all(names(nlp$documentSentiment) %in% c("magnitude","score")))
  expect_equal(nlp$language, "en")
  expect_s3_class(nlp$tokens[[1]], "data.frame")
  expect_s3_class(nlp$entities[[1]], "data.frame")
  expect_s3_class(nlp$documentSentiment, "data.frame")
  expect_s3_class(nlp$classifyText[[1]], "data.frame")


  nlp2 <- gl_nlp(c(test_text, test_text2))
  expect_equal(length(nlp2), 7)
  expect_true(all(names(nlp2) %in%
                    c("sentences","tokens","entities",
                      "text","documentSentiment","language", "classifyText")))
  expect_equal(length(nlp2$sentences), 2)

})

test_that("NLP error handling", {
  skip_on_cran()
  skip_on_travis()
  testthat::expect_warning(gl_nlp(c("the rain in spain falls mainly on the plain", "err", "", NA)))

})


context("Speech")

# TODO: why does this hang?
# test_that("Speech recognise expected", {
#   skip_on_cran()
#   skip_on_travis()
#   test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")
#   result <- gl_speech(test_audio)
#
#   test_result <- "to administer medicine to animals Is frequent give very difficult matter and yet sometimes it's necessary to do so"
#
#   expect_true(inherits(result, "list"))
#   expect_true(all(names(result$transcript) %in% c("transcript","confidence","languageCode","channelTag")))
#   expect_true(all(names(result$timings[[1]]) %in% c("startTime","endTime","word")))
#   ## the API call varies a bit, so it passes if within 10 characters of expected transscript
#   expect_true(stringdist::ain(result$transcript$transcript, test_result, maxDist = 10))
#
# })

test_that("Speech asynch tests", {
  skip_on_cran()
  skip_on_travis()
  test_gcs <- "gs://mark-edmondson-public-files/googleLanguageR/a-dream-mono.wav"

  async <- gl_speech(test_gcs, asynch = TRUE, sampleRateHertz = 44100)
  expect_true(inherits(async, "gl_speech_op"))

  Sys.sleep(45)

  result2 <- gl_speech_op(async)
  expect_true(stringdist::ain(result2$transcript$transcript[[1]],
                              "a Dream Within A Dream Edgar Allan Poe",
                              maxDist = 10))


})

test_that("Speech with custom configs", {
  skip_on_cran()
  skip_on_travis()
  ## Use a custom configuration
  my_config1 <- list(encoding = "LINEAR16",
                    diarizationConfig = list(
                      enableSpeakerDiarization = TRUE,
                      minSpeakerCount = 2,
                      maxSpeakerCount = 3
                    ))

  t1 <- gl_speech(speaker_d_test,
                  languageCode = "en-US",
                  customConfig = my_config1,
                  asynch = TRUE)

  # languageCode is required, so will be added if not in your custom config
  t2 <- gl_speech(test_gcs, languageCode = "en-US",
                  customConfig = list(enableAutomaticPunctuation = TRUE), asynch = TRUE)

  Sys.sleep(45)

  result3 <- gl_speech_op(t1)

  expect_true(all(names(result3) %in% c("transcript","timings")))

  expect_s3_class(result3$transcript, "data.frame")
  expect_true(all(names(result3$transcript) %in%
                    c("transcript","confidence","languageCode","channelTag")))
  expect_true(all(names(result3$timings[[1]]) %in%
                    c("startTime","endTime","word")))
  expect_true(all(names(result3$timings[[2]]) %in%
                    c("startTime","endTime","word","speakerTag")))



  result2 <- gl_speech_op(t2)

  # do we have a full stop or comma included?
  expect_true(any(grepl("\\.|\\,", result2$transcript$transcript)))

})

test_that("Can parse long diarization audio files (#57)",{
  skip_on_travis()
  skip_on_cran()

  my_config <- list(encoding = "LINEAR16",
                    diarizationConfig = list(
                      enableSpeakerDiarization = TRUE,
                      minSpeakerCount = 2,
                      maxSpeakerCount = 3
                    ))

  testcall <- "gs://mark-edmondson-public-read/testcall.wav"

  apicall<- gl_speech(testcall,
                      sampleRateHertz = 8000,
                      languageCode = "de-DE",
                      asynch = TRUE,
                      customConfig = my_config)

  testcall_transcript <- gl_speech_op(apicall)
  if(inherits(testcall_transcript, "gl_speech_op")){
    Sys.sleep(30)
    testcall_transcript <- gl_speech_op(testcall_transcript)
  }

  expect_true(!is.null(
    testcall_transcript$timings[[length(testcall_transcript$timings)]]$speakerTag)
    )

})

context("Translation")


test_that("Listing translations works", {
  skip_on_cran()
  skip_on_travis()
  gl_list <- gl_translate_languages()

  expect_s3_class(gl_list, "data.frame")
  expect_gt(nrow(gl_list), 100)
  expect_equal(names(gl_list), c("language","name"))

  gl_list_dansk <- gl_translate_languages("da")

  expect_true("Arabisk" %in% gl_list_dansk$name)

})

test_that("Translation detection works", {
  skip_on_travis()
  skip_on_cran()

  danish <- gl_translate_detect(trans_text)

  expect_s3_class(danish, "data.frame")
  expect_equal(danish$language, "da")
  expect_true(all(names(danish) %in% c("confidence","isReliable","language","text")))

  two_lang <- gl_translate_detect(c(trans_text, "The owl and the pussycat went to sea"))

  expect_equal(nrow(two_lang), 2)
  expect_equal(two_lang$language, c("da","en"))

})

test_that("Translation works", {
  skip_on_travis()
  skip_on_cran()

  danish <- gl_translate(trans_text)
  expected <- "There are people who, to the extent of being frivolous and disgraceful with other people's ideas, are given the idea that they should be prosecuted for unlawful dealings with lost property."

  expect_true(!is.null(danish$translatedText))


})

context("Talk")

test_that("Simple talk API call creates a file", {
  skip_on_travis()
  skip_on_cran()

  unlink("test.wav")
  filename <- gl_talk("Test talk sentence", output  = "test.wav", languageCode = "en",  gender = "FEMALE")

  expect_equal(filename, "test.wav")
  expect_true(file.exists("test.wav"))
  expect_gt(file.info("test.wav")$size, 50000)

  on.exit(unlink("test.wav"))

})

test_that("Specify a named voice", {
  skip_on_travis()
  skip_on_cran()

  unlink("test2.wav")
  filename <- gl_talk("Hasta la vista", name = "es-ES-Standard-A", output = "test2.wav")

  expect_equal(filename, "test2.wav")
  expect_true(file.exists("test2.wav"))
  expect_gt(file.info("test2.wav")$size, 50000)

  on.exit(unlink("test2.wav"))

})

test_that("Get list of talk languages", {
  skip_on_travis()
  skip_on_cran()

  lang <- gl_talk_languages()

  expect_s3_class(lang, "data.frame")
  expect_gt(nrow(lang), 30)
  expect_true(all(names(lang) %in%
                    c("languageCodes","name","ssmlGender","naturalSampleRateHertz")),
              info = "expect names in data.frame")


})

test_that("Get filtered list of talk languages", {
  skip_on_travis()
  skip_on_cran()

  lang <- gl_talk_languages(languageCode = "en")

  expect_s3_class(lang, "data.frame")
  expect_true(all(names(lang) %in%
                    c("languageCodes","name","ssmlGender","naturalSampleRateHertz")),
              info = "expect names in data.frame")
  expect_true(all(grepl("^en-", lang$languageCodes)),
              info = "Only languageCodes beginning with en")

})

