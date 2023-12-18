rm(list=ls())
library(httr); library(jsonlite); library(tidyverse)

for (year in 16:20) {
  assign(paste0("geodata_20", year), 
         read_csv(paste0("../../../raw/geodata/latlon_pop/ppp_IND_20", year,"_1km_Aggregated.csv")))
  assign(paste0("geodata_20", year), `names<-`(get(paste0("geodata_20", year)), c("lon", "lat", "pop")))
}

coord_to_pin <-  function(lat, lon) {
  pincode <-  NULL
  key <-  "YOUR_KEY_HERE"
  baseurl <-  "https://maps.googleapis.com/maps/api/geocode/json"
  endpoint <- paste0(baseurl, "?latlng=", lat, ",", lon, 
                     "&result_type=postal_code&key=", key)
  response <- httr::GET(endpoint)
  
  if (httr::status_code(response) %in% 200:299) {
    tryCatch ({
      results <- jsonlite::fromJSON(httr::content(response, "text"))$results[[1]]
      pincode <- results[[1]]$long_name[1]
    }, error = function(e) {
      cat("Error:", e$message, "\n")
    })
  } else {
    cat("Error: Non-200 status code\n")
  }
  return(pincode)
}

geodata_2016$pincode = "0"

for (i in 1:dim(geodata_2016)[1]) {
  if (is.null(coord_to_pin(as.numeric(geodata_2016$lat[i]),as.numeric(geodata_2016$lon[i]))) == TRUE) {
    geodata_2016$pincode[i] <- "0"
  } else {
    geodata_2016$pincode[i] <- coord_to_pin(as.numeric(geodata_2016$lat[i]),as.numeric(geodata_2016$lon[i]))
  }
  print(i)
}

# geodata_2020 <- geodata_2020 %>%
#   rowwise() %>%
#   mutate(pincode = ifelse(is.null(coord_to_pin(as.numeric(lat),as.numeric(lon))) == TRUE,
#                           NA, coord_to_pin(as.numeric(lat),as.numeric(lon))))
# 
# collapsed_2020 <- geodata_2020 %>%
#   group_by(pincode) %>%
#   summarize(sum = sum(pop, na.rm = TRUE))
# collapsed_2020$ac_year <- 2020
# 
# geodata_2019 <- geodata_2019 %>%
#   rowwise() %>%
#   mutate(pincode = ifelse(is.null(coord_to_pin(as.numeric(lat),as.numeric(lon))) == TRUE,
#                           NA, coord_to_pin(as.numeric(lat),as.numeric(lon))))
# 
# collapsed_2019 <- geodata_2019 %>%
#   group_by(pincode) %>%
#   summarize(sum = sum(pop, na.rm = TRUE))
# collapsed_2019$ac_year <- 2019
# 
# geodata_2018 <- geodata_2018 %>%
#   rowwise() %>%
#   mutate(pincode = ifelse(is.null(coord_to_pin(as.numeric(lat),as.numeric(lon))) == TRUE,
#                           NA, coord_to_pin(as.numeric(lat),as.numeric(lon))))
# 
# collapsed_2018 <- geodata_2018 %>%
#   group_by(pincode) %>%
#   summarize(sum = sum(pop, na.rm = TRUE))
# collapsed_2018$ac_year <- 2018
# 
# geodata_2017 <- geodata_2017 %>%
#   rowwise() %>%
#   mutate(pincode = ifelse(is.null(coord_to_pin(as.numeric(lat),as.numeric(lon))) == TRUE,
#                           NA, coord_to_pin(as.numeric(lat),as.numeric(lon))))
# 
# collapsed_2017 <- geodata_2017 %>%
#   group_by(pincode) %>%
#   summarize(sum = sum(pop, na.rm = TRUE))
# collapsed_2017$ac_year <- 2017
# 
# geodata_2016 <- geodata_2016 %>%
#   rowwise() %>%
#   mutate(pincode = ifelse(is.null(coord_to_pin(as.numeric(lat),as.numeric(lon))) == TRUE,
#                           NA, coord_to_pin(as.numeric(lat),as.numeric(lon))))

collapsed_2016 <- geodata_2016 %>%
  group_by(pincode) %>%
  summarize(sum = sum(pop, na.rm = TRUE))
collapsed_2016$ac_year <- 2016

pincode_pop <- rbind(collapsed_2016, collapse_2017, collapse_2018, collapse_2019, collapse_2020)
write.csv(pincode, "../output/pincode_pop.csv", row.names=FALSE)























