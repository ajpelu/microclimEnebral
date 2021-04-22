# Export to CLIMANEVADA 
library(tidyverse)
library(here)
library(sf)

# Create row for cn_network 
cn_network <- data.frame(
  network_id = 18,
  network_code = "ADAPTAMED", 
  network_name = "Red de sensores de temperatura del proyecto LIFE-ADAPTAMED",
  network_manager = "Laboratorio de Ecología - IISTA-CEAMA, Universidad de Granada",
  network_status = "Activa",
  data_policy = "https://obsnev.es/apps/adaptamed/metadatos/microclim-enebral/microclimEnebral.html",
  url = "https://doi.org/10.23728/B2SHARE.1B31CD1247B54ED383F3499CAC398822") 


# Create row for cn_stations 


sensors_md <- read_csv(here::here("db/sensors_md.csv"))
sensor_elev <- st_read(here::here("data/hobo_spatial/microclimEnebral_elev.shp")) %>% 
  mutate(elevation = round(rvalue_1)) %>% 
  dplyr::select(-rvalue_1,-sensor,-sensorName) %>%
  st_set_geometry(NULL) 
  
sensores2climanevada <- 
  sensors_md %>% 
  inner_join(sensor_elev) %>% 
  unite("station_code", logger_name, serial_number, sep = "-", remove = FALSE) %>% 
  mutate (
    station_id = serial_number,
    station_name = logger_name, 
    coord_x = long, 
    coord_y = lat, 
    epsg = 4326, 
    munic_code = case_when(loc == "HZM" ~ 18160, loc == "BER" ~ 18451),
    munic_name = case_when(loc == "HZM" ~ "Güejar-Sierra", loc == "BER" ~ "Bérchules"),
    province = "GRANADA", 
    cn_network_id = "18", 
    type = "A",
    category = "S", 
    elev = elevation,
    status = "ACTIVO",
    record_start = start_time,
    record_end = end_time, 
    station_variables_id = 57
  ) %>% 
  dplyr::select(
    station_id, station_name, station_code, coord_x, coord_y, epsg, munic_code, munic_name, province,
    cn_network_id, type, category, elev, record_start, record_end, station_variables_id
  )

temperature_md <- read_csv(here::here("db/temperature_md.csv"))

temperature2climanevada <- temperature_md %>% 
  mutate(variable_id = 57) %>% 
  dplyr::select(time = timestamp, variable_id,
                value = temperature, validation_id = validation,
                station_id = serial_number,-id_record)
  
  
write_csv(temperature2climanevada, here::here("db/to_climanevada/microclimEnebral_cn_datos.csv"))
write_csv(sensores2climanevada, here::here("db/to_climanevada/microclimEnebral_cn_stations.csv"))
write_csv(cn_network, here::here("db/to_climanevada/microclimEnebral_cn_network.csv"))

files2zip <- dir(here::here("db/to_climanevada"), full.names=TRUE)
zip(zipfile=here::here("db/to_climanevada/microclimEnebral"), files = files2zip)

  