#' Read a Parquet file stored in Microsoft Azure Data Storage container
#'
#' Reads a file from the `hdx-signals` container.
#' The file is read based on its prefix in `name`. Currently, the only support is for
#' Apache Parquet, CSV, GeoJSON and JSON files, but other support can be added if necessary.
#'
#' Function parsing is done based on file type:
#'
#' * Apache Parquet: [arrow::write_parquet()].
#' * CSV: [readr::read_csv()]
#' * Excel: [readxl::read_excel()]
#' * GeoJSON: [sf::st_read()]
#' * JSON: [jsonlite::read_json()]
#' * rds: [readr::read_rds()]

#'
#' @param name Name of the file to read, including directory prefixes
#'   (`input/` or `output/`) and file extension, such as `.parquet`.
#' @param stage Store to access, either `dev` (default) or `prod`.
#' @param container Container name (`character`) or actual container class
#'   object to read from
#' @param progress_show show progress bar (`logical`) (default = TRUE)
#' @param return_path_only  logical if FALSE (default) tries to read the data.
#'   If TRUE returns only the downloaded file path
#' @param ... Additional arguments passed to the respective reader functions:
#'   - For `.parquet` files: Passed to `arrow::read_parquet()`.
#'   - For `.geojson` files: Passed to `sf::st_read()`.
#'   - For `.json` files: Passed to `jsonlite::read_json()`.
#'   - For `.csv` files: Passed to `readr::read_csv()`.
#'   - For `.xls` files: Passed to `readxl::read_xls()`.
#'   - For `.xlsx` files: Passed to `readxl::read_xlsx()`.
#'   - For `.rds` files: Passed to `readr::read_rds()`.
#'
#' @returns Data frame.
#' @examples
#' df <- blob_read(name = "ds-aa-eth-drought/exploration/eth_admpop_2023.xlsx",
#'                 stage = "dev",
#'                 container = "projects",
#'                 progress_show = TRUE
#'                 )
#'
#' @export
blob_read <- function(name, stage = c("dev", "prod"), container="projects", progress_show = TRUE, return_path_only = FALSE, ...) {
  stage <- rlang::arg_match(stage)
  if(inherits(container, "character")){
    container <- blob_containers(stage = stage)[[container]]
  }

  fileext <- tools::file_ext(name)
  tf <- tempfile(fileext = paste0(".", fileext))

  opts <- options(azure_storage_progress_bar = progress_show)
  on.exit(options(opts))

  AzureStor::download_blob(
    container = container,
    src = name,
    dest = tf
  )
  if(!return_path_only){
  ret <- switch(fileext,
         parquet = arrow::read_parquet(tf, ...),
         geojson = sf::st_read(tf, quiet = TRUE,....),
         json = dplyr::as_tibble(jsonlite::read_json(tf, simplifyVector = TRUE),..),
         csv = readr::read_csv(tf, col_types = readr::cols(), guess_max = 10000,...),
         xls = readxl::read_xls(tf, col_types = "guess",...),
         xlsx = readxl::read_xlsx(tf, col_types = "guess", ...),
         rds = readr::read_rds(tf, ...)
  )
  }
  if(return_path_only){
    ret <- tf
  }
  ret


}

# will add some utility funcs to read in very specific files that are global
# in scope.

#' blob_load_admin_lookup
#'
#' @returns data.frame containing admin lookup data contained in parquet file
#' @export
#'
#' @examples
#' library(cumulus)
#' blob_load_admin_lookup()
blob_load_admin_lookup <- function(){
  blob_read(
    name = "admin_lookup.parquet",
    stage = "dev",
    container = "polygon"
  )
}

