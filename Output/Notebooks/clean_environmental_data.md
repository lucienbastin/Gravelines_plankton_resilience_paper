# Clean up environmental variables datasets
Lucien Bastin
2026-11-02

- [Libraries and data](#libraries-and-data)
  - [Libraries](#libraries)
  - [Data](#data)
- [Clean data](#clean-data)
  - [Physico-chemical variables](#physico-chemical-variables)
  - [Climatology](#climatology)
    - [NAO](#nao)
    - [EAP](#eap)
    - [Météo France](#météo-france)
- [Combine all datasets](#combine-all-datasets)
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
library(stringr)
library(tidyr)
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

Physico-chemical variables :

``` r
gravelines_environment <- read.csv2(
  here("Data/Raw/Q2_IGA_GravA_ENV_SEANOE.csv")
)
```

Climatological data (from Météo France). Data available at :
https://meteofrance.s3.sbg.io.cloud.ovh.net/data/synchro_ftp/BASE/MENS/MENSQ_59_previous-1950-2024.csv.gz

``` r
climatological_data <- read.csv2(
  here("Data/Raw/MENSQ_59_previous-1950-2024.csv")
)
```

North Atlantic Oscillation and East Atlantic Pattern. Data available at
https://climatedataguide.ucar.edu/sites/default/files/2026-04/nao_pc_monthly.txt
(NAO) and https://ftp.cpc.ncep.noaa.gov/wd52dg/data/indices/ea_index.tim
(EAP).

``` r
nao_data <- readLines(here("Data/Raw/nao_pc_monthly.txt"))
eap_data <- readLines(here("Data/Raw/ea_index.tim"))
```

# Clean data

## Physico-chemical variables

``` r
gravelines_environment <- gravelines_environment |>
  select(
    Passage...Date,
    Resultat...Code.parametre,
    Resultat...Valeur.de.la.mesure,
    Resultat...Symbole.unite.de.mesure.associe.au.quintuplet
  ) |>
  rename(
    date = Passage...Date,
    variable = Resultat...Code.parametre,
    value = Resultat...Valeur.de.la.mesure,
    unit = Resultat...Symbole.unite.de.mesure.associe.au.quintuplet
  ) |>
  mutate(
    date = as.Date(date, format = "%Y-%m-%d"),
    value = as.numeric(value)
  ) |>
  filter(date >= "1998-01-01")
```

Look at the units for each variable :

``` r
gravelines_environment |>
  select(variable, unit) |>
  filter(!duplicated(paste(variable, unit)))
```

| variable | unit       |
|:---------|:-----------|
| CHLOROA  | ug.l-1     |
| NH4      | umol.l-1   |
| NO3+NO2  | umol.l-1   |
| PHEO     | ug.l-1     |
| TEMP     | oC         |
| SALI     | sans unite |
| NO2      | umol.l-1   |
| NO3      | umol.l-1   |
| NO3+NO2  |            |
| PO4      | umol.l-1   |
| SIOH     | umol.l-1   |
| NO3      |            |
| OXYGENE  | mg.l-1     |
| TURB     | FNU        |
| TURB     | NTU        |

Some measures of NO<sub>3</sub> and NO<sub>3</sub>+NO<sub>2</sub> have
no unit associated. However we won’t be keeping those variables (see
later) so that is not a problem.

Convert dataset to wide format :

``` r
gravelines_environment <- gravelines_environment |>
  select(-unit) |>
  pivot_wider(names_from = variable, values_from = value) |>
  group_by(year = year(date), month = month(date)) |>
  summarize(across(everything(), ~ mean(., na.rm = TRUE))) |>
  ungroup() |>
  select(-c(year, month))
```

``` r
nrow(gravelines_environment)
```

    [1] 324

This dataset has 324 rows, that is one for each month from 1998-01 to
2024-12. We don’t need to compute monthly means.

Standardize dates to be on the first day of each month :

``` r
gravelines_environment <- gravelines_environment |>
  mutate(date = as.Date(paste(year(date), month(date), "01", sep = "-")))
```

Check percentage of missing data

``` r
missing_values <- gravelines_environment |>
  pivot_longer(-date, names_to = "variable", values_to = "value") |>
  group_by(variable) |>
  summarize(`missing_%` = sum(is.na(value)) / n()) |>
  arrange(`missing_%`)
```

``` r
missing_values
```

| variable | missing\_% |
|:---------|-----------:|
| CHLOROA  |  0.0000000 |
| NH4      |  0.0000000 |
| PHEO     |  0.0000000 |
| TEMP     |  0.0000000 |
| NO3      |  0.1327160 |
| NO3+NO2  |  0.2716049 |
| SALI     |  0.2993827 |
| NO2      |  0.3981481 |
| PO4      |  0.6419753 |
| SIOH     |  0.6759259 |
| TURB     |  0.6759259 |
| OXYGENE  |  0.6790123 |

Only four variables have no missing data : temperature, ammonium (NH4),
chlorophyll a and phaeopigments. The other variables have too many
missing values to be imputed, so we remove them.

``` r
gravelines_environment <- gravelines_environment |>
  rename(
    "temperature" = TEMP,
    "NH4" = NH4,
    "chlorophyll_a" = CHLOROA,
    "phaeopigments" = PHEO
  ) |>
  select(date, temperature, NH4, chlorophyll_a, phaeopigments)
```

``` r
head(gravelines_environment)
```

| date       | temperature |    NH4 | chlorophyll_a | phaeopigments |
|:-----------|------------:|-------:|--------------:|--------------:|
| 1998-01-01 |       8.050 | 5.7975 |        1.9300 |        0.7925 |
| 1998-02-01 |       6.925 | 3.5050 |        2.1450 |        0.4900 |
| 1998-03-01 |       8.820 | 2.4440 |        9.9980 |        1.3940 |
| 1998-04-01 |      10.375 | 1.2675 |       11.8375 |        0.8925 |
| 1998-05-01 |      13.500 | 3.7000 |        5.1575 |        0.5175 |
| 1998-06-01 |      16.840 | 4.5360 |        9.9620 |        0.6960 |

## Climatology

Newer versions of the datasets may impact the values of NAO and EAP
indices : “As is the nature of PC-based indices, every time additional
data is used to compute the EOF the individual PC values will likely
change.”
(https://climatedataguide.ucar.edu/climate-data/hurrell-north-atlantic-oscillation-nao-index-pc-based).

The datasets used here were retrieved on november 2nd, 2026.

### NAO

``` r
nao_data <- nao_data |>
  str_split("\\s+")
```

``` r
nao_data <- as.data.frame(
  as.matrix(do.call(rbind, nao_data[-1]))
)
```

``` r
colnames(nao_data) <- c("year", paste(1:12))
```

``` r
nao_data <- nao_data |>
  pivot_longer(-year, names_to = "month", values_to = "nao") |>
  mutate(
    date = ymd(paste(year, month, "1", sep = "-")),
    nao = as.numeric(nao)
  ) |>
  select(date, nao) |>
  filter(date >= as.Date("1998-01-01") & date < as.Date("2024-12-31"))
```

``` r
head(nao_data)
```

| date       |   nao |
|:-----------|------:|
| 1998-01-01 | -1.01 |
| 1998-02-01 |  0.50 |
| 1998-03-01 |  0.54 |
| 1998-04-01 | -0.42 |
| 1998-05-01 |  0.29 |
| 1998-06-01 | -0.95 |

### EAP

``` r
eap_data <- eap_data |>
  str_split("\\s+")
```

``` r
eap_data <- as.data.frame(
  as.matrix(do.call(rbind, eap_data[-c(1:9)]))
)
```

``` r
colnames(eap_data) <- c("year", "month", "eap")
```

``` r
eap_data <- eap_data |>
  mutate(
    date = ymd(paste(year, month, "1", sep = "-")),
    eap = as.numeric(eap)
  ) |>
  select(date, eap) |>
  filter(date >= as.Date("1998-01-01") & date < as.Date("2024-12-31"))
```

``` r
head(eap_data)
```

| date       |   eap |
|:-----------|------:|
| 1998-01-01 |  0.14 |
| 1998-02-01 |  1.33 |
| 1998-03-01 |  0.49 |
| 1998-04-01 |  2.39 |
| 1998-05-01 | -1.25 |
| 1998-06-01 | -0.03 |

### Météo France

``` r
climatological_data <- climatological_data |>
  filter(NOM_USUEL == "DUNKERQUE") |>
  select(AAAAMM, RR, FFM) |>
  rename(
    date = AAAAMM,
    precipitations = RR,
    wind_speed = FFM
  ) |>
  mutate(
    date = as.Date(paste0(date, "01"), format = "%Y%m%d"),
    precipitations = as.numeric(precipitations),
    wind_speed = as.numeric(wind_speed)
  ) |>
  filter(date >= as.Date("1998-01-01"))
```

``` r
head(climatological_data)
```

| date       | precipitations | wind_speed |
|:-----------|---------------:|-----------:|
| 1998-01-01 |           68.0 |        7.4 |
| 1998-02-01 |           12.0 |        5.2 |
| 1998-03-01 |           48.0 |        6.5 |
| 1998-04-01 |           49.6 |        5.8 |
| 1998-05-01 |           16.0 |        5.2 |
| 1998-06-01 |           67.8 |        6.4 |

# Combine all datasets

``` r
environmental_data <- gravelines_environment |>
  left_join(climatological_data) |>
  left_join(nao_data) |>
  left_join(eap_data)
```

``` r
head(environmental_data)
```

| date | temperature | NH4 | chlorophyll_a | phaeopigments | precipitations | wind_speed | nao | eap |
|:---|---:|---:|---:|---:|---:|---:|---:|---:|
| 1998-01-01 | 8.050 | 5.7975 | 1.9300 | 0.7925 | 68.0 | 7.4 | -1.01 | 0.14 |
| 1998-02-01 | 6.925 | 3.5050 | 2.1450 | 0.4900 | 12.0 | 5.2 | 0.50 | 1.33 |
| 1998-03-01 | 8.820 | 2.4440 | 9.9980 | 1.3940 | 48.0 | 6.5 | 0.54 | 0.49 |
| 1998-04-01 | 10.375 | 1.2675 | 11.8375 | 0.8925 | 49.6 | 5.8 | -0.42 | 2.39 |
| 1998-05-01 | 13.500 | 3.7000 | 5.1575 | 0.5175 | 16.0 | 5.2 | 0.29 | -1.25 |
| 1998-06-01 | 16.840 | 4.5360 | 9.9620 | 0.6960 | 67.8 | 6.4 | -0.95 | -0.03 |

Store the units of each variable in a separate dataset

``` r
environmental_data_units <- tribble(
  ~measure         , ~unit       ,
  "nao"            , "arbitrary" ,
  "eap"            , "arbitrary" ,
  "precipitations" , "mm"        ,
  "wind_speed"     , "m.s-1"     ,
  "temperature"    , "°C"        ,
  "NH4"            , "µmol.L-1"  ,
  "chlorophyll_a"  , "µg.L-1"    ,
  "phaeopigments"  , "µg.L-1"
)
```

``` r
environmental_data_units
```

| measure        | unit      |
|:---------------|:----------|
| nao            | arbitrary |
| eap            | arbitrary |
| precipitations | mm        |
| wind_speed     | m.s-1     |
| temperature    | °C        |
| NH4            | µmol.L-1  |
| chlorophyll_a  | µg.L-1    |
| phaeopigments  | µg.L-1    |

# Export data

``` r
write.csv(
  environmental_data,
  here("Data/Temp/environmental_data.csv"),
  row.names = FALSE
)

write.csv(
  environmental_data_units,
  here("Data/Temp/environmental_data_units.csv"),
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
    [1] tidyr_1.3.2        stringr_1.6.0      lubridate_1.9.5    here_1.0.2        
    [5] ggTimeSeries_1.0.1 ggplot2_4.0.3      dplyr_1.2.1        conflicted_1.2.0  

    loaded via a namespace (and not attached):
     [1] gtable_0.3.6        jsonlite_2.0.0      compiler_4.6.1     
     [4] renv_1.3.1          tidyselect_1.2.1    scales_1.4.0       
     [7] yaml_2.3.12         fastmap_1.2.0       R6_2.6.1           
    [10] generics_0.1.4      knitr_1.52          tibble_3.3.1       
    [13] rprojroot_2.1.1     pillar_1.11.1       RColorBrewer_1.1-3 
    [16] rlang_1.3.0         stringi_1.8.9       cachem_1.1.0       
    [19] xfun_0.62           S7_0.2.2            otel_0.2.0         
    [22] timechange_0.4.0    memoise_2.0.1       cli_3.6.6          
    [25] withr_3.0.3         magrittr_2.0.5      digest_0.6.39      
    [28] grid_4.6.1          lifecycle_1.0.5     vctrs_0.7.3        
    [31] evaluate_1.0.5      glue_1.8.1          data.table_1.18.6.1
    [34] farver_2.1.2        purrr_1.2.2         rmarkdown_2.32     
    [37] tools_4.6.1         pkgconfig_2.0.3     htmltools_0.5.9    

Document rendered using Quarto version 1.10.18.
