#' Authenticate with Google language API services
#'
#' @param json_file Authentication json file you have downloaded from your Google Project
#'
#' @details
#'
#' You may prefer to authenticate automatically upon package load by
#'   assigning a Environment argument \code{GL_AUTH} equal to the file
#'   location of your auth file JSON.
#'
#' @export
#' @importFrom googleAuthR gar_auth_service
gl_auth <- function(json_file){
  options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/cloud-platform")
  gar_auth_service(json_file = json_file)
}
