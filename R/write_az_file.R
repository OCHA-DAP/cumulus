#' Write data frame to Microsoft Azure Data Storage
#'
#' A convenient file saver that saves the data frame to the specified
#' parquet file. Simply writes out the data frame based on the file extension and
#' uploads that to the MADS container using [AzureStor::upload_blob()].
#' Currently supports Apache Parquet, GeoJSON, COG, and CSV files.
#'
#' Files written out based on file type:
#'
#' * Apache Parquet: [arrow::write_parquet()]
#' * GeoJSON: [sf::st_write()]
#' * CSV: [readr::write_csv()]
#' * COG: [terra::write_raster()]
#'
#'
#' @param x Data frame, simple features, or spatRaster
#' @param name Name of the file to write, including prefix (`input/` or `output/`)
#'     and filetype `.parquet`.
#' @param blob Blob in the Azure storage to read from, either `prod`, `dev`, or `wfp`.
#'
#' @returns Nothing, but file is written to the `hdx-signals` bucket.
#'
#' @export
write_az_file <- function(
    x,
    name,
    container,
    service = "blob",
    stage = "dev",
    endpoint_template = Sys.getenv("DSCI_AZ_ENDPOINT"),
    sas_key = Sys.getenv("DSCI_AZ_SAS_DEV")
    ) {

  container <- azure_container(
    container = container,
    service = service,
    stage = stage,
    endpoint_template = endpoint_template,
    sas_key = sas_key
  )

  fileext <- tools::file_ext(name)
  tf <- tempfile(fileext = paste0(".", fileext))

  switch(fileext,
         csv = readr::write_csv(x = x, file = tf),
         parquet = arrow::write_parquet(x = x, sink = tf),
         json = jsonlite::write_json(x = x, path = tf),
         geojson = sf::st_write(obj = x, dsn = tf, quiet = TRUE),
         terra::writeRaster(x,
                            filename = tf,
                            filetype = "COG",
                            gdal = c("COMPRESS=DEFLATE",
                                     "SPARSE_OK=YES",
                                     "OVERVIEW_RESAMPLING=AVERAGE")
         )
  )

  # wrapping to suppress printing of progress bar
  invisible(
    utils::capture.output(
      AzureStor::upload_blob(
        container = container,
        src = tf,
        dest = name
      )
    )
  )
}
