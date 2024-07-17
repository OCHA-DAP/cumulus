#' Return blob container
#'
#' Create endpoint URL to access Azure blob or file storage on either the
#' `dev` or `prod` stage from specified storage account
#' @param containers `character` vector containing the name of container to
#'     load (default, "global", "projects")
#' @param sas_key Shared access signature key to access the storage account or
#'    blob. Default is set to use  dev stage sas key via an a env var named
#'    "DSCI_AZ_SAS_DEV"
#' @param service Service to access, either `blob` (default) or `file.`
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#' @param storage_account Storage account to access. Default is `imb0chd0`
#' @examples
#' # load project containers
#' pc <- load_containers(containers= "projects")
#' AzureStor::list_blobs(
#'   container = pc$PROJECTS_CONT,
#'   dir = "ds-contingency-pak-floods"
#' )
#'
#' # You can also list as many containers as you want.
#' pc <- load_containers(containers= c("global","projects"))
#' AzureStor::list_blobs(
#'   container = pc$GLOBAL_CONT,
#'   dir = "raster/cogs"
#' )
#' @export
load_containers <- function(
    containers = c("global","projects"),
    sas_key= Sys.getenv("DSCI_AZ_SAS_DEV"),
    service = c("blob", "file"),
    stage = c("dev", "prod"),
    storage_account = "imb0chd0"
){

  service <- rlang::arg_match(service)
  stage <- rlang::arg_match(stage)
  storae_account <- rlang::arg_match(storage_account)

  es <- azure_endpoint_url(
    service = service,
    stage = stage,
    storage_account = storage_account
  )

  se <- AzureStor::storage_endpoint(es, sas = sas_key)

  # storage container

  item_labels <- paste0(toupper(containers),"_CONT")
  containers <- rlang:::set_names(containers, item_labels)

  l_containers<- purrr::map(containers, \(container_name){
    AzureStor::storage_container(se, container_name)

  })
  l_containers
}

#' Create the endpoint URL
#'
#' Create endpoint URL to access Azure blob or file storage on either the
#' `dev` or `prod` stage from specified storage account
#'
#' @param service Service to access, either `blob` (default) or `file.`
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#' @param storage_account Storage account to access. Default is `imb0chd0`
azure_endpoint_url <- function(
    service = c("blob", "file"),
    stage = c("dev", "prod"),
    storage_account = "imb0chd0"
    ) {

  blob_url <- "https://{storage_account}{stage}.{service}.core.windows.net/"
  service <- rlang::arg_match(service)
  stage <- rlang::arg_match(stage)
  storae_account <- rlang::arg_match(storage_account)
  endpoint <- glue::glue(blob_url)
  return(endpoint)
}


