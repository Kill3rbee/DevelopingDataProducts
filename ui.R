## ui.R #
library(shiny)
library(DT)
require(markdown)
library(shinydashboard)
library(rCharts)
header <-dashboardHeader(
  title = 'CVE Reporting Dashboard',titleWidth = 270,
  tags$li(class = "dropdown", height=15,
    tags$a(href="http://www.toolswatch.org/vfeed/", target="_blank", 
      tags$img(height = 20, alt="vFeed Logo", src="vFeed.png",valign="top")
    )
  )
)

sidebar <- dashboardSidebar(
  width = 270,
  sidebarMenu(
    id = "tabs",
    menuItem("Overview", tabName = "summary", icon = icon("info-circle")),
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    #menuItem("About Me", icon = icon("th"), tabName = "widgets",
    #         badgeLabel = "new", badgeColor = "green"),
    menuItem("Charts", tabName = "charts", icon = icon("bar-chart-o")),
    #menuItem("View CVE", tabName = "cvetable", icon = icon("info-circle")),
    menuItem("Click to View CVE Category", icon = icon("info-circle"),
             menuSubItem("General CVEs",icon=icon("th"),tabName ="cvetable"),
             menuSubItem("Web Applications CVEs",icon=icon("th"),tabName ="WASC")
    ),
    #menuItem("Controls", tabName = "controls", icon = icon("dashboard")),
    sliderInput("timeline", "CVE Publish Year:", min = 1998, max = 2018,
                value = c(2006, 2018)),
    sliderInput("risk", "CVE Risk Score:",min = 0, max = 10 ,
                value = c(7, 10)), 

    actionButton(inputId = "clearAll", label = "Clear selection", 
                 icon = icon("square-o"),
                 style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    actionButton(inputId = "selectAll", label = "Select all", 
                 icon = icon("check-square-o"),
                 style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    #uiOutput("cwetitlesControl")
    
    #box(title = "Click to View CWE Titles", status = "primary", background = "black", 
    #    solidHeader = TRUE, collapsible = TRUE, width = "100%", height = "100%",
    #    div(style = 'overflow-y: scroll',uiOutput("cwetitlesControl")))
    menuItem("Click to Load CWE Titles",tabName = "cwetitlesControl", 
             icon = icon("th"), uiOutput("cwetitlesControl"), selected = TRUE)
    #menuItem("Click to Load CWE Titles",
    #         menuSubItem(icon=icon("th"),tabName ="cwetitlesControl", uiOutput("cwetitlesControl"), selected = TRUE)
    #)
    #menuItem("CWE Titles",tabName = "cwetitles", icon = icon("th"), checkboxGroupInput('cwetitles', 'CWE cwetitles:', choices =  
    #                                                                                       cwetitles, selected = cwetitles))

  )
)

body <- dashboardBody(
  # Write the path to your .css file
  includeCSS("./mystyles.css"),
  # The guts of your app
  withMathJax(),
  #h3("Why is the Variance Estimator \\(S^2\\) divided by \\(n-1?\\)"),
  tabItems(
    #withMathJax(),
    tabItem(tabName = "summary",
      includeMarkdown("about.md")
    ),
        
    tabItem(tabName = "dashboard",
        fluidRow(
          box(
            width = "100%", status = "info", solidHeader = TRUE,
            h5('CVEs that will cause total loss of confidentiality,integrity and availability 
               of resources on the exploited system.', 
            style = "font-family: 'Lobster', cursive;font-weight: 800; line-height: 1.1; 
            color: #4d3a7d;"),

            valueBoxOutput("C"),
            valueBoxOutput("I"),
            valueBoxOutput("A")
          )
        ),
        
        fluidRow(
          box(
            width = "100%",status = "info", solidHeader = TRUE,
            h5('CVEs that require local/physical access, broadcast/collision domain of the vulnerable
               system (e.g. ARP spoofing, bluetooth attacks) and layer 3 or above of the OSI Model.', 
               style = "font-family: 'Lobster', cursive;font-weight: 800; line-height: 1.1; 
               color: #4d3a7d;"),
            valueBoxOutput("network"),
            valueBoxOutput("adjacent"),
            valueBoxOutput("local")
            )
        ),
        
        fluidRow(
          box(
            width = "100%", status = "info", solidHeader = TRUE,
            title = "CVS with highest Impact based on Exploitability"
          )
        )
    ),
    tabItem(tabName = "widgets",
            fluidRow(
              box(
                width = "100%", status = "info", solidHeader = TRUE,
                title = "How to Exploit and Abuse Camera",
                tags$img(height = "70%",width = "100%",src="me.jpg",valign="top")
              )
            )
            
    ),
    tabItem("subitem1",
            "Sub-item 2 tab content"
    ),
    tabItem("subitem2",
            "Sub-item 2 tab content"
    ),
    tabItem(tabName = "charts",
            showOutput("cvesByYear","nvd3"),
            showOutput("riskByYearAvg","nvd3")
            
    ),
    tabItem(tabName = "cvetable",
            fluidRow(
              #showOutput("cvePerYear", "nvd3"),
              #showOutput("mybarplot", "polycharts"),
              box(
                width = "100%", status = "info", solidHeader = TRUE,
                title = "CVEs for Common Weakness Enumeration(CWE) Titles",
                dataTableOutput(outputId="table")
              )
            )

    ),
    tabItem(tabName = "WASC",
            fluidRow(
              box(
                width = "100%", height="30%", status = "info", solidHeader = TRUE,
                title = "CVS with highest Impact based on Exploitability",
                div(showOutput("titlesDist","polycharts"), style="text-align: center;")
              ),
              box(
                width = "100%", status = "info", solidHeader = TRUE,
                title = "CVEs for Web Application Threat Classification",
                dataTableOutput(outputId="webtable")
              )
            )
    )
  
  )
)

# Put them together into a dashboardPage
dashboardPage(
  header,
  sidebar,
  body


)