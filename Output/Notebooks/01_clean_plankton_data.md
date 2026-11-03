# Clean up plankton datasets
Lucien Bastin
2026-11-03

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
zooplankton_data <- read.csv(here("Data/Raw/Zooplankton_Gravelines.csv"))
phytoplankton_data <- read.csv(here("Data/Raw/Phytoplankton_Gravelines.csv"))
```

# Clean plankton variables names and types

The raw data looks like this :

``` r
head(zooplankton_data)
```

| CNTRY | CRUIS | STNNO | SMPNO | MPROG | PURPM | MYEAR | DATE | Latitude | Longitude | MNDEP | MXDEP | STATN | OSPAR_region | HELCOM_subbasin | RLABO | ALABO | SLABO | RLIST | SPECI | SPECI_name | AphiaID | WoRMS_name | AphiaID_accepted | WoRMS_accepted_name | SEXCO | SFLAG | SIZCL | SIZRF | STAGE | CPORT | NPORT | PARAM | Value | MUNIT | Final_value | Final_MUNIT | SMTYP | SAREA | METOA | MAGNI | FLVOL | CLMET | SMVOL | METFP | QFLAG | VFLAG | FINFL | REFSK | DCFLGs | tblUploadID | tblSpotID | tblSampleID | tblParamID |
|:---|:---|:---|:---|:---|:---|---:|:---|---:|---:|---:|---:|:---|:---|:---|:---|:---|:---|:---|---:|:---|---:|:---|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|---:|:---|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|---:|---:|---:|---:|
| France | IGA_Gravelines_2024 | BOREA20240111 | BOREA20240111 | CEMP~NATL | T~S | 2024 | 11/01/2024 | 2.15003 | 51.02219 | 2 | 5 | GRAV - Canal Amenee | NA | NA | BAMN | BAMN | BAMN | ERID | 883 | Polychaeta | 883 | Polychaeta | 883 | Polychaeta | NA | NA | NA | NA | NA | NA | NA | ABUNDNR | 0.50 | nr/m3 | 0.50 | nr/m3 | NA | NA | NA | NA | NA | NA | NA | NA | NA | A | NA | NA | 00-CONV-SF | 13547 | 862528 | 5731088 | 73659265 |
| France | IGA_Gravelines_2024 | BOREA20240111 | BOREA20240111 | CEMP~NATL | T~S | 2024 | 11/01/2024 | 2.15003 | 51.02219 | 2 | 5 | GRAV - Canal Amenee | NA | NA | BAMN | BAMN | BAMN | ERID | 1078 | Ostracoda | 1078 | Ostracoda | 1078 | Ostracoda | NA | NA | NA | NA | NA | NA | NA | ABUNDNR | 0.50 | nr/m3 | 0.50 | nr/m3 | NA | NA | NA | NA | NA | NA | NA | NA | NA | A | NA | NA | 00-CONV-SF | 13547 | 862528 | 5731088 | 73659266 |
| France | IGA_Gravelines_2024 | BOREA20240111 | BOREA20240111 | CEMP~NATL | T~S | 2024 | 11/01/2024 | 2.15003 | 51.02219 | 2 | 5 | GRAV - Canal Amenee | NA | NA | BAMN | BAMN | BAMN | ERID | 1080 | Copepoda | 1080 | Copepoda | 1080 | Copepoda | NA | NA | NA | NA | NA | NA | NA | ABUNDNR | 0.76 | nr/m3 | 0.76 | nr/m3 | NA | NA | NA | NA | NA | NA | NA | NA | NA | A | NA | NA | 00-CONV-SF | 13547 | 862528 | 5731088 | 73659267 |
| France | IGA_Gravelines_2024 | BOREA20240111 | BOREA20240111 | CEMP~NATL | T~S | 2024 | 11/01/2024 | 2.15003 | 51.02219 | 2 | 5 | GRAV - Canal Amenee | NA | NA | BAMN | BAMN | BAMN | ERID | 1082 | Cirripedia | 1082 | Cirripedia | 1082 | Cirripedia | NA | NA | NA | NA | NA | NA | NA | ABUNDNR | 2.02 | nr/m3 | 2.02 | nr/m3 | NA | NA | NA | NA | NA | NA | NA | NA | NA | A | NA | NA | 00-CONV-SF | 13547 | 862528 | 5731088 | 73659268 |
| France | IGA_Gravelines_2024 | BOREA20240111 | BOREA20240111 | CEMP~NATL | T~S | 2024 | 11/01/2024 | 2.15003 | 51.02219 | 2 | 5 | GRAV - Canal Amenee | NA | NA | BAMN | BAMN | BAMN | ERID | 1131 | Isopoda | 1131 | Isopoda | 1131 | Isopoda | NA | NA | NA | NA | NA | NA | NA | ABUNDNR | 4.04 | nr/m3 | 4.04 | nr/m3 | NA | NA | NA | NA | NA | NA | NA | NA | NA | A | NA | NA | 00-CONV-SF | 13547 | 862528 | 5731088 | 73659269 |
| France | IGA_Gravelines_2024 | BOREA20240111 | BOREA20240111 | CEMP~NATL | T~S | 2024 | 11/01/2024 | 2.15003 | 51.02219 | 2 | 5 | GRAV - Canal Amenee | NA | NA | BAMN | BAMN | BAMN | ERID | 1137 | Cumacea | 1137 | Cumacea | 1137 | Cumacea | NA | NA | NA | NA | NA | NA | NA | ABUNDNR | 0.76 | nr/m3 | 0.76 | nr/m3 | NA | NA | NA | NA | NA | NA | NA | NA | NA | A | NA | NA | 00-CONV-SF | 13547 | 862528 | 5731088 | 73659270 |

We can select relevant variables and change their names to something
more informative.

``` r
clean_plankton_variables <- function(plankton_data) {
  plankton_data |>
    select(DATE, AphiaID, WoRMS_name, MUNIT, VFLAG, final_value) |>
    rename(
      date = DATE,
      taxo_id = AphiaID,
      worms_name = WoRMS_name,
      unit = MUNIT,
      quality_flag = VFLAG,
      abundance = final_value
    ) |>
    mutate(date = as.Date(as.character(date), format = "%d/%m/%Y"))
}
```

``` r
zooplankton_data <- zooplankton_data |>
  rename(final_value = Final_value) |>
  clean_plankton_variables()

phytoplankton_data <- clean_plankton_variables(phytoplankton_data)
```

``` r
head(zooplankton_data)
```

| date       | taxo_id | worms_name | unit  | quality_flag | abundance |
|:-----------|--------:|:-----------|:------|:-------------|----------:|
| 2024-01-11 |     883 | Polychaeta | nr/m3 | A            |      0.50 |
| 2024-01-11 |    1078 | Ostracoda  | nr/m3 | A            |      0.50 |
| 2024-01-11 |    1080 | Copepoda   | nr/m3 | A            |      0.76 |
| 2024-01-11 |    1082 | Cirripedia | nr/m3 | A            |      2.02 |
| 2024-01-11 |    1131 | Isopoda    | nr/m3 | A            |      4.04 |
| 2024-01-11 |    1137 | Cumacea    | nr/m3 | A            |      0.76 |

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
