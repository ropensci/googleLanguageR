# 0.2.0.9000

* Improved error handling for vectorised `gl_nlp()` (#55)
* `gl_nlp()`'s classifyText returns list of data.frames, not data.frame
* Fix `gl_nlp` when `nlp_type='classifyText'`
* `customConfig` available for `gl_speech`

# 0.2.0

* Added an example Shiny app that calls the Speech API
* Fixed bug where cbind of any missing API content raised an error (#28)
* Add Google text to speech via `gl_talk()` (#39)
* Add classify text endpoint for `gl_nlp()` (#20)

# 0.1.1

* Fix bug where `gl_speech()` only returned first few seconds of translation when asynch (#23)
* CRAN version carries stable API, GitHub version for beta features

# 0.1.0


* Natural language API via `gl_nlp`
* Speech annotation via `gl_speech_recognise`
* Translation detection and performance via `gl_translate_detect` and `gl_translate`
* Vectorised support for inputs
* Translating HTML support
* Tibble outputs
