
is.gcs <- function(x){
  out <- grepl("^gs://", x)
  if(out){
    myMessage("Using Google Storage URI: ", x, level = 3)
  }
  out
}

is.NullOb <- function(x) is.null(x) | all(sapply(x, is.null))


rmNullObs <- function(x) {
  x <- Filter(Negate(is.NullOb), x)
  lapply(x, function(x) if (is.list(x)) rmNullObs(x) else x)
}


is.error <- function(test_me){
  inherits(test_me, "try-error")
}

is.unit <- function(x){
  length(x) == 1
}


error.message <- function(test_me){
  if(is.error(test_me)) attr(test_me, "condition")$message
}


myMessage <- function(..., level = 1){


  compare_level <- getOption("googleAuthR.verbose")
  if(is.null(compare_level)) compare_level <- 1

  if(level >= compare_level){
    message(Sys.time()," -- ", ...)
  }

}


idempotency <- function(){
  paste(sample(c(LETTERS, letters, 0:9), 15, TRUE),collapse="")
}
