.word_rate <- new.env(parent = globalenv())
.word_rate$characters <- 0
.word_rate$timestamp <- Sys.time()

#' Lists languages from Google Translate API
#'
#' Returns a list of supported languages for translation.
#'
#' @param target If specified, language names are localized in target language
#'
#' @details
#' Supported language codes, generally consisting of its ISO 639-1 identifier. (E.g. \code{'en', 'ja'}).
#' In certain cases, BCP-47 codes including language + region identifiers are returned (e.g. \code{'zh-TW', 'zh-CH'})
#'
#' @return A tibble of supported languages
#' @seealso \url{https://cloud.google.com/translate/docs/reference/languages}
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' # default english names of languages supported
#' gl_translate_languages()
#'
#' # specify a language code to get other names, such as Danish
#' gl_translate_languages("da")
#'
#' }
#' @family translations
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble as_tibble
#' @import assertthat
gl_translate_languages <- function(target = 'en'){

  assert_that(is.string(target))

  call_api <- gar_api_generator("https://translation.googleapis.com/language/translate/v2/languages",
                         "GET",
                         pars_args = list(target = target),
                         data_parse_function = function(x) as_tibble(x$data$languages))

  call_api()

}

#' Detect the language of text within a request
#'
#' @param string A character vector of text to detect language for
#'
#' @details
#'   Consider using \code{library(cld2)} and \code{cld2::detect_language} instead offline,
#' since that is free and local without needing a paid API call.
#'
#' \link{gl_translate} also returns a detection of the language,
#' so you could also wish to do it in one step via that function.
#'
#' @return A tibble of the detected languages with columns \code{confidence}, \code{isReliable}, \code{language}, and \code{text} of length equal to the vector of text you passed in.
#'
#' @seealso \url{https://cloud.google.com/translate/docs/reference/detect}
#' @export
#' @family translations
#' @examples
#'
#' \dontrun{
#'
#' gl_translate_detect("katten sidder på måtten")
#' # Detecting language: 39 characters - katten sidder på måtten...
#' # confidence isReliable language                    text
#' # 1   0.536223      FALSE       da katten sidder på måtten
#'
#'
#' }
#'
#' @import assertthat
#' @importFrom utils URLencode
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble as_tibble
#' @importFrom stats setNames
#' @importFrom purrr map_df
gl_translate_detect <- function(string){

  assert_that(is.character(string))

  char_num <- sum(nchar(string))

  string <- trimws(string)

  my_message("Detecting language: ",char_num, " characters", level = 3)

  ## character limits - 100000 characters per 100 seconds
  check_rate(char_num)

  ## repeat per text
  pars <- setNames(as.list(string), rep("q",length(string)))

  call_api <- gar_api_generator("https://translation.googleapis.com/language/translate/v2/detect",
                                "POST",
                                customConfig = list(encode = "form"),
                                data_parse_function = function(x) Reduce(rbind,
                                                                         x$data$detections))

  me <- tryCatch(call_api(the_body = pars),
                 error = function(ex){
                   if(grepl("Too many text segments|Request payload size exceeds the limit", ex$message)){
                     my_message("Attempting to split into several API calls", level = 3)
                     Reduce(rbind, lapply(string, gl_translate_detect))
                   }
                 })

  me$text <- string

  as_tibble(me)

}

#' Translate the language of text within a request
#'
#' Translate character vectors via the Google Translate API
#'
#' @param t_string A character vector of text to detect language for
#' @param target The target language
#' @param format Whether the text is plain or HTML
#' @param source Specify the language to translate from. Will detect it if left default
#' @param model What translation model to use
#'
#' @details
#'
#' You can translate a vector of strings, although if too many for one call then it will be
#'   broken up into one API call per element.
#'   This is the same cost as charging is per character translated, but will take longer.
#'
#' If translating HTML set the \code{format = "html"}.
#' Consider removing anything not needed to be translated first, such as JavaScript and CSS scripts. See example on how to do this with \code{rvest}
#'
#' The API limits in three ways: characters per day, characters per 100 seconds, and API requests per 100 seconds. All can be set in the API manager \code{https://console.developers.google.com/apis/api/translate.googleapis.com/quotas}
#'
#' The function will limit the API calls for for the characters and API requests per 100 seconds, which you can set via the options \code{googleLanguageR.rate_limit} and \code{googleLanguageR.character_limit}.  By default these are set at \code{0.5} requests per second, and \code{100000} characters per 100 seconds.
#'
#'
#' @return A tibble of \code{translatedText} and \code{detectedSourceLanguage} and \code{text} of length equal to the vector of text you passed in.
#'
#' @seealso \url{https://cloud.google.com/translate/docs/reference/translate}
#'
#' @examples
#'
#' \dontrun{
#'
#' text <- "to administer medicine to animals is frequently a very difficult matter,
#'   and yet sometimes it's necessary to do so"
#'
#' gl_translate(text, target = "ja")
#'
#' # translate webpages using rvest to process beforehand
#' library(rvest)
#' library(googleLanguageR)
#'
#' # translate webpages
#'
#' my_url <- "http://www.dr.dk/nyheder/indland/greenpeace-facebook-og-google-boer-foelge-apples-groenne-planer"
#'
#' ## in this case the content to translate is in css selector '.wcms-article-content'
#' read_html(my_url) %>%
#'   html_node(css = ".wcms-article-content") %>%
#'   html_text %>%
#'   gl_translate(format = "html")
#'
#' }
#'
#' @export
#' @family translations
#' @import assertthat
#' @importFrom utils URLencode
#' @importFrom googleAuthR gar_api_generator
#' @importFrom tibble as_tibble
#' @importFrom stats setNames
#' @importFrom purrr map_df
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

  ## string checks
  t_string <- trimws(t_string)

  t_string <- check_if_html(t_string, format)

  char_num <- sum(nchar(t_string))

  my_message("Translating ",format,": ",
             char_num," characters - ", level = 3)

  if(!is.string(t_string)){
    my_message("Translating vector of strings > 1: ", length(t_string), level = 2)
  }

  ## character limits - 100000 characters per 100 seconds
  check_rate(char_num)

  pars <- list(target = target,
               format = format,
               source = source)

  ## repeat per text
  pars <- c(pars, setNames(as.list(t_string), rep("q",length(t_string))))

  call_api <- gar_api_generator("https://translation.googleapis.com/language/translate/v2",
                                "POST",
                                #otherwise jsonlite turns all the q's into q1, q2 etc.
                                customConfig = list(encode = "form"),
                                data_parse_function = function(x) x$data$translations)

  me <- tryCatch(call_api(the_body = pars),
                 error = function(ex){
                   if(grepl("Too many text segments|Request payload size exceeds the limit", ex$message)){
                     my_message("Attempting to split into several API calls", level = 3)
                     Reduce(rbind, lapply(t_string, gl_translate,
                                          format = format,
                                          target = target,
                                          source = source,
                                          model = model))
                   }
                 })

  me$text <- t_string

  as_tibble(me)

}


#' Limit the API to the limits imposed by Google
#'
#'
#' @import assertthat
#' @noRd
check_rate <- function(word_count,
                       timestamp = Sys.time(),
                       character_limit = getOption("googleLanguageR.character_limit")){

  ## window of character limit in seconds (e.g. 100000 per 100 seconds)
  delay_limit <- 100L

  if(word_count == 0) return()

  assert_that(is.count(word_count),
              is.numeric(character_limit),
              is.numeric(delay_limit),
              is.time(timestamp))

  if(.word_rate$characters > 0){
    my_message("# Current character batch: ", .word_rate$characters, level = 2)
  }

  .word_rate$characters <- .word_rate$characters + word_count
  if(.word_rate$characters > character_limit){
    my_message("Limiting API as over ", character_limit," characters in ", delay_limit, " seconds",
              level = 3)
    my_message("Timestamp batch start: ", .word_rate$timestamp,
              level = 2)

    delay <- difftime(timestamp, .word_rate$timestamp, units = "secs")

    while(delay < delay_limit){
      my_message("Waiting for ", format(round(delay_limit - delay), format = "%S"),
                level = 3)
      delay <- difftime(Sys.time(), .word_rate$timestamp, units = "secs")
      Sys.sleep(5)
    }

    my_message("Ready to call API again", level = 2)
    .word_rate$characters <- 0
    .word_rate$timestamp <- Sys.time()

  }
}

#' @noRd
check_if_html <- function(string, format){

  html_test <- any(grepl("<.+>", string))

  if(all(html_test, format != "html")){
    warning("Possible HTML found in input text, but format != 'html'")
  }

  string

}
