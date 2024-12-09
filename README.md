
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
containers <- load_containers()
AzureStor::list_blobs(
   container = containers$projects,
   dir = "ds-contingency-pak-floods"
 )
```
