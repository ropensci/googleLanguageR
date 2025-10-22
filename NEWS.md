# 0.3.1

* Documentation & vignettes updated to fix CRAN URL and Rd issues (#92)
  - Fixed redirected/moved Google Cloud URLs (Natural Language, Speech-to-Text, Text-to-Speech, Translation, BCP47)
  - Updated README links and Rd references
  - Addressed Windows CRAN notes related to URLs
  - Minor doc clarifications and consistency improvements

* `gl_translate()` now supports recursive batching for large vectors (#80)
  - Preserves input order
  - Improves efficiency and reduces API calls

* Added `test_translate_batching.R` with:
  - Batch splitting unit test
  - Medium vector efficiency test
  - Order preservation test

* Added `IMPROVED_TRANSLATION_TESTS.txt` and `TEST_COVERAGE_SUMMARY.md`

* `gl_speech()` now supports MP3 encoding (#77)

# 0.3.0

* Improved error handling for vectorised `gl_nlp()` (#55)
* `gl_nlp()`'s classifyText returns list of data.frames, not data.frame
* Fix `gl_nlp` when `nlp_type='classifyText'`
* `customConfig` available for `gl_speech`
* Add support for SSML for `gl_talk()` (#66)
* Add support for device profiles for `gl_talk()` (#67)
* Add support for tuneR wave objects in `gl_speech()` - (#62 thanks @muschellij2)
* Add check for file size for audio source - (#62 thanks @muschellij2)

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
