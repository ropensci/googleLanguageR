## ---- message=TRUE, warning=FALSE----------------------------------------
library(googleLanguageR)

texts <- c("to administer medicince to animals is frequently a very difficult matter,
         and yet sometimes it's necessary to do so", 
         "I don't know how to make a text demo that is sensible")
nlp_result <- gl_nlp(texts)

# two results of lists of tibbles
str(nlp_result, max.level = 2)

## get first return
nlp <- nlp_result[[1]]
nlp$sentences

nlp2 <- nlp_result[[2]]
nlp2$sentences

nlp2$tokens

nlp2$entities

nlp2$documentSentiment

nlp2$language

