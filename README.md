# googleLanguageR - R client for the Google Translation API, Google Cloud Natural Language API and Google Cloud Speech API

[![CRAN](http://www.r-pkg.org/badges/version/googleLanguageR)](http://cran.r-project.org/package=googleLanguageR)
[![Build Status](https://travis-ci.org/MarkEdmondson1234/googleLanguageR.png?branch=master)](https://travis-ci.org/MarkEdmondson1234/googleLanguageR)
[![codecov.io](http://codecov.io/github/MarkEdmondson1234/googleLanguageR/coverage.svg?branch=master)](http://codecov.io/github/MarkEdmondson1234/googleLanguageR?branch=master)
[![](https://ropensci.org/badges/127_status.svg)](https://github.com/ropensci/onboarding/issues/127)

This package contains functions for analysing language through the [Google Cloud Machine Learning APIs](https://cloud.google.com/products/machine-learning/)

Note all are paid services, you will need to provide your credit card details for your own Google Project to use them.

## Google Natural Language API

> Google Natural Language API reveals the structure and meaning of text by offering powerful machine learning models in an easy to use REST API. You can use it to extract information about people, places, events and much more, mentioned in text documents, news articles or blog posts. You can also use it to understand sentiment about your product on social media or parse intent from customer conversations happening in a call center or a messaging app. 

Read more [on the Google Natural Language API](https://cloud.google.com/natural-language/)

## Google Cloud Translation API

> Google Cloud Translation API provides a simple programmatic interface for translating an arbitrary string into any supported language. Translation API is highly responsive, so websites and applications can integrate with Translation API for fast, dynamic translation of source text from the source language to a target language (e.g. French to English). 

Read more [on the Google Cloud Translation Website](https://cloud.google.com/translate/)

## Google Cloud Speech API

> Google Cloud Speech API enables you to convert audio to text by applying neural network models in an easy to use API. The API recognizes over 80 languages and variants, to support your global user base. You can transcribe the text of users dictating to an application’s microphone or enable command-and-control through voice among many other use cases. 

Read more [on the Google Cloud Speech Website](https://cloud.google.com/speech/)

## Installation

1. Create a [Google API Console Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
2. Within your project, add a [payment method to the project](https://support.google.com/cloud/answer/6293589)
3. Within your project, check the relevant APIs are activated
  - [Google Natural Language API](https://console.cloud.google.com/apis/api/language.googleapis.com/overview)
  - [Google Cloud Translation API](https://console.cloud.google.com/apis/api/translate.googleapis.com/overview)
  - [Google Cloud Speech API](https://console.cloud.google.com/apis/api/speech.googleapis.com/overview)
4. [Generate a service account credential](https://cloud.google.com/storage/docs/authentication#generating-a-private-key) as a JSON file
5. Return to R, and install this library via `devtools::install_github("MarkEdmondson1234/googleLanguageR")`

## Usage

### Authentication

The best way to authenticate is to use an environment file.  See `?Startup`.  I usually place this in my home directory. (e.g. if using RStudio, click on `Home` in the file explorer, create a new `TEXT` file and call it `.Renviron`)  

Set the file location of your download Google Project JSON file in a `GL_AUTH` argument:

```
#.Renviron
GL_AUTH=location_of_json_file.json
```

Then, when you load the library you should auto-authenticate:

```r
library(googleLanguageR)
# Setting scopes to https://www.googleapis.com/auth/cloud-platform
# Set any additional scopes via options(googleAuthR.scopes.selected = c('scope1', 'scope2')) before loading library.
# Successfully authenticated via location_of_json_file.json
```

You can also authenticate directly using the `gl_auth` function pointing at your JSON auth file:

```r
library(googleLanguageR)
gl_auth("location_of_json_file.json")
```

You can then call the APIs via the functions:

* `gl_nlp()` - Natural Langage API
* `gl_speech_recognise()` - Cloud Speech API
* `gl_translate_language()` - Cloud Translation API

## Natural Language API

The Natural Language API returns natural language understanding technolgies.  You can call them individually, or the default is to return them all.  The available returns are:

* *Entity analysis* - Finds named entities (currently proper names and common nouns) in the text along with entity types, salience, mentions for each entity, and other properties.  If possible, will also return metadata about that entity such as a Wikipedia URL. If using the **v1beta2** endpoint this also includes sentiment for each entity.
* *Syntax* - Analyzes the syntax of the text and provides sentence boundaries and tokenization along with part of speech tags, dependency trees, and other properties.
* *Sentiment* - The overall sentiment of the text, represented by a magnitude `[0, +inf]` and score between `-1.0` (negative sentiment) and `1.0` (positive sentiment).


### Demo for Entity Analysis

```r
text <- "to administer medicince to animals is frequently a very difficult matter,
         and yet sometimes it's necessary to do so"
nlp_result <- gl_nlp(text)

head(nlp_result$tokens$text)
#      content beginOffset
# 1         to           0
# 2 administer           3
# 3   medicine          14
# 4         to          23
# 5    animals          26
# 6         is          34

head(nlp_result$tokens$partOfSpeech$tag)
#> [1] "PRT"  "VERB" "NOUN" "ADP"  "NOUN" "VERB"


nlp_result$entities
#       name  type  salience             mentions
# 1 medicine OTHER 0.5268406 medicine, 14, COMMON
# 2  animals OTHER 0.2444008  animals, 26, COMMON
# 3   matter OTHER 0.2287586   matter, 65, COMMON

nlp_result$documentSentiment
# $magnitude
# [1] 0.2
#
# $score
# [1] 0.2


```

## Google Translation API

You can only detect language via `gl_translate_detect`, or translate and detect language via `gl_translate_language`

### Language Translation

Translate text via `gl_translate_language`.  Note this is a lot more refined than the free version on Google's translation website.

```r
## translate British into Japanese
japan <- gl_translate_language(result_brit_freq$transcript, target = "ja")

japan$translatedText
```

You can choose the target language via the argument `target`.  The function will automatically detect the language if you do not define an argument `source`.

You can also supply web HTML and select the `format` argument to `html` which will strip out known tags to give you a cleaner translation. 

This function which will also detect the langauge. As it costs the same as `gl_translate_detect`, its usually cheaper to detect and translate in one step.

### Language Detection

This function only detects the language:

```r
## which language is this?
gl_translate_detect("katten sad på måtten")
#  confidence isReliable language
#1  0.1863063      FALSE       sv

gl_translate_detect("katten sidder på måtten")
#  Detecting language: 39 characters - katten sidder på måtten...
#  [[1]]
#  isReliable language confidence
#  1      FALSE       da   0.536223
```

The more text it has, the better.  And it helps if its not Danish...

It may be better to use [`cld2`](https://github.com/ropensci/cld2) to translate offline first, to avoid charges if the translation is unnecessary (e.g. already in English).  You could then verify online for more uncertain cases.

```r
cld2::detect_language("katten sad på måtten")
# [1] NA

cld2::detect_language("katten sidder på måtten")
# [1] "DANISH"
# attr(,"code")
# [1] "da"

gl_translate_detect("katten sidder på måtten")
#  Detecting language: 39 characters - katten sidder på måtten...
#  [[1]]
#  isReliable language confidence
#  1      FALSE       da   0.536223
```

### Translation API limits

The API limits in three ways: characters per day, characters per 100 seconds, and API requests per 100 seconds. All can be set in the API manager `https://console.developers.google.com/apis/api/translate.googleapis.com/quotas`

The library will limit the API calls for for the characters and API requests per 100 seconds, which you can set via the options `googleLanguageR.rate_limit` and `googleLanguageR.character_limit`.  By default these are set at `0.5` requests per second, and `100000` characters per 100 seconds.  Change them via:

```r
options(googleLanguageR.rate_limit = 0.15, 
        googleLanguageR.character_limit = 10000L)
```

## Google Cloud Speech API

The Cloud Speech API provides audio transcription.  Its accessible via the `gl_speech_recognise` function.

Arguments include:

* `audio_source` - this is a local file in the correct format, or a Google Cloud Storage URI
* `encoding` - the format of the sound file - `LINEAR16` is the common `.wav` format, other formats include `FLAC` and `OGG_OPUS`
* `sampleRate` - this needs to be set to what your file is recorded at.  
* `languageCode` - specify the language spoken as a [`BCP-47` language tag](https://tools.ietf.org/html/bcp47)
* `speechContexts` - you can supply keywords to help the translation with some context. 

### Demo for Google Cloud Speech API

A test audio file is installed with the package which reads:

> "To administer medicine to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so"

The file is sourced from the [University of Southampton's speech detection](http://www-mobile.ecs.soton.ac.uk/newcomms/) group and is fairly difficult for computers to parse, as we see below:

```r
## get the sample source file
test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")

result <- gl_speech_recognise(test_audio)

## its not perfect but...:)
result$transcript
#> [1] "to administer medicine to animals is freaking care very difficult matter 
#  and yet sometimes it's necessary to do so"
result$confidence
#> [1] 0.9154025

## get alternative transcriptions
result2 <- gl_speech_recognise(test_audio, maxAlternatives = 2L)

result2$transcript
#> [1] "to administer medicine to animals is freaking care very difficult matter 
#  and yet sometimes it's necessary to do so"
#> [2] "to administer medicine to animals is freaking give very difficult matter 
#  and yet sometimes it's necessary to do so"

## specify british accent
result_brit <- gl_speech_recognise(test_audio, languageCode = "en-GB")
result_brit
#> [1] "to administer medicine to animals if we can give very difficult matter 
#  and yet sometimes it's necessary to do so"

## help it out with context for "frequently"
result_brit_freq <- 
  gl_speech_recognise(test_audio, 
                      languageCode = "en-GB", 
                      speechContexts = list(phrases = list("is frequently a very difficult")))
result_brit_freq$transcript
#> "to administer medicine to animals is frequently a very difficult matter 
#  and yet sometimes it's necessary to do so"
```

