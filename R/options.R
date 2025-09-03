.onAttach <- function(libname, pkgname){
  needed <- c(
    "https://www.googleapis.com/auth/cloud-language",
    "https://www.googleapis.com/auth/cloud-platform"
  )

  if(Sys.getenv("GL_AUTH") != "") {
    try(
      googleAuthR::gar_attach_auto_auth(needed, environment_var = "GL_AUTH"),
      silent = TRUE
    )
  }

  invisible()
}
