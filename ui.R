library(shiny)

row <- function(...) {
  tags$div(class="row", ...)
}

col <- function(width, ...) {
  tags$div(class=paste0("span", width), ...)
}

shinyUI(bootstrapPage(
  tags$head(tags$link(rel='stylesheet', type='text/css', href='styles.css')),
  tags$div(
      class = "container",
    row(
      col(5, h2('WindNinja Project Creator'))
    ),
    
    tags$hr(),
    
    row(
      col(8, h5('Enter an email address and project name to create your project space.'))
    ),
    
    tags$br(),

    row(
      col(4,
         textInput("email", "Email:", " ")
      )
    ),
    row(
      col(4,
         textInput("project", "Project:", " ")
      )
    ),
    
    tags$br(),
    
    row(
      col(8,
        actionButton('createProject', "Create Project")
      )
    ),
    
    tags$br(),
    
    row(
      col(8,
        htmlOutput("projectText")# style = "color:darkblue"),
      )
    )
      
  )
))
