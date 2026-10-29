# Takes in a vegan rda object and extracts the information needed to plot the pca using ggplot2

library(dplyr)
library(tibble)

extract_pca_data <- function(
  pca,
  scaling = 1,
  ax1 = 1,
  ax2 = 2
) {
  # Internal functions

  "stretch" <- function(sites, species, ax1, ax2, n) {
    tmp1 <- rbind(c(0, 0), sites[, c(ax1, ax2)])
    D <- dist(tmp1)
    target <- max(D[1:n])

    p <- nrow(species)
    tmp2 <- rbind(c(0, 0), species[, c(ax1, ax2)])
    D <- dist(tmp2)
    longest <- max(D[1:p])

    target / longest
  }

  # Positions of sites and species on axes

  pca_eig <- pca$CA$eig
  lambda <- diag(pca_eig)
  n <- nrow(pca$CA$u)

  species_sc1 <- pca$CA$v
  species_sc2 <- species_sc1 %*% sqrt(lambda)

  sites_sc2 <- pca$CA$u * sqrt(n - 1)
  sites_sc1 <- sites_sc2 %*% sqrt(lambda)

  if (scaling == 1) {
    sites <- sites_sc1
    species <- species_sc1
  } else {
    sites <- sites_sc2
    species <- species_sc2
  }

  # Correct species position

  stretch <- stretch(sites, species, ax1, ax2, n)

  species <- species * stretch

  # Format to dataframes

  sites <- sites |>
    as.data.frame() |>
    rename_all(~ gsub("V", "PC", .)) |>
    rownames_to_column("sites")

  species <- species |>
    as.data.frame() |>
    rename_all(~ gsub("V", "PC", .)) |>
    rownames_to_column("species")

  # Percent variance explained by each axis

  s <- summary(pca)
  percent_var <- round(s$cont$importance[2, ] * 100, 2)

  list(
    sites_scores = sites,
    species_scores = species,
    percent_var = percent_var
  )
}
