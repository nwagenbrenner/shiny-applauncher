library(leaflet)
library(ShinyDash)
# install_github('ShinyDash', 'trestletech')
#install_github('leaflet-shiny', 'jcheng5')

row <- function(...) {
  tags$div(class="row", ...)
}

col <- function(width, ...) {
  tags$div(class=paste0("span", width), ...)
}

actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

shinyUI(bootstrapPage(

  tags$head(tags$link(rel='stylesheet', type='text/css', href='styles.css')),
  leafletMap(
    "map", "100%", 400,
    initialTileLayer = "http://{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
    initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
    options=list(
      center = c(40.45, -110.85),
      zoom = 5,
      maxBounds = list(list(17, -180), list(59, 180))
    )
  ),

  tags$div(
      class = "container",
      tags$p(tags$br()),
    row(
      col(0, tags$br()),
      col(8, h2('Test WindNinja Interface'))
    ),

  tags$hr(),

    
    #tags$br(),
    row(
      col(
        3,
        selectInput("elevation", "Elevation input:",
                list("Upload DEM" = "uploadDem", 
                     "Select from map" = "swoopMap",
                     "Enter bounding box coordinates" = "boundingBox")),
        selectInput("vegetation", "Choose predominant vegetation type:",
                list("Grass" = "grass", 
                     "Shrubs" = "shrubs",
                     "Trees" = "trees")),
    
        selectInput("runType", "Choose simulation type:",
                list("Domain average" = "domainAvg", 
                     "Point initialization" = "pointInitialization",
                     "Weather model" = "wxModel"))
      )
      
      )
    )
))
