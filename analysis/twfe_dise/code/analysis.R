rm(list=ls())
library(xlsx)
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(estimatr)
library(ggthemes)
library(matrixStats)

memory.limit(size=56000)
df <- read.csv('../../../shared_data/cohortdata.csv')

B = 10^5
betas_most <- matrix(0, 8, B)
betas_least <- matrix(0, 8, B)

set.seed(1960)
for (reps in 1:B) {
  districts <- df %>% group_by(statename, reliable_scale) %>% slice_sample(n = 1)
  sample <- df[df$distname %in% districts$distname,] 
  reg_most <- lm_robust(enrollment_rate ~ F_4 + F_3 + F_2 + F_1 + L_0 + L_1 + L_2 +
                   L_3 + L_4 + factor(district_x_data) + factor(year_x_data),  
                   clusters = statename, 
                   weights = schtot,
                   se_type = 'stata',
                   data = sample[sample$reliable_scale=="Most Reliable",])
  reg_least <- lm_robust(enrollment_rate ~ F_4 + F_3 + F_2 + F_1 + L_0 + L_1 + L_2 +
                        L_3 + L_4 + factor(district_x_data) + factor(year_x_data),  
                        clusters = statename,
                        weights = schtot,
                        se_type = 'stata',
                        data = sample[sample$reliable_scale=="Least Reliable",])
  bm <- reg_most$coefficients[c(2:4, 6:10)]
  bl <- reg_least$coefficients[c(2:4, 6:10)]
  betas_most[,reps] <- bm
  betas_least[,reps] <- bl
}

betaM <- as.data.frame(t(rowMeans(betas_most)))
SE_M <- rowSds(betas_most)

betaL <- as.data.frame(t(rowMeans(betas_least)))
SE_L <- rowSds(betas_least)

beta <- rbind(betaM, betaL)
SE <-  as.data.frame(rbind(SE_M, SE_L))


longB <- beta %>%
  pivot_longer(cols = everything(), names_to = "EventTime", values_to = "Coefficient")
longSE <- SE %>%
  pivot_longer(cols = everything(), names_to = "EventTime", values_to = "SE")

combine <- cbind(longB, longSE[,2])

combine$EventTime[combine$EventTime == "V1"] <- "-4"
combine$EventTime[combine$EventTime == "V2"] <-  "-3"
combine$EventTime[combine$EventTime == "V3"] <- "-2"
combine$EventTime[combine$EventTime == "V4"] <- "0"
combine$EventTime[combine$EventTime == "V5"] <- "1"
combine$EventTime[combine$EventTime == "V6"] <-  "2"
combine$EventTime[combine$EventTime == "V7"] <- "3"
combine$EventTime[combine$EventTime == "V8"] <- "4"

combine$Group <- "Most Reliable"
combine$Group[9:16] <- "Least Reliable"

normalized_year <-data.frame(-1, 0, 0, "Most Reliable")
normalized_year <- rbind(normalized_year, c(-1, 0, 0, "Least Reliable"))
names(normalized_year)<-c("EventTime", "Coefficient", "SE", "Group")

combine <- rbind(combine, normalized_year)
combine$EventTime <- as.numeric(combine$EventTime)
combine$SE <- as.numeric(combine$SE)
combine$Coefficient <- as.numeric(combine$Coefficient)

p <- ggplot(combine, aes(x = EventTime, y = Coefficient, color = as.factor(Group))) +
  geom_point(position = position_dodge(0.2)) +
  geom_errorbar(aes(ymin = Coefficient - 2*SE, ymax = Coefficient + 2*SE),
                width = 0.2, position = position_dodge(0.2)) +
  labs(title = "Event Study Plot, Most vs. Least Reliable Districts",
       x = "Time to Event",
       y = "Treatment Effect",
       color = "Group") +
  scale_x_continuous(breaks = seq(-4, 4, by = 1)) +
  scale_color_manual(values=c("steelblue4", "red4")) + 
  theme_stata(base_size = 11, base_family = "sans", scheme = "s2color")

ggsave('../output/erroranalysis.png', plot = p, width = 30, height = 20, units = "cm")










