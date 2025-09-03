#' A helper function that tests whether an object is either NULL _or_
#' a list of NULLs
#'
#' @keywords internal
is.NullOb <- function(x) {
  is.null(x) || all(sapply(x, is.null))
}

#' Recursively remove NULL objects from a list
#'
#' @keywords internal
rmNullObs <- function(x) {
  x <- Filter(Negate(is.NullOb), x)
  lapply(x, function(el) if (is.list(el)) rmNullObs(el) else el)
}

#' Safe cbind that removes data.frames with no rows
#'
#' @keywords internal
my_cbind <- function(...) {
  dots <- list(...)
  nrows <- vapply(dots, function(x) nrow(x) > 0, logical(1))
  dots <- dots[nrows]
  do.call(cbind, args = dots)
}

#' Safe rbind for lists of data.frames with differing column names
#'
#' @param x A list of data.frames
#' @return One combined data.frame
#' @noRd
my_reduce_rbind <- function(x) {
  stopifnot(all(vapply(x, inherits, logical(1), what = "data.frame")))

  # All unique column names
  df_names <- Reduce(union, lapply(x, names))

  df_same_names <- lapply(x, function(y) {
    missing_names <- setdiff(df_names, names(y))
    num_col <- length(missing_names)

    if (num_col > 0) {
      missing_cols <- vapply(missing_names, function(i) NA, NA, USE.NAMES = TRUE)
      new_df <- as.data.frame(matrix(missing_cols, ncol = num_col, nrow = nrow(y)))
      names(new_df) <- names(missing_cols)
      y <- cbind(y, new_df, row.names = NULL)
    }

    y[, df_names, drop = FALSE]
  })

  Reduce(rbind, df_same_names)
}

#' purrr::map_df equivalent without dplyr
#'
#' @param .x Input list or vector
#' @param .f Function to apply
#' @param ... Additional arguments passed to `.f`
#' @return Combined data.frame
#' @noRd
my_map_df <- function(.x, .f, ...) {
  tryCatch(
    {
      .f <- purrr::as_mapper(.f, ...)
      res <- purrr::map(.x, .f, ...)
      my_reduce_rbind(res)
    },
    error = function(err) {
      warning("Could not parse object with names: ", paste(names(.x), collapse = " "))
      .x
    }
  )
}

#' JSON unbox helper
#'
#' @importFrom jsonlite unbox
#' @noRd
jubox <- function(x) {
  jsonlite::unbox(x)
}

#' Test if a string is a Google Cloud Storage URI
#'
#' @param x Character string
#' @return Logical
#' @keywords internal
is.gcs <- function(x) {
  out <- grepl("^gs://", x)
  if (out) my_message("Using Google Storage URI: ", x, level = 3)
  out
}

#' Custom messaging function for package
#'
#' @param ... Messages to print
#' @param level Message level (1=low, 2=debug, 3=normal)
#' @keywords internal
my_message <- function(..., level = 1) {
  compare_level <- getOption("googleAuthR.verbose", default = 1)
  if (level >= compare_level) {
    message(Sys.time(), " -- ", ...)
  }
}
