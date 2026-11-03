# Deseasonalize timeseries to focus on long-term changes
Lucien Bastin
2026-11-03

- [Libraries and data](#libraries-and-data)
  - [Libraries](#libraries)
  - [Data](#data)
- [Asymmetric moving average](#asymmetric-moving-average)
- [Export Data](#export-data)
- [Session info](#session-info)

# Libraries and data

## Libraries

``` r
library(conflicted)
library(dplyr)
library(here)
library(vegan)
```

``` r
conflicted::conflict_scout()
```

    2 conflicts

    • `filter()`: dplyr and stats

    • `lag()`: dplyr and stats

## Data

``` r
zooplankton_data <- read.csv(here("Data/Temp/zoo_regularized.csv"))
phytoplankton_data <- read.csv(here("Data/Temp/phyto_regularized.csv"))
```

``` r
zooplankton_data$date = as.Date(zooplankton_data$date)
phytoplankton_data$date = as.Date(phytoplankton_data$date)
```

# Asymmetric moving average

The deseasonalization method used here is a moving average : all
variables are meaned within a moving window of 12 months that slides
across the whole timeseries.

The method is called “asymmetric” because for each month, it takes a
takes in a different number of months before and after in the window
(for instance, 5 months before + the current month + 6 months after = 12
months total).

``` r
asymmetric_moving_average <- function(x, n_left, n_right) {
  out <- rep(NA, n_left)

  for (i in 1:(length(x) - (n_left + n_right))) {
    start <- i
    end <- i + n_left + n_right

    out <- c(out, mean(x[start:end]))
  }

  c(out, rep(NA, n_right))
}
```

``` r
zooplankton_deseasonalized <- zooplankton_data |>
  select(-date) |>
  decostand("hellinger") |>
  mutate(date = zooplankton_data$date, .before = everything()) |>
  mutate(across(-date, ~ asymmetric_moving_average(., 6, 5)))

phytoplankton_deseasonalized <- phytoplankton_data |>
  select(-date) |>
  # mutate(across(everything(), log1p)) |>
  decostand("hellinger") |>
  mutate(date = phytoplankton_data$date, .before = everything()) |>
  mutate(across(-date, ~ asymmetric_moving_average(., 6, 5)))
```

``` r
head(zooplankton_deseasonalized, n = 10)
```

| date | Acartiidae | Bryozoan_larva | Calanus | Centropages | Chaetognatha | Cirriped_larva | Cyclopoida | Decapod_larva | Euterpina | Gasteropod_larva | Oikopleura | Paracalanus | Polychaete_larva | Pseudocalanus | Temora | Jellyfish | Pleurobrachia | Bivalvia_larva | Echinoderm_larva | Large_Ctenophora | Labidocera | Corycaeidae | Ascidiacea | Clausidiidae | Cyclopinoides | Stephos | Copepoda | Siphonostomatoida | Monstrilloida | Branchiopoda | Parapontella | Oithona | Doliolum | Isias | Fritillaria | Oncaeidae | Ostracoda | Fish_larva | Longipedia | Eurytemora | Pseudodiaptomus | Harpacticus | Platycopia |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1998-01-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-02-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-03-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-04-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-05-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-06-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-07-01 | 0.4323094 | 0.0640320 | 0.0261881 | 0.1747478 | 0.0736859 | 0.2795870 | 0.0533452 | 0.0498413 | 0.2604139 | 0.0614174 | 0.1778938 | 0.0840348 | 0.2080991 | 0.1691410 | 0.4014756 | 0.0473486 | 0.0243513 | 0.0210192 | 0.0598032 | 0.0042391 | 0.0010268 | 0.0106638 | 0.0098778 | 0.0434721 | 0.0104899 | 0.0039099 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-08-01 | 0.4418646 | 0.0583928 | 0.0249771 | 0.1825216 | 0.0735543 | 0.2774929 | 0.0365347 | 0.0486304 | 0.2758465 | 0.0567114 | 0.1658137 | 0.0730394 | 0.1915719 | 0.1717506 | 0.3952812 | 0.0473486 | 0.0338254 | 0.0248751 | 0.0598032 | 0.0042391 | 0.0010268 | 0.0253934 | 0.0098778 | 0.0495913 | 0.0104899 | 0.0066864 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-09-01 | 0.4708057 | 0.0566808 | 0.0260417 | 0.2016802 | 0.0774102 | 0.2076391 | 0.0398305 | 0.0496950 | 0.3182423 | 0.0639442 | 0.1644739 | 0.0741040 | 0.2002641 | 0.1938063 | 0.4143771 | 0.0443833 | 0.0415875 | 0.0287310 | 0.0598032 | 0.0042391 | 0.0010268 | 0.0401230 | 0.0098778 | 0.0557106 | 0.0104899 | 0.0094630 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-10-01 | 0.4997467 | 0.0549688 | 0.0271063 | 0.2208388 | 0.0812661 | 0.1377854 | 0.0431262 | 0.0507595 | 0.3606382 | 0.0711770 | 0.1631342 | 0.0751685 | 0.2089563 | 0.2158620 | 0.4334731 | 0.0414181 | 0.0493496 | 0.0325869 | 0.0598032 | 0.0042391 | 0.0010268 | 0.0548527 | 0.0098778 | 0.0618298 | 0.0104899 | 0.0122396 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

We can remove the missing values left over by the moving window

``` r
zooplankton_deseasonalized <- zooplankton_deseasonalized |>
  na.omit()

phytoplankton_deseasonalized <- phytoplankton_deseasonalized |>
  na.omit()
```

# Export Data

``` r
write.csv(
  zooplankton_deseasonalized,
  here("Data/Temp/zoo_deseasonalized.csv"),
  row.names = FALSE
)

write.csv(
  phytoplankton_deseasonalized,
  here("Data/Temp/phyto_deseasonalized.csv"),
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
    [1] vegan_2.7-6      permute_0.9-10   here_1.0.2       dplyr_1.2.1     
    [5] conflicted_1.2.0

    loaded via a namespace (and not attached):
     [1] Matrix_1.7-5     jsonlite_2.0.0   compiler_4.6.1   renv_1.3.1      
     [5] tidyselect_1.2.1 parallel_4.6.1   cluster_2.1.8.2  splines_4.6.1   
     [9] yaml_2.3.12      fastmap_1.2.0    lattice_0.22-9   R6_2.6.1        
    [13] generics_0.1.4   knitr_1.52       MASS_7.3-65      tibble_3.3.1    
    [17] rprojroot_2.1.1  pillar_1.11.1    rlang_1.3.0      cachem_1.1.0    
    [21] xfun_0.62        otel_0.2.0       memoise_2.0.1    cli_3.6.6       
    [25] withr_3.0.3      magrittr_2.0.5   mgcv_1.9-4       digest_0.6.39   
    [29] grid_4.6.1       lifecycle_1.0.5  nlme_3.1-169     vctrs_0.7.3     
    [33] evaluate_1.0.5   glue_1.8.1       rmarkdown_2.32   tools_4.6.1     
    [37] pkgconfig_2.0.3  htmltools_0.5.9 

Document rendered using Quarto version 1.10.18.
