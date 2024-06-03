#' Read a Parquet file stored on Microsoft Azure Data Storage blob or file storage
#'
#' Reads a file from the Azure Storage
#' The file is read based on its prefix. Currently, the only support is for
#' Apache Parquet, GeoJSON, CSV, and XLSX/XLS files, but other support will be added as necessary
#'
#' Function parsing is done based on file type:
#'
#' * Apache Parquet: [arrow::write_parquet()].
#' * GeoJSON: [sf::st_read()]
#' * CSV: [readr::read_csv()]
#' * XLSX: [readxl::read_excel()]
#'
#' @param file_path Name of the file to read, including directory prefixes (`input/` or `output/`)
#'     and file extension, such as `.parquet`.
#' @param sheet `character` name of sheet (tab) if file is excel format (.xlsx). If NULL (default) it reads
#'     the first tab or ignores sheet argument
#' @param container `character` container name in the Azure storage.
#' @param sas_key `character` SAS key. Default set to env var naming convention used for hdx-signals
#' @param service service in the Azure storage to read from, either "blob" (default) or "file"
#' @param stage Stage in the Azure storage to read from, either "blob" (default) or "file"
#'
#'
#' @returns Data frame.
#'
#' @export
read_az_file <- function(
    file_path,
    sheet = NULL,
    container,
    sas_key = Sys.getenv("DSCI_AZ_SAS_DEV"),
    service = "blob",
    stage = "dev"
) {

  container <- azure_container(
    container = container,
    service =service,
    stage = stage,
    endpoint = endpoint,
    sas_key = sas_key
  )

  fileext <- tools::file_ext(file_path)
  tf <- tempfile(fileext = paste0(".", fileext))

  # wrapping to suppress printing of progress bar
  invisible(
    capture.output(
      AzureStor::download_blob(
        container = container,
        src = file_path,
        dest = tf
      )
    )
  )

  switch(
    fileext,
    parquet = arrow::read_parquet(tf),
    geojson = sf::st_read(tf, quiet = TRUE),
    csv = readr::read_csv(tf, col_types = readr::cols()),
    xlsx = readxl::read_excel(tf, sheet = sheet)
  )

}


#' Connect to azure container
#'
#' @param container `character` container name in the Azure storage.
#' @param service service in the Azure storage to read from, either "blob" (default) or "file"
#' @param stage Stage in the Azure storage to read from, either "blob" (default) or "file"
#' @param sas_key `character` SAS key. Default set to env var naming convention used for hdx-signals
#' @param endpoint `character` endpoint url constructued up with `{stage}` and `{service}` braced
#'     placeholders which get filled by the `azure_endpoint_url()` function.
#'
#' @return blob_container
#' @export
#'
#' @examples
#' library(cumulus)
#' azure_container(container = "projects")

azure_container <-  function(
    container,
    service = c("blob", "file"),
    stage = c("prod", "dev"),
    endpoint = Sys.getenv("DSCI_AZ_ENDPOINT"),
    sas_key = Sys.getenv("DSCI_AZ_SAS_DEV")
) {

  blob_endpoint <- AzureStor::blob_endpoint(
    endpoint = azure_endpoint_url(service = service, stage = stage),
    sas = sas_key
  )

  AzureStor::blob_container(
    endpoint = blob_endpoint,
    name = container
  )

}

azure_endpoint_url <- function(
    service = c("blob", "file"),
    stage = c("prod", "dev"),
    endpoint = Sys.getenv("DSCI_AZ_ENDPOINT")
) {
  service <- rlang::arg_match(service)
  stage <- rlang::arg_match(stage)
  endpoint <- glue::glue(endpoint)
  return(endpoint)
}
