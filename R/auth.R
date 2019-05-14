#' Authenticate with Google language API services
#'
#' @param json_file Authentication json file you have downloaded from your Google Project
#'
#' @details
#'
#' The best way to authenticate is to use an environment argument pointing at your authentication file.
#'
#' Set the file location of your download Google Project JSON file in a \code{GL_AUTH} argument
#'
#' Then, when you load the library you should auto-authenticate
#'
#' However, you can authenticate directly using this function pointing at your JSON auth file.
#'
#' @examples
#'
#' \dontrun{
#' library(googleLanguageR)
#' gl_auth("location_of_json_file.json")
#' }
#'
#' @export
#' @importFrom googleAuthR gar_auth_service gar_attach_auto_auth
gl_auth <- function(json_file){
  options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/cloud-language",
                                          "https://www.googleapis.com/auth/cloud-platform"))
  googleAuthR::gar_auth_service(json_file = json_file)
}

#' @export
#' @rdname gl_auth
#' @param ... additional argument to
#' pass to \code{\link{gar_attach_auto_auth}}.
#'
#' @examples
#' \dontrun{
#' library(googleLanguageR)
#' gl_auto_auth()
#' gl_auto_auth(environment_var = "GAR_AUTH_FILE")
#' }
gl_auto_auth <- function(...){
  required_scopes = c("https://www.googleapis.com/auth/cloud-language",
                      "https://www.googleapis.com/auth/cloud-platform")
  googleAuthR::gar_attach_auto_auth(
    required_scopes = required_scopes,
    ...)
}
