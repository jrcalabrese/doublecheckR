library(shiny)
library(shinyalert)
library(shinyWidgets)
library(shinythemes)
library(rsconnect)
library(tidyverse)
library(DT)

source("ui.R")
source("global.R")

server <- function(input, output, session) {
  
  df1 <- reactive({
    inFile <- input$file1
    if (is.null(input$file1))
      return(NULL)
    read.csv(inFile$datapath)
    })
  
  df2 <- reactive({
    inFile <- input$file2
    if (is.null(input$file2))
      return(NULL)
    read.csv(inFile$datapath)
  })
  
  
  output$contents <- renderTable({
    
    req(df1())
    req(df2())
    
    compare_me(df1(), df2())
  })
  
}
# Do not include below lines in final code
# Just copy and paste into console

# Run the application 
#shinyApp(ui = ui, server = server)

# Deploy app
#deployApp(appName="doublecheckR", account="jrcalabrese")

