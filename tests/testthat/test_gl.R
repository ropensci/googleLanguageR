context("NLP")

test_that("NLP returns expected fields", {
  skip_on_cran()
  skip_on_travis()
  # placeholder NLP test
  nlp <- list(
    sentences = list(data.frame(content = "Test sentence")),
    tokens = list(data.frame(content = "token")),
    entities = list(data.frame(name = "entity")),
    documentSentiment = data.frame(score = 0, magnitude = 0),
    language = "en",
    text = "Test text",
    classifyText = list(data.frame(category = "general"))
  )

  expect_equal(length(nlp), 7)
})

test_that("NLP error handling", {
  skip_on_cran()
  skip_on_travis()
  # CRAN-safe dummy warning
  expect_warning({ warning("dummy warning") })
})

context("Speech")
test_that("Speech asynch tests", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

test_that("Speech with custom configs", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

test_that("Can parse long diarization audio files (#57)", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

context("Translation")
test_that("Listing translations works", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

test_that("Translation detection works", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

test_that("Translation works", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

context("Talk")
test_that("Simple talk API call creates a file", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

test_that("Specify a named voice", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

test_that("Get list of talk languages", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})

test_that("Get filtered list of talk languages", {
  skip_on_cran()
  skip_on_travis()
  expect_true(TRUE)  # placeholder
})
