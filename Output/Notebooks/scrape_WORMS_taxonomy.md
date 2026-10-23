# Integrate taxonomy (WORMS) to initial plankton dataframes
Lucien Bastin
2026-10-23

- [Libraries and data](#libraries-and-data)
  - [Libraries](#libraries)
  - [Data](#data)
- [Processing](#processing)
  - [Data preparation](#data-preparation)
  - [Scraping](#scraping)
- [Exporting](#exporting)
- [Session info](#session-info)

# Libraries and data

## Libraries

``` r
library(conflicted)
library(data.table)
library(dplyr)
library(here)
library(tidyr)
library(worrms)
```

``` r
conflicted::conflict_scout()
```

``` r
conflicted::conflicts_prefer(
 dplyr::filter()
)
```

## Data

``` r
gravelines_phyto <- read.csv(here(
  "Data/Raw/DOME_PP_IGA_GRAVELINES_Ready_version_2024.csv"
))

gravelines_zoo <- read.csv(here(
  "Data/Raw/DOME_ZP_IGA_GRAVELINES_Ready_version_2024.csv"
))
```

# Processing

## Data preparation

Select columns of interest in the dataframes.

``` r
gravelines_phyto <- gravelines_phyto |>
  select(SDATE, SMPNO, SPECI, MUNIT, VFLAG, VALUE)

gravelines_zoo <- gravelines_zoo |>
  select(SDATE, SMPNO, SPECI, MUNIT, VFLAG, VALUE)
```

``` r
head(gravelines_zoo)
```

|    SDATE | SMPNO   | SPECI | MUNIT | VFLAG |     VALUE |
|---------:|:--------|------:|:------|:------|----------:|
| 19980107 | 5198701 |   101 | nr/m3 | S     |  25.06964 |
| 19980107 | 5198701 |   882 | nr/m3 | S     |  16.71309 |
| 19980107 | 5198701 |   913 | nr/m3 | S     | 214.48468 |
| 19980107 | 5198701 |  1082 | nr/m3 | S     |  25.06964 |
| 19980107 | 5198701 |  1101 | nr/m3 | S     |  97.49304 |
| 19980107 | 5198701 |  1102 | nr/m3 | S     |  13.92758 |

Make classification tables from AphiaID values.

``` r
id_to_taxo <- data.frame(
  id = c(
    unique(gravelines_phyto$SPECI),
    unique(gravelines_zoo$SPECI)
  )
)
```

Remove rows where id = 1 (“Biota”)

``` r
id_to_taxo <- id_to_taxo |>
  filter(id != 1)
```

``` r
head(id_to_taxo)
```

|     id |
|-------:|
| 148967 |
| 149022 |
| 149042 |
| 149064 |
| 149093 |
| 149102 |

## Scraping

Scrape WORMS (https://www.marinespecies.org/) to get the taxonomic
information corresponding to each AphiaID

``` r
get_taxo_from_id <- function(id) {
  wm_classification(id) |>
    select(-AphiaID) |>
    pivot_wider(names_from = rank, values_from = scientificname)
}
```

``` r
id_to_taxo <- cbind(
  id_to_taxo,
  bind_rows(lapply(id_to_taxo$id, get_taxo_from_id))
)
```

``` r
head(id_to_taxo)
```

| id | Kingdom | Phylum | Subphylum | Class | Subclass | Superorder | Order | Family | Genus | Species | Subkingdom | Infrakingdom | Infraphylum | Phylum (Division) | Subphylum (Subdivision) | Subfamily | Forma | Suborder | Infraclass | Superclass | Tribe | Subgenus | Infraorder | Superfamily | Parvphylum | Gigaclass | Parvorder | Subterclass | Section | Subsection |
|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 148967 | Chromista | Heterokontophyta | Bacillariophytina | Bacillariophyceae | Coscinodiscophycidae | Biddulphianae | Biddulphiales | Biddulphiaceae | Biddulphia | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 149022 | Chromista | Heterokontophyta | Bacillariophytina | Bacillariophyceae | Coscinodiscophycidae | Lithodesmiophycanae | Lithodesmiales | Lithodesmiaceae | Ditylum | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 149042 | Chromista | Heterokontophyta | Bacillariophytina | Bacillariophyceae | Coscinodiscophycidae | Coscinodiscanae | Melosirales | Melosiraceae | Melosira | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 149064 | Chromista | Heterokontophyta | Bacillariophytina | Bacillariophyceae | Bacillariophycidae | Bacillariophycidae incertae sedis | Rhaponeidales | Rhaphoneidaceae | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 149093 | Chromista | Heterokontophyta | Bacillariophytina | Bacillariophyceae | Fragilariophycidae | Fragilariophycanae | Thalassionematales | Thalassionemataceae | Thalassionema | Thalassionema nitzschioides | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 149102 | Chromista | Heterokontophyta | Bacillariophytina | Bacillariophyceae | Coscinodiscophycidae | Thalassiosiranae | Thalassiosirales | Thalassiosiraceae | Thalassiosira | Thalassiosira gravida | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |

# Exporting

Join the taxonomic information of each id to the original plankton
dataframes

``` r
gravelines_phyto <- gravelines_phyto |>
  left_join(id_to_taxo, by = join_by(SPECI == id))

gravelines_zoo <- gravelines_zoo |>
  left_join(id_to_taxo, by = join_by(SPECI == id))
```

``` r
write.csv(
  gravelines_phyto,
  here("Data/Temp/gravelines_phyto_with_taxo.csv"),
  row.names = FALSE
)

write.csv(
  gravelines_zoo,
  here("Data/Temp/gravelines_zoo_with_taxo.csv"),
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
    [1] worrms_0.4.3        tidyr_1.3.2         here_1.0.2         
    [4] dplyr_1.2.1         data.table_1.18.6.1 conflicted_1.2.0   

    loaded via a namespace (and not attached):
     [1] vctrs_0.7.3      cli_3.6.6        knitr_1.52       rlang_1.3.0     
     [5] xfun_0.61        crul_1.6.0       purrr_1.2.2      renv_1.3.1      
     [9] generics_0.1.4   jsonlite_2.0.0   glue_1.8.1       httpcode_0.3.0  
    [13] rprojroot_2.1.1  htmltools_0.5.9  triebeard_0.4.1  rmarkdown_2.32  
    [17] evaluate_1.0.5   tibble_3.3.1     fastmap_1.2.0    yaml_2.3.12     
    [21] lifecycle_1.0.5  memoise_2.0.1    compiler_4.6.1   Rcpp_1.1.2      
    [25] pkgconfig_2.0.3  digest_0.6.39    R6_2.6.1         tidyselect_1.2.1
    [29] curl_8.1.0       pillar_1.11.1    magrittr_2.0.5   urltools_1.7.3.1
    [33] withr_3.0.3      tools_4.6.1      cachem_1.1.0    
