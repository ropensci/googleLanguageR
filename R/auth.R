#' Auth with Google Translate API
#'
#' @param json_file File you have downloaded from your Google Project
#'
#' @export
gl_auth <- function(json_file){

  options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/cloud-platform")
  googleAuthR::gar_auth_service(json_file = json_file)
}
