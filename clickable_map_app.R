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
library(rnaturalearth)

us <- ne_states("united states of america", returnclass = "sf")

# Define UI for application that draws a histogram
ui <- fluidPage(
  leafletOutput("mymap"),
  verbatimTextOutput("stuff")
  
  
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$mymap <- renderLeaflet({
    # generate the map
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Default Maptile",
                       options = providerTileOptions(noWrap = TRUE)) %>%
      setView(lng = -95.0491410487803, lat = 38.8977674296551, zoom = 4)%>%
      addPolygons(data=us, col="black", 
                  weight = 1, 
                  layerId = ~iso_3166_2,
                  highlight = highlightOptions(color = "blue",weight = 2, 
                                               bringToFront = F, opacity = 0.7))
    
  })
  
  selected_zone <- reactive({
    p <- input$mymap_shape_click
  })
  
  
  output$stuff <- renderPrint(
    print(selected_zone())
  )
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
