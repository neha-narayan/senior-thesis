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
                "Bihar", "Dadra and Nagar Haveli", "Daman and Diu",
                "Goa", "Gujarat", "Karnataka", "Lakshadweep",  
                "Nagaland", "Orissa", "Punjab", "Rajasthan", "Sikkim", "Tripura",
                "Uttar Pradesh", "Madhya Pradesh")
treat_2017 <- states_shape[states_shape$NAME_1 %in% names_2017, ]

names_2016 <- c("Delhi", "Manipur",  "Jharkhand")
treat_2016 <- states_shape[states_shape$NAME_1 %in% names_2016, ]

names_2015 <- c("Andhra Pradesh", "Telangana", "Haryana")
treat_2015 <- states_shape[states_shape$NAME_1 %in% names_2015, ]

names_control <- c("Assam", "Jammu and Kashmir", "Kerala", 
                   "Maharashtra", "Meghalaya", "West Bengal")
control <- states_shape[states_shape$NAME_1 %in% names_control, ]

names_missing <- c("Uttaranchal", "Himachal Pradesh", "Chhattisgarh", "Mizoram")
nodata <- states_shape[states_shape$NAME_1 %in% names_missing, ]

#plot map of india
map <- ggplot() +
  geom_sf(data = states_shape, fill = "white", color = "black") +
  geom_sf(data = treat_2019, aes(fill = "2019"), color = NA) +
  geom_sf(data = treat_2017, aes(fill = "2017"), color = NA) + 
  geom_sf(data = treat_2016, aes(fill = "2016"), color = NA) +
  geom_sf(data = treat_2015, aes(fill = "2015"), color = NA) +
  geom_sf(data = control, aes(fill = "Control"), color = NA) +
  geom_sf(data = nodata, aes(fill = "Unknown"), color = NA) +
  labs(title = "Policy Rollout by State") +
  scale_fill_manual(values = c("2019" = "#014421", 
                               "2017" = "#3A754E", 
                               "2016" = "#548F66", 
                               "2015" = "#6DAA7F", 
                               "Control" = "#DBFFEC",
                               "Unknown" = "#FFFFFF"),
                    labels = c("2015", "2016", "2017", "2019", "Control", "Unknown"),
                    name = "Year of Treatment")

ggsave('../output/policy_rollout.png', plot = map, width = 30, height = 20, units = "cm")

#district reliability
dists_shape = st_read('../../../raw/data/polbnda_ind.shp')
dists_shape <- dists_shape %>% 
  rename(distname = laa)
ratings = distinct(read.csv('../../../shared_data/cohortdata.csv')[,c("distname", "reliable_scale")])

total <- merge(dists_shape, ratings, by="distname", all.x = TRUE)
most_reliable <- total[total$reliable_scale == "Most Reliable",]
least_reliable <- total[total$reliable_scale == "Least Reliable",]

map2 <- ggplot() +
  geom_sf(data = total, fill = "white", color = "black") +
  geom_sf(data = most_reliable, aes(fill = "Most Reliable"), color = NA) +
  geom_sf(data = least_reliable, aes(fill = "Least Reliable"), color = NA) +
  labs(title = "Most vs. Least Reliable Districts") +
  scale_fill_manual(values = c("Most Reliable" = "#014421","Least Reliable" = "#6DAA7F"),
                    name = "Group")
ggsave('../output/reliable_geo_dist.png', plot = map2, width = 30, height = 20, units = "cm")

















