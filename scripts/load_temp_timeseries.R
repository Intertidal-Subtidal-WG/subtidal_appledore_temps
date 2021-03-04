#'------------------------------------------------------
#' Load all three temperature timeseries and make daily
#'------------------------------------------------------

library(vroom)
library(dplyr)
library(ggplot2)
library(lubridate)


buoy_dat <- vroom("data/buoy_data/44030_2013_2019.csv") %>%
  mutate(datetime = floor_date(datetime, unit = "day")) %>%
  select(datetime, sea_surface_temperature) %>%
  group_by(datetime) %>%
  summarize(sea_surface_temperature = 
              mean(sea_surface_temperature, na.rm=TRUE)) %>%
  ungroup() %>%
  arrange(datetime) %>%
  mutate(t_change = sea_surface_temperature - lag(sea_surface_temperature),
         week = factor(week(datetime)))

logger_dat <- vroom("data/processed_data/merged_hobo_data_with_sites.csv")%>%
  mutate(datetime = floor_date(datetime, unit = "day")) %>%
  select(Site, datetime, temp_c) %>%
  group_by(Site, datetime) %>%
  summarize(temp_c = 
              mean(temp_c, na.rm=TRUE)) %>%
  ungroup()


sml_oisst <- vroom("data/processed_data/oisst_data.csv") %>%
  select(datetime, oisst_temp) %>%
  arrange(datetime) %>%
  mutate(t_change = oisst_temp - lag(oisst_temp),
         week = factor(week(datetime)))