#' Translate document
#'
#' Translate a document via the Google Translate API
#'

#'
#' @param d_path path of the document to be translated
#' @param output_path where to save the translated document
#' @param format currently only pdf-files are supported
#'
#' @return invisible() on success
#' @family translations
#' @import assertthat
#' @importFrom base64enc base64encode
#' @importFrom base64enc base64decode
#' @importFrom utils URLencode
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble as_tibble
#' @importFrom stats setNames
#' @export
gl_translate_document <- function(d_path,
                                  target = "es-ES",
                                  output_path = "out.pdf",
                                  format = c("pdf"),
                                  source = 'en-UK',
                                  model = c("nmt", "base"),

                                  location = "global"){

  ## Checks
  assert_that(is.character(d_path),
              is.character(output_path),
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


  call_api <- gar_api_generator(my_URI, "POST" )

  me <- tryCatch(call_api(the_body = payload), error=function(e){print(e)})

    writeBin(
      base64decode(
        me$content$documentTranslation[[1]]
      ), output_path)

}

