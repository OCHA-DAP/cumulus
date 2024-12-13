#' Write data frame to Microsoft Azure Data Storage container
#'
#' A convenient file saver that saves the data frame to the specified
#' parquet file. Simply writes out the data frame based on the file extension and
#' uploads that to the MADS container using [AzureStor::upload_blob()].
#' Currently supports Apache Parquet, CSV, GeoJSON, and JSON files.
#'
#' Files written out based on file type:
#'
#' * Apache Parquet: [arrow::write_parquet()]
#' * CSV: [readr::write_csv()]
#' * GeoJSON: [sf::st_write()]
#' * JSON: [jsonlite::write_json()]
#'
#'
#' @param df Data frame or simple features to save out.
#' @param name Name of the file to write, including prefix (`input/` or `output/`)
#'     and filetype `.parquet`.
#' @param stage Store to access, either `dev` (default) or `prod`.
#' @param container Container name (`character`) or actual container class object to read from
#' @param progress_show show progress bar (`logical`) (default = TRUE)
#'
#' @returns Nothing, but file is written to selected container
#'
#' @export
blob_write <- function(df, name, stage = c("dev","prod"), container = "projects", progress_show = TRUE) {
  stage <- rlang::arg_match(stage)
  if(inherits(container, "character")){
    container <- blob_containers(stage = stage)[[container]]
  }

  fileext <- tools::file_ext(name)
  tf <- tempfile(fileext = paste0(".", fileext))


  switch(fileext,
         csv = readr::write_csv(x = df, file = tf, na = ""),
         parquet = arrow::write_parquet(x = df, sink = tf),
         json = jsonlite::write_json(x = df, path = tf),
         geojson = sf::st_write(obj = df, dsn = tf, quiet = TRUE)
  )
  opts <- options(azure_storage_progress_bar = progress_show)
  on.exit(options(opts))

  AzureStor::upload_blob(
    container = container,
    src = tf,
    dest = name
  )
}
