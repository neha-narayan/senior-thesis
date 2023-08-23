rm(list=ls())
library(xlsx)
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)

memory.limit(size=56000)

#gen directories 
root <- "C:/Users/Neha Narayan/Desktop/GitHub/senior-thesis/raw/DISE_school_data"
outdata <- "C:/Users/Neha Narayan/Desktop/GitHub/senior-thesis/derived/construct_dataframes_dise/output/csv"
yeardirs <- dir(root, pattern = "", full.names = TRUE)

idx = 2005
for (dir in yeardirs) {
  Basic <- data.frame(matrix(NA, nrow = 1, ncol = 7))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
        file <- list.files(sdir, pattern = "Basic")
        basic <- read_xlsx(paste(sdir, file, sep = "/"))
        if (sdir == statedirs[1]) {
          Basic <- basic
        }
        else {
          Basic <- rbind(Basic, basic)
        }
  }
  basic_path <- toString(paste(outdata, "/basic", "_", idx, ".csv", sep = ""))
  write.csv(Basic, file = basic_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2005
for (dir in yeardirs) {
  General <- data.frame(matrix(NA, nrow = 1, ncol = 30))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "General")
    general <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      General <- general 
    }
    else {
      General <- rbind(General, general)
    }
  }
  general_path <- toString(paste(outdata, "/general", "_", idx, ".csv", sep = ""))
  write.csv(General, general_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2005
for (dir in yeardirs) {
  Facility <- data.frame(matrix(NA, nrow = 1, ncol = 18))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "Facility")
    facility <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      Facility <- facility 
    }
    else {
      Facility <- rbind(Facility, facility)
    }
  }
  facility_path <- paste(outdata, "/facility", "_", idx, ".csv", sep = "")
  write.csv(Facility, facility_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2005
for (dir in yeardirs) {
  Repeaters <- data.frame(matrix(NA, nrow = 1, ncol = 10))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "Repeaters")
    repeaters <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      Repeaters <- repeaters
    }
    else {
      Repeaters <- rbind(Repeaters, repeaters)
    }
  }
  repeaters_path <- paste(outdata, "/repeaters", "_", idx, ".csv", sep = "")
  write.csv(Repeaters, repeaters_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2016
for (dir in yeardirs[12:13]) {
  Enrollment <- data.frame(matrix(NA, nrow = 1, ncol = 18))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "TotalEnrolment")
    enrollment <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      Enrollment <- enrollment
    }
    else {
      Enrollment <- rbind(Enrollment, enrollment)
    }
  }
  enrollment_path <- paste(outdata, "/enrollment", "_", idx, ".csv", sep = "")
  write.csv(Enrollment, enrollment_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2005
for (dir in yeardirs) {
  SCEnrollment <- data.frame(matrix(NA, nrow = 1, ncol = 18))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "SCEnrolment")
    scenrollment <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      SCEnrollment <- scenrollment
    }
    else {
      SCEnrollment <- rbind(SCEnrollment, scenrollment)
    }
  }
  scenrollment_path <- paste(outdata, "/scenrollment", "_", idx, ".csv", sep = "")
  write.csv(SCEnrollment, scenrollment_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2005
for (dir in yeardirs) {
  STEnrollment <- data.frame(matrix(NA, nrow = 1, ncol = 18))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "STEnrolment")
    stenrollment <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      STEnrollment <- stenrollment
    }
    else {
      STEnrollment <- rbind(STEnrollment, stenrollment)
    }
  }
  stenrollment_path <- paste(outdata, "/stenrollment", "_", idx, ".csv", sep = "")
  write.csv(STEnrollment, stenrollment_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2013
for (dir in yeardirs[9:13]) {
  OBCEnrollment <- data.frame(matrix(NA, nrow = 1, ncol = 18))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "OBCEnrolment")
    obcenrollment <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      OBCEnrollment <- obcenrollment
    }
    else {
      OBCEnrollment <- rbind(OBCEnrollment, obcenrollment)
    }
  }
  obcenrollment_path <- paste(outdata, "/obcenrollment", "_", idx, ".csv", sep = "")
  write.csv(OBCEnrollment, obcenrollment_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2005
for (dir in yeardirs) {
  DisabledEnrollment <- data.frame(matrix(NA, nrow = 1, ncol = 18))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "DisabledEnrolment")
    disabledenrollment <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      DisabledEnrollment <- disabledenrollment
    }
    else {
      DisabledEnrollment <- rbind(DisabledEnrollment, disabledenrollment)
    }
  }
  disabledenrollment_path <- paste(outdata, "/disabledenrollment", "_", idx, ".csv", sep = "")
  write.csv(DisabledEnrollment, disabledenrollment_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2010 
for (dir in yeardirs[6:13]) {
  RTE <- data.frame(matrix(NA, nrow = 1, ncol = 55))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "RTE")
    rte <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      RTE <- rte
    }
    else {
      RTE <- rbind(RTE, rte)
    }
  }
  rte_path <- paste(outdata, "/rte", "_", idx, ".csv", sep = "")
  write.csv(RTE, rte_path, row.names=FALSE)
  idx = idx + 1
}

idx = 2009
for (dir in yeardirs[5:13]) {
  Teachers <- data.frame(matrix(NA, nrow = 1, ncol = 10))
  statedirs <- dir(dir, pattern = "", full.names = TRUE)
  for (sdir in statedirs) {
    file <- list.files(sdir, pattern = "Teachers")
    teachers <- read_xlsx(paste(sdir, file, sep = "/"))
    if (sdir == statedirs[1]) {
      Teachers <- teachers
    }
    else {
      Teachers <- rbind(Teachers, teachers)
    }
  }
  teachers_path <- paste(outdata, "/teachers", "_", idx, ".csv", sep = "")
  write.csv(Teachers, teachers_path, row.names=FALSE)
  idx = idx + 1
}




















