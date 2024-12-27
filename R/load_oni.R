

#' load_oni
#' Convenience function to load tidy ENSO ONI data
#' @param show_col_types `logical` from readr::read_table() whether or not to
#' print column types when the data.frame/table is loaded
#' @return `data.frame`
#' @export
#'
#' @examples
#' library(cumulus)
#' load_oni()
load_oni <-  function(show_col_types = TRUE){
  readr::read_table(
    "https://origin.cpc.ncep.noaa.gov/products/analysis_monitoring/ensostuff/detrend.nino34.ascii.txt",
    show_col_types = show_col_types
    )  |>
    janitor::clean_names() |>
    dplyr::select(-x6) |>
    dplyr::mutate(
    # create propoer date col
    date= lubridate::ym(paste0(yr,".",mon))
  )
}

