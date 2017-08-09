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
#' @importFrom googleAuthR gar_auth_service
gl_auth <- function(json_file){
  options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/cloud-platform")
  gar_auth_service(json_file = json_file)
}
