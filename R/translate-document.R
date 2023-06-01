#' Translate document
#'
#' Translate a document via the Google Translate API
#'

#'
#' @param d_path path of the document to be translated
#' @param out_path where to save the translated document
#' @param format currently only pdf-files are supported
#'
#' @return invisible() on success
#' @family translations
#' @import assertthat
#' @importFrom utils URLencode
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble as_tibble
#' @importFrom stats setNames
#' @export
gl_translate_document <- function(d_path,
                                  target = "es-ES",
                                  out_path = "out.pdf",
                                  format = c("pdf"),
                                  source = 'en-UK',
                                  model = c("nmt", "base"),

                                  location = "global"){

  ## Checks
  assert_that(is.character(d_path),
              is.character(out_path),
              is.string(target),
              is.string(source))

  format <- match.arg(format)
  model  <- match.arg(model)

  format <- paste0("application/",format)

  payload <-
    list(
      target_language_code = target,
      source_language_code = source,
         document_input_config = list(
           mimeType = format,
           content = base64encode(d_path)
         )
    )


  project_id <- gar_token()$auth_token$secrets$project_id
  LOCATION <- location

  my_URI <- paste0(
    "https://translation.googleapis.com/v3beta1/projects/",
    project_id,
    "/locations/",
    location,":translateDocument")


  call_api <- gar_api_generator(my_URI,
                                "POST"
                                )



  me <- tryCatch(call_api(the_body = payload))
  # me <- tryCatch(call_api(the_body = pars),
  #                error = function(ex){
  #                  if(grepl(catch_errors,
  #                           ex$message)){
  #                    my_message(ex$message, level = 3)
  #                    my_message("Attempting to split into several API calls", level = 3)
  #                    # Reduce(rbind, lapply(t_string, gl_translate,
  #                    #                      format = format,
  #                    #                      target = target,
  #                    #                      source = source,
  #                    #                      model = model))
  #                  } else if(grepl("User Rate Limit Exceeded",
  #                                  ex$message)){
  #                    my_message("Characters per 100 seconds rate limit reached, waiting 10 seconds...",
  #                               level = 3)
  #                    Sys.sleep(10)
  #                    ## try again
  #                    gl_translate(t_string,
  #                                 format = format,
  #                                 target = target,
  #                                 source = source,
  #                                 model = model)
  #                  } else {
  #                    stop(ex$message, call. = FALSE)
  #                  }
  #                })
  #
  me

}

if(interactive()){
  library(googleAuthR)
  gl_auth("_api-keys/google_api_key.json") -> my_test
  library(dplyr)
  library(assertthat)
  gl_translate_document("./notes/test-doc.pdf") %>% print
}

