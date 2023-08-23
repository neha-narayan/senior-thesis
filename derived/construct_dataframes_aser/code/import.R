rm(list=ls())
library(ImportExport)
library(dplyr)
library(ggplot2)
library(tidyr)

memory.limit(size=56000)

#gen directories 
root <- "C:/Users/Neha Narayan/Desktop/GitHub/senior-thesis/raw/ASER_Household_Village_Data"
setwd(root)
test <- access_import(file = "ASER_2007_Household_Data.mdb", table_names = "hh_clean")
