context("Auth")

## to run tests, you currently need to add the file location of your
## Google project service JSON file to an environemnt variable GL_AUTH
test_that("Local auth working", {

  gl_auth(Sys.getenv("GL_AUTH"))

})

context("NLP")

test_that("NLP returns expected fields", {
  skip_on_cran()

  test_text <- "The cat sat on the mat"
  nlp <- gl_nlp(test_text)

  expect_equal(nlp$sentences$text$content, test_text)

})

context("Speech")

test_that("Speech recognise expected", {
  skip_on_cran()
  ## get the sample source file
  test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")

  result <- gl_speech_recognise(test_audio)

  test_result <- "to administer medicine to animals Is frequent very difficult matter and yet sometimes it's necessary to do so"

  expect_equal(result$transcript, test_result)

})

context("Translation")

test_that("Translation works", {
  skip_on_cran()
  text <- "to administer medicince to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so"

  japan <- gl_translate_language(text, target = "ja")

  test_result <- "動物に医薬品を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"

  expect_equal(japan$translatedText, test_result)

})

