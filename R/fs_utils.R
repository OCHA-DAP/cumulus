#' blob_floodscan_catalogue
#' return useful data.frame for filtering and pathing to floodscan cog urls
#' TODO: only set up for dev container so far.
#'
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#'
#' @return data.frame with columns `name`, `date`, and `vp` (virtual path),
#'   `isdir`, `blobtype`
#' @export
#'
#' @examples
#' library(cumulus)
#' catalogue <- blob_floodscan_catalogue()
blob_floodscan_catalogue <- function(stage= c("dev","prod")){
  stage <- rlang::arg_match(stage)
  containers <- blob_containers(stage= stage)

  if(stage=="dev"){
    catalogue <- AzureStor::list_blobs(
      container = containers$global,
      prefix = "raster/cogs/aer_area_300s_"
    )
  }
  catalogue |>
    dplyr::mutate(
      date = fs_date(stage= stage)(name),
      vp = paste0("vsiaz/",containers$global$name,"/",name)
    )
}


#' blob_floodscan_catalogue
#'
#' blob_floodscan_catalogue
#' return useful data.frame for filtering and pathing to floodscan cog urls
#' TODO: only set up for dev container so far.
#'
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#' @param start_date `character` start date to begin check (default = 1998-01-01)
#' @param end_date `character` end date to end check (default = Sys.Date()-2)
#'
#' @return if no missing date returns message "No dates missing" else returns
#'  data.frame catalogue with missing dates
#' @export
#'
#' @examples
#' library(cumulus)
#' blob_fs_check_dates()
blob_fs_check_dates <-  function(stage=c("dev","prod"), start_date="1998-01-01", end_date=Sys.Date()-2){
  stage <-  rlang::arg_match(stage)
  start_date <- lubridate::as_date(start_date)
  end_date <-  lubridate::as_date(end_date)
  full_date_seq <- seq(start_date,end_date, by = "day")

  catalogue <- blob_floodscan_catalogue(stage= stage)
  df_missing <- catalogue |>
    dplyr::filter(
      !any(full_date_seq %in% date)
    )

  if(nrow(df_missing)==0){
    cat("No dates missing")
  }else{
    cat("Missing dates: \n")
    df_missing
  }
}

#' fs_date floodscan date
#' utility function to parse dates from file names depending on where they are
#' stored and with what syntax.
#'
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#'
#' @return date parsing function
fs_date <- function(stage=c("dev","prod")){
  stage <- rlang::arg_match(stage)
  switch(
    stage,
    dev = function(x){lubridate::as_date(stringr::str_extract(x, "\\d{8}"),tz= NULL,format= "%Y%m%d")}
  )
}


