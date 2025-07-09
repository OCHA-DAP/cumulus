#' Return blob containers
#'
#' Create endpoint URL to access Azure blob or file storage on either the
#' `dev` or `prod` stage from specified storage account
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#' @param sas Shared access signature key to access the storage account or
#'    blob (defaults to NULL) and is automatically set based on stage based on
#'    our current SAS key nomenclature
#' @param write_access `logical` indicating whether to use the write access SAS key
#' @param service Service to access, either `blob` (default) or `file.`
#' @return list of blob container class objects
#' @examples
#' # load project containers
#' containers <- blob_containers()
#' AzureStor::list_blobs(
#'   container = containers$projects,
#'   dir = "ds-contingency-pak-floods"
#' )
#'
#' # You can also list as many containers as you want.
#' containers <- blob_containers()
#'
#' AzureStor::list_blobs(
#'   container = containers$global,
#'   dir = "raster/cogs"
#' )
#' @export
blob_containers <- function(
    stage = c("dev", "prod"),
    sas = NULL,
    write_access = TRUE,
    service = c("blob", "file")) {
  stage <- rlang::arg_match(stage)

  if (is.null(sas)) {
    sas <- get_sas_key(stage, write_access = write_access)
  }
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
    service = c("blob", "file")) {
  stage <- rlang::arg_match(stage)
  service <- rlang::arg_match(service)
  blob_url <- "https://imb0chd0{stage}.{service}.core.windows.net/"
  endpoint <- glue::glue(blob_url)
  return(endpoint)
}


#' get_sas_key
#' Convenience function get SAS key based on stage.
#' TODO: will eventually creat some credential registration step to make this
#' more flexible, but this will work well internally for now
#' @param stage Store to access, either `prod` (default) or `dev`. `dev`
#' @param key_syntax_v `integer` indicating which version of key env var naming
#'   to use. Default is set to 2 (this is a bit of hack for now)
#
#

#' @return SAS key based on stage

get_sas_key <- function(
    stage,
    key_syntax_v = 3,
    write_access = TRUE) {

  stage_upper <- toupper(stage)
  if(key_syntax_v == 1){
    key <- switch(stage,
                  dev = Sys.getenv("DSCI_AZ_SAS_DEV"),
                  prod = Sys.getenv("DSCI_AZ_SAS_PROD")
    )
  }
  if(key_syntax_v==2){
    key <-  switch(stage,
                   dev = Sys.getenv("DS_AZ_BLOB_DEV_SAS"),
                   prod = Sys.getenv("DS_AZ_BLOB_PROD_SAS_WRITE")
    )
  }
  if(key_syntax_v==3){
    if(!write_access){
      key <- Sys.getenv(glue::glue("DSCI_AZ_BLOB_{stage_upper}_SAS"))
    }

    if(write_access){
      key <- Sys.getenv(glue::glue("DSCI_AZ_BLOB_{stage_upper}_SAS_WRITE"))

      assertthat::assert_that(
        (key!=""),
        msg = "No write access to production blob storage. Please set the DSCI_AZ_BLOB_PROD_SAS_WRITE environment variable."
      )
    }


  }
  return(key)

}
