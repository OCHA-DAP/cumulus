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
#'
#' @param name Name of the file to read, including directory prefixes (`input/` or `output/`)
#'     and file extension, such as `.parquet`.
#' @param container Container name (`character`) or actual container class object to read from, either `prod`, `dev`, or `wfp`.
#'
#' @returns Data frame.
#' @examples
#' df <- blob_read(name = "ds-aa-afg-drought/raw/vector/wfp-chirps-adm2.csv", stage = "dev", container = "projects")
#'
#' @export
blob_read <- function(name, stage = c("prod", "dev"), container="projects") {
  stage <- rlang::arg_match(stage)
  if(inherits(container, "character")){
    container <- blob_containers(stage = stage)[[container]]
  }

  fileext <- tools::file_ext(name)
  tf <- tempfile(fileext = paste0(".", fileext))

  # wrapping to suppress printing of progress bar
  invisible(
    utils::capture.output(
      AzureStor::download_blob(
        container = container,
        src = name,
        dest = tf
      )
    )
  )

  switch(fileext,
    parquet = arrow::read_parquet(tf),
    geojson = sf::st_read(tf, quiet = TRUE),
    json = dplyr::as_tibble(jsonlite::read_json(tf, simplifyVector = TRUE)),
    csv = readr::read_csv(tf, col_types = readr::cols(), guess_max = 10000),
    xls = readxl::read_xls(tf, col_types = "guess"),
    xlsx = readxl::read_xlsx(tf, col_types = "guess")
  )
}
