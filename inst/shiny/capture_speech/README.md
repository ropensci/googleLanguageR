# Google Cloud Speech API Shiny app

This is a demo on using the [Cloud Speech API](https://cloud.google.com/speech/) with Shiny. 

It uses `library(tuneR)` to process the audio file, and a JavaScript audio library from [Web Audio Demos](https://webaudiodemos.appspot.com/AudioRecorder/index.html) to capture the audio in your browser.

You can also optionally send your transcription to the [Cloud Translation API](https://cloud.google.com/translate/)

The results are then spoken back to you using the `gl_talk()` functions.

## Screenshot

![](babelfish.png)

