

#' get tabular Vegetative Health Index (VHI) data from
#' FAO GIEWS system at admin 1 level by country
#'
#' @param iso3 `character` containing country iso3 code
#'
#' @returns `data.frame` containing contents of FAO admin 1 csv from GIEWS
#' @export
#'
#' @examples
#' df_somalia <- fao_vhi_adm1_tabular("SOM")

fao_vhi_adm1_tabular <- function(iso3){
  iso3_upper <- toupper(iso3)
  readr::read_csv(
    glue::glue(
      "https://www.fao.org/giews/earthobservation/asis/data/country/{iso3_upper}/MAP_NDVI_ANOMALY/DATA/vhi_adm1_dekad_data.csv"
      ),
    show_col_types = FALSE
  )
}
