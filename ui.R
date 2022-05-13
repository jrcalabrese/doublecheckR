library(shiny)
library(shinyalert)
library(shinyWidgets)
library(shinythemes)
library(rsconnect)
library(tidyverse)
library(DT)

ui <-  navbarPage("doublecheckR by @jrosecalabrese", 
                  theme = shinytheme("flatly"), 
                  tabPanel("Upload", 
                           titlePanel("Upload your datafiles"),
                           sidebarLayout(
                             sidebarPanel(
                               
                               ## File 1
                               fileInput('file1', 'Data Entry #1',
                                         accept=c('text/csv', 
                                                  'text/comma-separated-values,text/plain', 
                                                  '.csv')),
                               tags$hr(),
                               #checkboxInput('header', 'Header', TRUE),
                               #radioButtons('sep', 'Separator',
                                #            c(Comma=',',
                                 #             Semicolon=';',
                                  #            Tab='\t'),
                                   #         ','),
                               #radioButtons('quote', 'Quote',
                                #            c(None='',
                                 #             'Double Quote'='"',
                                  #            'Single Quote'="'"),
                                   #         '"'),
                               
                               ## File 2
                               fileInput('file2', 'Data Entry #2',
                                         accept=c('text/csv', 
                                                  'text/comma-separated-values,text/plain', 
                                                  '.csv')),
                               tags$hr(),
                               #checkboxInput('header', 'Header', TRUE),
                               #radioButtons('sep', 'Separator',
                                #            c(Comma=',',
                                 #             Semicolon=';',
                                  #            Tab='\t'),
                                   #         ','),
                               #radioButtons('quote', 'Quote',
                                #            c(None='',
                                 #             'Double Quote'='"',
                                  #            'Single Quote'="'"),
                                   #         '"')
                               ),
                             
                             mainPanel(tableOutput("contents"))
                           )
                  ),
)

