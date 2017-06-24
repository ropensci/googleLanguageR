# Contributing to googleLanguageR

Thank you for your interest in contributing to this project!

To run unit tests, saved API calls are cached in the `tests/testthat/mock` folder.  These substitute for an API call to Google and avoid authentication.

To run tests taht hit the API, you will need to add your own authentication service JSON file from Google Cloud projects.  Save this file to your computer and then set an environment variable `GL_AUTH` pointing to the file location. 

You will also need to enable the following APIS:

* [Google Cloud Speech API](https://console.developers.google.com/apis/api/speech.googleapis.com/overview)


