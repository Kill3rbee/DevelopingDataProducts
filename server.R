library(shiny)
library(shinydashboard)
source("webapp.R")
cwetitles <- sort(unique(mapCVEEXPLOIT$cwetitle))
cveNames <- names(mapCVEEXPLOIT)
function(input, output) {
  #Reactive functions ###########################################
  # Initialize reactive values
  #values <- reactiveValues()
  #values$cwetitles <- cwetitles
  # use a reactive value to represent group level selection
  values <- reactiveValues()
  values$cwetitles <- cwetitles
  
  # Prepare dataset
  mainTable <- reactive({
    #subset(mainTable(),cveid, year, cwetitle, summary, exploitdbscripturl)
    if(is.null(input$cwetitles) || input$cwetitles == '')
      req(values$value)
        else {
      groupByCWETitle(mapCVEEXPLOIT,input$timeline[1], 
                      input$timeline[2], input$risk[1],
                      input$risk[2], input$cwetitles)
    }

  })
  #cveData <- reactive({
  #  groupAllCVEID(mapCVEEXPLOIT,input$timeline[1], 
  #                input$timeline[2], input$risk[1],
  #                input$risk[2])
  #})
  
  dataTableByCveYear <- reactive({
    groupByYearCve(mapCVEEXPLOIT,input$timeline[1], 
                   input$timeline[2], input$risk[1],
                   input$risk[2], input$cwetitles)
  })
  
  dataTableByRiskAvg <- reactive({
    groupByRiskAvg(mapCVEEXPLOIT, input$timeline[1], 
                    input$timeline[2], input$risk[1],
                    input$risk[2], input$cwetitles)
  })
  
  dataTableDist <- reactive({
    wascTopTen(mainTable())
  })
  
  cvetable <- reactive({
    #data<-dataTable()
    #subset(mainTable(),cveid, year, cwetitle, summary, exploitdbscripturl)
    if(is.null(input$cwetitles) || input$cwetitles == '')
      req(values$value)
    else {
      cveToDisplay(mainTable())
    }
    
    #cveToDisplay(mainTable(),input$timeline[1],input$timeline[2],
    #             input$risk[1],input$risk[2], input$cwetitles)
    
  })
  
  #Input Functions ##############################################

  #Output Functions ##############################################
  # Create event type checkbox
  output$cwetitlesControl <- renderUI({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...', value = 0, {
                   for (i in 1:15) {
                     incProgress(1/15)
                     Sys.sleep(0.25)
                   }
                 })
    checkboxGroupInput('cwetitles', 'CWE Titles:',choices = cwetitles, 
                       selected = values$cwetitles)
  })
  
  #Observer functions ###########################################
  # Add observer on select-all button
  #observeEvent(input$selectAll, {
  #if(is.null(input$selectAll))
  #  values$cwetitles <- cwetitles
  #values$cwetitles <- cwetitles
  #})
  observe({
    if(input$selectAll == 0) return()
    #cwetitles
    values$cwetitles <- cwetitles
  })
  
  # Add observer on clear-all button
  #observeEvent(input$clearAll, {
  #if(input$clearAll == 0) return()
  #cwetitles <- c() # empty list
  #  values$cwetitles <- c() # empty list
  #})
  observe({
    if(input$clearAll == 0) return()
    #cwetitles <- c() # empty list
    values$cwetitles <- NULL # empty list
  })
  # End of Observer functions ######################################
  
  # Render data table
  output$mtable <- renderDataTable({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...', value = 0, {
                   for (i in 1:15) {
                     incProgress(1/15)
                     Sys.sleep(0.25)
                   }
                 })
    mainTable()
  })
    
 output$table <- renderDataTable({
    withProgress(message = 'Loading CVE data in progress',
                 detail = 'Please Standby...', value = 0, {
                   for (i in 1:10) {
                     incProgress(1/10)
                     Sys.sleep(0.1)  }})
    expr= datatable(cvetable(), escape=FALSE)

  })
 
 output$webtable <- renderDataTable({
   withProgress(message = 'Loading CVE data in progress',
                detail = 'Please Standby...', value = 0, {
                  for (i in 1:10) {
                    incProgress(1/10)
                    Sys.sleep(0.1)  }})
   expr= datatable(dataTableDist(), escape=FALSE)
   
 })
  
  output$cvesByYear <- renderChart({
    withProgress(message = 'Calculation in progress',
                 detail = 'Standby...', value = 0, {
                   for (i in 1:10) {
                     incProgress(1/10)
                     Sys.sleep(0.1)  }})
    plotCvesCountByYear(dataTableByCveYear())
  })

  output$riskByYearAvg <- renderChart({
    withProgress(message = 'Calculation in progress',
                 detail = 'Standby...', value = 0, {
                   for (i in 1:10) {
                     incProgress(1/10)
                     Sys.sleep(0.1)  }})
    plotRiskByYearAvg(dataTableByRiskAvg())
  })
  
  output$titlesDist <- renderChart2({
    withProgress(message = 'Calculation in progress',
                 detail = 'Standby...', value = 0, {
                   for (i in 1:10) {
                     incProgress(1/10)
                     Sys.sleep(0.1)  }})
    result<-as.data.frame(table(dataTableDist()$wascname))
    plotTitlesDist(result[order(-result$Freq),])
  })
  
  output$rate <- renderValueBox({
    # The downloadRate is the number of rows in pkgData since
    # either startTime or maxAgeSecs ago, whichever is later.
    #elapsed <- as.numeric(Sys.time()) - startTime
    result <- rowCount(mainTable(),cveNames[11], "complete")
    
    valueBox(
      value = paste(result,"%",sep = ""),
      subtitle = "Downloads per sec (last 5 min)",
      icon = icon("area-chart"),
      color = if (result >= 25) "yellow" else "aqua"
    )
  })
  
  output$C <- renderValueBox({
    C <- rowCount(mainTable(),cveNames[11], "complete")
    valueBox(
      withProgress(message = 'Calculation in progress',
                   detail = 'Standby...', value = 0, {
                     for (i in 1:10) {
                       incProgress(1/10)
                       Sys.sleep(0.1)  }}),
      value = paste(C,"%",sep = ""),
      subtitle = "Confidentiality",
      icon = icon("user-secret"),
      color = if (C <= 25){"green"} else if(C<=50){"yellow"} else{"red"} 
    )
  })
  
  output$I <- renderValueBox({
    I <- rowCount(mainTable(),cveNames[12], "complete")
    valueBox(
      value = paste(I,"%",sep = ""),
      subtitle = "Integrity",
      icon = icon("balance-scale"),
      color = if (I <= 25){"green"} else if(I<=50){"yellow"} else{"red"}
    )
  })
  
  output$A <- renderValueBox({
    A <- rowCount(mainTable(),cveNames[13], "complete")
    valueBox(
      value = paste(A,"%",sep = ""),
      subtitle = "Availability",
      icon = icon("sun-o"),
      color = if (A <= 25){"green"} else if(A<=50){"yellow"} else{"red"}
    )
  })
  
  output$network <- renderValueBox({
    network <- rowCount(mainTable(),cveNames[8], "network")
    valueBox(
      value = paste(network,"%",sep = ""),
      "Network",
      icon = icon("cloud"),
      color = if (network <= 25){"green"} else if(network<=50){"yellow"} else{"red"}
    )
  })

  output$adjacent <- renderValueBox({
    adjacent <- rowCount(mainTable(),cveNames[8], "adjacent_network")
    valueBox(
      value = paste(adjacent,"%",sep = ""),
      subtitle = "Adjacent Network",
      icon = icon("wifi"),
      color = if (adjacent <= 25){"green"} else if(adjacent<=50){"yellow"} else{"red"}
    )
  })
  
  output$local <- renderValueBox({
    local <- rowCount(mainTable(),cveNames[8], "local")
    valueBox(
      value = paste(local,"%",sep = ""),
      "Local/Physical",
      icon = icon("terminal"),
      color = if (local <= 25){"green"} else if(local<=50){"yellow"} else{"red"}
    )
  })
  
  
}
  
  