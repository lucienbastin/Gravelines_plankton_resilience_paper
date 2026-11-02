# Clean up plankton datasets
Lucien Bastin
2026-11-02

- [Libraries and data](#libraries-and-data)
  - [Libraries](#libraries)
  - [Data](#data)
- [Clean plankton variables names and
  types](#clean-plankton-variables-names-and-types)
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

## Data

``` r
zooplankton_data <- read.csv(here(
  "Data/Raw/DOME_ZP_IGA_GRAVELINES_Ready_version_2024.csv"
))

phytoplankton_data <- read.csv(here(
  "Data/Raw/DOME_PP_IGA_GRAVELINES_Ready_version_2024.csv"
))
```

# Clean plankton variables names and types

The raw data looks like this :

``` r
head(zooplankton_data)
```

| RLABO | SHIPC | CRUIS | STNNO | LATIT | LONGI | POSYS | STATN | SDATE | STIME | WADEP | SMPNO | FINFL | SMVOL | MNDEP | MXDEP | SPECI | TRPHY | STAGE | PARAM | MUNIT | VFLAG | ALABO | METOA | METFP | SLABO | SMTYP | MPROG | PURPM | MYEAR | DTYPE | RLIST | SIZCL | SIZRF | SFLAG | VALUE |
|:---|:---|---:|:---|---:|---:|:---|:---|---:|:---|:---|:---|:---|:---|---:|---:|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|---:|:---|:---|:---|:---|:---|---:|
| BAMN | AA31 | 1998 | 5198701 | 2.15003 | 51.02219 | NA | GRAV - Canal Amenee | 19980107 | 00:00:00 | NA | 5198701 | NA | NA | 2 | 5 | 101 | NA | NA | ABUNDNR | nr/m3 | S | NA | NA | NA | NA | NA | CEMP~NATL | T~S | 1998 | ZP | ERID | NA | NA | NA | 25.06964 |
| BAMN | AA31 | 1998 | 5198701 | 2.15003 | 51.02219 | NA | GRAV - Canal Amenee | 19980107 | 00:00:00 | NA | 5198701 | NA | NA | 2 | 5 | 882 | NA | NA | ABUNDNR | nr/m3 | S | NA | NA | NA | NA | NA | CEMP~NATL | T~S | 1998 | ZP | ERID | NA | NA | NA | 16.71309 |
| BAMN | AA31 | 1998 | 5198701 | 2.15003 | 51.02219 | NA | GRAV - Canal Amenee | 19980107 | 00:00:00 | NA | 5198701 | NA | NA | 2 | 5 | 913 | NA | NA | ABUNDNR | nr/m3 | S | NA | NA | NA | NA | NA | CEMP~NATL | T~S | 1998 | ZP | ERID | NA | NA | NA | 214.48468 |
| BAMN | AA31 | 1998 | 5198701 | 2.15003 | 51.02219 | NA | GRAV - Canal Amenee | 19980107 | 00:00:00 | NA | 5198701 | NA | NA | 2 | 5 | 1082 | NA | NA | ABUNDNR | nr/m3 | S | NA | NA | NA | NA | NA | CEMP~NATL | T~S | 1998 | ZP | ERID | NA | NA | NA | 25.06964 |
| BAMN | AA31 | 1998 | 5198701 | 2.15003 | 51.02219 | NA | GRAV - Canal Amenee | 19980107 | 00:00:00 | NA | 5198701 | NA | NA | 2 | 5 | 1101 | NA | NA | ABUNDNR | nr/m3 | S | NA | NA | NA | NA | NA | CEMP~NATL | T~S | 1998 | ZP | ERID | NA | NA | NA | 97.49304 |
| BAMN | AA31 | 1998 | 5198701 | 2.15003 | 51.02219 | NA | GRAV - Canal Amenee | 19980107 | 00:00:00 | NA | 5198701 | NA | NA | 2 | 5 | 1102 | NA | NA | ABUNDNR | nr/m3 | S | NA | NA | NA | NA | NA | CEMP~NATL | T~S | 1998 | ZP | ERID | NA | NA | NA | 13.92758 |

We can select relevant variables and change their names to something
more informative.

``` r
clean_plankton_variables <- function(plankton_data) {
  plankton_data |>
    select(SDATE, SMPNO, SPECI, MUNIT, VFLAG, VALUE) |>
    rename(
      date = SDATE,
      sample_no = SMPNO,
      taxo_id = SPECI,
      unit = MUNIT,
      quality_flag = VFLAG,
      abundance = VALUE
    ) |>
    mutate(date = as.Date(as.character(date), format = "%Y%m%d"))
}
```

``` r
zooplankton_data <- clean_plankton_variables(zooplankton_data)
phytoplankton_data <- clean_plankton_variables(phytoplankton_data)
```

``` r
head(zooplankton_data)
```

| date       | sample_no | taxo_id | unit  | quality_flag | abundance |
|:-----------|:----------|--------:|:------|:-------------|----------:|
| 1998-01-07 | 5198701   |     101 | nr/m3 | S            |  25.06964 |
| 1998-01-07 | 5198701   |     882 | nr/m3 | S            |  16.71309 |
| 1998-01-07 | 5198701   |     913 | nr/m3 | S            | 214.48468 |
| 1998-01-07 | 5198701   |    1082 | nr/m3 | S            |  25.06964 |
| 1998-01-07 | 5198701   |    1101 | nr/m3 | S            |  97.49304 |
| 1998-01-07 | 5198701   |    1102 | nr/m3 | S            |  13.92758 |

# Export data

``` r
write.csv(
  zooplankton_data,
  here("Data/Temp/zoo_clean.csv"),
  row.names = FALSE
)

write.csv(
  phytoplankton_data,
  here("Data/Temp/phyto_clean.csv"),
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
