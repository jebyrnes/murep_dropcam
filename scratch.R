library(sf)
library(leaflet)

tracks <- read_sf("data/salem_sound_tracks.shp")

leaflet() |>
  addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Default Maptile",
                              options = providerTileOptions(noWrap = TRUE)) |>
  setView(lat = 42.5264892, lng = -70.8222588, zoom = 12) |>
  addPolylines(data = tracks,
               col = "red",
               weight = 3,
               layerId = ~`Youtube Li`,
               highlight = highlightOptions(color = "blue",weight = 5, 
                                            bringToFront = F, opacity = 1))
  addPolygons(data=us, 
              col="black", 
              weight = 3, 
              layerId = ~iso_3166_2,
              highlight = highlightOptions(color = "blue",weight = 2, 
                                           bringToFront = F, opacity = 0.7))
