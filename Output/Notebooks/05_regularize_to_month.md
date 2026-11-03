# Regularize all datasets to have a monthly temporal resolution
Lucien Bastin
2026-11-03

- [Libraries and data](#libraries-and-data)
  - [Libraries](#libraries)
  - [Data](#data)
- [Check for irregularities in the time
  series](#check-for-irregularities-in-the-time-series)
- [Compute monthly means](#compute-monthly-means)
- [Impute missing values](#impute-missing-values)
- [Export data](#export-data)
- [Session info](#session-info)

# Libraries and data

## Libraries

``` r
library(conflicted)
library(dplyr)
library(ggplot2)
library(ggTimeSeries)
library(here)
library(lubridate)
library(pastecs)
library(tidyr)
library(vegan)
```

``` r
conflicted::conflict_scout()
```

    5 conflicts

    • `extract()`: tidyr and pastecs

    • `filter()`: dplyr and stats

    • `first()`: pastecs and dplyr

    • `lag()`: dplyr and stats

    • `last()`: pastecs and dplyr

## Data

``` r
zooplankton_data <- read.csv(here("Data/Temp/zoo_filtered.csv"))
phytoplankton_data <- read.csv(here("Data/Temp/phyto_filtered.csv"))
```

``` r
zooplankton_data$date <- as.Date(zooplankton_data$date)
```

# Check for irregularities in the time series

``` r
zooplankton_sampling <- data.frame(
  date = unique(zooplankton_data$date),
  sampled = TRUE
)
```

``` r
head(zooplankton_sampling)
```

| date       | sampled |
|:-----------|:--------|
| 1998-01-09 | TRUE    |
| 1998-02-10 | TRUE    |
| 1998-04-22 | TRUE    |
| 1998-05-20 | TRUE    |
| 1998-06-04 | TRUE    |
| 1998-07-01 | TRUE    |

``` r
zooplankton_sampling_calendar <- data.frame(
  date = seq(as.Date("1998-01-01"), as.Date("2024-12-31"), "days")
) |>
  left_join(zooplankton_sampling) |>
  replace_na(list(sampled = FALSE))
```

``` r
head(zooplankton_sampling_calendar, n = 10)
```

| date       | sampled |
|:-----------|:--------|
| 1998-01-01 | FALSE   |
| 1998-01-02 | FALSE   |
| 1998-01-03 | FALSE   |
| 1998-01-04 | FALSE   |
| 1998-01-05 | FALSE   |
| 1998-01-06 | FALSE   |
| 1998-01-07 | FALSE   |
| 1998-01-08 | FALSE   |
| 1998-01-09 | TRUE    |
| 1998-01-10 | FALSE   |

``` r
calendar_palette <- c(
  "FALSE" = "gray90",
  "TRUE" = "#ff2222"
)

ggplot_calendar_heatmap(
  zooplankton_sampling_calendar,
  'date',
  'sampled',
  monthBorderSize = 0.75
) +
  facet_wrap(~Year, ncol = 2) +
  scale_fill_manual(
    values = calendar_palette,
    breaks = c("none", "sampled")
  ) +
  labs(x = "Month", y = "Day", fill = "Sampling") +
  theme_test()
```

![Calendar of the zooplankton sampling scheme at Gravelines from 1998 to
2025](05_regularize_to_month_files/figure-commonmark/unnamed-chunk-9-1.png)

The sampling scheme for zooplankton is not perfectly regular, but it is
close to a monthly sampling scheme. We will therefore use a monthly
teporal resolution for this project (for zooplankton, phytoplankton and
the environmental variables).

Some months have more than one sample, so we need to compute the mean
for each month.

Some months have no sample at all. This is more problematic because we
need to impute a value to fill in the blanks in order to conserve
regular data.

# Compute monthly means

``` r
compute_monthly_means <- function(data) {
  data_wide <- data |>
    pivot_wider(
      names_from = superior_group,
      values_from = abundance,
      values_fill = 0
    )

  data_wide |>
    # select(-date) |>
    # decostand("hellinger") |>
    # mutate(date = data_wide$date) |>
    group_by(
      year = year(date),
      month = month(date)
    ) |>
    summarize(across(-date, mean)) |>
    ungroup()
}
```

``` r
zooplankton_monthly_mean <- compute_monthly_means(zooplankton_data)
phytoplankton_monthly_mean <- compute_monthly_means(phytoplankton_data)
```

``` r
head(zooplankton_monthly_mean)
```

| year | month | Acartiidae | Bryozoan_larva | Calanus | Centropages | Chaetognatha | Cirriped_larva | Cyclopoida | Decapod_larva | Euterpina | Gasteropod_larva | Oikopleura | Paracalanus | Polychaete_larva | Pseudocalanus | Temora | Jellyfish | Pleurobrachia | Bivalvia_larva | Echinoderm_larva | Large_Ctenophora | Labidocera | Corycaeidae | Ascidiacea | Clausidiidae | Cyclopinoides | Stephos | Copepoda | Siphonostomatoida | Monstrilloida | Branchiopoda | Parapontella | Oithona | Doliolum | Isias | Fritillaria | Oncaeidae | Ostracoda | Fish_larva | Longipedia | Eurytemora | Pseudodiaptomus | Harpacticus | Platycopia |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1998 | 1 | 15.04 | 0.56 | 0.28 | 4.46 | 0.28 | 2.51 | 9.75 | 0.28 | 14.48 | 2.51 | 7.24 | 3.34 | 23.40 | 11.98 | 26.18 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998 | 2 | 12.22 | 0.37 | 0.37 | 2.59 | 0.00 | 801.85 | 1.48 | 0.37 | 0.37 | 0.00 | 11.48 | 0.37 | 15.93 | 5.56 | 22.22 | 1.11 | 0.37 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998 | 4 | 13.51 | 0.00 | 0.44 | 1.74 | 0.00 | 0.88 | 0.65 | 0.65 | 1.31 | 0.87 | 9.15 | 0.44 | 15.69 | 3.49 | 28.10 | 0.66 | 0.54 | 1.09 | 1.96 | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998 | 5 | 94.58 | 0.00 | 1.15 | 56.52 | 0.00 | 3.46 | 1.15 | 1.16 | 2.31 | 0.00 | 99.19 | 2.31 | 12.68 | 28.84 | 628.60 | 1.61 | 4.27 | 1.15 | 89.97 | 0.35 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998 | 6 | 200.90 | 0.00 | 1.50 | 16.49 | 0.30 | 11.99 | 0.45 | 1.65 | 17.99 | 6.00 | 9.00 | 0.00 | 50.97 | 308.85 | 278.86 | 64.62 | 1.65 | 0.00 | 16.49 | 0.15 | 0.15 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998 | 7 | 521.14 | 0.11 | 0.00 | 1.71 | 0.34 | 4.57 | 0.00 | 0.67 | 13.94 | 0.69 | 2.97 | 0.11 | 12.91 | 0.11 | 8.91 | 0.34 | 0.00 | 0.11 | 0.00 | 0.23 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

# Impute missing values

The `pastecs` package allows to generate missing values from the values
aroud the missing data point.

``` r
regularize_monthly <- function(data) {
  data_prepared <- data |>
    mutate(
      total_month = month + (year - min(year)) * 12,
      .before = everything()
    ) |>
    select(-c(year, month))

  regularized_timeseries <- regul(
    data_prepared$total_month,
    data_prepared[-1],
    n = max(data_prepared$total_month),
    units = "months",
    frequency = 1,
    methods = "constant"
  )

  regularized_data <- data.frame(total_month = regularized_timeseries$x) |>
    cbind(pastecs::extract(
      regularized_timeseries,
      series = colnames(data_prepared[-1])
    ))

  regularized_data |>
    mutate(
      date = min(floor_date(zooplankton_data$date, "month")) +
        months(total_month - 1),
      .before = everything()
    ) |>
    select(-total_month)
}
```

``` r
zooplankton_regularized <- regularize_monthly(zooplankton_monthly_mean)
phytoplankton_regularized <- regularize_monthly(phytoplankton_monthly_mean)
```

``` r
head(zooplankton_regularized)
```

| date | Acartiidae | Bryozoan_larva | Calanus | Centropages | Chaetognatha | Cirriped_larva | Cyclopoida | Decapod_larva | Euterpina | Gasteropod_larva | Oikopleura | Paracalanus | Polychaete_larva | Pseudocalanus | Temora | Jellyfish | Pleurobrachia | Bivalvia_larva | Echinoderm_larva | Large_Ctenophora | Labidocera | Corycaeidae | Ascidiacea | Clausidiidae | Cyclopinoides | Stephos | Copepoda | Siphonostomatoida | Monstrilloida | Branchiopoda | Parapontella | Oithona | Doliolum | Isias | Fritillaria | Oncaeidae | Ostracoda | Fish_larva | Longipedia | Eurytemora | Pseudodiaptomus | Harpacticus | Platycopia |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1998-01-01 | 15.04 | 0.56 | 0.28 | 4.46 | 0.28 | 2.51 | 9.75 | 0.28 | 14.48 | 2.51 | 7.24 | 3.34 | 23.40 | 11.98 | 26.18 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-02-01 | 12.22 | 0.37 | 0.37 | 2.59 | 0.00 | 801.85 | 1.48 | 0.37 | 0.37 | 0.00 | 11.48 | 0.37 | 15.93 | 5.56 | 22.22 | 1.11 | 0.37 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-03-01 | 12.22 | 0.37 | 0.37 | 2.59 | 0.00 | 801.85 | 1.48 | 0.37 | 0.37 | 0.00 | 11.48 | 0.37 | 15.93 | 5.56 | 22.22 | 1.11 | 0.37 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-04-01 | 13.51 | 0.00 | 0.44 | 1.74 | 0.00 | 0.88 | 0.65 | 0.65 | 1.31 | 0.87 | 9.15 | 0.44 | 15.69 | 3.49 | 28.10 | 0.66 | 0.54 | 1.09 | 1.96 | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-05-01 | 94.58 | 0.00 | 1.15 | 56.52 | 0.00 | 3.46 | 1.15 | 1.16 | 2.31 | 0.00 | 99.19 | 2.31 | 12.68 | 28.84 | 628.60 | 1.61 | 4.27 | 1.15 | 89.97 | 0.35 | 0.00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-06-01 | 200.90 | 0.00 | 1.50 | 16.49 | 0.30 | 11.99 | 0.45 | 1.65 | 17.99 | 6.00 | 9.00 | 0.00 | 50.97 | 308.85 | 278.86 | 64.62 | 1.65 | 0.00 | 16.49 | 0.15 | 0.15 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

# Export data

``` r
write.csv(
  zooplankton_regularized,
  here("Data/Temp/zoo_regularized.csv"),
  row.names = FALSE
)

write.csv(
  phytoplankton_regularized,
  here("Data/Temp/phyto_regularized.csv"),
  row.names = FALSE
)
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
     [1] vegan_2.7-6        permute_0.9-10     tidyr_1.3.2        pastecs_1.4.2     
     [5] lubridate_1.9.5    here_1.0.2         ggTimeSeries_1.0.1 ggplot2_4.0.3     
     [9] dplyr_1.2.1        conflicted_1.2.0  

    loaded via a namespace (and not attached):
     [1] generics_0.1.4      renv_1.3.1          lattice_0.22-9     
     [4] digest_0.6.39       magrittr_2.0.5      evaluate_1.0.5     
     [7] grid_4.6.1          timechange_0.4.0    RColorBrewer_1.1-3 
    [10] fastmap_1.2.0       Matrix_1.7-5        rprojroot_2.1.1    
    [13] jsonlite_2.0.0      mgcv_1.9-4          purrr_1.2.2        
    [16] scales_1.4.0        cli_3.6.6           rlang_1.3.0        
    [19] splines_4.6.1       withr_3.0.3         cachem_1.1.0       
    [22] yaml_2.3.12         otel_0.2.0          tools_4.6.1        
    [25] parallel_4.6.1      memoise_2.0.1       boot_1.3-32        
    [28] vctrs_0.7.3         R6_2.6.1            lifecycle_1.0.5    
    [31] MASS_7.3-65         cluster_2.1.8.2     pkgconfig_2.0.3    
    [34] pillar_1.11.1       gtable_0.3.6        data.table_1.18.6.1
    [37] glue_1.8.1          xfun_0.62           tibble_3.3.1       
    [40] tidyselect_1.2.1    knitr_1.52          farver_2.1.2       
    [43] htmltools_0.5.9     nlme_3.1-169        rmarkdown_2.32     
    [46] compiler_4.6.1      S7_0.2.2           

Document rendered using Quarto version 1.10.18.
