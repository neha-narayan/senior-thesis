rm(list = ls())
library(tidyverse)
library(broom)

df <- read_csv("../../../shared_data/pincode_ipw.csv")

df$interact <- 0 
df$interact[df$ac_year >= 2017 & 
              df$statename %in% c("ANDAMAN & NICOBAR ISLANDS", 
                                  "ARUNACHAL PRADESH", "BIHAR", "CHANDIGARH", 
                                  "CHHATTISGARH", "DNH & DD", "GOA", "GUJARAT", 
                                  "KARNATAKA", "LAKSHADWEEP", "MIZORAM", "NAGALAND", 
                                  "ODISHA", "PUNJAB", "RAJASTHAN", "SIKKIM", "TRIPURA", 
                                  "UTTAR PRADESH", "MADHYA PRADESH")] <- 1
df$interact[df$ac_year >= 2016 & df$statename %in% c("MANIPUR", "JHARKHAND", "DELHI")] <- 1 
df$interact[df$ac_year >= 2015 & df$statename %in% c("ANDHRA PRADESH", "HARYANA")] <- 1 

df <- df[df$reliable_index <= 1 & is.na(df$reliable_index) == FALSE & df$ac_year == 2018, ]

#logistic regression
predict <- glm(interact ~ reliable_index,
               family = binomial(link = "logit"),
               data = df)
df <- augment_columns(predict, df, type.predict = "response") %>%
  rename (ps = .fitted) %>%
  mutate(ipw = ps/(1-ps))
df$ipw_norm <- 1
df$ipw_norm[df$interact==0] <- df$ipw[df$interact==0]/sum(df$ipw[df$interact==0])

df <- as.data.frame(cbind(df$pincode, df$ipw_norm))
colnames(df) <- c("pincode", "ipw")
write.csv(df, "../../../shared_data/ipw_weights_reliability.csv")

df <- read_csv("../../../shared_data/pincode_ipw.csv")

df$interact <- 0
df$interact[df$ac_year >= 2017 & 
              df$statename %in% c("ANDAMAN & NICOBAR ISLANDS", 
                                  "ARUNACHAL PRADESH", "BIHAR", "CHANDIGARH", 
                                  "CHHATTISGARH", "DNH & DD", "GOA", "GUJARAT", 
                                  "KARNATAKA", "LAKSHADWEEP", "MIZORAM", "NAGALAND", 
                                  "ODISHA", "PUNJAB", "RAJASTHAN", "SIKKIM", "TRIPURA", 
                                  "UTTAR PRADESH", "MADHYA PRADESH")] <- 1
df$interact[df$ac_year >= 2016 & df$statename %in% c("MANIPUR", "JHARKHAND", "DELHI")] <- 1 
df$interact[df$ac_year >= 2015 & df$statename %in% c("ANDHRA PRADESH", "HARYANA")] <- 1 

df <- df[df$ac_year == 2018, ]

#logistic regression
predict <- glm(interact ~ num_centers,
               family = binomial(link = "logit"),
               data = df)
df <- augment_columns(predict, df, type.predict = "response") %>%
  rename (ps = .fitted) %>%
  mutate(ipw = ps/(1-ps))
df$ipw_norm <- 1
df$ipw_norm[df$interact==0] <- df$ipw[df$interact==0]/sum(df$ipw[df$interact==0])

df <- as.data.frame(cbind(df$pincode, df$ipw_norm))
colnames(df) <- c("pincode", "ipw")
write.csv(df, "../../../shared_data/ipw_weights_centers.csv")










