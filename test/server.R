library(shiny)
library(leaflet)
library(maps)
library(raster)
library(plotGoogleMaps)
#library(shinyIncubator)

#default max upload size is 5MB, increase to 30.
options(shiny.maxRequestSize=30*1024^2)

demFile <- NULL

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

# Make smaller, side-by-side text boxes
textInputRow<-function (inputId, label, value = "") 
{
    div(
        tags$label(label, `for` = inputId), 
        tags$input(id = inputId, type = "text", value = value, class="input-small"))
}


#==================================================================
#     server logic
#==================================================================

shinyServer(function(input, output, session) {

#-----------------------------------------------------
#    write the cfg
#-----------------------------------------------------   

  writeCfg <- reactive({
  isolate({
      cat("num_threads = 2\n",file="windninja.cfg")
      cat(paste("vegetation = ", input$vegetation, "\n", collapse=""), file="windninja.cfg", append=TRUE)

      if(input$elevation == "boundingBox"){
          cat(paste("fetch_elevation = dem.tif\n"), file="windninja.cfg", append=TRUE)
          cat(paste("elevation_source = us_srtm\n"), file="windninja.cfg", append=TRUE)
          cat(paste("north = ", input$northExtent, "\n", collapse=""),file="windninja.cfg", append=TRUE)
          cat(paste("south = ", input$southExtent, "\n", collapse=""),file="windninja.cfg", append=TRUE)
          cat(paste("east = ", input$eastExtent, "\n", collapse=""),file="windninja.cfg", append=TRUE)
          cat(paste("west = ", input$westExtent, "\n", collapse=""),file="windninja.cfg", append=TRUE)
      }

      else if(input$elevation == "uploadDem"){
          #move the file to working dir and rename
          if(length(input$demFile$datapath) == 2){
              system(paste("mv ",  input$demFile$datapath[1], " dem.asc"))
              system(paste("mv ",  input$demFile$datapath[2], " dem.prj"))
          }
          else{
              system(paste("mv ",  input$demFile$datapath, " dem.asc"))
          }
          demFile = "dem.asc"
          cat("elevation_file = dem.asc\n", file="windninja.cfg", append=TRUE)
      }
      cat(paste("time_zone = auto-detect\n", collapse=""), file="windninja.cfg", append=TRUE)
      cat(paste("initialization_method = ", input$initializationMethod, "\n", collapse=""), file="windninja.cfg", append=TRUE)

      if(input$initializationMethod == "domainAverageInitialization"){
          cat(paste("input_wind_height = ", input$inputWindHeight, "\n", collapse=""), file="windninja.cfg", append=TRUE)
          cat(paste("units_input_wind_height = ", input$unitsInputWindHeight, "\n", collapse=""), file="windninja.cfg", append=TRUE)
          cat(paste("input_speed = ", input$inputSpeed, "\n", collapse=""), file="windninja.cfg", append=TRUE)
          cat(paste("input_speed_units = ", input$unitsInputSpeed, "\n", collapse=""), file="windninja.cfg", append=TRUE)
          cat(paste("input_direction = ", input$inputDirection, "\n", collapse=""), file="windninja.cfg", append=TRUE)
      }

      cat(paste("output_wind_height = ", input$outputWindHeight, "\n", collapse=""), file="windninja.cfg", append=TRUE)
      cat(paste("units_output_wind_height = ", input$unitsOutputWindHeight, "\n", collapse=""), file="windninja.cfg", append=TRUE)
      cat(paste("mesh_choice = ", input$meshChoice, "\n", collapse=""), file="windninja.cfg", append=TRUE)
      if(input$outFire == 1 || input$outGoogleMaps == 1){
          cat("write_ascii_output = true\n", file="windninja.cfg", append=TRUE)
      }
      if(input$outGoogleEarth == 1){
          cat("write_goog_output = true\n", file="windninja.cfg", append=TRUE)
      }
      if(input$outShape == 1){
          cat("write_shapefile_output = true\n", file="windninja.cfg", append=TRUE)
      }
      if(input$outVtk == 1){
          cat("write_vtk_output = true\n", file="windninja.cfg", append=TRUE)
      }
      })
  })
     
#-----------------------------------------------------
#   Start a WindNinja run
#-----------------------------------------------------

    createSubmittedMessage <- reactive({
        if(input$run_wn == 1){
            paste("WindNinja run status:", collapse="")
            
        }
        else{
            paste("Click the run button and watch here for messages indicating that the run has completed and\n",
                  "the Google Maps output file has been created (if requested). This will take several seconds.", collapse="")
        }
    })
    
    output$runSubmittedMessage <- renderText({
      createSubmittedMessage()
  })
    
    runWN <- reactive({
      if(input$run_wn == 1){
         unlink("windninja.cfg")
         unlink("wind_vect.htm")
         unlink("Legend*")
         unlink("dem_*")
         writeCfg()
         L<-system2("/home/natalie/windinja_trunk/build/src/cli/./WindNinja_cli", "windninja.cfg",
                    stdout=TRUE, stderr=TRUE)
         #L<-system2("WindNinja_cli", "windninja.cfg",
         #           stdout=TRUE, stderr=TRUE)
         paste(L, sep="\n")
      }
    })
    
     #attempt to pipe unbuffered WN stdout to UI
#    runWN2 <- reactive({
#      if(input$run_wn == 1){
#         writeCfg()
#         unlink ("wnpipe")
#         system("mkfifo wnpipe")
#         system(paste("/home/natalie/windninja_trunk/build/src/cli/./WindNinja_cli", 
#                "/home/natalie/windninja_trunk/test_runs/bigbutte_domainAvg.cfg > wnpipe &",
#                collapse=""))
#         Sys.sleep (2)
#         fileName="wnpipe"
#         con=fifo(fileName,open="rt",blocking=TRUE)
#         linn = " "
#         while ( length(linn) > 0) {
#           linn=scan(con,nlines=1,what="character", sep=" ", quiet=TRUE)
#           cat(linn,"\n") #flush.console()
#         }
#         close(con)
#         unlink ("wnpipe") 
#       }
#    })
    
    output$wnText <- renderUI({
      runWN()
    })
    
    output$convertToGoogleMapsText <- renderUI({
      convertToGoogleMaps() #writes the Google Maps File 
    })
    
#-----------------------------------------------------
#   Download outputs
#-----------------------------------------------------

  createDownloadButton <- reactive({
      if(input$run_wn == 1){
          downloadButton('downloadData', 'Download Output Files')
      }
  })
  
  output$downloadButton <- renderUI({
      createDownloadButton()
  }) 
  
  output$downloadData <- downloadHandler(
         filename = function() { paste("windninja_output", '.tar', sep='') },
         content = function(file) {
           tar(file,".") 
         }
  )


#---------------------------------------------------------
# convert ascii grids to Google Maps format and display
#---------------------------------------------------------
  convertToGoogleMaps <- reactive({  
      #isolate({
      if(input$run_wn==1 && input$outGoogleMaps == 1){
          
          spdFiles<-system("ls -t | grep vel.asc", intern = TRUE)
          spd<-raster(spdFiles[1]) # get the most recent one
          
          angFiles<-system("ls -t | grep ang.asc", intern = TRUE)
          ang<-raster(angFiles[1]) # get the most recent one

          vectors<-brick(spd, ang)
          names(vectors)<-c("speed", "angle")

          vectors_sp<-rasterToPoints(vectors, spatial=TRUE)
          
          vectors_sp$angle<-vectors_sp$angle - 180
          vectors_sp$angle[vectors_sp$angle < 0] <- vectors_sp$angle[vectors_sp$angle < 0] + 360
          
          wind_vect=vectorsSP(vectors_sp, maxlength=200, zcol=c('speed','angle'))

          pal<-colorRampPalette(c("blue","green","yellow", "orange", "red"))
          m=plotGoogleMaps(wind_vect, zcol='speed', colPalette=pal(5),
                           mapTypeId='HYBRID',strokeWeight=2,openMap=FALSE)
                           
          paste("Google Maps output written.")
      }
      #isolate})
  })

  displayMap <- reactive({  
      if(input$run_wn==1 && input$outGoogleMaps == 1){
          tags$iframe(
              srcdoc = paste(readLines('wind_vect.htm'), collapse = '\n'),
              width = "100%",
              height = "600px"
          )
      }
  })

  output$mymap <- renderUI({
      displayMap()
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
          fileInput("demFile", "Upload DEM:", multiple=TRUE, accept=NULL)
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


#-------------------------------------------------------------
#   create input wind fields for domain average runs
#-------------------------------------------------------------
  createHeightBox <- reactive({
      if(input$initializationMethod == "domainAverageInitialization"){
          textInputRow("inputWindHeight", "Input height", "10.0")
      }
  })
  createUnitsHeightButtons <- reactive({
      if(input$initializationMethod == "domainAverageInitialization"){
          #radioButtons("unitsInputWindHeight", "Units", c("ft" = "ft", "m" = "m"))
          selectInput("unitsInputWindHeight", "Units:",
                list("ft" = "ft", 
                     "m" = "m"))
      }
  })
  createInputSpeedBox <- reactive({
      if(input$initializationMethod == "domainAverageInitialization"){
          textInputRow("inputSpeed", "Wind speed", "0.0")
      }
  })
  createUnitsSpeedButtons <- reactive({
      if(input$initializationMethod == "domainAverageInitialization"){
          #radioButtons("unitsInputSpeed", "Units", c("mph" = "mph", "m/s" = "mps"))
          selectInput("unitsInputSpeed", "Units:",
                list("mph" = "mph", 
                     "m/s" = "mps"))
      }
  })
  createDirectionBox <- reactive({
      if(input$initializationMethod == "domainAverageInitialization"){
          textInputRow("inputDirection", "Wind direction", "0")
      }
  })
  createOutputHeightBox <- reactive({
      textInputRow("outputWindHeight", "Output height:", "10.0")
  })
  createUnitsOutputHeightButtons <- reactive({
      #radioButtons("unitsOutputWindHeight", "Units", c("ft" = "ft", "m" = "m"))
      selectInput("unitsOutputWindHeight", "Units:",
                list("ft" = "ft", 
                     "m" = "m"))
  })
  
  output$inputHeightField <- renderUI({
      createHeightBox()
  })
  output$unitsInputHeightField <- renderUI({
      createUnitsHeightButtons()
  })
  output$inputSpeedField <- renderUI({
      createInputSpeedBox()
  })
  output$unitsInputSpeedField <- renderUI({
      createUnitsSpeedButtons()
  })
  output$inputDirectionField <- renderUI({
      createDirectionBox()
  })
  output$outputHeightField <- renderUI({
      createOutputHeightBox()
  })
  output$unitsOutputHeightField <- renderUI({
      createUnitsOutputHeightButtons()
  })
  
#----------------------------------------------------------------------
#  Use map to choose DEM
#----------------------------------------------------------------------

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

#==============================================================================
#         TESTING
#============================================================================== 
  
    createTestMessage <- reactive({
      paste("input$demFile$datapath = ", input$demFile$datapath, collapse = "")
  })
  output$testMessage <- renderUI({
      createTestMessage()
  })
  
  
  
})  

