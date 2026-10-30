# Data analysis flowchart

Click on nodes to open the relevant files.

```mermaid
flowchart TD
  zooplankton-raw-data([Zooplankton raw data])
  click zooplankton-raw-data "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Data/Raw/DOME_ZP_IGA_GRAVELINES_Ready_version_2024.csv"

  phytoplankton-raw-data([Phytoplankton raw data])
  click phytoplankton-raw-data "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Data/Raw/DOME_PP_IGA_GRAVELINES_Ready_version_2024.csv"

  clean-datasets[Clean datasets]
  click clean-datasets "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Output/Notebooks/01_clean_data.md"

  scrape-worms-taxo[Scrape WORMS taxonomy]
  click scrape-worms-taxo "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Output/Notebooks/02_scrape_WORMS_taxonomy.md"

  group-plankton-taxa[Group plankton taxa into superior groups]
  click group-plankton-taxa "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Output/Notebooks/03_taxonomic_grouping.md"

  regularize-timeseries[Regularize time series to have a monthly resolution]
  click regularize-timeseries "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Output/Notebooks/05_regularize_to_month.md"

  deseasonalize-timeseries[Deseasonalize the timeseries by moving average]
  click deseasonalize-timeseries "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Output/Notebooks/06_deseasonalization.md"

  zooplankton-deseasonalized-data([Deseasonalized zooplankton data])
  phytoplankton-deseasonalized-data([Deseasonalized phytoplankton data])

  longterm-zooplankton-clustering[Time-constrained clustering of zooplankton data]
  click longterm-zooplankton-clustering "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Output/Notebooks/0zooplankton_longterm_clustering.md"

  longterm-zooplankton-trajectory[Long-term evolution of the zooplankton community]
  click longterm-zooplankton-trajectory "https://gitlab.com/lucien_bastin/Gravelines_plankton_resilience_paper/-/blob/master/Output/Notebooks/zooplankton_longterm_trajectory.md"

  zooplankton-raw-data & phytoplankton-raw-data --> clean-datasets
  clean-datasets --> scrape-worms-taxo
  scrape-worms-taxo --> group-plankton-taxa
  group-plankton-taxa --> regularize-timeseries
  regularize-timeseries --> deseasonalize-timeseries
  deseasonalize-timeseries --> zooplankton-deseasonalized-data
  zooplankton-deseasonalized-data --> longterm-zooplankton-clustering
  zooplankton-deseasonalized-data & longterm-zooplankton-clustering --> longterm-zooplankton-trajectory
```