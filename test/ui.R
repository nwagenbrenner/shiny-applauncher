library(leaflet)
library(ShinyDash)
library(shinyIncubator)
library(shiny)
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
    div(
        tags$label(label, `for` = inputId), 
        tags$input(id = inputId, type = "text", value = value, class="input-small"))
}

shinyUI(bootstrapPage(
  tags$head(tags$link(rel='stylesheet', type='text/css', href='styles.css'), 
           tags$style("label.radio { display: inline-block; }", ".radio input[type=\"radio\"] { float: none; }")
           ),
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
  

  tags$div(
      class = "container",
    row(
      col(5, h2('Test WindNinja Interface'))
    ),

  tags$hr(),

    row(
      col(3.5,
        h4('1. Input'),
        selectInput("elevation", "Elevation input:",
                list(#"Select from map" = "swoopMap",
                     "Upload DEM" = "uploadDem", 
                     "Enter bounding box coordinates" = "boundingBox")),

        div(style="width:220px", htmlOutput("demUploader")),
        
        div(style="display:inline-block", htmlOutput("nField")),
        div(style="display:inline-block", htmlOutput("sField")),
        tags$br(),
        div(style="display:inline-block", htmlOutput("wField")),
        div(style="display:inline-block", htmlOutput("eField")),
        
        tags$br(),
        tags$br(),
    
        selectInput("initializationMethod", "Simulation type:",
                list("Domain average" = "domainAverageInitialization")), 
                     #"Point initialization" = "pointInitialization",
                     #"Weather model" = "wxModelInitialization")),
        
        tags$br(),
        
        div(style="display:inline-block", htmlOutput("inputHeightField")),
        div(class="input-mini",style="display:inline-block",htmlOutput("unitsInputHeightField")),
        
        tags$br(),

        div(style="display:inline-block", htmlOutput("inputSpeedField")),
        div(class="input-mini",style="display:inline-block; width: 20px;",htmlOutput("unitsInputSpeedField")),
        
        tags$br(),
        
        htmlOutput("inputDirectionField"),

        selectInput("vegetation", "Vegetation type:",
                list("Grass" = "grass", 
                     "Shrubs" = "shrubs",
                     "Trees" = "trees")),
        selectInput("meshChoice", "Mesh choice:",
                list("Coarse" = "coarse",
                     "Medium" = "medium",
                     "Fine" = "fine"
                     )),
        tags$br(),
               
        div(style = "display:inline-block ", htmlOutput("outputHeightField")),
        div(style = "display:inline-block; width: 20%;",htmlOutput("unitsOutputHeightField"))
      ),
     
      col(3,
        h4('2. Additional options'),
        selectInput("timeZone", "Time zone:",
                c(t$ID[1:length(t$ID)]),
                t$ID[65]
                ),

        checkboxInput("dirunalInput", "Use dirunal wind", FALSE),
        helpText("(Not active)"),
        checkboxInput("stabilityInput", "Use non-neutral stability", FALSE),
        helpText("(Not active)"),
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
      
      col(8, textOutput("runSubmittedMessage")),# style = "color:darkblue"),
      #col(8, textOutput("runFinishedMessage"), style = "color:blue"),
      col(4, htmlOutput('wnText')),# style = "color:darkblue"),
      col(4, htmlOutput('convertToGoogleMapsText')),# style = "color:darkblue")
      tags$br(),
      col(8, htmlOutput('downloadButton'))
      ),
      
      tags$br(),
      
      row(
      col(8,
          tags$br(),
          uiOutput('mymap')
      )
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
