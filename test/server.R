library(leaflet)
library(maps)

#default max upload size is 5MB, increase to 30.
options(shiny.maxRequestSize=30*1024^2)


# From a future version of Shiny
bindEvent <- function(eventExpr, callback, env=parent.frame(), quoted=FALSE) {
  eventFunc <- exprToFunction(eventExpr, env, quoted)
  
  initialized <- FALSE
  invisible(observe({
    eventVal <- eventFunc()
    if (!initialized)
      initialized <<- TRUE
    else
      isolate(callback())
  }))
}

textInputRow<-function (inputId, label, value = "") 
{
    div(style="display:inline-block",
        tags$label(label, `for` = inputId), 
        tags$input(id = inputId, type = "text", value = value, class="input-small"))
}

#----------------------------------------------------
#     server logic
#----------------------------------------------------
shinyServer(function(input, output, session) {
     
    runWN <- reactive({
      if(input$run_wn == 1){
         writeCfg()
         L<-system2("/home/natalie/windninja_trunk/build/src/cli/./WindNinja_cli", 
                    "/home/natalie/windninja_trunk/test_runs/bigbutte_domainAvg.cfg", 
                    stdout=TRUE, stderr=TRUE)
         paste(L, sep="\n")
      }
    })
    
    #attempt to pipe unbuffered WN stdout to UI
    runWN2 <- reactive({
      if(input$run_wn == 1){
         unlink ("wnpipe")
         system("mkfifo wnpipe")
         system(paste("/home/natalie/windninja_trunk/build/src/cli/./WindNinja_cli", 
                "/home/natalie/windninja_trunk/test_runs/bigbutte_domainAvg.cfg > wnpipe &",
                collapse=""))
         Sys.sleep (2)
         fileName="wnpipe"
         con=fifo(fileName,open="rt",blocking=TRUE)
         linn = " "
         while ( length(linn) > 0) {
           linn=scan(con,nlines=1,what="character", sep=" ", quiet=TRUE)
           cat(linn,"\n") #flush.console()
         }
         close(con)
         unlink ("wnpipe") 
       }
    })
    
    output$wn_progress <- renderText({
        runWN()
    })
    
  output$text1 <- renderText({ 
      paste("WindNinja messages could be directed here. Press the button and wait",
             "for a few seconds (to let the run finish) to see the output below.",
             "Should be able to pipe this in line by line",
             "so user can see status. For now it's just being read in as a full",
             "stream once the process ends.", collapse="")
    })
  
  writeCfg <- reactive({
      cat("num_threads = 1\n",file="windninja.cfg")
      if(input$elevation == "boundingBox"){
          cat(paste("north = ", input$northExtent, "\n", collapse=""),file="windninja.cfg", append=TRUE)
          cat(paste("south = ", input$southExtent, "\n", collapse=""),file="windninja.cfg", append=TRUE)
          cat(paste("east = ", input$eastExtent, "\n", collapse=""),file="windninja.cfg", append=TRUE)
          cat(paste("west = ", input$westExtent, "\n", collapse=""),file="windninja.cfg", append=TRUE)
      }
      else if(input$elevation == "uploadDem"){ #not sure about input$demFile$datapath...see ?inputFile
          cat(paste("elevation_file = ", input$demFile$datapath, "\n", collapse=""),file="windninja.cfg", append=TRUE)
      }
  })

#-------------------------------------------------------------
#   create elevation input options (bb or dem upload)
#-------------------------------------------------------------
  createSpace <- reactive({
      if(input$elevation == "boundingBox"){
          tags$br()
      }
  })
  createNbox <- reactive({
      if(input$elevation == "boundingBox"){
          textInputRow("northExtent", "North:", "42.8342")
      }
  })
  createSbox <- reactive({
      if(input$elevation == "boundingBox"){
          textInputRow("southExtent", "South:", "42.8322")
      }
  })
  createEbox <- reactive({
      if(input$elevation == "boundingBox"){
          textInputRow("eastExtent", "East:", "-113.0294")
      }
  })
  createWbox <- reactive({
      if(input$elevation == "boundingBox"){
          textInputRow("westExtent", "West:", "-113.2423")
      }
  })
  createDemUpload <- reactive({
      if(input$elevation == "uploadDem"){
          fileInput("demFile", "Upload DEM:", multiple=FALSE, accept=NULL)
      }
  })

  output$addExtraSpace <- renderUI({
      createSpace()
  })
  output$addExtraSpace2 <- renderUI({
      createSpace()
  })
  output$nField <- renderUI({
      createNbox()
  })
  output$sField <- renderUI({
      createSbox()
  })
  output$eField <- renderUI({
      createEbox()
  })
  output$wField <- renderUI({
      createWbox()
  })
  output$demUploader <- renderUI({
      createDemUpload()
  })
  

  # Create reactive values object to store our markers, so we can show 
  # their values in a table.
  values <- reactiveValues(markers = NULL)
  
  # Create the map; this is not the "real" map, but rather a proxy
  # object that lets us control the leaflet map on the page.
  map <- createLeafletMap(session, 'map')
  
  bindEvent(input$map_click, function() {
    values$selectedCity <- NULL
    if (!input$addMarkerOnClick)
      return()
    map$addMarker(input$map_click$lat, input$map_click$lng, NULL)
    values$markers <- rbind(data.frame(lat=input$map_click$lat,
                                       long=input$map_click$lng),
                            values$markers)
  })
  
  bindEvent(input$clearMarkers, function() {
    map$clearMarkers()
    values$markers <- NULL
  })
})  

