#' Authenticate with Google Language API services
#'
#' @param json_file Character. Path to the JSON authentication file downloaded from your Google Cloud project.
#' @details
#' This function authenticates with Google Cloud's language APIs. By default, it uses the JSON file specified
#' in \code{json_file}. Alternatively, you can set the file path in the environment variable \code{GL_AUTH} to
#' auto-authenticate when loading the package.
#' @examples
#' \dontrun{
#' library(googleLanguageR)
#' gl_auth("path/to/json_file.json")
#' }
#' @export
#' @importFrom googleAuthR gar_auth_service gar_attach_auto_auth
gl_auth <- function(json_file) {
  options(googleAuthR.scopes.selected = c(
    "https://www.googleapis.com/auth/cloud-language",
    "https://www.googleapis.com/auth/cloud-platform"
  ))
  googleAuthR::gar_auth_service(json_file = json_file)
}

#' @rdname gl_auth
#' @param ... Additional arguments passed to \code{gar_attach_auto_auth}.
#' @examples
#' \dontrun{
#' library(googleLanguageR)
#' gl_auto_auth()
#' gl_auto_auth(environment_var = "GAR_AUTH_FILE")
#' }
#' @export
gl_auto_auth <- function(...) {
  required_scopes <- c(
    "https://www.googleapis.com/auth/cloud-language",
    "https://www.googleapis.com/auth/cloud-platform"
  )
  googleAuthR::gar_attach_auto_auth(
    required_scopes = required_scopes,
    ...
  )
}
