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

setwd(here::here())

tracks <- read_sf("data/tracks/salem_sound_tracks_density.shp") 
warning(names(tracks))

tracks <- tracks |>
  mutate(`Kelp Dens#` = ifelse(is.na(`Kelp Dens#`),0,`Kelp Dens#`))


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
    # column(1,
    #        checkboxGroupInput("layers",
    #                      "Basemap Choice",
    #                      choices = c("Gray Canvas"),
    #                      selected = "Gray Canvas"
    #                      ),
    #        
    #        checkboxGroupInput("data_sources",
    #                           "Data Sources",
    #                           choices = c("Dropcam Tracks",
    #                                       "Diver Biomass",
    #                                       "Sidescan Survey Area"),
    #                           selected = c("Dropcam Tracks"))
    #        ),
    
    column(8,
           HTML("<b>Click a Track to Open a Video</b>"),
           leafletOutput("mymap",
                         height = 700)
    ),
    
    column(4,
           HTML("<b>Video of Track</b>"),
           uiOutput("video")
    )
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
      addTiles(group = "OSM") %>%
      addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
      addProviderTiles(providers$Esri.WorldGrayCanvas, 
                       group = "ESRI World Gray Canvas",
                       options = providerTileOptions(noWrap = TRUE)) |>
      setView(lat = 42.5264892, lng = -70.8222588, zoom = 12) |>
      
      #the data
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
      addLegend("bottomright",
                pal = pal,
                values = tracks$`Kelp Dens#`,
                title = "Kelp Relative Abundance Score",
                opacity = 1
      ) %>%
      addLayersControl(
        baseGroups = c("OSM", "ESRI World Gray Canvas", "Toner", "Toner Lite"),
        overlayGroups = c("Dropcam Tracks", "Diver Biomass Surveys"),
        options = layersControlOptions(collapsed = FALSE)
      ) 
    
    
  })
  
  selected_track <- reactive({
    p <- input$mymap_shape_click
  })
  
  
  
  observeEvent(input$data_sources, {
    proxy <- leafletProxy('mymap')
    if (!("Dropcam Tracks" %in% input$data_sources)){ proxy %>% removeShape(`Kelp Dens#`)}
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
