library(googleLanguageR)
library(rvest)
library(magrittr)
library(xml2)
library(rvest)

local_auth <- Sys.getenv("GL_AUTH") != ""
if(!local_auth){
  cat("\nNo authentication file detected\n")
} else {
  cat("\nFound local auth file:", Sys.getenv("GL_AUTH"))
}

on_travis <- Sys.getenv("CI") == "true"
if(on_travis){
  cat("\n#testing on CI - working dir: ", path.expand(getwd()), "\n")
} else {
  cat("\n#testing not on CI\n")
}

## Generate test text and audio
testthat::context("Setup test files")

test_text <- "Norma is a small constellation in the Southern Celestial Hemisphere between Ara and Lupus, one of twelve drawn up in the 18th century by French astronomer Nicolas Louis de Lacaille and one of several depicting scientific instruments. Its name refers to a right angle in Latin, and is variously considered to represent a rule, a carpenter's square, a set square or a level. It remains one of the 88 modern constellations. Four of Norma's brighter stars make up a square in the field of faint stars. Gamma2 Normae is the brightest star with an apparent magnitude of 4.0. Mu Normae is one of the most luminous stars known, but is partially obscured by distance and cosmic dust. Four star systems are known to harbour planets. "
test_text2 <- "Solomon Wariso (born 11 November 1966 in Portsmouth) is a retired English sprinter who competed primarily in the 200 and 400 metres.[1] He represented his country at two outdoor and three indoor World Championships and is the British record holder in the indoor 4 × 400 metres relay."
trans_text <- "Der gives Folk, der i den Grad omgaaes letsindigt og skammeligt med Andres Ideer, de snappe op, at de burde tiltales for ulovlig Omgang med Hittegods."
expected <- "There are people who are soberly and shamefully opposed to the ideas of others, who make it clear that they should be charged with unlawful interference with the former."

test_gcs <- "gs://mark-edmondson-public-files/googleLanguageR/a-dream-mono.wav"

test_audio <- system.file(package = "googleLanguageR", "woman1_wb.wav")

speaker_d_test <- "gs://mark-edmondson-public-read/boring_conversation.wav"

