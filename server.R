library(shiny)

uuid <- ""

shinyServer(function(input, output, session) {
#-----------------------------------------------------
#    Request user info and set up a project dir 
#-----------------------------------------------------
  
  makeNinja<-function(){
      system(paste0("cp serverWindNinja.R ../userWork/ ", uuid, "/server.R"))
      system(paste0("cp uiWindNinja.R ../userWork", uuid, "/ui.R"))
      system(paste0("cp -r www/ ../userWork", uuid))
      system(paste0("cp ascii2vectorsSP.R ../userWork", uuid))
  }
  
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
              uuid<<-system2("uuidgen", "-r", stdout=TRUE)
              system(paste("mkdir ../userWork", uuid, sep=" "))
              
              if(input$shinyApp == "windninja"){
                  makeNinja()
                  system2("./mailMessage.bash", c(input$email, uuid, input$shinyApp))
                  h4("WindNinja project created! An email has been sent with the link to your project page.")
              }
              else if(input$shinyApp == "fvs"){
                  h4("Try again, only WindNinja is currently available.")
              }
              else if(input$shinyApp == "hireswind"){
                  h4("Try again, only WindNinja is currently available.")
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

