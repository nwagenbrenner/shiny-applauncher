library(shiny)


shinyServer(function(input, output, session) {
#-----------------------------------------------------
#    Request user info and set up a project dir 
#-----------------------------------------------------
  
  generateEmail <- reactive({
          if(input$email == " " && input$project == " "){
              return(h4("Enter valid email address and project name."))
          }
          if(input$email == " "){
              return(h4("Enter valid email address."))
          }
          if(input$project == " "){
              return(h4("Enter project name."))
          }
          else{
              uuid<-system2("uuidgen", "-r", stdout=TRUE)
              system(paste("mkdir", uuid, sep=" "))
              system(paste0("cp serverWindNinja.R ", uuid, "/server.R"))
              system(paste0("cp uiWindNinja.R ", uuid, "/ui.R"))
              system(paste0("cp -r www/ ", uuid))
              system(paste0("cp ascii2vectorsSP.R ", uuid))
              
              
              system2("./mailMessage.bash", c(input$email, uuid))
              
              h4("Project created! An email has been sent with the link to your project page.")
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

