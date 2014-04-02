library(leaflet)
library(ShinyDash)
library(shiny)

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

shinyUI(fluidPage(

  fluidRow(
    column(12,
      h2("Test WindNinja-Dust Interface"),
     
      hr()

    )
  ),

  #titlePanel("Test WindNinja-Dust Interface"),

  #title = 'Test WindNinja-Dust Interface',
      
  fluidRow(
    column(4, 
      wellPanel(
      h4('1. Input'),
        
      div(style="width:220px", 
          fileInput("firePerimeterFile", "Upload fire perimeter:", multiple=TRUE, accept=NULL)
         ),
         
      selectInput("initializationMethod", "Wind input:",
                list("Domain average" = "domainAverageInitialization")), 
                     #"Point initialization" = "pointInitialization",
                     #"Weather model" = "wxModelInitialization")),
        
      br(),
        
      div(style="display:inline-table", htmlOutput("inputHeightField")),
      div(style="display:inline-table; width: 70px",htmlOutput("unitsInputHeightField")),
        
      br(),

      div(style="display:inline-table", htmlOutput("inputSpeedField")),
      div(style="display:inline-table; width: 70px;",htmlOutput("unitsInputSpeedField")),
        
      br(),
        
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
      br(),
               
      div(style = "display:inline-table", htmlOutput("outputHeightField")),
      div(style = "display:inline-table; width: 70px",htmlOutput("unitsOutputHeightField"))
      )           
    ),

    column(3,
      wellPanel(
      h4('2. Additional options'),
      
      checkboxInput("diurnalInput", "Use diurnal wind", FALSE),
      checkboxInput("stabilityInput", "Use non-neutral stability", FALSE),
      
      br(),
      
      div(style="display:inline-table", htmlOutput("yearField")),
      div(style="display:inline-table", htmlOutput("monthField")),
      #br(),
      div(style="display:inline-table", htmlOutput("dayField")),
      div(style="display:inline-table", htmlOutput("hourField")),
      div(style="display:inline-table", htmlOutput("minuteField")),
        
      br(),
      br(),
        
      div(style="display:inline-table", htmlOutput("inputAirTempField")),
      div(style="display:inline-table; width: 90px",htmlOutput("unitsInputAirTempField")),
        
      br(),

      div(style="display:inline-table", htmlOutput("inputCloudCoverField")),
      div(style="display:inline-table; width: 90px;",htmlOutput("unitsInputCloudCoverField")),
        
      br()
      )
  
    ),
    column(3,
      wellPanel(
      h4('3. Output'),
      h5("Choose output format(s):"),
      checkboxInput("outGoogleMaps", "Google Maps", TRUE),
      helpText(em("Viewable on your smart phone")), 
      checkboxInput("outGoogleEarth", "Google Earth", FALSE), 
      checkboxInput("outFire", "ASCII files", FALSE)
      )
    )
  ),
  
  tags$hr(),
      
  fluidRow(
    column(1, htmlOutput('runButtonText')),
    column(1, htmlOutput('runButton')),
      
    column(1, textOutput("runSubmittedMessage")),# style = "color:darkblue"),
    column(1, textOutput("runFinishedMessage")),
    column(1, htmlOutput('wnText')),
    column(1, htmlOutput('convertToGoogleMapsText')),# style = "color:darkblue")
    tags$br(),
    column(1, htmlOutput('downloadButton'))
  ),
      
  tags$br(),
      
  fluidRow(
    column(11,
      tags$br(),
      uiOutput('mymap')
    )
  ),
      
  tags$br(),

  fluidRow(
    column(3, htmlOutput('cleanupButton')) 
  ),

  fluidRow(
    column(3, htmlOutput('cleanupText'))
  ),

  tags$hr(),

  fluidRow(
    column(3, HTML('<a href="http://www.firemodels.org/index.php/windninja-introduction">About WindNinja</a>')),
    column(3, HTML('<a href="http://www.firemodels.org/index.php/windninja-support/windninja-contact-us">Contact</a>')),
    column(3, HTML('<a href="https://collab.firelab.org/software/projects/windninja">Development</a>'))
  ),
      
  tags$br()
  
  ))
  


