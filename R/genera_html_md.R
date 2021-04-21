# Generate HTML with metadata 

# Create a EML document --------------------------------
# 1. Go to https://environmentaldatainitiative.org/submit-your-data/ 
# 2. Login into ezEML web interface https://ezeml.edirepository.org/eml/ 
# 3. Dowload xml 

library(tidyverse)
library(xml2)
library(here)
library(leaflet)
library(htmlwidgets)
library(xslt)

### Generate html from EML 
file <- list.files(here::here("md/"), pattern = "*.xml")
encoding <- "UTF-8"
style <- xml2::read_xml(here::here("md/template/bootstrap.xsl"))
eml <- xml2::read_xml(paste0(here::here("md/"), file), encoding = encoding)

# make map
name <- xml2::xml_find_all(eml, "//geographicCoverage/geographicDescription")
name <- unlist(xml2::as_list(name))

west <- xml2::xml_find_all(eml, "//geographicCoverage/boundingCoordinates/westBoundingCoordinate")
west <- as.numeric(unlist(xml2::as_list(west)))

east <- xml2::xml_find_all(eml, "//geographicCoverage/boundingCoordinates/eastBoundingCoordinate")
east <- as.numeric(unlist(xml2::as_list(east)))

north <- xml2::xml_find_all(eml, "//geographicCoverage/boundingCoordinates/northBoundingCoordinate")
north <- as.numeric(unlist(xml2::as_list(north)))

south <- xml2::xml_find_all(eml, "//geographicCoverage/boundingCoordinates/southBoundingCoordinate")
south <- as.numeric(unlist(xml2::as_list(south)))

geo_info <- data.frame(name = name,
                       west = west, east = east,
                       south = south, north = north)

map <- leaflet::leaflet(geo_info) %>% 
  leaflet::addProviderTiles("OpenTopoMap") %>%
  leaflet::addRectangles(
    lng1 = west, lat1 = south,
    lng2 = east, lat2 = north,
    popup = name,
    fillColor = "transparent"
  )

htmlwidgets::saveWidget(map, file = here::here("md/map.html"), selfcontained = FALSE)

html <- xslt::xml_xslt(eml, style)
xml2::write_html(html, here::here("md/microclimEnebral.html"))



