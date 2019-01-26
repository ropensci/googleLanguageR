# Contributing to googleLanguageR

Thank you for your interest in contributing to this project!

To run unit tests, saved API calls are cached in the `tests/testthat/mock` folder.  These substitute for an API call to Google and avoid authentication.

The API calls to the Cloud Speech API and translation varies slightly, so test success is judged if the string is within 10 characters of the test string. For this test then, the `stringdist` package is needed (under the package `Suggests`)

To run integration tests that hit the API, you will need to add your own authentication service JSON file from Google Cloud projects.  Save this file to your computer and then set an environment variable `GL_AUTH` pointing to the file location. If not present, (such as on CRAN or Travis) the integration tests will be skipped.

You will need to enable the following APIs:

* [Google Cloud Speech API](https://console.developers.google.com/apis/api/speech.googleapis.com/overview)
* [Google Cloud Natural Language API](https://console.developers.google.com/apis/api/language.googleapis.com/overview)
* [Google Cloud Translation API](https://console.developers.google.com/apis/api/translate.googleapis.com/overview)

To create new mock files, it needs to fully load the package so do:

```
remotes::install_github("ropensci/googleLanguageR")
setwd("tests/testthat")
source("test_unit.R")
```

## Contributor Covenant Code of Conduct.

* Any contributors should be doing so for the joy of creating and sharing and advancing knowledge.  Treat each other with the respect this deserves.  
* The main language is English. 
* The community will tolerate everything but intolerance. It should be assumed everyone is trying to be tolerant until they repeatedly prove otherwise. 
* Don't break any laws or copyrights during contributions, credit sources where it is due. 
