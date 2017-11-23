googleLanguageR - R client for the Google Translation API, Google Cloud Natural Language API and Google Cloud Speech API
================
Mark Edmondson
8/10/2017

[![CRAN](https://www.r-pkg.org/badges/version/googleLanguageR)](https://cran.r-project.org/package=googleLanguageR) [![Build Status](https://travis-ci.org/ropensci/googleLanguageR.png?branch=master)](https://travis-ci.org/ropensci/googleLanguageR) [![codecov.io](http://codecov.io/github/ropensci/googleLanguageR/coverage.svg?branch=master)](http://codecov.io/github/ropensci/googleLanguageR?branch=master) [![](https://badges.ropensci.org/127_status.svg)](https://github.com/ropensci/onboarding/issues/127)

This package contains functions for analysing language through the [Google Cloud Machine Learning APIs](https://cloud.google.com/products/machine-learning/)

Note all are paid services, you will need to provide your credit card details for your own Google Project to use them.

The package can be used by any user who is looking to take advantage of Google's massive dataset to train these machine learning models. Some applications include:

-   Translation of speech into another language text, via speech-to-text then translation
-   Identification of sentiment within text, such as from Twitter feeds
-   Pulling out the objects of a sentence, to help classify texts and get metadata links from Wikipedia about them.

The applications of the API results could be relevant to business or researchers looking to scale text analysis.

Google Natural Language API
---------------------------

> Google Natural Language API reveals the structure and meaning of text by offering powerful machine learning models in an easy to use REST API. You can use it to extract information about people, places, events and much more, mentioned in text documents, news articles or blog posts. You can also use it to understand sentiment about your product on social media or parse intent from customer conversations happening in a call center or a messaging app.

Read more [on the Google Natural Language API](https://cloud.google.com/natural-language/)

Google Cloud Translation API
----------------------------

> Google Cloud Translation API provides a simple programmatic interface for translating an arbitrary string into any supported language. Translation API is highly responsive, so websites and applications can integrate with Translation API for fast, dynamic translation of source text from the source language to a target language (e.g. French to English).

Read more [on the Google Cloud Translation Website](https://cloud.google.com/translate/)

Google Cloud Speech API
-----------------------

> Google Cloud Speech API enables you to convert audio to text by applying neural network models in an easy to use API. The API recognizes over 80 languages and variants, to support your global user base. You can transcribe the text of users dictating to an application’s microphone or enable command-and-control through voice among many other use cases.

Read more [on the Google Cloud Speech Website](https://cloud.google.com/speech/)

Installation
------------

1.  Create a [Google API Console Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
2.  Within your project, add a [payment method to the project](https://support.google.com/cloud/answer/6293589)
3.  Within your project, check the relevant APIs are activated

-   [Google Natural Language API](https://console.cloud.google.com/apis/api/language.googleapis.com/overview)
-   [Google Cloud Translation API](https://console.cloud.google.com/apis/api/translate.googleapis.com/overview)
-   [Google Cloud Speech API](https://console.cloud.google.com/apis/api/speech.googleapis.com/overview)

1.  [Generate a service account credential](https://cloud.google.com/storage/docs/authentication#generating-a-private-key) as a JSON file
2.  Return to R, and install the official release via `install.packages("googleLanguageR")`, or the development version with `devtools::install_github("ropensci/googleLanguageR")`

Usage
-----

### Authentication

The best way to authenticate is to use an environment file. See `?Startup`. I usually place this in my home directory. (e.g. if using RStudio, click on `Home` in the file explorer, create a new `TEXT` file and call it `.Renviron`)

Set the file location of your download Google Project JSON file in a `GL_AUTH` argument:

    #.Renviron
    GL_AUTH=location_of_json_file.json

Then, when you load the library you should auto-authenticate:

``` r
library(googleLanguageR)
```

You can also authenticate directly using the `gl_auth` function pointing at your JSON auth file:

``` r
library(googleLanguageR)
gl_auth("location_of_json_file.json")
```

You can then call the APIs via the functions:

-   `gl_nlp()` - Natural Langage API
-   `gl_speech()` - Cloud Speech API
-   `gl_translate()` - Cloud Translation API

Natural Language API
--------------------

The Natural Language API returns natural language understanding technolgies. You can call them individually, or the default is to return them all. The available returns are:

-   *Entity analysis* - Finds named entities (currently proper names and common nouns) in the text along with entity types, salience, mentions for each entity, and other properties. If possible, will also return metadata about that entity such as a Wikipedia URL. If using the **v1beta2** endpoint this also includes sentiment for each entity.
-   *Syntax* - Analyzes the syntax of the text and provides sentence boundaries and tokenization along with part of speech tags, dependency trees, and other properties.
-   *Sentiment* - The overall sentiment of the text, represented by a magnitude `[0, +inf]` and score between `-1.0` (negative sentiment) and `1.0` (positive sentiment).

### Demo for Entity Analysis

You can pass a vector of text which will call the API for each element. The return is a list of responses, each response being a list of tibbles holding the different types of analysis.

``` r
texts <- c("to administer medicince to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so", 
         "I don't know how to make a text demo that is sensible")
nlp_result <- gl_nlp(texts)

# two results of lists of tibbles
str(nlp_result, max.level = 2)
```

    ## List of 6
    ##  $ sentences        :List of 2
    ##   ..$ :'data.frame': 1 obs. of  4 variables:
    ##   ..$ :'data.frame': 1 obs. of  4 variables:
    ##  $ tokens           :List of 2
    ##   ..$ :'data.frame': 21 obs. of  17 variables:
    ##   ..$ :'data.frame': 13 obs. of  17 variables:
    ##  $ entities         :List of 2
    ##   ..$ :Classes 'tbl_df', 'tbl' and 'data.frame': 3 obs. of  9 variables:
    ##   ..$ :Classes 'tbl_df', 'tbl' and 'data.frame': 1 obs. of  9 variables:
    ##  $ language         : chr [1:2] "en" "en"
    ##  $ text             : chr [1:2] "to administer medicince to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so" "I don't know how to make a text demo that is sensible"
    ##  $ documentSentiment:Classes 'tbl_df', 'tbl' and 'data.frame':   2 obs. of  2 variables:
    ##   ..$ magnitude: num [1:2] 0.5 0.3
    ##   ..$ score    : num [1:2] 0.5 -0.3

See more examples and details [on the website](http://code.markedmondson.me/googleLanguageR/articles/nlp.html) or via `vignette("nlp", package = "googleLanguageR")`

Google Translation API
----------------------

You can detect the language via `gl_translate_detect`, or translate and detect language via `gl_translate`

Note this is a lot more refined than the free version on Google's translation website.

``` r
text <- "to administer medicine to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so"
## translate British into Danish
gl_translate(text, target = "da")$translatedText
```

    ## [1] "at administrere medicin til dyr er ofte en meget vanskelig sag, og dog er det undertiden nødvendigt at gøre det"

See more examples and details [on the website](http://code.markedmondson.me/googleLanguageR/articles/translation.html) or via `vignette("translate", package = "googleLanguageR")`

Google Cloud Speech API
-----------------------

The Cloud Speech API provides audio transcription. Its accessible via the `gl_speech` function.

A test audio file is installed with the package which reads:

> "To administer medicine to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so"

The file is sourced from the [University of Southampton's speech detection](http://www-mobile.ecs.soton.ac.uk/newcomms/) group and is fairly difficult for computers to parse, as we see below:

``` r
## get the sample source file
test_audio <- system.file("woman1_wb.wav", package = "googleLanguageR")

## its not perfect but...:)
gl_speech(test_audio)$transcript
```

    ## # A tibble: 1 x 2
    ##                                                                    transcript
    ##                                                                         <chr>
    ## 1 to administer medicine to animals is freaking cute very difficult matter an
    ## # ... with 1 more variables: confidence <chr>

See more examples and details [on the website](http://code.markedmondson.me/googleLanguageR/articles/speech.html) or via `vignette("speech", package = "googleLanguageR")`

[![ropensci\_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
