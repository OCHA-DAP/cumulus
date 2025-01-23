#' load_sea5_historical
#'
#' @param con postgres connection class object. If none provided it will
#'   connect to main by default
#' @param iso3 `character` iso3 code for country
#' @param adm_level `numeric` administrative level
#' @param adm_name `character` admin name of interest
#' @param convert_units `logical` should we convert from m/s to mm/month
#'   default = TRUE
#'
#' @returns
#' @export
#'
#' @examples
#' library(cumulus)
#' pg_load_seas5_historical(
#'   iso3 = "AFG",
#'   adm_level=1,
#'   adm_name = "Faryab"
#' )

pg_load_seas5_historical <- function(
    con=NULL,
    iso3,
    adm_level,
    adm_name,
    convert_units =TRUE
    ){

  if(is.null(con)){
    con <- pg_con()
  }
  df_lookup <- blob_load_admin_lookup() |>
    janitor::clean_names()

  df_lookup_filt <- df_lookup |>
    dplyr::filter(
      iso3 %in% {{iso3}},
      !!rlang::sym(glue::glue("adm{adm_level}_name")) %in% adm_name,
      adm_level == {{adm_level}}
    ) |>
    dplyr::select(
      dplyr::matches("adm\\d"),-adm0_name,-adm0_pcode
    ) |>
    janitor::remove_empty(which ="cols")

  pcodes <- unique(df_lookup_filt[[glue::glue("adm{adm_level}_pcode")]])

  df_seas5 <- dplyr::tbl(con, "seas5") |>
    dplyr::filter(
      pcode %in% pcodes
    ) |>
    dplyr::collect()

  df_seas5_labelled <- df_seas5 |>
    dplyr::left_join(
      df_lookup_filt,
      by = c(
        "pcode" = glue::glue("adm{adm_level}_pcode")
        )
    ) |>
    dplyr::rename(
      name = !!glue::glue("adm{adm_level}_name")
    ) |>
    dplyr::relocate(
      name,.after = pcode
    )
  if(convert_units){
    df_seas5_labelled <- df_seas5_labelled |>
      convert_precip_units()
  }
  df_seas5_labelled
}
