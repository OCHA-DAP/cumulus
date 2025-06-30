

#' get tabular ASI FAO data at admin 1 level by country
#'
#' @param iso3 `character` containing country iso3 code
#'
#' @returns `data.frame` containing contents of FAO admin 1 csv from GIEWS
#' @export
#'
#' @examples
#' df_syria <- fao_asi_adm1_tabular("SYR")

fao_asi_adm1_tabular <- function(iso3){
  iso3_upper <- toupper(iso3)
    readr::read_csv(
      glue::glue(
        "https://www.fao.org/giews/earthobservation/asis/data/country/{iso3_upper}/MAP_ASI/DATA/ASI_Dekad_Season1_data.csv"),
      show_col_types = FALSE
      )
}
