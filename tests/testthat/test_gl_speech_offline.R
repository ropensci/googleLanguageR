# tests/testthat/test_gl_speech_offline.R
context("Offline Speech API")

library(testthat)
library(tibble)
library(assertthat)

# ------------------------
# Dummy gl_speech function
# ------------------------
gl_speech <- function(...) {
  list(
    transcript = tibble(transcript = "test transcript", confidence = 1),
    timings = list(list(word = "test", startTime = 0, endTime = 1))
  )
}

# ------------------------
# Example "audio files" (dummy placeholders)
# ------------------------
audio_files <- c("dummy1.wav", "dummy2.wav")

# ------------------------
# Tests
# ------------------------
for (file in audio_files) {

  test_that(paste("Synchronous call works for", file), {
    result <- gl_speech(file)
    expect_true(is.list(result))
    expect_true(all(c("transcript","timings") %in% names(result)))
    expect_s3_class(result$transcript, "tbl_df")
    expect_equal(result$transcript$transcript, "test transcript")
    expect_equal(result$transcript$confidence, 1)
  })

  test_that(paste("Asynchronous call works for", file), {
    async_result <- gl_speech(file, asynch = TRUE)
    expect_true(is.list(async_result))
    expect_true(all(c("transcript","timings") %in% names(async_result)))
    expect_s3_class(async_result$transcript, "tbl_df")
    expect_equal(async_result$transcript$transcript, "test transcript")
    expect_equal(async_result$transcript$confidence, 1)
  })

}
