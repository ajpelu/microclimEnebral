# Read and combine data 

library("sp")
library("raster")
source(here::here("R/read_hobo.R"))
library("tidyverse")

# List all csv files 
lf <- list.files(here::here("data/hobo_last"), pattern= ".csv", full.names = TRUE)

# Read all temperature data
raw_data <- map(lf, read_hobo) %>% transpose() 

# Combine all temperatures data and remove not valid values (validation == 0)
temp <- bind_rows(raw_data$temperature) %>% filter(validation == 1)

# Combine all metadata 
metadata_temp <- bind_rows(raw_data$metadata)

events_temp <- bind_rows(raw_data$events)

saveRDS(temp, file = here::here("data/temp_microenebral.rds"))


# Prepare Metadata 
saveRDS(metadata_temp, file = here::here("data/temp_microenebral_md.rds"))

# Read spatial info 
library(sf) 
sensor_spa <- st_read(here::here("data/hobo_spatial/microclimEnebral.shp"))
# transform to epsg 4326 
s <- st_transform(sensor_spa, 4326)

microhabitat <- read_csv(here::here("data/sensorCorrespondence.csv")) 
sfull <- s %>% 
  left_join(metadata_temp, by = c("sensorName"= "sensor_name")) %>% 
  left_join(microhabitat, by = c("sensorName" = "sensor_name_raw")) %>% 
  dplyr::select(-code_sowing, -microhabitat, -temp_units, -sensor, -obs) %>% 
  rename(microhabitat = microhab)
  
saveRDS(sfull, file = here::here("data/temp_microenebral_spatial.rds"))



# other sources 
# https://github.com/RyanLab/microclimloggers 








