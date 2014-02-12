library(leaflet)
library(ShinyDash)
#install_github('ShinyDash', 'trestletech')
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
      #tags$p(tags$br()),
    row(
      col(8, h2('Test WindNinja Interface'))
    ),

  tags$hr(),

    
    #tags$br(),
    row(
      col(3,
        h4('1. Input'),
        selectInput("elevation", "Elevation input:",
                list("Select from map" = "swoopMap",
                     "Upload DEM" = "uploadDem", 
                     "Enter bounding box coordinates" = "boundingBox")),
        tags$br(),
        selectInput("vegetation", "Vegetation type:",
                list("Grass" = "grass", 
                     "Shrubs" = "shrubs",
                     "Trees" = "trees")),
    
        selectInput("runType", "Simulation type:",
                list("Domain average" = "domainAvg", 
                     "Point initialization" = "pointInitialization",
                     "Weather model" = "wxModel"))
      ),
      
      col(3,
        h4('2. Additional options'),
        selectInput("meshResolution", "Mesh resolution:",
                list("Fine" = "fine", 
                     "Medium" = "medium",
                     "Coarse" = "coarse")),
        selectInput("timeZone", "Time zone:",
                list("America/Boise" = "america_boise")),
        tags$br(),
        checkboxInput("dirunalInput", "Use dirunal wind", FALSE),
        tags$br(),
        checkboxInput("stabilityInput", "Use non-neutral stability", FALSE),
        tags$br()

      ),
      col(3,
        h4('3. Output'),
        selectInput("outputFiles", "Output:",
                list("Google Earth" = "google", 
                     "Fire Behavior" = "fire",
                     "Shape Files" = "shape",
                     "VTK Files" = "vtk"))
      )
      ),
      
      tags$hr(),

      row(
      col(3, downloadButton('run_wn', 'Run WindNinja'))
      )
      
    )
))
