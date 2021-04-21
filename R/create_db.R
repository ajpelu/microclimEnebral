# Creating 
# Flujo
# 1. Genera rds
# 2. Incluye en db sqlite
# 3. Exporta from db sqlite to csv for Metadata 

library(RSQLite) 
library(DBI) 
library(tidyverse)
library(here)

### Incluir en BD (microclimEnebralDB.db // sqlite)
# add ID
library(DBI) 
temperatura <- readRDS(here::here("data/temp_microenebral.rds")) %>% 
  sqlRownamesToColumn("id_record") %>% 
  mutate(id_record = as.integer(id_record), 
         timestamp = as.character(timestamp))

# Prepare Spatial Data  
sensores <- readRDS(here::here("data/temp_microenebral_spatial.rds")) %>% 
  sqlRownamesToColumn("id_sensor") %>% 
  mutate(id_sensor= as.integer(id_sensor),
         lat = unlist(map(geometry,2)),
         long = unlist(map(geometry,1)), 
         start_time = as.character(start_time), 
         end_time = as.character(end_time)) %>% 
  dplyr::select(-geometry) 

# Create a connection to the new database 
conection <- dbConnect(RSQLite::SQLite(), 
                       here::here("db/microclimEnebralDB.db"))

# Create a table
dbWriteTable(conection, "temperature_data", temperatura)
dbWriteTable(conection, "spatial_data", sensores)
# If you want to add new data, uses append = TRUE inside previous function 
dbListTables(conection)


## Exporta data to generate MD package 
sensorescsv <- dbGetQuery(conection, 
                          "SELECT 
                          logger_name, cod_sowing,serial_number, start_time, 
                          end_time, time_zone, loc, microhabitat, status, lat, long 
                          FROM spatial_data")  
write_csv(sensorescsv, here::here("db/sensors_md.csv"))

temperaturecsv <- dbGetQuery(conection, 
                          "SELECT * FROM temperature_data")  


temperaturecsv %>% 
  dplyr::select(id_record, timestamp, temperature, validation, serial_number) %>% 
  mutate(timestamp = as.POSIXct(timestamp, format="%Y-%m-%d %H:%M:%S")) %>% 
  write_csv(here::here("db/temperature_md.csv"))

