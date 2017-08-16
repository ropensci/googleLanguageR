## ---- include=FALSE------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ---- warning=FALSE------------------------------------------------------
library(googleLanguageR)

text <- "to administer medicince to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so"
## translate British into Danish
gl_translate(text, target = "da")$translatedText

## ------------------------------------------------------------------------
# translate webpages
library(rvest)
library(googleLanguageR)

my_url <- "http://www.dr.dk/nyheder/indland/greenpeace-facebook-og-google-boer-foelge-apples-groenne-planer"

## in this case the content to translate is in css select .wcms-article-content
read_html(my_url) %>% # read html
  html_node(css = ".wcms-article-content") %>%   # select article content with CSS
  html_text %>% # extract text
  gl_translate(format = "html") %>% # translate with html flag
  dplyr::select(translatedText) # show translatedText column of output tibble


## ------------------------------------------------------------------------
## which language is this?
gl_translate_detect("katten sidder på måtten")

## ------------------------------------------------------------------------
cld2::detect_language("katten sidder på måtten")

