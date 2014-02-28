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
      
    tags$hr(),
    
    row(
      col(3, h2('Project Creator')),
      #col(1, img(src = "wn-icon.png", height = 40, width = 40)),
      #col(1.5, img(src = "burning_ninja_text3_web.png", height = 240, width = 120)),
      col(1, img(src = "wn-desktop.ico", height = 40, width = 40)),
      col(1, img(src = "FVSlogo.png", height = 40, width = 40))
    ),
    
    tags$hr(),
    
    row(
      col(8, h4('1. Choose the type of application you want to create.'))
    ),
    
    #tags$br(),
   
    row(
      col(4,
         radioButtons("shinyApp", " ", 
                    c( "WindNinja" = "windninja", 
                       "Forest Vegetation Simulator" = "fvs",
                       "High-resolution Surface Wind Data Access" = "hireswind" ))
         )
       ),
       
    tags$br(),
    
    row(
      col(8, h4('2. Enter an email address and project name to create your project space.'))
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
    ),
    
    tags$hr(),
    
    row(
      col(2, img("About")),
      col(2, img("Support"))
    ),
    
    row(
      tags$br(),
      col(2, HTML('<a href="http://www.firemodels.org/index.php/windninja-introduction">WindNinja</a>')),
      col(2, HTML('<a href="http://www.firemodels.org/index.php/windninja-support/windninja-contact-us">Contact</a>'))
    ),
    row(
      col(2, HTML('<a href="http://www.fs.fed.us/fmsc/fvs/">FVS</a>'))
    ),
    row(
      col(2, HTML('<a href="http://www.firemodels.org/index.php/windwizard-introduction/windwizard-publications">Wind Data Project</a>'))
    )
  )
))
