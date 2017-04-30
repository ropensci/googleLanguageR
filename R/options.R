.onLoad <- function(libname, pkgname) {

  op <- options()
  op.googleLanguageR <- list(
    googleLanguageR.rate_limit = 0.5,
    googleLanguageR.character_limit = 100000L
  )

  toset <- !(names(op.googleLanguageR) %in% names(op))

  if(any(toset)) options(op.googleLanguageR[toset])

  invisible()

}

