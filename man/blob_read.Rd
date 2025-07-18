% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/blob_read.R
\name{blob_read}
\alias{blob_read}
\title{Read a Parquet file stored in Microsoft Azure Data Storage container}
\usage{
blob_read(
  name,
  stage = c("dev", "prod"),
  container = "projects",
  progress_show = TRUE,
  return_path_only = FALSE,
  write_access = FALSE,
  ...
)
}
\arguments{
\item{name}{Name of the file to read, including directory prefixes
(`input/` or `output/`) and file extension, such as `.parquet`.}

\item{stage}{Store to access, either `dev` (default) or `prod`.}

\item{container}{Container name (`character`) or actual container class
object to read from}

\item{progress_show}{show progress bar (`logical`) (default = TRUE)}

\item{return_path_only}{logical if FALSE (default) tries to read the data.
If TRUE returns only the downloaded file path}

\item{write_access}{`logical` indicating whether to use the write access SAS key (default = FALSE)}

\item{...}{Additional arguments passed to the respective reader functions:
- For `.parquet` files: Passed to `arrow::read_parquet()`.
- For `.geojson` files: Passed to `sf::st_read()`.
- For `.json` files: Passed to `jsonlite::read_json()`.
- For `.csv` files: Passed to `readr::read_csv()`.
- For `.xls` files: Passed to `readxl::read_xls()`.
- For `.xlsx` files: Passed to `readxl::read_xlsx()`.
- For `.rds` files: Passed to `readr::read_rds()`.}
}
\value{
Data frame.
}
\description{
Reads a file from the `hdx-signals` container.
The file is read based on its prefix in `name`. Currently, the only support is for
Apache Parquet, CSV, GeoJSON and JSON files, but other support can be added if necessary.
}
\details{
Function parsing is done based on file type:

* Apache Parquet: [arrow::write_parquet()].
* CSV: [readr::read_csv()]
* Excel: [readxl::read_excel()]
* GeoJSON: [sf::st_read()]
* JSON: [jsonlite::read_json()]
* rds: [readr::read_rds()]
}
\examples{
df <- blob_read(
    name = "ds-aa-eth-drought/exploration/eth_admpop_2023.xlsx",
    stage = "dev",
    container = "projects",
    progress_show = TRUE
)

}
