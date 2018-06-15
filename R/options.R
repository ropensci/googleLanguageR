.onLoad <- function(libname, pkgname) {

  op <- options()
  op.googleLanguageR <- list(
    googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/cloud-language",
                                    "https://www.googleapis.com/auth/cloud-platform")
  )

  toset <- !(names(op.googleLanguageR) %in% names(op))

  if(any(toset)) options(op.googleLanguageR[toset])

  invisible()

}

.onAttach <- function(libname, pkgname){

  needed <- c("https://www.googleapis.com/auth/cloud-language",
              "https://www.googleapis.com/auth/cloud-platform")

  googleAuthR::gar_attach_auto_auth(needed,
                                    environment_var = "GL_AUTH")

  invisible()

}



