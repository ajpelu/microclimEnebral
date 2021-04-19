#' Read temperature files from HOBO sensors 
#' 
#' This functions read and validade temperature files derived from HOBO
#' 
#' @param csv_file path to input csv file
#' 
#' @descriptiopn 
#' \itemize{This function generates three dataframes from an input csv:
#'   \item Sensor Metadata \code{md} gets the serial number and the sensor name; 
#'   the units of temperature (ºC or ºF); and the start- and end-date of the 
#'   sensor data collection; and the timezone. 
#'   \item \code{events} contains all the events recorded by the sensor (\emph{i.e.}
#'   Coupler attached, bad battery, etc); and the date on which that event occurs. 
#'   \item \code{temperature} dataframe contains temperature recorded by the sensor;
#'   the data/time of the measure; the serial number of the sensor and the 
#'   validation of the measures, with value = 1 for values passing the range 
#'   validation process
#'}   
#' 
#' @return a list with three dataframe
#' @author Antonio J Pérez-Luque (\email{ajpelu@@gmail.com})
#' 
#' @importFrom lubridate mdy_hms 
#' @importFrom stringr str_extract str_replace str_replace_all str_split str_remove str_remove_all
#' @importFrom stats complete.cases
#' @importFrom utils read.csv
#' @importFrom dplyr 
#' @import tidyr 
#' 
#' @export

read_hobo <- function(csv_file){ 
  
  # Read the header (two first lines)
  con <- file(csv_file, encoding = "UTF-8")
  header <- readLines(con=con, n=2)
  close(con)
  
  # Split up the second header line which contains column names, logger serial number and time zone  
  header_bits <- unlist(stringr::str_split(header[2], '",\\"'))
  
  # Extract serial number 
  SNs <- stringr::str_extract(header_bits, '(?<=S\\/N:\\s)[0-9]+') 
  SN <- unique(SNs[!is.na(SNs)])
  if(length(SN) > 1) stop("multiple serial numbers in file header")
  
  # Sensor name
  sensor_name <- stringr::str_remove(basename(csv_file), "\\.csv")
  
  # Extract timezone 
  tzraw <- stringr::str_extract(header_bits[grep("Date Time", header_bits)], "GMT[+-][0-9][0-9]")
  tz <- stringr::str_replace(tzraw, "GMT", "Etc/GMT")
  tz <- stringr::str_remove(tz, "0")
  
  # Temperature units 
  u <- stringr::str_extract(header_bits[grep("Temp,", header_bits)], "[\U00B0][A-Z]")
  
  # Read Data 
  hobofile <- read.csv(csv_file, skip=2, header=FALSE, stringsAsFactors = FALSE, na.strings = "")
  
  # variable names 
  header_bits[grep("Date Time", header_bits)] <- "datetime"
  header_bits[grep("Temp", header_bits)] <- "temperature"
  header_bits <- str_remove_all(header_bits, "\"")
  header_bits <- str_replace_all(header_bits, " ", "_")

  names(hobofile) <- header_bits
  hobofile$timestamp <- lubridate::mdy_hms(hobofile[, "datetime"], tz=tz)
  
  # Temperatue data 
  tempraw <- hobofile[,c("timestamp", "temperature")] %>% 
    tidyr::separate(timestamp, c("Year", "Month", "Day", "Hour", "Minute", "Second"), 
                    remove = FALSE, convert = TRUE) %>% 
    filter(!is.na(temperature)) 
    
  # Validation
  temp <- tempraw %>% 
    mutate(validation = if_else(temperature < -20, 0, 
                                ifelse(temperature >= 70, 0, 1))) %>% 
    filter(timestamp > (min(timestamp) + as.difftime(24, units = "hours"))) # range
  
  temp$serial_number <- SN
  
  # Get events 
  events <- hobofile %>%
    dplyr::select(-temperature, -datetime) %>% 
    pivot_longer(-timestamp, 
                 names_to = "event_type", 
                 values_to = "event_value", 
                 values_drop_na = TRUE)
  events$serial_number <- SN
  
  # Metadata
  md <- data.frame(serial_number = SN, 
                   sensor_name = sensor_name,
                   temp_units = u, 
                   start_time = min(temp$timestamp),
                   end_time = max(temp$timestamp),
                   time_zone = tz)
  

return(list(temperature = temp, events = events, metadata = md))
}
