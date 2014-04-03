library(shiny)
library(leaflet)
library(maps)
library(raster)
library(plotGoogleMaps)
#library(shinyIncubator)
library(maptools)
library(rgdal)

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
#    Add run button 
#----------------------------------------------------- 

  addRunButton <- reactive({
      if(length(input$firePerimeterFile) > 0){
          actionButton('run_wn', img(src = "wn-icon.png", height = 40, width = 40))
      }
      else{
          paste("")
      }
  })

  output$runButton <- renderUI({
      addRunButton()
  })
  
  addRunButtonText <- reactive({
      if(length(input$firePerimeterFile) > 0){
          h4("Start run!")
      }
      else{
          h4("Specify the fire perimeter input to get started.")
      }
  })
  
  output$runButtonText <- renderUI({
      addRunButtonText()
  })

#-----------------------------------------------------
#    write the cfg
#-----------------------------------------------------   

  writeCfg <- reactive({
  isolate({
      cfg<-"windninja.cfg"
      cat("num_threads = 2\n",file=cfg)
      
      cat("compute_friction_velocity = true\n",file=cfg, append=TRUE)
      cat("compute_emissions = true\n",file=cfg, append=TRUE)
      
      #move the zipped fire perimeter files to working dir and rename
      system(paste("mv ",  input$firePerimeterFile$datapath[1], "perimeter.zip"))
      shape_list<-unzip('perimeter.zip', list=TRUE)
      shp<-shape_list$Name[1]
      shp<-paste0(substr(shp, 1, nchar(shp)-4), ".shp") 
      unzip("perimeter.zip", exdir='perimeter')
      cat(paste0("fire_perimeter_file = perimeter/", shp, "\n"), file=cfg, append=TRUE)
      
      #use rgdal to get CRS
      dsn <- "perimeter"
      shp_base <- substr(shp, 1, nchar(shp)-4)
      sp<-readShapeSpatial(paste0(dsn, "/", shp_base))
      proj4string(sp) <- OGRSpatialRef(dsn=dsn, layer=shp_base)
      
      latlon_crs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=GRS80 +towgs84=0,0,0"
      
      #check for latlon CRS and transform if necessary
      if(proj4string(sp) != latlon_crs){
          sp<-spTransform(sp, CRS(latlon_crs))
      }
      
      
      
      north <- bbox(sp)[4]
      south <- bbox(sp)[2]
      east <- bbox(sp)[3]
      west <- bbox(sp)[1] 
      
      #!!!!!!!for testing!!!!
      #cat("elevation_file = long_draw_dem.tif\n",file=cfg, append=TRUE)  
      #fetch DEM based on fire perimeter
      cat(paste("fetch_elevation = dem.tif\n"), file=cfg, append=TRUE)
      cat(paste("elevation_source = us_srtm\n"), file=cfg, append=TRUE)
      cat(paste("north = ", north, "\n", collapse=""),file=cfg, append=TRUE)
      cat(paste("south = ", south, "\n", collapse=""),file=cfg, append=TRUE)
      cat(paste("east = ", east, "\n", collapse=""),file=cfg, append=TRUE)
      cat(paste("west = ", west, "\n", collapse=""),file=cfg, append=TRUE)
      
      cat("vegetation = grass\n", file=cfg, append=TRUE)
      cat(paste("time_zone = auto-detect\n", collapse=""), file=cfg, append=TRUE)
      cat(paste("initialization_method = ", input$initializationMethod, "\n", collapse=""), file=cfg, append=TRUE)

      if(input$initializationMethod == "domainAverageInitialization"){
          cat(paste("input_wind_height = ", input$inputWindHeight, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("units_input_wind_height = ", input$unitsInputWindHeight, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("input_speed = ", input$inputSpeed, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("input_speed_units = ", input$unitsInputSpeed, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("input_direction = ", input$inputDirection, "\n", collapse=""), file=cfg, append=TRUE)
      }
      if(input$diurnalInput == TRUE){
          cat("diurnal_winds = true\n", file=cfg, append=TRUE)
          cat(paste("uni_air_temp = ", input$inputAirTemp, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("air_temp_units = ", input$unitsInputAirTemp, "\n", collapse=""), file=cfg, append=TRUE)
      }
      if(input$stabilityInput == TRUE){
          cat("non_neutral_stability = true\n", file=cfg, append=TRUE)
          
      }
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          cat(paste("uni_cloud_cover = ", input$inputCloudCover, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("cloud_cover_units = ", input$unitsInputCloudCover, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("year = ", input$year, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("month = ", input$month, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("day = ", input$day, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("hour = ", input$hour, "\n", collapse=""), file=cfg, append=TRUE)
          cat(paste("minute = ", input$minute, "\n", collapse=""), file=cfg, append=TRUE)
      }
      cat("output_wind_height = 10\n", file=cfg, append=TRUE)
      cat("units_output_wind_height = m\n", file=cfg, append=TRUE)
      cat(paste("mesh_choice = ", input$meshChoice, "\n", collapse=""), file=cfg, append=TRUE)
      if(input$outFire == 1 || input$outGoogleMaps == 1){
          cat("write_ascii_output = true\n", file=cfg, append=TRUE)
      }
      if(input$outGoogleEarth == 1){
          cat("write_goog_output = true\n", file=cfg, append=TRUE)
      }
      })
  })
     
#-----------------------------------------------------
#   Start a WindNinja run
#-----------------------------------------------------

    createSubmittedMessage <- reactive({
        if(length(input$run_wn) > 0){ 
            if(input$run_wn == 1){
                paste("WindNinja run status:", collapse="")
            }
            else{
                paste("Specifiy input parameters above. When you are ready to do a run, Click the run button\n",
                      "and watch here for messages indicating that the run has completed and\n",
                      "the Google Maps output file has been created (if requested). This will take several seconds.", collapse="")
            }
        }
        else{
            paste("")
        }
    })
    
    output$runSubmittedMessage <- renderText({
      createSubmittedMessage()
  })
    
#    runWN <- reactive({
#        if(length(input$run_wn) > 0){ 
#            if(input$run_wn == 1){
#                unlink("windninja.cfg")
#                unlink("www/wind_vect.htm")
#                unlink("www/Legend*")
#                unlink("dem_*")
#                writeCfg()               
#                L<-system2("/home/natalie/windninja_trunk/build/src/cli/./WindNinja_cli", "windninja.cfg",
#                           stdout="wnout", stderr=TRUE)
                #L<-system2("WindNinja_cli", "windninja.cfg",
                #           stdout=TRUE, stderr=TRUE)
#                paste(L, sep="\n")
#            }
#        }
#    })
    
     #attempt to pipe unbuffered WN stdout to UI
    runWN <- reactive({
      if(length(input$run_wn) > 0 && input$run_wn == 1){
         #unlink("windninja.cfg")
         #unlink("www/wind_vect.htm")
         #unlink("www/Legend*")
         #unlink("dem_*")
         writeCfg()
         unlink ("wnpipe")
         system("mkfifo wnpipe")
         #system(paste("WindNinja_cli", 
         #       "windninja.cfg", ">> wnpipe",
         #       collapse=""), intern=FALSE, wait=FALSE)
         system(paste("NINJA_FILL_DEM_NO_DATA=YES", "/home/natalie/windninja_trunk/build/src/cli/WindNinja_cli", 
                "windninja.cfg", ">> wnpipe",
                collapse=""), intern=FALSE, wait=FALSE)
         fileName="wnpipe"
         con=fifo(fileName,open="rt",blocking=TRUE)
         linn = " "
         while ( length(linn) > 0) {
           linn=scan(con,nlines=1,what="character", sep=" ", quiet=TRUE)
           cat(linn,"\n"); flush.console()
         }
         close(con)
         unlink ("wnpipe")
         
       }
    })

    output$wnText <- renderPrint({
         runWN()   
    })
    
#-----------------------------------------------------
#   Download outputs
#-----------------------------------------------------

  createDownloadButton <- reactive({
      if(length(input$run_wn) > 0 && 
          input$run_wn == 1){ 

          downloadButton('downloadData', 'Download Output Files')
      }
  })
  
  output$downloadButton <- renderUI({
      createDownloadButton()
  }) 
  
  output$downloadData <- downloadHandler(
         filename = function() { paste("windninja_output", '.tar.gz', sep='') },
         content = function(file) {
           tar(file,".", compression="gzip") 
         }
  )

#---------------------------------------------------------
# convert ascii grids to Google Maps format and display
#---------------------------------------------------------
  convertToGoogleMaps <- reactive({  
      #isolate({
      if(length(input$run_wn) > 0){ 
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
                           mapTypeId='HYBRID',strokeWeight=2,
                           clickable=FALSE,openMap=FALSE)
                           
              system("mv wind_vect.htm Legend* www/")
              
              paste("")
              #paste("Google Maps output written.")
          }
      }
      else{
          paste("")
      }
      #isolate})
  })
  
  output$convertToGoogleMapsText <- renderUI({
      convertToGoogleMaps() #writes the Google Maps File 
    })

  displayMap <- reactive({
      if(length(input$run_wn) > 0 ){   
          if(input$run_wn==1 && 
             input$outGoogleMaps == 1 && 
             "wind_vect.htm" %in% dir("www")){
              tags$iframe(
                  srcdoc = paste(readLines('www/wind_vect.htm'), collapse = '\n'),
                  width = "100%",
                  height = "600px"
              )
          }
      }
  })

  output$mymap <- renderUI({
      displayMap()
  })


#-------------------------------------------------------------
#   create input wind fields for domain average runs
#-------------------------------------------------------------
  createHeightBox <- reactive({
      if(input$initializationMethod == "domainAverageInitialization"){
          textInputRow("inputWindHeight", "Input height:", "10.0")
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
          textInputRow("inputSpeed", "Wind speed:", "0.0")
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
          textInputRow("inputDirection", "Wind direction:", "0")
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

#-------------------------------------------------------------
#   create input option boxes for diurnal and stability
#-------------------------------------------------------------
  createSpace <- reactive({
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          tags$br()
      }
  })
  createYearbox <- reactive({
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          textInputRow("year", "Year:", "2014")
      }
  })
  createMonthbox <- reactive({
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          textInputRow("month", "Month:", "06")
      }
  })
  createDaybox <- reactive({
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          textInputRow("day", "Day:", "13")
      }
  })
  createHourbox <- reactive({
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          textInputRow("hour", "Hour:", "15")
      }
  })
  createMinutebox <- reactive({
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          textInputRow("minute", "Minute:", "30")
      }
  })

  output$addExtraSpace <- renderUI({
      createSpace()
  })
  output$yearField <- renderUI({
      createYearbox()
  })
  output$monthField <- renderUI({
      createMonthbox()
  })
  output$dayField <- renderUI({
      createDaybox()
  })
  output$hourField <- renderUI({
      createHourbox()
  })
  output$minuteField <- renderUI({
      createMinutebox()
  })
  
  createInputAirTempBox <- reactive({
      if(input$diurnalInput == TRUE){
          textInputRow("inputAirTemp", "Air temperature:", "72.0")
      }
  })
  createUnitsAirTempButtons <- reactive({
      if(input$diurnalInput == TRUE){
          #radioButtons("unitsInputAirTemp", "Units", c("F" = "F", "C" = "C"))
          selectInput("unitsInputAirTemp", "Units:",
                list("F" = "F", 
                     "C" = "C"))
      }
  })
  createInputCloudCoverBox <- reactive({
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          textInputRow("inputCloudCover", "Cloud cover:", "50")
      }
  })
  createUnitsCloudCoverButtons <- reactive({
      if(input$diurnalInput == TRUE || input$stabilityInput == TRUE){
          #radioButtons("unitsInputCloudCover", "Units", c("percent" = "percent", "fraction" = "fraction"))
          selectInput("unitsInputCloudCover", "Units:",
                list("percent" = "percent", 
                     "fraction" = "fraction"))
      }
  })

  output$inputAirTempField <- renderUI({
      createInputAirTempBox()
  })
  output$unitsInputAirTempField <- renderUI({
      createUnitsAirTempButtons()
  })
  output$inputCloudCoverField <- renderUI({
      createInputCloudCoverBox()
  })
  output$unitsInputCloudCoverField <- renderUI({
      createUnitsCloudCoverButtons()
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

