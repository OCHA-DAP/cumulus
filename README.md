
# cumulus

<!-- badges: start -->
<!-- badges: end -->

The goal of cumulus is to simplify common CHD workflows,by providing utility functions for accessing our cloud infrastructure and other common data resources

## Installation

You can install the development version of cumulus from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("OCHA-DAP/cumulus")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(cumulus)
## basic example code
```

```r
gdf_adm1 <- download_fieldmaps_sf("som","som_adm1")
```

```{r}
containers <- blob_containers()
AzureStor::list_blobs(
   container = containers$projects,
   dir = "ds-contingency-pak-floods"
 )
```

With convenience access to containers above could easily use `{AzureStor}` for flexible reading/downloading of files, but we've provided some convenient wrappers 
for reading some basic file types

```{r}
df <- blob_read(name = "ds-aa-eth-drought/exploration/eth_admpop_2023.xlsx", container = "projects",stage= "dev")
```

`blob_write()` is now available and works almost exactly as `blob_read()`. Will add an example soon.

