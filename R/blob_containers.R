#' Return blob containers
#'
#' Create endpoint URL to access Azure blob or file storage on either the
#' `dev` or `prod` stage from specified storage account
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#' @param sas Shared access signature key to access the storage account or
#'    blob. Default is set to use  dev stage sas key via an a env var named
#'    "DSCI_AZ_SAS_DEV"
#' @param service Service to access, either `blob` (default) or `file.`
#' @examples
#' # load project containers
#' containers <- blob_containers()
#' AzureStor::list_blobs(
#'   container = containers$projects,
#'   dir = "ds-contingency-pak-floods"
#' )
#'
#' # You can also list as many containers as you want.
#' containers = blob_containers()
#'
#' AzureStor::list_blobs(
#'   container = containers$global,
#'   dir = "raster/cogs"
#' )
#' @export
blob_containers <- function(
    stage = c("dev", "prod"),
    sas = Sys.getenv("DSCI_AZ_SAS_DEV"),
    service = c("blob", "file")
    ) {

  ep_url <- azure_endpoint_url(
    stage = stage,
    service = service
  )
  be <- AzureStor::blob_endpoint(ep_url, sas = sas)

  AzureStor::list_blob_containers(be)
}

#' Create the endpoint URL
#'
#' Create endpoint URL to access Azure blob or file storage on either the
#' `dev` or `prod` stage from specified storage accountd
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#' @param service Service to access, either `blob` (default) or `file.`
azure_endpoint_url <- function(
    stage = c("dev", "prod"),
    service = c("blob", "file")
    ) {
  stage <- rlang::arg_match(stage)
  service <- rlang::arg_match(service)
  blob_url <- "https://imb0chd0{stage}.{service}.core.windows.net/"
  endpoint <- glue::glue(blob_url)
  return(endpoint)
}


