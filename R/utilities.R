# purrr's map_df without dplyr
my_map_df <- function(.x, .f, ...){

  .f <- purrr::as_mapper(.f, ...)
  res <- map(.x, .f, ...)
  Reduce(rbind, res)

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

# check loaded package
check_package_loaded <- function(package_name){
  if (!requireNamespace(package_name, quietly = TRUE)) {
    stop(paste0(package_name, " needed for this function to work. Please install it"),
         call. = FALSE)
  }
}
