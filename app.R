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

tracks <- read_sf("data/salem_sound_tracks.shp")

# Define UI for application that draws a histogram
ui <- fluidPage(
  leafletOutput("mymap"),
  uiOutput("video")
  
  
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$mymap <- renderLeaflet({
    # generate the map
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