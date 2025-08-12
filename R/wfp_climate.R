#
# # download function unfortunately doesn't work because link ids change depending on country
#
# # wfp_chirps <- function(iso3="afg",time_step = c("dekad","month")){
# #   iso3 <-  tolower(iso3)
# #   time_step <- rlang::arg_match(time_step)
# #   chirps_url <- glue::glue("https://data.humdata.org/dataset/3b5e8a5c-e4e0-4c58-9c58-d87e33520e08/resource/a8c98023-e078-4684-ade3-9fdfd66a1361/download/{iso3}-rainfall-adm2-full.csv")
# #
# #   utils::download.file(chirps_url, tf <- tempfile("{iso3}-rainfall-adm2-full.csv"))
# #   df_raw <- readr::read_csv(tf)
# #
# #   df_clean <- df_raw[-1,] |>
# #     janitor::clean_names() |>
# #     janitor::type_convert()
# #   if(time_step == "month"){
# #
# #   }
# # }
#
#
# label_wfp_climate_data <- function(){
#
# }
# https://data.humdata.org/dataset/a1f60b8a-51ff-4ee7-87ab-897983714595/resource/edef1b38-b67f-4e1f-ac4e-764fffcf0357/download/lbr-rainfall-adm2-full.csv
