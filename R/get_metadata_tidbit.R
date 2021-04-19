# Function para procesar los metadatos de los sensores Tidbit 

library("tidyverse")
library("here")
library("parsedate")
library("purrr")


metadataTidbit <- function(file) {
  raw <- tibble::enframe(read_lines(file))
  
  # Me quedo solo con la variable que necesito
  f <- raw %>% dplyr::select(value)

  #  Get numero de serie
  sn <- f %>%
    filter(stringr::str_detect(value, 
                               paste(c("Número de serie", "Serial Number"), 
                                     collapse = '|'))) %>%
    separate(value, into = c("name", "sn"), sep = ":") %>%
    unique() %>%
    mutate(sn = as.numeric(trimws(sn))) %>%
    dplyr::select(sn)

  # Get nombre sensor
  sensor <- f %>%
    filter(stringr::str_detect(value, 
                               paste(c("Iniciar descripción", 
                                       "Launch Name"), collapse = '|'))) %>%
    separate(value, into = c("name", "sensor_name"), sep = ":") %>%
    unique() %>%
    mutate(sensor_name = trimws(sensor_name)) %>%
    dplyr::select(sensor_name)

  # Get hora de inicio
  inicio <- f %>%
    filter(stringr::str_detect(value, 
                               paste(c("Tiempo de inicio", "Launch Time"), 
                                     collapse = '|'))) %>%
    separate(value, into = c("name", "start"), 
             sep = paste(c("inicio: ", "Time: "), collapse = '|')) %>%
    mutate(start_time = parsedate::parse_date(start)) %>%
    unique() %>%
    mutate(tz = lubridate::tz(start_time)) %>%
    dplyr::select(
      start_time_raw = start,
      start_time, tz_start = tz
    )

  # Get hora de fin
  fin <- f %>%
    filter(stringr::str_detect(value, 
                               paste(c("Hora de última muestra:", 
                                       "Last Sample Time:"), collapse = '|'))) %>%
    separate(value, into = c("name", "fin"), 
             sep = paste(c("muestra: ", "Time: "), collapse = '|')) %>%
    mutate(end_time = parsedate::parse_date(fin)) %>%
    mutate(tz = lubridate::tz(end_time)) %>%
    slice(which.max(end_time)) %>%
    dplyr::select(
      end_time_raw = fin,
      end_time, tz_end = tz
    )

  # unir todos
  out <- bind_cols(sensor, sn, inicio, fin)

  return(out)
}

# Read files 
lf <- list.files(here::here("data/hobo_detail/"), full.names = TRUE)

# Get metatada 
md <- map_dfr(lf, metadataTidbit)

# Export metadata
write_csv(md, file = here::here("data/sensor_metadata.csv"))









