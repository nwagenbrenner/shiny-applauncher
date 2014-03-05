library(shiny)

uuid <- ""

shinyServer(function(input, output, session) {
#-----------------------------------------------------
#    Request user info and set up a project dir 
#-----------------------------------------------------
  
  makeNinja<-function(){
      system(paste0("cp windninja/server.R ../userWork/", uuid))
      system(paste0("cp windninja/ui.R ../userWork/", uuid))
      system(paste0("cp -r windninja/www/ ../userWork/", uuid))
      system(paste0("cp windninja/ascii2vectorsSP.R ../userWork/", uuid))
      system2("./mailMessage.bash", c(input$email, uuid, "WindNinja", "webNinja", input$project))
      h4("WindNinja project created! An email has been sent with the link to your project page.")
  }
  makeFVS<-function(){
      system(paste0("cp -r fvs/* ../userWork/", uuid))
      system2("./mailMessage.bash", c(input$email, uuid, "FVS", "webFVS", input$project))
      h4("FVS project created! An email has been sent with the link to your project page.")
  }
  makeHiresWind<-function(){
      system(paste0("cp -r hiresWind/* ../userWork/", uuid))
      system2("./mailMessage.bash", c(input$email, uuid, "WindData", "webWindData", input$project))
      h4("Wind Data project created! An email has been sent with the link to your project page.")
  }

  
  generateEmail <- reactive({
          if(input$email == " " && input$project == " "){
              return(h4("Enter valid email address and project name.", style = "color:red"))
          }
          if(input$email == " "){
              return(h4("Enter valid email address.", style = "color:red"))
          }
          if(input$project == " "){
              return(h4("Enter project name.", style = "color:red"))
          }
          else{
              uuid<<-system2("uuidgen", "-r", stdout=TRUE)
              system(paste0("mkdir ../userWork/", uuid))
              
              idFile<-paste0("../userWork/",uuid,"/id.txt")
              cat(paste("email = ", input$email, "\n", collapse=""), file=idFile)
              cat(paste("project type = ", input$shinApp, "\n", collapse=""), file=idFile, append=TRUE)
              cat(paste("project name = ", input$project, "\n", collapse=""), file=idFile, append=TRUE)
              
              if(input$shinyApp == "windninja"){
                  makeNinja()
              }
              else if(input$shinyApp == "fvs"){
                 makeFVS()
              }
              else if(input$shinyApp == "hireswind"){
                 makeHiresWind()
              }
          }
  })
  
  addCreateProjectText <- reactive({
      if(input$createProject > 0){
          isolate({
              generateEmail()
          })
           
      }
  })
  
  output$projectText <- renderUI({
      addCreateProjectText()
  })  
  
})  

