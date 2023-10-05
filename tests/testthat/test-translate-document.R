source("prep_tests.R")
test_that("document tranlation works", {
  skip_on_cran()
  skip_on_travis()

  my_out <- tempfile(fileext = ".pdf")

  gl_translate_document(system.file(package = "googleLanguageR","test-doc.pdf"), target = "no",output_path = my_out)

  my_pdf1 <-pdftools::pdf_data(my_out)

  my_pdf2 <- pdftools::pdf_data(
    system.file(package = "googleLanguageR","test-doc-no.pdf")
    )

  expect_equal(my_pdf1[[1]]$text, my_pdf2[[1]]$text)
})
