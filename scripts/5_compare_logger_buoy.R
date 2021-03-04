#'------------------------------------------------------
#' Merge and Model Buoy data
#'------------------------------------------------------

library(vroom)
library(dplyr)
library(ggplot2)
library(lubridate)

setwd(here::here())

#read in data and put on a daily scale

buoy_dat <- vroom("data/buoy_data/44030_2013_2019.csv") %>%
  mutate(datetime = floor_date(datetime, unit = "day")) %>%
  select(datetime, sea_surface_temperature) %>%
  group_by(datetime) %>%
  summarize(sea_surface_temperature = 
              mean(sea_surface_temperature, na.rm=TRUE)) %>%
  ungroup()

logger_dat <- vroom("data/processed_data/merged_hobo_data_with_sites.csv")%>%
  mutate(datetime = floor_date(datetime, unit = "day")) %>%
  select(Site, datetime, temp_c) %>%
  group_by(Site, datetime) %>%
  summarize(temp_c = 
              mean(temp_c, na.rm=TRUE)) %>%
  ungroup()


sml_oisst <- vroom("data/processed_data/oisst_data.csv") %>%
  select(datetime, oisst_temp)

#join the temps
joined_temps <- left_join(logger_dat, buoy_dat) %>%
  group_by(Site) %>%
  arrange(datetime) %>%
  mutate(t_change = sea_surface_temperature - lag(sea_surface_temperature),
         week = factor(week(datetime))) %>%
  ungroup()

joined_oisst <- left_join(logger_dat, sml_oisst) %>%
  group_by(Site) %>%
  arrange(datetime) %>%
  mutate(t_change = oisst_temp - lag(oisst_temp),
         week = factor(week(datetime))) %>%
  ungroup()

#fit a MLR model
mod <- lm(temp_c ~ Site*(sea_surface_temperature*week+
             sea_surface_temperature*t_change), data = joined_temps)


mod_oisst <- lm(temp_c ~ Site*(oisst_temp*week+
                                 oisst_temp*t_change), data = joined_oisst)


#show the fit
joined_temps %>%
  modelr::add_predictions(mod) %>%
  tidyr::pivot_longer(cols = c(sea_surface_temperature, temp_c, pred),
                      names_to = "type",
                      values_to = "temp_c") %>%
  filter(type != "sea_surface_temperature") %>%
  ggplot(aes(x = datetime, y = temp_c, color = type)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~Site, scale = "free_x")


joined_oisst %>%
  modelr::add_predictions(mod_oisst) %>%
  tidyr::pivot_longer(cols = c(oisst_temp, temp_c, pred),
                      names_to = "type",
                      values_to = "temp_c") %>%
  filter(type != "oisst_temp") %>%
  ggplot(aes(x = datetime, y = temp_c, color = type)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~Site, scale = "free_x")


#save the model
saveRDS(mod, "models/44030_hobo_fit.R")
saveRDS(mod_oisst, "models/oisst_hobo_fit.R")
