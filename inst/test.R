library(dplyr)
library(shiny)
library(lubridate)

sen <- readRDS(here::here("data/sensor_spatial.rds")) 

ui <- fluidPage()





ui = navbarPage("microclimEnebral", id="nav",
                tabPanel("interactiveMap", 
                         leafletOutput("map", width="100%", height="100%"),
                         absolutePanel(id = "controls", class = "panel panel-default", 
                              fixed = TRUE, draggable = TRUE, top = 60, left = "auto", right = 20, 
                              bottom = "auto", width = 330, height = "auto",
                              
                              h3("Filter Temperature Logger"),
                              selectizeInput("site", "Select Site",  
                                             c("All", unique(sen$loc)), multiple = TRUE),
                              submitButton(text = "Submit", icon = NULL, width = NULL)
                              
                )
                ),
                tabPanel("Data explorer",
                         shiny::dataTableOutput("merged"))
                              
  
  
  # fluidPage(
  # ## Filtros 
  #   sidebarPanel(
  #     uiOutput("statlist"), 
  #     submitButton(text = "Submit", icon = NULL, width = NULL)
  #     ),
  #   
  #   mainPanel(
  #     leafletOutput("map"),
  #     shiny::dataTableOutput("merged") 
  #     )
)

server = function(input, output, session) {
  
  # output$statlist <- renderUI({
  #   sensores <- sort(unique(as.vector(sen$loc)), decreasing = FALSE)
  #   
  #   selectizeInput("sensores", "Select Data Logger",  c("All", sensores), multiple = TRUE)
  #   submitButton(text = "Submit", icon = NULL, width = NULL)
  # })
  
  output$map<-renderLeaflet({
    
    c1 <- awesomeIcons(icon = "ios-close", iconColor = "black", library = "ion", markerColor = "blue")
    c2 <- awesomeIcons(icon = "ios-close", iconColor = "black", library = "ion", markerColor = "grey")
    
    m <- sen %>% 
      leaflet() %>% 
      addEasyButton(easyButton(
        icon = "fa-crosshairs", title = "Locate Me",
        onClick = JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
      addProviderTiles("OpenStreetMap.Mapnik", group = "Street Map") %>% 
      addAwesomeMarkers(icon = c1)
    
    m 
    # m%>% addDrawToolbar(
    #   
    #   #targetLayerId ='draw',
    #   targetGroup='draw',
    #   polygonOptions = drawPolygonOptions(),
    #   editOptions = editToolbarOptions(edit=FALSE),
    #   polylineOptions=FALSE,
    #   markerOptions = FALSE,
    #   circleOptions = FALSE,
    #   rectangleOptions =FALSE,
    #   circleMarkerOptions =FALSE)
  })

 
  output$merged <- shiny::renderDataTable({
    sen %>%
      dplyr::select(logger_name, cod_sowing, serial_number, loc, microhabitat, replica, status, -geometry) %>% 
      filter(loc == input$sensores)
  })
}

shinyApp(ui = ui, server = server)












# Choices for drop-downs
# microenv <- c(
#   "Under Rocks" = "ROCA",
#   "Under Juniperus sp." = "ENEBRAL",
#   "Under Genista sp." = "GENISTA",
#   "Wet meadows" = "BORREGUIL",
#   "Dry hillside" = "PASTIZAL"
# )
# 
# sites <- c(
#   "Haza Mesa (Güejar-Sierra)" = "HZM",
#   "Acequia de Bérchules (Bérchules)" = "BER"
# )



# 
# s %>% 
#   leaflet::leaflet() %>%
#   leaflet::addProviderTiles(providers$OpenStreetMap) %>% 
#   leaflet::addAwesomeMarkers(
#     popup = ~paste0("<strong>Serial Number:</strong> ", sensores$serial_number, "</br>",
#                     "<strong>Location:</strong> ", 
#                     ifelse(sensores$loc == "HZM", "Haza Mesa (Güejar-Sierra)", "Bérchules"), "</br>",
#                     "<strong>Status:</strong> ", sensores$status, "</br>",
#                     "<strong>Microhabitat:</strong> ", sensores$microhabitat, "</br>",
#                     "<strong>Start Date:</strong> ", sensores$start_time,"</br>",
#                     "<strong>End Date:</strong> ", sensores$end_time),
#     icon = awesomeIcons(
#       library = "ion",
#       icon = "ion-android-radio-button-off",
#       iconColor = "white",
#       markerColor = ifelse(
#         test = sensores$status == "Ok", 
#         yes = "green",
#         no = "red"
#       )
#     )
#   ) 
