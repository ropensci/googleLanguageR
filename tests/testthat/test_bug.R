library(googleLanguageR)
# auto auth

library(httptest)

test_text <- "Translate this"

capture_requests(
  gl_translate(test_text), path = ".", verbose = TRUE
)

with_mock_api(gl_translate(test_text))

sessionInfo()

dir.exists("translation.googleapis.com")
