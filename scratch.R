library(sf)
library(leaflet)
library(dplyr)

tracks <- read_sf("data/tracks/salem_sound_tracks_density.shp") |>
  mutate(`Kelp Dens#` = ifelse(is.na(`Kelp Dens#`),0,`Kelp Dens#`))
  #rename(`YouTube Li` = Youtube.Li) #deal with difference in versions of sf

biomass <- read_sf("data/biomass/salem_sound_dive_locs.shp")

ss <- readRDS("data/Sidescan/sss_coverage.rds")


pal <- colorNumeric(
  palette = "Greens",
  domain = tracks$`Kelp Dens#`)


pal_biomass <- colorNumeric(
  palette = "PuOr",
  domain = biomass$`Mean SL bi`)

leaflet() |>
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
  addProviderTiles(providers$Esri.WorldGrayCanvas, 
                   group = "ESRI World Gray Canvas",
                              options = providerTileOptions(noWrap = TRUE)) |>
  setView(lat = 42.5264892, lng = -70.8222588, zoom = 12) |>
  addPolygons(data = ss,
              fill = "darkblue",
              color = "darkblue",
              weight = 1,
              opacity = 0.8,
              group = "Sidescan Areas") |>
  addPolylines(data = tracks,
               col = ~pal(`Kelp Dens#`),
               weight = 3,
               layerId = ~`YouTube Li`,
               highlight = highlightOptions(color = "blue",weight = 5,
                                            bringToFront = F, opacity = 1),
               group = "Dropcam Tracks") %>%
    addLegend("bottomright",
              pal = pal,
              values = tracks$`Kelp Dens#`,
              title = "Kelp Relative Abundance Score",
              opacity = 1
    ) %>%
  addLayersControl(
    baseGroups = c("OSM (default)", "ESRI World Gray Canvas", "Toner", "Toner Lite"),
    overlayGroups = c("Dropcam Tracks", "Diver Biomass Surveys", "Sidescan Areas"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addPolygons(data = biomass,
              fill = "black",
              stroke = TRUE,
              color = ~pal_biomass(`Mean SL bi`),
              popup = ~paste(name, `Mean SL bi`),
              weight = 1.5,
              opacity = 0.8,
              group = "Diver Biomass Surveys") 





# addPolygons(data=us, 
#             col="black", 
#             weight = 3, 
#             layerId = ~iso_3166_2,
#             highlight = highlightOptions(color = "blue",weight = 2, 
#                                          bringToFront = F, opacity = 0.7)) %>%
