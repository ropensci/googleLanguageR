
#' A helper function that tests whether an object is either NULL _or_
#' a list of NULLs
#'
#' @keywords internal
is.NullOb <- function(x) is.null(x) | all(sapply(x, is.null))

#' Recursively step down into list, removing all such objects
#'
#' @keywords internal
rmNullObs <- function(x) {
  x <- Filter(Negate(is.NullOb), x)
  lapply(x, function(x) if (is.list(x)) rmNullObs(x) else x)
}

# safe cbind that removes df with no rows
my_cbind <- function(...){
  dots <- list(...)

  nrows <- vapply(dots, function(x) nrow(x) > 0, logical(1))

  dots <- dots[nrows]

  do.call(cbind, args = dots)

}

#' base R safe rbind
#'
#' Send in a list of data.fames with different column names
#'
#' @return one data.frame
#' a safe rbind for variable length columns
#' @noRd
my_reduce_rbind <- function(x){
  classes <- lapply(x, inherits, what = "data.frame")
  stopifnot(all(unlist(classes)))

  # all possible names
  df_names <- Reduce(union, lapply(x, names))

  df_same_names <- lapply(x, function(y){
    missing_names <- setdiff(df_names,names(y))
    num_col <- length(missing_names)
    if(num_col > 0){
      missing_cols <- vapply(missing_names, function(i) NA, NA, USE.NAMES = TRUE)
      new_df <- data.frame(matrix(missing_cols, ncol = num_col))
      names(new_df) <- names(missing_cols)
      y <- cbind(y, new_df, row.names = NULL)
    }

    y[, df_names]

  })

  Reduce(rbind, df_same_names)
}

# purrr's map_df without dplyr
my_map_df <- function(.x, .f, ...){
  tryCatch(
    {
      .f <- purrr::as_mapper(.f, ...)
      res <- map(.x, .f, ...)
      my_reduce_rbind(res)
    },
    error = function(err){
      warning("Could not parse object with names: ", paste(names(.x), collapse = " "))
      .x
    }

  )


}


#' @importFrom jsonlite unbox
#' @noRd
jubox <- function(x){
  unbox(x)
}

# tests if a google storage URL
is.gcs <- function(x){
  out <- grepl("^gs://", x)
  if(out){
    my_message("Using Google Storage URI: ", x, level = 3)
  }
  out
}

# controls when messages are sent to user via an option
# 1 = low level, 2= debug, 3=normal
my_message <- function(..., level = 1){

  compare_level <- getOption("googleAuthR.verbose", default = 1)

  if(level >= compare_level){
    message(Sys.time()," -- ", ...)
  }

}

