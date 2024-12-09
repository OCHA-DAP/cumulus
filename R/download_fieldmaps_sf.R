#' Download and load adm0 boundaries
#'
#' Downloads the adm0 shapefile from fieldmaps, because it sources OCHA boundaries
#' but standardizes column names. Then it loads the file in using `sf::st_read()`.
#'
#' @param iso3 ISO3 code
#' @export
download_fieldmaps_sf <- function(iso3,layer) {
  iso3 <- tolower(iso3)
  download_shapefile(
    url = glue::glue("https://data.fieldmaps.io/cod/originals/{iso3}.gpkg.zip"),
    layer= layer
  )
}

#' Download shapefile and read
#'
#' Download shapefile to temp file, unzipping zip files if necessary. Deals with zipped
#' files like geojson or gpkg files as well as shapefiles, when the unzipping
#' returns a folder. The file is then read with `sf::st_read()`.
#'
#' @param url URL to download
#' @param layer Layer to read
#'
#' @returns sf object
#'
#' @export
download_shapefile <- function(url, layer = NULL) {
  if (stringr::str_ends(url, ".zip")) {
    utils::download.file(
      url = url,
      destfile = zf <- tempfile(fileext = ".zip"),
      quiet = TRUE
    )

    utils::unzip(
      zipfile = zf,
      exdir = td <- tempdir()
    )

    # if the file extension is just `.zip`, we return the temp dir alone
    # because that works for shapefiles, otherwise we return the file unzipped
    fn <- stringr::str_remove(basename(url), ".zip")
    if (tools::file_ext(fn) == "") {
      fn <- td
    } else {
      fn <- file.path(td, fn)
    }
  } else {
    utils::download.file(
      url = url,
      destfile = fn <- tempfile(fileext = paste0(".", tools::file_ext(url))),
      quiet = TRUE
    )
  }

  if (!is.null(layer)) {
    purrr::map(
      purrr::set_names(layer,layer),
      \(lyr_tmp) {
        sf::st_read(
          fn,
          layer = lyr_tmp,
          quiet = TRUE
        )
      }
    )
  } else {
    cat("No layer argument supplied. Therefore reading the first of all the layers below:")

    print(sf::st_layers(fn))

    sf::st_read(
      fn,
      quiet = TRUE
    )
  }
}
