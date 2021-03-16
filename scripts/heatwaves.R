library(heatwaveR)
library(dplyr)
library(ggplot2)
library(tidyr)

dat <- readRDS("data/processed_data/oisst_predicted_temps.RDS")

head(dat)


a <- dat %>% 
  filter(Site=="SW Appledore") %>%
  mutate(datetime = as.Date(datetime)) %>%
  ts2clm(x = datetime,
         y = oisst_temp,
         climatologyPeriod = c("1982-01-01", "2019-12-31"))  


ne_event <- detect_event(a,
                         x = datetime,
                         y = oisst_temp)


event_line(ne_event, spread = 180, metric = "intensity_max", 
          start_date = "1982-01-01", end_date = "2019-12-31",
          x = datetime, y = oisst_temp)

library(ggplot2)
ggplot(ne_event$event, aes(x = date_peak, y = intensity_max)) +
  geom_lolli(colour = "firebrick") +
  labs(x = "Peak Date", 
       y = expression(paste("Max. intensity [", degree, "C]")), x = NULL) +
  theme_linedraw()


ggplot(ne_event$climatology %>%
        pivot_longer(c(oisst_temp, seas, thresh), 
                     names_to = "type", values_to = "temperature"),
       aes(x = datetime, y = temperature, color = type)) +
  geom_line()
