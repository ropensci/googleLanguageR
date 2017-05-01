# googleLanguageR - R client for the Google Translation API, Google Cloud Natural Language API and Google Cloud Speech API

This package contains functions for analysing language through the [Google Cloud Machine Learning APIs](https://cloud.google.com/products/machine-learning/)

Note all are paid services, you will need to provide your credit card details for your own Google Project to use them.

## Google Cloud Speech API

> Google Cloud Speech API enables you to convert audio to text by applying neural network models in an easy to use API. The API recognizes over 80 languages and variants, to support your global user base. You can transcribe the text of users dictating to an application’s microphone or enable command-and-control through voice among many other use cases. 

Read more [here](https://cloud.google.com/speech/)

## Google Cloud Translation API

> Google Cloud Translation API provides a simple programmatic interface for translating an arbitrary string into any supported language. Translation API is highly responsive, so websites and applications can integrate with Translation API for fast, dynamic translation of source text from the source language to a target language (e.g. French to English). 

Read more [here](https://cloud.google.com/translate/)

## Google Natural Language API

> Google Natural Language API reveals the structure and meaning of text by offering powerful machine learning models in an easy to use REST API. You can use it to extract information about people, places, events and much more, mentioned in text documents, news articles or blog posts. You can also use it to understand sentiment about your product on social media or parse intent from customer conversations happening in a call center or a messaging app. 

Read more [here](https://cloud.google.com/natural-language/)

## Setup

1. Create a Google Project
2. Set up a credit card
3. Activate the relevant APIs
4. Download a service JSON file
5. Load this library via `devtools::install_github("MarkEdmondson1234/googleLanguageR")`
6. Authenticate via:

```r
library(googleLanguageR)
gl_auth("location_of_json_file.json")
```

7. Call APIs via functions:

* `gl_nlp()` - Natural Langage API
* `gl_speech_recognise()` - Cloud Speech API
* `gl_translate_language()` - Cloud Translation API


## Translation API limits

The API limits in three ways: characters per day, characters per 100 seconds, and API requests per 100 seconds. All can be set in the API manager \code{https://console.developers.google.com/apis/api/translate.googleapis.com/quotas}

The library will limit the API calls for for the characters and API requests per 100 seconds, which you can set via the options `googleLanguageR.rate_limit` and `googleLanguageR.character_limit`.  By default these are set at `0.5` requests per second, and `100000` characters per 100 seconds.  Change them via:

```r
options(googleLanguageR.rate_limit = 0.15, 
        googleLanguageR.character_limit = 10000L)
```


## Demo for Google Cloud Speech API

```r
library(googleLanguageR)

## download a service JSON from your own Google Project
gl_auth(json_file.json)

## a test audio file is installed with the package which reads:
## "to administer medicince to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so"
test_audio <- system.files(package = "googleLanguageR", "woman1_wb.wav")
result <- gl_speech_recognise(test_audio)

## its not perfect but...:)
result$transcript
#> [1] "to administer medicine to animals is freaking care very difficult matter and yet sometimes it's necessary to do so"
result$confidence
#> [1] 0.9154025

## get alternative transcriptions
result2 <- gl_speech_recognise(test_audio, maxAlternatives = 2L)

result2$transcript
#> [1] "to administer medicine to animals is freaking care very difficult matter and yet sometimes it's necessary to do so"
#> [2] "to administer medicine to animals is freaking give very difficult matter and yet sometimes it's necessary to do so"

## specify british accent
result_brit <- gl_speech_recognise(test_audio, languageCode = "en-GB")
result_brit
#> [1] "to administer medicine to animals if we can give very difficult matter and yet sometimes it's necessary to do so"

## help it out with context for "frequently"
result_brit_freq <- gl_speech_recognise(test_audio, 
                                        languageCode = "en-GB", 
                                        speechContexts = list(phrases = list("is frequently a very difficult")))
result_brit_freq$transcript
#> "to administer medicine to animals is frequently a very difficult matter and yet sometimes it's necessary to do so"
```

## Demo for Google Translation API

```r
## translate British into Japanese
japan <- gl_translate_language(result_brit_freq$transcript, target = "ja")

japan$translatedText
#> [1] "動物に薬を投与することはしばしば非常に困難な問題ですが、時にはそれを行う必要があります"
```

## Demo for Entity Analysis

```r
nlp_result <- gl_nlp(result_brit_freq$transcript)
#>2017-05-01 21:57:18 -- annotateTextanalyzeEntitiesanalyzeSentimentanalyzeSyntax for 'to administer medicine to animals is frequently a very difficult matter and yet sometimes it's neces...'

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
