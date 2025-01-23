#' seas5_aggregate_forecast
#'
#' @param df `data.frame` with seas5 forecast as formatted in pg db
#' @param value `character` name of column containing seas5 value to forecast
#'   (default = 'mean')
#' @param valid_months `integer` vector w/ valid_months to aggregate (by sum)
#' @param by `character` vector to group calculations by
#'
#' @returns data.frame containing aggregated forecast values.
#' @export
#'
#' @examples
#' library(cumulus)
#' df_seas5 <- pg_load_seas5_historical(
#'   iso3 = "AFG",
#'   adm_level=1,
#'   adm_name = "Faryab",
#'   convert_units = TRUE
#' )
#' df_seas5_mam <- seas5_aggregate_forecast(
#'   df_seas5,
#'   value = "mean",
#'   valid_months = c(3,4,5),
#'   by = c("iso3", "pcode","name","issued_date")
#'   )
#'
#'
seas5_aggregate_forecast <-  function(df,value= "mean",valid_months=c(3,4,5), by = c("iso3", "pcode","issued_date")){
  soi <- glue::glue_collapse(lubridate::month(valid_months,abbr=T,label =T),sep = "-")
  df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
    dplyr::filter(
      lubridate::month(valid_date) %in% valid_months,
      all(valid_months %in% lubridate::month(valid_date))

    ) |>
    dplyr::summarise(
      !!value := sum(!!rlang::sym(value)),
      # **min() - BECAUSE**  for MJJA (5,6,7,8) at each pub_date we have a set of leadtimes
      # for EXAMPLE in March we have the following leadtimes 2
      # 2 : March + 2 = May,
      # 3 : March + 3 = June,
      # 4 : March + 4 = July
      # 5:  March + 5 = Aug
      # Therefore when we sum those leadtime precip values we take min() of lt integer so we get the leadtime to first month being aggregated
      leadtime = min(leadtime),
      .groups = "drop"
    ) |>
    dplyr::arrange(issued_date) |>
    dplyr::mutate(
      valid_month_label = soi
    )
}

#' pg_load_sea5_historical
#'
#' @param con postgres connection class object. If none provided it will
#'   connect to main by default
#' @param iso3 `character` iso3 code for country
#' @param adm_level `numeric` administrative level
#' @param adm_name `character` admin name of interest
#' @param convert_units `logical` should we convert from m/s to mm/month
#'   default = TRUE
#'
#' @returns data.frame with historical seas5 forecast
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


convert_precip_units <- function(df){
  df |>
    dplyr::mutate(
      dplyr::across(
        .cols = c("mean","median","min","max","std"),
        \(x) x *lubridate::days_in_month(valid_date)
      )
    )
}

