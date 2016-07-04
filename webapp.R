library(sqldf)
library(lubridate)
library(httr)
library(dplyr)
library(rCharts)
library(data.table)
# Read data
mapCVEEXPLOIT <- readRDS("mapCVEEXPLOIT.rds")

#saveRDS(mapCVEEXPLOIT, file="mapCVEEXPLOIT.rds")
#setnames(mapCVEEXPLOIT, "cwetitle", "title")
#setnames(mapCVEEXPLOIT, "cvss_base", "risk")
#setnames(mapCVEEXPLOIT, "date_publishedYear", "year")
cwetitles <- sort(unique(mapCVEEXPLOIT$cwetitle))
wascnames <- sort(unique(mapCVEEXPLOIT$wascname))
#years <- sort(unique(mapCVEEXPLOIT$year))
#risk <- sort(unique(mapCVEEXPLOIT$risk))

## Helper functions##########################################
#' Aggregate dataset by cwetitle
#' 
#' @param cvedata data.frame
#' @param minYear
#' @param maxYear
#' @param minRisk
#' @param maxRisk
#' @param cwetitles
#' @return result data.table
#' 
groupByCWETitle <- function(cvedata, minYear, maxYear, minRisk,
                         maxRisk, cwetitles) {
  result <- cvedata %>% filter(year >= minYear, year <= maxYear,
                          risk >= minRisk, risk <= maxRisk,cwetitle %in% cwetitles)#%>%

    #datatable(cvedata, options = list(iDisplayLength = 20))
  return(result)
}
#' Filter dataset by years, risk score and cwetitles
#' 
#' @param cvedata data.frame
#' @param minYear
#' @param maxYear
#' @param minRisk
#' @param maxRisk
#' @param cwetitles
#' @return data.frame
#'
groupAllCVEID <- function(cvedata, minYear, maxYear, minRisk,
                           maxRisk, cwetitles) {
  cvedata %>% 
    filter(year >= minYear, year <= maxYear,
           risk >= minRisk, risk <= maxRisk,cwetitle %in% cwetitles)
  #return(result)
}


#' Aggregate dataset by CVEID
#' 
#' @param cvedata data.frame
#' @param minYear
#' @param maxYear
#' @param minRisk
#' @param maxRisk
#' @param cwetitles
#' @return result data.table
#' 
groupByYearCve <- function(cvedata, minYear, maxYear, 
                           minRisk, maxRisk, cwetitles) {
  cvedata <- groupByYear(cvedata, minYear, maxYear)
  result <- cvedata %>% 
    group_by(year) %>% 
    summarise(total_cveid = n_distinct(cveid)) %>%
    arrange(year)
  return(result) 
}

#' Aggregate dataset only by year
#' 
#' @param cvedata data.table
#' @param minYear
#' @param maxYear
#' @return data.table
#'
groupByYear <- function(cvedata, minYear, maxYear) {
  result <- cvedata %>% filter(year >= minYear, year <= maxYear) 
  return(result)
}


#' Aggregate dataset by year to get total count of average risk score
#' 
#' @param cvedata data.table
#' @param minYear
#' @param maxYear
#' @param minRisk
#' @param maxRisk
#' @param cwetitles
#' @return data.table
#'
groupByRiskAvg <- function(cvedata, minYear, maxYear, 
                            minRisk, maxRisk, cwetitles) {
  cvedata <- groupAllCVEID(cvedata, minYear, maxYear,minRisk, maxRisk, cwetitles)
  result <- cvedata %>% 
    group_by(year) %>% 
    summarise(avg_risk = round(mean(risk),0)) %>%
    arrange(year)
  return(result)      
}
#test<-groupByRiskAvg(mapCVEEXPLOIT,2000,2013,7,10,cwetitles)
#' Calculate percentage based on sample size
#' #' 
#' @param cvedata data.table
#' @param input
#' @param colvar
#' @return numeric value
#'
rowCount<- function(cvedata,input,colvar){
    denom <- length(unique(cvedata$cveid))
    var <-paste0("'", c(colvar), "'")
    calc <- 
      sqldf(paste0("select ", "distinct(cveid), ", input, " from cvedata WHERE ", input, " = ", var, sep=" "))
    
    k<-sqldf(paste0("select ", input, " from calc WHERE ", input, " = ",var, sep=" "))
    enum <- length(k[,1])
    result <- round((enum/denom)*100,0)
    #print(result)
  return(result)
}

#C <- rowCount(mapCVEEXPLOIT,cveNames[11], "complete")
#I <- rowCount(mapCVEEXPLOIT,cveNames[12], "complete")
#A <- rowCount(mapCVEEXPLOIT,cveNames[13], "complete")

#network <- rowCount(mapCVEEXPLOIT,cveNames[8], "network")
#adjacent <- rowCount(mapCVEEXPLOIT,cveNames[8], "adjacent_network")
#local <- rowCount(mapCVEEXPLOIT,cveNames[8], "local")

#' Filter columns to display
#' 
#' @param cvedata data.table
#' @param minYear
#' @param maxYear
#' @return data.table
#'
cveToDisplay <- function(cvedata) {
  result <-cvedata %>% 
    #filter(year >= minYear, year <= maxYear,
    #       risk >= minRisk, risk <= maxRisk,cwetitle %in% cwetitles)%>%
    select(cveid, risk, year, wascname,cwetitle, summary, exploitdbscripturl)
  return(result)
}

#test2<-cveToDisplay(mapCVEEXPLOIT)
#' Filter columns to display for Web application related CVEs
#' 
#' @param cvedata data.table
#' @return data.table
#'
wascTopTen <- function(cvedata){
  result <- cvedata[!is.na(cvedata$wascname),]
  cveToDisplay(result)[order(-result$risk),]
  #test2 <- 
  #testL<-as.data.frame(table(test2$wascname))
  #testL[order(-testL$Freq),]
}
#testa<-wascTopTen(mapCVEEXPLOIT)
## Helper plot functions ##########################################

#' Plot number of CVE by year
#' 
#' @param cvedata data.table
#' @param dom
#' @param xAxisLabel year
#' @param yAxisLabel number of cves
#' @return cvesByYear plot
plotCvesCountByYear <- function(cvedata, dom = "cvesByYear", 
                                xAxisLabel = "Year",
                                yAxisLabel = "Number of CVEs") {
  cvesByYear <- nPlot(
    total_cveid ~ year,
    data = cvedata,
    type = "stackedAreaChart",
    dom = dom, width = 650
  )
  cvesByYear$chart(margin = list(left = 100))
  cvesByYear$chart(color = c('purple', 'blue', 'green'))
  cvesByYear$chart(tooltipContent = "#! function(key, x, y, e){ 
                   return '<h5><b>Year</b>: ' + e.point.year + '<br>' + '<b>Total CVEs</b>: ' 
                   + e.point.total_cveid + '<br>'
                   + '</h5>'
} !#")
  cvesByYear$yAxis(axisLabel = yAxisLabel, width = 80)
  cvesByYear$yAxis(tickFormat = "#! function(d) {return d3.format(',.0f')(d)} !#")
  #n1$yAxis(showMaxMin = FALSE)
  cvesByYear$xAxis(axisLabel = xAxisLabel, width = 70)
  cvesByYear 
  }

#' Plot average CVE risk by year
#' 
#' @param cvedata data.table
#' @param dom
#' @param xAxisLabel year
#' @param yAxisLabel average risk
#' @return riskByYearAvg plot
plotRiskByYearAvg <- function(cvedata, dom = "riskByYearAvg", 
                                xAxisLabel = "Year",
                                yAxisLabel = "Average Risk") {
  
  riskByYearAvg <- nPlot(
    avg_risk ~ year,
    data = cvedata,
    type = "lineChart",
    dom = dom, width = 650
  )
  riskByYearAvg$chart(margin = list(left = 100))
  riskByYearAvg$chart(color = c('orange', 'blue', 'green'))
  riskByYearAvg$yAxis(axisLabel = yAxisLabel, width = 80)
  riskByYearAvg$xAxis(axisLabel = xAxisLabel, width = 70)
  riskByYearAvg$yAxis(tickFormat = "#! function(d) {return d3.format(',.0f')(d)} !#")
  #riskByYearAvg$yAxis(showMaxMin = FALSE)
  riskByYearAvg$chart(forceY = c(1, 10))
  riskByYearAvg
}

#' Plot average CVE risk by year
#' 
#' @param cvedata data.table
#' @return titlesDist plot
plotTitlesDist <- function(cvedata) {
  names(cvedata)[1]<-"Titles"
  names(cvedata)[2]<-"Count"
  titlesDist<-rPlot(Count~Titles, 
            color = 'Titles', 
            data = cvedata, 
            type = 'bar',
            size = list( const = 1))
  titlesDist$guides(color = list(numticks = length((cvedata[,1]))),
            x = list(title="Titles", ticks = ''),
            y = list(title="Count")
  )
  titlesDist$addParams(width = 600, height = 300)
  titlesDist
}
