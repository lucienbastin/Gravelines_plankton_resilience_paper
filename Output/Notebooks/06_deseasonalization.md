# Deseasonalize timeseries to focus on long-term changes
Lucien Bastin
2026-10-29

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

| date | Acartiidae | Bryozoan_larva | Calanus | Centropages | Chaetognatha | Cirriped_larva | Cyclopoida | Decapod_larva | Euterpina | Gasteropod_larva | Oikopleura | Paracalanus | Polychaete_larva | Pseudocalanus | Temora | Jellyfish | Pleurobrachia | Bivalvia_larva | Echinoderm_larva | Large_Ctenophora | Labidocera | Ascidiacea | Branchiopoda | Corycaeidae | Clausidiidae | Cyclopinoides | Stephos | Fish_larva | Copepoda | Oithona | Siphonostomatoida | Monstrilloida | Parapontella | Doliolum | Isias | Fritillaria | Oncaeidae | Ostracoda | Longipedia | Eurytemora | Pseudodiaptomus | Harpacticus | Platycopia |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1998-01-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-02-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-03-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-04-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-05-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-06-01 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1998-07-01 | 0.3802011 | 0.0580915 | 0.0261881 | 0.1634706 | 0.0643809 | 0.2821767 | 0.0603882 | 0.0461103 | 0.2637977 | 0.0654365 | 0.1861141 | 0.0771243 | 0.2114000 | 0.1618617 | 0.3919280 | 0.0449271 | 0.0243513 | 0.0210192 | 0.1214559 | 0.0042391 | 0.0010268 | 0.0133997 | 0.003522 | 0.0141848 | 0.0434721 | 0.0104899 | 0.0039099 | 0.0000000 | 0.0000000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-08-01 | 0.3897563 | 0.0524523 | 0.0249771 | 0.1712444 | 0.0642492 | 0.2800826 | 0.0435777 | 0.0448993 | 0.2792303 | 0.0607305 | 0.1740341 | 0.0661289 | 0.1948728 | 0.1644713 | 0.3857336 | 0.0449271 | 0.0338254 | 0.0248751 | 0.1214559 | 0.0042391 | 0.0010268 | 0.0133997 | 0.003522 | 0.0289144 | 0.0495913 | 0.0104899 | 0.0066864 | 0.0000000 | 0.0000000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-09-01 | 0.3952101 | 0.0569262 | 0.0261818 | 0.1854443 | 0.0642492 | 0.2592875 | 0.0430031 | 0.0482376 | 0.2775183 | 0.0607305 | 0.1777012 | 0.0800530 | 0.1928610 | 0.2000939 | 0.3945793 | 0.0455340 | 0.0341758 | 0.0248751 | 0.1214559 | 0.0042391 | 0.0010268 | 0.0133997 | 0.003522 | 0.0303727 | 0.0495913 | 0.0111128 | 0.0066864 | 0.0034053 | 0.0000000 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1998-10-01 | 0.4023600 | 0.0637859 | 0.0279235 | 0.2113216 | 0.0655213 | 0.2062094 | 0.0395791 | 0.0536457 | 0.2889830 | 0.0645054 | 0.1914109 | 0.0901511 | 0.2226115 | 0.2195180 | 0.4194779 | 0.0450102 | 0.0352179 | 0.0333156 | 0.1214559 | 0.0042391 | 0.0010268 | 0.0133997 | 0.003522 | 0.0303727 | 0.0495913 | 0.0111128 | 0.0066864 | 0.0090119 | 0.0092462 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

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
