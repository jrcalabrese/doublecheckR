library(shiny)
library(shinythemes)
library(data.table)
library(DT)
library(qpcR)
library(readxl)
library(lubridate)
library(rsconnect)
library(tidyverse)

ui <- navbarPage("doublecheckR by @jrosecalabrese", 
                  theme = shinytheme("flatly"), 
                  tabPanel("Upload", 
                           titlePanel("Upload your datafiles"),
                           sidebarLayout(
                             sidebarPanel(
                               
                               ## File 1
                               fileInput('file1', 'Data Entry #1',
                                         accept = c(".xlsx")),
                               tags$hr(),
                               
                               ## File 2
                               fileInput('file2', 'Data Entry #2',
                                         accept = c(".xlsx")),
                               tags$hr(),
                               downloadButton("download")
                               
                             ),
                             
                             mainPanel(
                               #DT::dataTableOutput("contents"),
                               DT::DTOutput("print"))
                               #verbatimTextOutput("print"))
                           )
                  ),
)

server <- function(input, output, session) {

  good_size <- reactive({   
    inFile1 <- input$file1
    if (is.null(input$file1)) return(NULL)
    here1 <- readxl::read_excel(inFile1$datapath) %>% 
      select(Period:ObjEng) %>% filter(ObjEng!=88) %>%
      mutate(ClockStop = format(ymd_hms(ClockStop), "%H:%M:%S")) %>%
      mutate(ClockStart = format(ymd_hms(ClockStart), "%H:%M:%S")) %>% nrow()
    
    inFile2 <- input$file2
    if (is.null(input$file2)) return(NULL)
    here2 <- readxl::read_excel(inFile2$datapath) %>% dplyr::select(Period:ObjEng) %>% filter(ObjEng!=88) %>%
      mutate(ClockStop = format(ymd_hms(ClockStop), "%H:%M:%S")) %>%
      mutate(ClockStart = format(ymd_hms(ClockStart), "%H:%M:%S")) %>% nrow()
    
    good_size <- if_else(here1 < here2, here1, here2)
    return(good_size)
  })
  
  df1 <- reactive({
    req(good_size())
    inFile <- input$file1
    if (is.null(input$file1))
      return(NULL)
    readxl::read_excel(inFile$datapath) %>% dplyr::select(Period:ObjEng) %>% filter(ObjEng!=88) %>%
      mutate(ClockStop = format(ymd_hms(ClockStop), "%H:%M:%S")) %>%
      mutate(ClockStart = format(ymd_hms(ClockStart), "%H:%M:%S")) %>% head(good_size())
  })
  
  df2 <- reactive({
    req(good_size())
    inFile <- input$file2
    if (is.null(input$file2)) 
      return(NULL) 
    readxl::read_excel(inFile$datapath) %>% 
      select(Period:ObjEng) %>% filter(ObjEng!=88) %>%
      mutate(ClockStop = format(ymd_hms(ClockStop), "%H:%M:%S")) %>%
      mutate(ClockStart = format(ymd_hms(ClockStart), "%H:%M:%S")) %>% head(good_size())
  })
  
  name_of_file <- reactive({
    inFile <- input$file1
    x <- inFile$name
    x <- substr(x, 1, 5)
    x <- paste(x, "_Checked.csv", sep = "")
    return(x)
    
  })
  
  vals <- reactiveValues(x = NULL)
  
  observe({

    req(df1())
    req(df2())

    tbl_diffs <- which(df1() != df2(), arr.ind = TRUE)
    tbl_compare <- df2() %>% DT::datatable(selection = 'none', rownames = FALSE, edit = TRUE,
                                           options = list(dom = 'ft', pageLength = 10000)) # this is what keeps page length good! no more snapping! 
    for (i in seq_len(nrow(tbl_diffs))) {
      tbl_compare <- tbl_compare %>%
        formatStyle(
          columns = tbl_diffs[[i, "col"]], 
          backgroundColor = styleRow(tbl_diffs[[i, "row"]], c('yellow')))
    } 
    vals$x <- tbl_compare
  })
  
  output$print <- DT::renderDT({ vals$x })
  #output$print <- DT::renderDT( vals$x )
  output$contents <- DT::renderDataTable(vals$x)

  proxy <- dataTableProxy("contents")
  
  observeEvent(input$print_cell_edit, {
    info = input$print_cell_edit
    str(info)
    i = info$row
    j = info$col + 1
    v = info$value
    vals$x$x$data[i, j] <<- DT:::coerceValue(v, vals$x$x$data[i, j])
    replaceData(proxy, vals$x$x$data, resetPaging = FALSE, rownames = FALSE)
  })
  
  output$download <- downloadHandler(name_of_file, #"example.csv", 
                                     content = function(file){
                                       write.csv(vals$x$x$data, file, row.names = F)
                                     },
                                     contentType = "text/csv")
  
}

# Don't include these lines in the final product
# Just copy and paste them into your console

# Run the application 
shinyApp(ui = ui, server = server)

# Deploy app
#deployApp(appName = "doublecheckR", account="jrcalabrese")
