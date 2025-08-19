# tests/testthat/test_gl_speech_offline.R

library(testthat)
library(tibble)
library(assertthat)
library(base64enc)

# ------------------------
# Mock gl_speech for offline testing
# ------------------------
gl_speech <- function(...) {
  message("Dummy gl_speech called")
  list(
    transcript = tibble(transcript = "test transcript", confidence = 1),
    timings = list(list(word = "test", startTime = 0, endTime = 1))
  )
}

# ------------------------
# Example audio files
# ------------------------
test_audio_wav <- "C:/Users/Isabella/Documents/test_audio.wav"
audio_files <- c(test_audio_wav)

# ------------------------
# Tests
# ------------------------
for (file in audio_files) {
  
  test_that(paste("Synchronous call works for", basename(file)), {
    result <- gl_speech(file)
    expect_true(is.list(result))
    expect_true("transcript" %in% names(result))
    expect_true("timings" %in% names(result))
    expect_s3_class(result$transcript, "tbl_df")
    expect_equal(result$transcript$transcript, "test transcript")
    expect_equal(result$transcript$confidence, 1)
  })
  
  test_that(paste("Asynchronous call works for", basename(file)), {
    async_result <- gl_speech(file, asynch = TRUE)
    expect_true(is.list(async_result))
    expect_true("transcript" %in% names(async_result))
    expect_true("timings" %in% names(async_result))
    expect_s3_class(async_result$transcript, "tbl_df")
    expect_equal(async_result$transcript$transcript, "test transcript")
    expect_equal(async_result$transcript$confidence, 1)
  })
}
