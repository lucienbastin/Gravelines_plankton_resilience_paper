# Filter out plankton datasets
Lucien Bastin
2026-11-03

- [Libraries and data](#libraries-and-data)
  - [Libraries](#libraries)
  - [Data](#data)
- [Filter out samples (dates) with too many bad quality flags (S
  flags)](#filter-out-samples-dates-with-too-many-bad-quality-flags-s-flags)
- [Filter out samples (dates) that contain only fish and decapod
  larvae](#filter-out-samples-dates-that-contain-only-fish-and-decapod-larvae)
- [Filter out superior groups that should be
  removed](#filter-out-superior-groups-that-should-be-removed)
- [Export data](#export-data)
- [Session info](#session-info)

# Libraries and data

## Libraries

``` r
library(conflicted)
library(dplyr)
library(here)
```

``` r
conflicted::conflict_scout()
```

    2 conflicts

    • `filter()`: dplyr and stats

    • `lag()`: dplyr and stats

``` r
conflicted::conflicts_prefer(dplyr::filter())
```

## Data

``` r
zooplankton_data <- read.csv(here("Data/Temp/zoo_grouped.csv"))
phytoplankton_data <- read.csv(here("Data/Temp/phyto_grouped.csv"))
```

# Filter out samples (dates) with too many bad quality flags (S flags)

N.B. sometimes there are both good and bad quality flags for the same
organism in the same sample, so we compute the total (sum) abundance of
the organism in that case.

``` r
filter_bad_quality <- function(plankton_data, quality_threshold) {
  plankton_data |>
    group_by(date) |>
    filter((sum(quality_flag == "S") / n()) < quality_threshold) |>
    select(-quality_flag) |>
    group_by(date, superior_group) |>
    summarize(across(abundance, sum)) |>
    ungroup()
}
```

``` r
zooplankton_data <- filter_bad_quality(zooplankton_data, 0.9)
phytoplankton_data <- filter_bad_quality(phytoplankton_data, 0.9)
```

# Filter out samples (dates) that contain only fish and decapod larvae

``` r
filter_fish_samples <- function(plankton_data) {
  plankton_data |>
    group_by(date) |>
    filter(!(all(superior_group %in% c("Fish_larva", "Decapod_larva")))) |>
    ungroup()
}
```

``` r
zooplankton_data <- filter_fish_samples(zooplankton_data)
phytoplankton_data <- filter_fish_samples(phytoplankton_data)
```

# Filter out superior groups that should be removed

For instance, benthic taxa. These have already been identified and
grouped into the “REMOVE” superior group.

``` r
zooplankton_data <- zooplankton_data |>
  filter(superior_group != "REMOVE")

phytoplankton_data <- phytoplankton_data |>
  filter(superior_group != "REMOVE")
```

# Export data

``` r
write.csv(zooplankton_data, here("Data/Temp/zoo_filtered.csv"), row.names = FALSE)
write.csv(phytoplankton_data, here("Data/Temp/phyto_filtered.csv"), row.names = FALSE)
```

# Session info

``` r
sessionInfo()
```

    R version 4.6.1 (2026-06-24)
    Platform: x86_64-redhat-linux-gnu
    Running under: Fedora Linux 44 (COSMIC)

    Matrix products: default
    BLAS/LAPACK: FlexiBLAS OPENBLAS-OPENMP;  LAPACK version 3.12.1

    locale:
     [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
     [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
     [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
     [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
     [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

    time zone: Europe/Paris
    tzcode source: system (glibc)

    attached base packages:
    [1] stats     graphics  grDevices datasets  utils     methods   base     

    other attached packages:
    [1] here_1.0.2       dplyr_1.2.1      conflicted_1.2.0

    loaded via a namespace (and not attached):
     [1] vctrs_0.7.3      cli_3.6.6        knitr_1.52       rlang_1.3.0     
     [5] xfun_0.62        otel_0.2.0       renv_1.3.1       generics_0.1.4  
     [9] jsonlite_2.0.0   glue_1.8.1       rprojroot_2.1.1  htmltools_0.5.9 
    [13] rmarkdown_2.32   evaluate_1.0.5   tibble_3.3.1     fastmap_1.2.0   
    [17] yaml_2.3.12      lifecycle_1.0.5  memoise_2.0.1    compiler_4.6.1  
    [21] pkgconfig_2.0.3  digest_0.6.39    R6_2.6.1         tidyselect_1.2.1
    [25] pillar_1.11.1    magrittr_2.0.5   withr_3.0.3      tools_4.6.1     
    [29] cachem_1.1.0    
