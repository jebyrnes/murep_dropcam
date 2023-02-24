library(sf)
library(dplyr)

ss <- list.files("data/Sidescan/SSS_Coverage", pattern = "\\.shp", full.names = TRUE) |>
  purrr::map_df(st_read) |>
  st_transform(crs = 4326)

ss2 <- ss |> st_simplify(preserveTopology = TRUE, dTolerance = 10)

saveRDS(ss2, "data/Sidescan/sss_coverage.rds")
