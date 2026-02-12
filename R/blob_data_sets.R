
#' Load EM-DAT data from blob storage
#'
#' @param stage Store to access, either `"dev"` (default) or `"prod"`.
#' @param filename Path to the file in the container
#'   (default: `"emdat/processed/emdat_all.parquet"`).
#'
#' @returns Data frame of EM-DAT data.
#' @examples
#' \dontrun{
#' df_emdat <- load_emdat_from_blob()
#' }
#' @export
load_emdat_from_blob <- function(
    filename = "emdat/processed/emdat_all.parquet",
    stage = "dev",
    container = "global",
    progress_show = TRUE
    ) {
  blob_read(
    name = filename,
    stage = stage,
    container = container,
    progress_show = progress_show
  )
}
