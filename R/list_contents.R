#' list container contents or contents within "sub-directory" of container
#'
#' @param container `character` container name
#' @param dir ``character` 	For list_blobs, a string naming the directory.
#'      Note that blob storage does not support real directories; this argument
#'      simply filters the result to return only blobs whose names start with
#'      the given value.
#' @param stage `character` stage of the container (default = dev)
#' @param sas `character` SAS token
#'
#' @return `data.frame` of container/"sub-directory" contents
#' @export
#'
#' @examples
#' library(cumulus)
#' list_contents("global", "raster/cogs")
list_contents <-  function(
  container,
  dir,
  stage = "dev",
  sas = Sys.getenv("DSCI_AZ_SAS_DEV")

){
  # endpoint_string
  es <- azure_endpoint_url(
    service = "blob",
    stage = "dev",

    # toying with the idea of just hardcoding and requiring user to
    # name them the same.
    endpoint_template = Sys.getenv("DSCI_AZ_ENDPOINT")
  )
  # storage endpoint
  se <- AzureStor::storage_endpoint(es, sas = sas )

  # storage container
  sc <-  AzureStor::storage_container(se, container)

  AzureStor::list_blobs(sc,dir = dir)

}


