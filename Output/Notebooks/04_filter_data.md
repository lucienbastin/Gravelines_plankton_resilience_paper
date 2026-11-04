# Filter out plankton datasets
Lucien Bastin
2026-11-04

- [Libraries and data](#libraries-and-data)
  - [Libraries](#libraries)
  - [Data](#data)
- [Filter out samples (dates) with more than a certain amount of bad
  quality flags (S
  flags)](#filter-out-samples-dates-with-more-than-a-certain-amount-of-bad-quality-flags-s-flags)
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

# Filter out samples (dates) with more than a certain amount of bad quality flags (S flags)

S flags indicate that the recorded abundance of an organism (here, our
superior groups) in a sample may be inaccurate.

``` r
head(zooplankton_data)
```

| date       | superior_group | quality_flag |   abundance |
|:-----------|:---------------|:-------------|------------:|
| 1998-01-07 | Acartiidae     | S            | 150.4178273 |
| 1998-01-07 | Bryozoan_larva | S            |   5.5710306 |
| 1998-01-07 | Calanus        | S            |   2.7855153 |
| 1998-01-07 | Centropages    | A            |   0.1740947 |
| 1998-01-07 | Chaetognatha   | S            |   2.7855153 |
| 1998-01-07 | Cirriped_larva | S            |  25.0696379 |

The more S quality flags there are in a sample, the more we can question
the quality of the sample as a whole.

The following function discards samples where the percentage of S flags
exceeds a certain threshold.

N.B. sometimes there are both good and bad quality flags for the same
group in the same sample (because of the taxonomic grouping), so we
simplify by computing the total (sum) abundance of the group in that
case (if we keep the sample).

``` r
filter_bad_quality <- function(plankton_data, quality_threshold) {
  plankton_data |>
    group_by(date) |>
    filter((sum(quality_flag == "S") / n()) <= quality_threshold) |>
    select(-quality_flag) |>
    group_by(date, superior_group) |>
    summarize(across(abundance, sum)) |>
    ungroup()
}
```

Here we use a threshold of zero to remove all samples where there is at
least one bad quality flag (but it would also be possible to use a less
strict threshold such as 0.1 or 0.5 for instance).

``` r
zooplankton_data <- filter_bad_quality(zooplankton_data, 0)
phytoplankton_data <- filter_bad_quality(phytoplankton_data, 0)
```

# Filter out samples (dates) that contain only fish and decapod larvae

``` r
zooplankton_data |>
  filter(date == as.Date("2024-04-08"))
```

| date       | superior_group | abundance |
|:-----------|:---------------|----------:|
| 2024-04-08 | Decapod_larva  | 0.1368518 |
| 2024-04-08 | Fish_larva     | 1.3806606 |

Some zooplankton samples such as this one only contain fish larvae and
decapod larvae, so we can confidently remove them (they were likely not
supposed to be a part of this dataset).

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
