library(sf)
library(leaflet)
library(dplyr)

tracks <- read_sf("data/tracks/salem_sound_tracks_density.shp") |>
  mutate(`Kelp Dens#` = ifelse(is.na(`Kelp Dens#`),0,`Kelp Dens#`))
  #rename(`YouTube Li` = Youtube.Li) #deal with difference in versions of sf


pal <- colorNumeric(
  palette = "Greens",
  domain = tracks$`Kelp Dens#`)

leaflet() |>
  addProviderTiles(providers$Esri.WorldGrayCanvas, 
                   group = "ESRI World Gray Canvas",
                              options = providerTileOptions(noWrap = TRUE)) |>
  setView(lat = 42.5264892, lng = -70.8222588, zoom = 12) |>
  addPolylines(data = tracks,
               col = ~pal(`Kelp Dens#`),
               weight = 3,
               layerId = ~`YouTube Li`,
               highlight = highlightOptions(color = "blue",weight = 5, 
                                            bringToFront = F, opacity = 1)) %>%
    addLegend("bottomright", 
              pal = pal, 
              values = tracks$`Kelp Dens#`,
              title = "Kelp Relative Abundance Score",
              opacity = 1
    ) %>%
  addLayersControl(
    baseGroups = c("ESRI World Gray Canvas", "Toner by Stamen")
  )





# addPolygons(data=us, 
#             col="black", 
#             weight = 3, 
#             layerId = ~iso_3166_2,
#             highlight = highlightOptions(color = "blue",weight = 2, 
#                                          bringToFront = F, opacity = 0.7)) %>%
