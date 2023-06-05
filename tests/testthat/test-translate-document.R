source("prep_tests.R")
test_that("document tranlation works", {
  skip_on_cran()
  skip_on_travis()

  my_out <- tempfile(fileext = ".pdf")

  gl_translate_document(system.file(package = "googleLanguageR","test-doc.pdf"), target = "no",output_path = my_out)

  my_file1 <- readBin(my_out, "raw")
  my_file2 <- readBin(system.file(package = "googleLanguageR","test-doc.pdf"), "raw")
  expect_equal(my_file1, my_file2)
})
