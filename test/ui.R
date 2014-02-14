library(leaflet)
library(ShinyDash)
#install_github('ShinyDash', 'trestletech')
#install_github('leaflet-shiny', 'jcheng5')

t<-read.table('date_time_zonespec.csv', header=TRUE, sep=",", stringsAsFactors=FALSE)

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

textInputRow<-function (inputId, label, value = "") 
{
    div(style="display:inline-block",
        tags$label(label, `for` = inputId), 
        tags$input(id = inputId, type = "text", value = value, class="input-small"))
}

shinyUI(bootstrapPage(

  tags$head(tags$link(rel='stylesheet', type='text/css', href='styles.css')),
  leafletMap(
    "map", "100%", 400,
    #initialTileLayer = "http://{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
    #initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
    options=list(
      center = c(40.45, -110.85),
      zoom = 5,
      maxBounds = list(list(17, -180), list(59, 180))
    )
  ),
  
  #row(
    #tags$br(),
    #col(1, tags$br()),
    #col(2, img(src = "wn-icon.png", height = 72, width = 72))
    #col(3, tags$br()),
    #col(4, h2('Test WindNinja Interface'))
  #),

  tags$div(
      class = "container",
      #tags$p(tags$br()),
    row(
      #tags$br(),
      col(5, h2('Test WindNinja Interface'))
      #col(1, img(src = "wn-icon.png", height = 72, width = 72))
    ),

  tags$hr(),

    #tags$br(),
    row(
      col(2.5,
        h4('1. Input'),
        selectInput("elevation", "Elevation input:",
                list("Select from map" = "swoopMap",
                     "Upload DEM" = "uploadDem", 
                     "Enter bounding box coordinates" = "boundingBox")),
                             
        htmlOutput("demUploader"),
        htmlOutput("nField"),
        htmlOutput("sField"),
        htmlOutput("wField"),
        htmlOutput("eField"),

        
    
        selectInput("initializationMethod", "Simulation type:",
                list("Domain average" = "domainAvg", 
                     "Point initialization" = "pointInitialization",
                     "Weather model" = "wxModel")),
        
        htmlOutput("inputHeightField"),

        htmlOutput("unitsInputHeightField"),


        htmlOutput("inputSpeedField"),
        htmlOutput("unitsInputSpeedField"),
        htmlOutput("inputDirectionField")

      ),
      col(3,
        tags$br(),
        tags$br(),
        selectInput("vegetation", "Vegetation type:",
                list("Grass" = "grass", 
                     "Shrubs" = "shrubs",
                     "Trees" = "trees")),
        selectInput("meshChoice", "Mesh choice:",
                list("Fine" = "fine", 
                     "Medium" = "medium",
                     "Coarse" = "coarse")),
        textInputRow("outputWindHeight", "Output wind height", "10.0"),
        radioButtons("unitsOutputWindHeight", "Units", c("ft" = "ft", "m" = "m"))
      ),
     
      col(3,
        h4('2. Additional options'),
        selectInput("timeZone", "Time zone:",
                c(t$ID[1:length(t$ID)]),
                t$ID[65]
                ),
        tags$br(),
        tags$br(),
        checkboxInput("dirunalInput", "Use dirunal wind", FALSE),
        checkboxInput("stabilityInput", "Use non-neutral stability", FALSE),
        tags$br()

      ),
      col(3,
        h4('3. Output'),
        h5("Choose output format(s):"),
        checkboxInput("outGoogleMaps", "Google Maps", TRUE),
        helpText(em("Viewable on your smart phone")), 
        checkboxInput("outGoogleEarth", "Google Earth", FALSE), 
        checkboxInput("outFire", "Fire Behavior", FALSE),
        checkboxInput("outShape", "Shape Files", FALSE),
        checkboxInput("outVtk", "VTK Files", FALSE)
      )
      ),
      
      tags$hr(),

      row(
      col(0.5, h5("Start run!")),
      col(2, actionButton('run_wn', img(src = "wn-icon.png", height = 40, width = 40))),
      col(8, htmlOutput("text1"), style = "color:grey"),
      col(4, htmlOutput('wn_progress'))
      ),
      
      tags$hr(),

      row(
      col(3, HTML('<a href="http://www.firemodels.org/index.php/windninja-introduction">About WindNinja</a>')),
      col(3, HTML('<a href="http://www.firemodels.org/index.php/windninja-support/windninja-contact-us">Contact</a>')),
      col(3, HTML('<a href="https://collab.firelab.org/software/projects/windninja">Development</a>'))
      ),
      
      tags$br()
    ) #end tags$div(class='container') 
))
