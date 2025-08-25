#' Translate a document via the Google Translate API
#'
#' @param d_path Path to the document to be translated
#' @param target Target language code (default "es-ES")
#' @param output_path Path where to save the translated document (default "out.pdf")
#' @param format Document format. Currently, only "pdf" is supported
#' @param source Source language code (default "en-UK")
#' @param model Translation model to use ("nmt" or "base")
#' @param location Location for translation API (default "global")
#'
#' @return The full path of the translated document
#' @family translations
#' @export
#'
#' @examples
#' \dontrun{
#' gl_translate_document(
#'   system.file(package = "googleLanguageR", "test-doc.pdf"),
#'   target = "no"
#' )
#' }
#'
#' @import assertthat
#' @importFrom base64enc base64encode base64decode
#' @importFrom utils URLencode
#' @importFrom googleAuthR gar_api_generator gar_token
gl_translate_document <- function(d_path,
                                  target = "es-ES",
                                  output_path = "out.pdf",
                                  format = c("pdf"),
                                  source = 'en-UK',
                                  model = c("nmt", "base"),
                                  location = "global"){

  ## Argument checks
  assert_that(is.character(d_path),
              is.character(output_path),
              is.string(target),
              is.string(source))

  format <- match.arg(format)
  model  <- match.arg(model)

  mime_type <- paste0("application/", format)

  if(file.exists(output_path)) stop("Output file already exists.")

  payload <- list(
    target_language_code = target,
    source_language_code = source,
    document_input_config = list(
      mimeType = mime_type,
      content = base64encode(d_path)
    )
  )

  # get project ID from token
  project_id <- gar_token()$auth_token$secrets$project_id

  my_URI <- paste0(
    "https://translation.googleapis.com/v3beta1/projects/",
    project_id,
    "/locations/",
    location,
    ":translateDocument"
  )

  call_api <- gar_api_generator(my_URI, "POST")

  me <- tryCatch(
    call_api(the_body = payload),
    error = function(e){
      stop("Translation API error: ", e$message, call. = FALSE)
    }
  )

  # write translated document
  writeBin(
    base64decode(me$content$documentTranslation[[1]]),
    output_path
  )

  path.expand(output_path)
}
