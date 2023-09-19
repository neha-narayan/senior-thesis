rm(list=ls())
library(dplyr)
library(ggplot2)
library(tidyr)
library(cowplot)

library(RColorBrewer)
library(ggmap)
library(maps)
library(rgdal)
library(scales)
library(maptools)
library(gridExtra)
library(rgeos)
library(sf)

states_shape = st_read('../../../raw/IND_adm/IND_adm1.shp')

names_2019 <- c("Tamil Nadu")
treat_2019 <- states_shape[states_shape$NAME_1 %in% names_2019, ]

names_2017 <- c("Andaman and Nicobar", "Arunachal Pradesh", "Chandigarh",
                "Bihar", "Chhattisgarh", "Dadra and Nagar Haveli", "Daman and Diu",
                "Goa", "Gujarat", "Karnataka", "Lakshadweep", "Mizoram", 
                "Nagaland", "Orissa", "Punjab", "Rajasthan", "Sikkim", "Tripura",
                "Uttar Pradesh", "Madhya Pradesh")
treat_2017 <- states_shape[states_shape$NAME_1 %in% names_2017, ]

names_2016 <- c("Delhi", "Manipur",  "Jharkhand")
treat_2016 <- states_shape[states_shape$NAME_1 %in% names_2016, ]

names_2015 <- c("Andhra Pradesh", "Telangana", "Haryana")
treat_2015 <- states_shape[states_shape$NAME_1 %in% names_2015, ]

names_2013 <- c("Himachal Pradesh")
treat_2013 <- states_shape[states_shape$NAME_1 %in% names_2013, ]

names_control <- c("Assam", "Jammu and Kashmir", "Kerala", 
                   "Maharashtra", "Meghalaya", "West Bengal")
control <- states_shape[states_shape$NAME_1 %in% names_control, ]

names_missing <- c("Uttaranchal")
nodata <- states_shape[states_shape$NAME_1 %in% names_missing, ]

#plot map of india
map <- ggplot() +
  geom_sf(data = states_shape, fill = "white", color = "black") +
  geom_sf(data = treat_2019, aes(fill = "2019"), color = NA) +
  geom_sf(data = treat_2017, aes(fill = "2017"), color = NA) + 
  geom_sf(data = treat_2016, aes(fill = "2016"), color = NA) +
  geom_sf(data = treat_2015, aes(fill = "2015"), color = NA) +
  geom_sf(data = treat_2013, aes(fill = "2013"), color = NA) +
  geom_sf(data = control, aes(fill = "Control"), color = NA) +
  geom_sf(data = nodata, aes(fill = "Unknown"), color = NA) +
  labs(title = "Policy Rollout by State") +
  scale_fill_manual(values = c("2019" = "#014421", 
                               "2017" = "#3A754E", 
                               "2016" = "#548F66", 
                               "2015" = "#6DAA7F", 
                               "2013" = "#88C599",
                               "Control" = "#DBFFEC",
                               "Unknown" = "#FFFFFF"),
                    labels = c("2013", "2015", "2016", "2017", "2019", "Control", "Unknown"),
                    name = "Year of Treatment")

ggsave('../output/policy_rollout.png', plot = map, width = 30, height = 20, units = "cm")

















