# Integrate taxonomy (WORMS) to initial plankton dataframes
Lucien Bastin
2026-10-26

- [Libraries and data](#libraries-and-data)
  - [Libraries](#libraries)
  - [Data](#data)
- [Processing](#processing)
  - [Preparation](#preparation)
  - [Scraping](#scraping)
- [Exporting](#exporting)
- [Session info](#session-info)

# Libraries and data

## Libraries

``` r
library(conflicted)
library(dplyr)
library(here)
library(tidyr)
library(worrms)
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
zooplankton_data <- read.csv(here("Data/Temp/zoo_clean.csv"))
phytoplankton_data <- read.csv(here("Data/Temp/phyto_clean.csv"))
```

# Processing

## Preparation

Make classification tables from AphiaID values.

``` r
id_to_taxo <- data.frame(
  taxo_id = c(
    unique(zooplankton_data$taxo_id),
    unique(phytoplankton_data$taxo_id)
  )
)
```

Remove rows where id = 1 (“Biota”, brings no information on what this
organism is)

``` r
id_to_taxo <- id_to_taxo |>
  filter(taxo_id != 1)
```

``` r
head(id_to_taxo)
```

| taxo_id |
|--------:|
|     101 |
|     882 |
|     913 |
|    1082 |
|    1101 |
|    1102 |

## Scraping

Scrape WORMS (https://www.marinespecies.org/) to get the taxonomic
information corresponding to each AphiaID

``` r
get_taxo_from_id <- function(taxo_id) {
  wm_classification(taxo_id) |>
    select(-AphiaID) |>
    pivot_wider(names_from = rank, values_from = scientificname)
}
```

``` r
id_to_taxo <- cbind(
  id_to_taxo,
  bind_rows(lapply(id_to_taxo$taxo_id, get_taxo_from_id))
)
```

``` r
head(id_to_taxo)
```

| taxo_id | Kingdom | Phylum | Class | Subclass | Infraclass | Order | Suborder | Family | Subphylum | Superclass | Superorder | Subfamily | Tribe | Genus | Subgenus | Species | Infraorder | Superfamily | Infraphylum | Parvphylum | Gigaclass | Parvorder | Subterclass | Section | Subsection | Subkingdom | Infrakingdom | Phylum (Division) | Subphylum (Subdivision) | Forma |
|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 101 | Animalia | Mollusca | Gastropoda | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 882 | Animalia | Annelida | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 913 | Animalia | Annelida | Polychaeta | Sedentaria | Canalipalpata | Spionida | Spioniformia | Spionidae | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1082 | Animalia | Arthropoda | Thecostraca | Cirripedia | NA | NA | NA | NA | Crustacea | Multicrustacea | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1101 | Animalia | Arthropoda | Copepoda | NA | Neocopepoda | Cyclopoida | NA | NA | Crustacea | Multicrustacea | Podoplea | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 1102 | Animalia | Arthropoda | Copepoda | NA | Neocopepoda | Harpacticoida | NA | NA | Crustacea | Multicrustacea | Podoplea | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |

Select the 7 commonly used levels of phylogeny : Kingdom, Phylum, Class,
Order, Family, Genus and Species.

``` r
id_to_taxo <- id_to_taxo |>
  select(taxo_id, Kingdom, Phylum, Class, Order, Family, Genus, Species)
```

``` r
head(id_to_taxo)
```

| taxo_id | Kingdom  | Phylum     | Class       | Order         | Family    | Genus | Species |
|--------:|:---------|:-----------|:------------|:--------------|:----------|:------|:--------|
|     101 | Animalia | Mollusca   | Gastropoda  | NA            | NA        | NA    | NA      |
|     882 | Animalia | Annelida   | NA          | NA            | NA        | NA    | NA      |
|     913 | Animalia | Annelida   | Polychaeta  | Spionida      | Spionidae | NA    | NA      |
|    1082 | Animalia | Arthropoda | Thecostraca | NA            | NA        | NA    | NA      |
|    1101 | Animalia | Arthropoda | Copepoda    | Cyclopoida    | NA        | NA    | NA      |
|    1102 | Animalia | Arthropoda | Copepoda    | Harpacticoida | NA        | NA    | NA      |

# Exporting

Join the taxonomic information of each id to the original plankton
dataframes

``` r
zooplankton_data <- zooplankton_data |>
  left_join(id_to_taxo)

phytoplankton_data <- phytoplankton_data |>
  left_join(id_to_taxo)
```

``` r
head(zooplankton_data)
```

| date | sample_no | taxo_id | unit | quality_flag | abundance | Kingdom | Phylum | Class | Order | Family | Genus | Species |
|:---|:---|---:|:---|:---|---:|:---|:---|:---|:---|:---|:---|:---|
| 1998-01-07 | 5198701 | 101 | nr/m3 | S | 25.06964 | Animalia | Mollusca | Gastropoda | NA | NA | NA | NA |
| 1998-01-07 | 5198701 | 882 | nr/m3 | S | 16.71309 | Animalia | Annelida | NA | NA | NA | NA | NA |
| 1998-01-07 | 5198701 | 913 | nr/m3 | S | 214.48468 | Animalia | Annelida | Polychaeta | Spionida | Spionidae | NA | NA |
| 1998-01-07 | 5198701 | 1082 | nr/m3 | S | 25.06964 | Animalia | Arthropoda | Thecostraca | NA | NA | NA | NA |
| 1998-01-07 | 5198701 | 1101 | nr/m3 | S | 97.49304 | Animalia | Arthropoda | Copepoda | Cyclopoida | NA | NA | NA |
| 1998-01-07 | 5198701 | 1102 | nr/m3 | S | 13.92758 | Animalia | Arthropoda | Copepoda | Harpacticoida | NA | NA | NA |

``` r
write.csv(
  zooplankton_data,
  here("Data/Temp/zoo_with_taxo.csv"),
  row.names = FALSE
)

write.csv(
  phytoplankton_data,
  here("Data/Temp/phyto_with_taxo.csv"),
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
    [1] worrms_0.4.3     tidyr_1.3.2      here_1.0.2       dplyr_1.2.1     
    [5] conflicted_1.2.0

    loaded via a namespace (and not attached):
     [1] vctrs_0.7.3      cli_3.6.6        knitr_1.52       rlang_1.3.0     
     [5] xfun_0.62        crul_1.6.0       purrr_1.2.2      renv_1.3.1      
     [9] generics_0.1.4   jsonlite_2.0.0   glue_1.8.1       httpcode_0.3.0  
    [13] rprojroot_2.1.1  htmltools_0.5.9  triebeard_0.4.1  rmarkdown_2.32  
    [17] evaluate_1.0.5   tibble_3.3.1     fastmap_1.2.0    yaml_2.3.12     
    [21] lifecycle_1.0.5  memoise_2.0.1    compiler_4.6.1   Rcpp_1.1.2      
    [25] pkgconfig_2.0.3  digest_0.6.39    R6_2.6.1         tidyselect_1.2.1
    [29] curl_8.1.0       pillar_1.11.1    magrittr_2.0.5   urltools_1.7.3.1
    [33] withr_3.0.3      tools_4.6.1      cachem_1.1.0    
