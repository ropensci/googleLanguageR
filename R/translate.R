.word_rate <- new.env(parent = globalenv())
.word_rate$characters <- 0
.word_rate$timestamp <- Sys.time()

#' List languages from Google Translate API
#'
#' Returns a list of supported languages for translation.
#'
#' @param target If specified, language names are localized in target langauge
#'
#' @details
#' Supported language codes, generally consisting of its ISO 639-1 identifier. (E.g. \code{'en', 'ja'}).
#' In certain cases, BCP-47 codes including language + region identifiers are returned (e.g. \code{'zh-TW', 'zh-CH'})
#'
#' @return data.frame of supported languages
#' @seealso \url{https://cloud.google.com/translate/docs/reference/languages}
#'
#' @export
#' @family translations
gl_translate_list <- function(target = 'en'){

  assertthat::assert_that(assertthat::is.string(target))

  call_url <- sprintf("https://translation.googleapis.com/language/translate/v2/languages")

  f <- googleAuthR::gar_api_generator(call_url,
                                      "GET",
                                      pars_args = list(target = target),
                                      data_parse_function = function(x) x$data$languages)

  f()

}

#' Detect the language of text within a request
#'
#' @param string A character vector of text to detect language for
#' @param encode If TRUE, will run strings through URL encoding
#'
#' @details
#'   Consider using \code{library(cld2)} and \code{cld2::detect_language} instead offline,
#' since that is free and local without needing a paid API call.
#'
#' \link{gl_translate_language} also returns a detection of the language,
#' so you could also wish to do it in one step via that function.
#'
#' @return A list of the detected languages
#' @seealso \url{https://cloud.google.com/translate/docs/reference/detect}
#' @export
#' @family translations
#' @examples
#'
#' \dontrun{
#' ## which language is this?
#' gl_translate_detect("katten sad på måtten")
#' # confidence isReliable language
#' #1  0.1863063      FALSE       sv
#'
#' gl_translate_detect("katten sidder på måtten")
#' # Detecting language: 39 characters - katten sidder på måtten...
#' # [[1]]
#' # isReliable language confidence
#' # 1      FALSE       da   0.536223
#'
#'
#' }
#'
gl_translate_detect <- function(string, encode = TRUE){

  assertthat::assert_that(is.character(string),
                          is.logical(encode))

  if(encode){
    raw <- string
    string <- vapply(string,
                     utils::URLencode,
                     FUN.VALUE = character(1),
                     reserved = TRUE,
                     repeated = TRUE,
                     USE.NAMES = FALSE)
  }

  char_num <- sum(nchar(string))

  message("Detecting language: ",char_num,
          " characters - ", substring(raw, 0, 50), "...")

  ## rate limits - 1000 requests per 100 seconds
  Sys.sleep(getOption("googleLanguageR.rate_limit"))

  ## character limits - 100000 characters per 100 seconds
  check_rate(sum(nchar(string)))

  call_url <- paste0("https://translation.googleapis.com/language/translate/v2/detect?",
                     paste0("q=", string, collapse = "&"))

  if(nchar(call_url) > 2000){
    stop("Total URL must be less than 2000 characters")
  }

  f <- googleAuthR::gar_api_generator(call_url,
                                      "POST",
                                      data_parse_function = function(x) x$data$detections)

  f()

}

#' Translate the language of text within a request
#'
#' Translate character vectors via the Google Translate API
#'
#' @param t_string A character vector of text to detect language for
#' @param encode If TRUE, will run strings through URL encoding
#' @param target The target language
#' @param format Whether the text is plain or HTML
#' @param source Specify the language to translate from. Will detect it if left default
#' @param model What translation model to use
#'
#' @details
#'
#' You can translate a vector of strings, but each call must be under 2000 characters.
#' If more than 2000 characters, split it up into seperate calls.
#'
#' The API limits in three ways: characters per day, characters per 100 seconds, and API requests per 100 seconds. All can be set in the API manager \code{https://console.developers.google.com/apis/api/translate.googleapis.com/quotas}
#'
#' The function will limit the API calls for for the characters and API requests per 100 seconds, which you can set via the options \code{googleLanguageR.rate_limit} and \code{googleLanguageR.character_limit}.  By default these are set at \code{0.5} requests per second, and \code{100000} characters per 100 seconds.
#'
#'
#'
#' @return A list of the translations
#' @seealso \url{https://cloud.google.com/translate/docs/reference/translate}
#'
#' @examples
#'
#' \dontrun{
#'
#' text <- "to administer medicince to animals is frequently a very difficult matter,
#'   and yet sometimes it's necessary to do so"
#'
#' gl_translate_language(text, target = "ja")
#'
#'
#' }
#'
#' @export
#' @family translations
gl_translate_language <- function(t_string,
                                  encode = TRUE,
                                  target = "en",
                                  format = c("text","html"),
                                  source = '',
                                  model = c("nmt", "base")){

  assertthat::assert_that(is.character(t_string),
                          is.logical(encode),
                          is.character(target),
                          is.unit(target),
                          is.character(source),
                          is.unit(source))

  format <- match.arg(format)
  model <- match.arg(model)
  raw <- t_string

  if(encode){

    t_string <- vapply(t_string,
                     utils::URLencode,
                     FUN.VALUE = character(1),
                     reserved = TRUE,
                     repeated = TRUE,
                     USE.NAMES = FALSE)
  }

  char_num <- sum(nchar(t_string))

  if(char_num > 1500){
    warning("Too many characters to send to API, only sending first 1500.  Got ", char_num)
    t_string <- substring(t_string, 0, 1500)
    char_num <- 1500
  }

  myMessage("Translating: ",char_num," characters - ", substring(raw, 0, 50), "...", level = 3)

  if(!is.unit(t_string)){
    myMessage("Translating vector of strings > 1: ", length(t_string), level = 2)
  }

  ## rate limits - 1000 requests per 100 seconds
  Sys.sleep(getOption("googleLanguageR.rate_limit"))

  ## character limits - 100000 characters per 100 seconds
  check_rate(char_num)

  call_url <- paste0("https://translation.googleapis.com/language/translate/v2")

  f <- googleAuthR::gar_api_generator(call_url,
                                      "POST",
                                      pars_args = list(target = target,
                                                       format = format,
                                                       source = source,
                                                       q = paste0(t_string, collapse = "&q=")),
                                      data_parse_function = function(x) x$data$translations)

  f()

}


# Limit the API to the limits imposed by Google
check_rate <- function(word_count,
                       timestamp = Sys.time(),
                       character_limit = getOption("googleLanguageR.character_limit")){

  ## window of character limit in seconds (e.g. 100000 per 100 seconds)
  delay_limit <- 100L

  assertthat::assert_that(is.numeric(word_count),
                          is.unit(word_count),
                          is.numeric(character_limit),
                          is.numeric(delay_limit),
                          assertthat::is.time(timestamp))

  if(.word_rate$characters > 0){
    myMessage("# Current character batch: ", .word_rate$characters, level = 2)
  }

  .word_rate$characters <- .word_rate$characters + word_count
  if(.word_rate$characters > character_limit){
    myMessage("Limiting API as over ", character_limit," characters in ", delay_limit, " seconds",
              level = 3)
    myMessage("Timestamp batch start: ", .word_rate$timestamp,
              level = 2)

    delay <- difftime(timestamp, .word_rate$timestamp, units = "secs")

    while(delay < delay_limit){
      myMessage("Waiting for ", format(round(delay_limit - delay), format = "%S"),
                level = 3)
      delay <- difftime(Sys.time(), .word_rate$timestamp, units = "secs")
      Sys.sleep(5)
    }

    myMessage("Ready to call API again", level = 2)
    .word_rate$characters <- 0
    .word_rate$timestamp <- Sys.time()

  }
}


