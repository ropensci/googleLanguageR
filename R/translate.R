#' Lists languages from Google Translate API
#'
#' Returns a list of supported languages for translation.
#'
#' @param target A language code for localized language names (default 'en')
#'
#' @details
#' Supported language codes generally consist of their ISO 639-1 identifiers (e.g., \code{'en', 'ja'}).
#' In certain cases, BCP-47 codes including language + region identifiers are returned (e.g., \code{'zh-TW', 'zh-CH'}).
#'
#' @return A tibble of supported languages
#' @seealso \url{https://cloud.google.com/translate/docs/reference/languages}
#'
#' @export
#' @examples
#' \dontrun{
#' gl_translate_languages()
#' gl_translate_languages("da")
#' }
#' @family translations
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble as_tibble
#' @import assertthat
gl_translate_languages <- function(target = 'en'){
  assert_that(is.string(target))

  call_api <- gar_api_generator(
    "https://translation.googleapis.com/language/translate/v2/languages",
    "GET",
    pars_args = list(target = target),
    data_parse_function = function(x) as_tibble(x$data$languages)
  )

  call_api()
}

#' Detect the language of text within a request
#'
#' @param string Character vector of text to detect language for
#'
#' @details
#' Consider using \code{library(cld2)} and \code{cld2::detect_language} instead for offline detection,
#' since that is free and does not require an API call.
#'
#' \link{gl_translate} also returns a detection of the language, so you could optionally use that in one step.
#'
#' @return A tibble of the detected languages with columns \code{confidence}, \code{isReliable}, \code{language}, and \code{text}, of length equal to the vector of text you passed in.
#'
#' @seealso \url{https://cloud.google.com/translate/docs/reference/detect}
#' @export
#' @family translations
#' @examples
#' \dontrun{
#' gl_translate_detect("katten sidder på måtten")
#' }
#' @import assertthat
#' @importFrom utils URLencode
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble as_tibble
#' @importFrom stats setNames
gl_translate_detect <- function(string){
  assert_that(is.character(string))

  char_num <- sum(nchar(string))
  string <- trimws(string)

  my_message("Detecting language: ", char_num, " characters", level = 3)

  pars <- setNames(as.list(string), rep("q", length(string)))

  call_api <- gar_api_generator(
    "https://translation.googleapis.com/language/translate/v2/detect",
    "POST",
    customConfig = list(encode = "form"),
    data_parse_function = function(x) Reduce(rbind, x$data$detections)
  )

  catch_errors <- "Too many text segments|Request payload size exceeds the limit|Text too long"

  me <- tryCatch(
    call_api(the_body = pars),
    error = function(ex){
      if (grepl(catch_errors, ex$message)) {
        my_message("Attempting to split into several API calls", level = 3)
        Reduce(rbind, lapply(string, gl_translate_detect))
      } else if (grepl("User Rate Limit Exceeded", ex$message)) {
        my_message("Characters per 100 seconds rate limit reached, waiting 10 seconds...", level = 3)
        Sys.sleep(10)
        gl_translate_detect(string)
      } else {
        stop(ex$message, call. = FALSE)
      }
    }
  )

  if(length(string) == nrow(me)){
    me$text <- string
  }

  as_tibble(me)
}

#' Split vector into batches
#'
#' @param x Vector to split
#' @param batch_size Size of each batch
#' @return List of batches
#' @noRd
split_into_batches <- function(x, batch_size) {
  n <- length(x)
  if (n <= batch_size) {
    return(list(x))
  }

  num_batches <- ceiling(n / batch_size)
  batches <- vector("list", num_batches)

  for (i in seq_len(num_batches)) {
    start_idx <- (i - 1) * batch_size + 1
    end_idx <- min(i * batch_size, n)
    batches[[i]] <- x[start_idx:end_idx]
  }

  batches
}

#' Translate with smart batching
#'
#' @param t_string Character vector of text to translate
#' @param target The target language code
#' @param format Whether the text is plain text or HTML
#' @param source Specify the language to translate from
#' @param model Translation model to use
#' @param batch_size Initial batch size (will be halved on errors)
#' @noRd
translate_with_batching <- function(t_string, target, format, source, model, batch_size = NULL) {
  # If batch_size not specified, try to estimate based on total character count
  if (is.null(batch_size)) {
    total_chars <- sum(nchar(t_string))
    # Google Translate API limit is around 30k characters per request
    # Start with a conservative batch size
    if (total_chars > 25000) {
      batch_size <- max(1, floor(length(t_string) * 25000 / total_chars))
    } else {
      batch_size <- length(t_string)
    }
  }

  # Ensure batch_size is at least 1
  batch_size <- max(1, batch_size)

  my_message("Attempting translation with batch size: ", batch_size, level = 3)

  pars <- list(target = target, format = format, source = source, model = model)
  pars <- c(pars, setNames(as.list(t_string), rep("q", length(t_string))))

  call_api <- gar_api_generator(
    "https://translation.googleapis.com/language/translate/v2",
    "POST",
    customConfig = list(encode = "form"),
    data_parse_function = function(x) x$data$translations
  )

  catch_errors <- "Too many text segments|Request payload size exceeds the limit|Text too long"

  me <- tryCatch(
    call_api(the_body = pars),
    error = function(ex){
      if(grepl(catch_errors, ex$message)){
        my_message(ex$message, level = 3)

        # If we're already at batch_size of 1, can't split further
        if (batch_size == 1 && length(t_string) == 1) {
          stop("Single string too large to translate: ", nchar(t_string), " characters", call. = FALSE)
        }

        # Split into smaller batches (halve the batch size)
        new_batch_size <- max(1, floor(batch_size / 2))
        batches <- split_into_batches(t_string, new_batch_size)

        my_message("Splitting into ", length(batches), " batches of ~", new_batch_size, " strings each", level = 3)

        # Process each batch
        results <- lapply(batches, function(batch) {
          translate_with_batching(batch, target, format, source, model, new_batch_size)
        })

        Reduce(rbind, results)

      } else if(grepl("User Rate Limit Exceeded", ex$message)){
        my_message("Characters per 100 seconds rate limit reached, waiting 10 seconds...", level = 3)
        Sys.sleep(10)
        translate_with_batching(t_string, target, format, source, model, batch_size)
      } else {
        stop(ex$message, call. = FALSE)
      }
    }
  )

  if(length(t_string) == nrow(me)){
    me$text <- t_string
  }

  as_tibble(me)
}

#' Translate the language of text within a request
#'
#' Translate character vectors via the Google Translate API.
#'
#' @param t_string Character vector of text to translate
#' @param target The target language code
#' @param format Whether the text is plain text or HTML
#' @param source Specify the language to translate from. Will detect it if left default
#' @param model Translation model to use
#'
#' @details
#' You can translate a vector of strings; if too many for one call, it will be
#' broken up into multiple API calls with smart batching.
#' The API charges per character translated, so splitting does not change cost but may take longer.
#'
#' If translating HTML, set \code{format = "html"}.
#' Consider removing anything not needed to be translated first, such as JavaScript or CSS.
#'
#' API limits: characters per day, characters per 100 seconds, and API requests per 100 seconds.
#' These can be configured in the API manager: \url{https://console.developers.google.com/apis/api/translate.googleapis.com/quotas}
#'
#' @return A tibble of \code{translatedText}, \code{detectedSourceLanguage}, and \code{text} of length equal to the vector of text you passed in
#'
#' @seealso \url{https://cloud.google.com/translate/docs/reference/translate}
#' @export
#' @family translations
#' @import assertthat
#' @importFrom utils URLencode
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble as_tibble
#' @importFrom stats setNames
gl_translate <- function(t_string,
                         target = "en",
                         format = c("text","html"),
                         source = '',
                         model = c("nmt", "base")){
  assert_that(is.character(t_string),
              is.string(target),
              is.string(source))

  format <- match.arg(format)
  model  <- match.arg(model)

  t_string <- trimws(t_string)
  t_string <- check_if_html(t_string, format)
  char_num <- sum(nchar(t_string))
  my_message("Translating ", format, ": ", char_num, " characters - ", level = 3)

  if(!is.string(t_string)){
    my_message("Translating vector of strings > 1: ", length(t_string), level = 2)
  }

  # Use the new batching function
  translate_with_batching(t_string, target, format, source, model)
}

# helper function
#' @noRd
check_if_html <- function(string, format){
  html_test <- any(grepl("<.+>", string))
  if(all(html_test, format != "html")){
    warning("Possible HTML found in input text, but format != 'html'")
  }
  string
}
