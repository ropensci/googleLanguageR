.onLoad <- function(libname, pkgname) {

  op <- options()
  op.googleLanguageR <- list(
    googleLanguageR.rate_limit = 0.5,
    googleLanguageR.character_limit = 100000L,
    googleAuthR.scopes.selected = "https://www.googleapis.com/auth/cloud-platform"
  )

  toset <- !(names(op.googleLanguageR) %in% names(op))

  if(any(toset)) options(op.googleLanguageR[toset])

  invisible()

}

.onAttach <- function(libname, pkgname){

  needed <- "https://www.googleapis.com/auth/cloud-platform"

  googleAuthR::gar_attach_auto_auth(needed,
                                    environment_var = "GL_AUTH",
                                    travis_environment_var = "TRAVIS_GL_AUTH")

  invisible()

}



