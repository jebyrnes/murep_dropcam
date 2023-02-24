#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(RColorBrewer)
library(ggplot2)

setwd(here::here())

tracks <- read_sf("data/tracks/salem_sound_tracks_density.shp") 
#warning(names(tracks))

tracks <- tracks |>
  mutate(`Kelp Dens#` = ifelse(is.na(`Kelp Dens#`),0,`Kelp Dens#`))

biomass <- read_sf("data/biomass/salem_sound_dive_locs.shp")

#sidescan areas
ss <- readRDS("data/Sidescan/sss_coverage.rds")


pal <- colorNumeric(
  palette = "Greens",
  domain = tracks$`Kelp Dens#`)


pal_biomass <- colorNumeric(
  palette = "PuOr",
  domain = biomass$`Mean SL bi`)

# Define UI for application that draws a histogram

ui <- fluidPage(
  titlePanel("The Subtidal Environment of Salem Sound"),
  
  fluidRow(
  
    
    column(7,
           HTML("<b>Click a Track to Open a Video</b>"),
           leafletOutput("mymap",
                         height = 600)
    ),
    
    column(5,
           HTML("<b>Video of Track</b>"),
           uiOutput("video")
    )
  ),
  
  fluidRow(
    br(),br(),
    img(src='nasa-logo-web-rgb_small.jpg', align = "left", height = 50),
    img(src='umb_logo.png', align = "left", height = 50),
    HTML("&nbsp; &nbsp; Data from <A href=https://www.nasa.gov/stem/murep/home/index.html>NASA MUREP</a> grant <a href=https://msiexchange.nasa.gov/attachments/4fac5315dbada300f8ebfd0e0f961966/award_abstract_University%20of%20Mass%20Boston%20OCEAN%202020.pdf>Using Hyperspectral Imagery to Assess the Effects of Warming on New England Kelp Forests</a>")
    
  )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  output$mymap <- renderLeaflet({
    # generate the map
    # leaflet() |>
    #   addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Default Maptile",
    #                    options = providerTileOptions(noWrap = TRUE)) |>
    #   setView(lat = 42.5264892, lng = -70.8222588, zoom = 12) |>
    #   addPolylines(data = tracks,
    #                col = ~pal(`Kelp Dens#`),
    #                weight = 3,
    #                layerId = ~ `YouTube Li`,
    #                highlight = highlightOptions(color = "blue",weight = 5, 
    #                                             bringToFront = F, opacity = 1)) %>%
    #   addLegend("bottomright", 
    #             pal = pal, 
    #             values = tracks$`Kelp Dens#`,
    #             title = "Kelp Relative Abundance Score",
    #             opacity = 1
    #   )
    # 
    
    leaflet() |>
      
      #the setup
      addProviderTiles(providers$Esri.WorldTopoMap, group = "Topo Map") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "World Imagery") %>%
      addProviderTiles(providers$Esri.WorldGrayCanvas, 
                       group = "ESRI World Gray Canvas",
                       options = providerTileOptions(noWrap = TRUE)) |>
      setView(lat = 42.5264892, lng = -70.8222588, zoom = 12) |>
      
      #the data
      addPolygons(data = ss,
                  fill = "grey",
                  color = "grey",
                  weight = 1,
                  opacity = 0.8,
                  group = "Sidescan Areas") |>
      
      addPolygons(data = biomass,
                  fill = "black",
                  stroke = TRUE,
                  color = ~pal_biomass(`Mean SL bi`),
                  popup = ~paste(name, `Mean SL bi`),
                  weight = 1.5,
                  opacity = 0.8,
                  group = "Diver Biomass Surveys") |>
      addPolylines(data = tracks,
                   col = ~pal(`Kelp Dens#`),
                   weight = 3,
                   layerId = ~`YouTube Li`,
                   highlight = highlightOptions(color = "blue",weight = 5,
                                                bringToFront = F, opacity = 1),
                   group = "Dropcam Tracks") %>%
      
      # add controls, legends, etc.
      addLegend("bottomright",
                pal = pal,
                values = tracks$`Kelp Dens#`,
                title = "Kelp Relative <br>Abundance Score",
                opacity = 1
      ) %>%
      addLegend("bottomleft",
                pal = pal_biomass,
                values = biomass$`Mean SL bi`,
                title = "Mean Sugar Kelp <br>Wet Biomass (kg)",
                opacity = 1
      ) %>%
      addLayersControl(
        baseGroups = c("Topo Map", "ESRI World Gray Canvas", "World Imagery"),
        overlayGroups = c("Dropcam Tracks", "Diver Biomass Surveys", "Sidescan Areas"),
        options = layersControlOptions(collapsed = FALSE)
      ) 
    
    
  })
  
  selected_track <- reactive({
    p <- input$mymap_shape_click
  })
  
  
  
  output$video <- renderUI({
#    print(selected_track())
    url <- selected_track()$id
    url <- gsub("youtu\\.be/", "www.youtube.com/embed/", url)
    
#    HTML(paste0('<iframe width="200" height="100" src="', url, '" frameborder="0" allowfullscreen></iframe>'))
    HTML(paste0(
      '<html>
        <body>
          <iframe id="existing-iframe"
              width="100%" height="360"
              src="',url,'" ###This URL needs to change dynamically based on which link the user clicks in output$table
              frameborder="0"
          ></iframe>

          <script type="text/javascript">
            var tag = document.createElement(\'script\');
            tag.src = \'https://www.youtube.com/iframe_api\';
            var firstScriptTag = document.getElementsByTagName(\'script\')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
              player = new YT.Player(\'existing-iframe\');
            }
          </script>
        </body>
      </html>'))
      
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
