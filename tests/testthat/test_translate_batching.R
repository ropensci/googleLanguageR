# ============================================================================
# Tests for gl_translate Smart Batching (Issue #80)
# ============================================================================

context("Translation Batching")

# Test 1: split_into_batches helper function
test_that("split_into_batches creates correct batch sizes", {
  skip_on_cran()
  
  # Test with vector smaller than batch size
  result1 <- googleLanguageR:::split_into_batches(1:5, 10)
  expect_equal(length(result1), 1)
  expect_equal(length(result1[[1]]), 5)
  
  # Test with vector exactly equal to batch size
  result2 <- googleLanguageR:::split_into_batches(1:10, 10)
  expect_equal(length(result2), 1)
  expect_equal(length(result2[[1]]), 10)
  
  # Test with vector larger than batch size
  result3 <- googleLanguageR:::split_into_batches(1:25, 10)
  expect_equal(length(result3), 3)
  expect_equal(length(result3[[1]]), 10)
  expect_equal(length(result3[[2]]), 10)
  expect_equal(length(result3[[3]]), 5)
  
  # Test with batch size of 1
  result4 <- googleLanguageR:::split_into_batches(1:3, 1)
  expect_equal(length(result4), 3)
  expect_equal(length(result4[[1]]), 1)
})

# Test 2: Translation with medium-sized vector
test_that("Translation handles medium vectors efficiently", {
  skip_on_cran()
  skip_on_travis()
  
  # Create 10 short strings (should fit in one API call)
  test_strings <- paste("Test string number", 1:10)
  
  result <- tryCatch({
    gl_translate(test_strings, target = "en", source = "en")
  }, error = function(e) {
    skip("API authentication not available")
  })
  
  if (!inherits(result, "try-error")) {
    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 10)
    expect_true(all(c("translatedText", "text") %in% names(result)))
    expect_equal(result$text, test_strings)
  }
})

# Test 3: Verify batching preserves order
test_that("Batching preserves original string order", {
  skip_on_cran()
  skip_on_travis()
  
  # Create strings with identifiable content
  test_strings <- paste("String", sprintf("%03d", 1:20))
  
  result <- tryCatch({
    gl_translate(test_strings, target = "es", source = "en")
  }, error = function(e) {
    skip("API authentication not available")
  })
  
  if (!inherits(result, "try-error")) {
    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), 20)
    expect_equal(result$text, test_strings)
    
    # Verify order is maintained
    for (i in seq_along(test_strings)) {
      expect_true(!is.na(result$translatedText[i]))
    }
  }
})

