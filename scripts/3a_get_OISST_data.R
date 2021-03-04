#'------------------------------------------------------
#' Get NOAA OISST data
#'------------------------------------------------------

#using vignette at https://cran.r-project.org/web/packages/heatwaveR/vignettes/OISST_preparation.html

library(dplyr) # A staple for modern data management in R
library(lubridate) # Useful functions for dealing with dates
library(ggplot2) # The preferred library for data visualisation
library(tidync) # For easily dealing with NetCDF data
library(rerddap) # For easily downloading subsets of data
library(doParallel) # For parallel processing

setwd(here::here())

# The information for the NOAA OISST data
rerddap::info(datasetid = "ncdcOisst21Agg_LonPM180", url = "https://coastwatch.pfeg.noaa.gov/erddap/")

# This function downloads and prepares data based on user provided start and end dates
OISST_sub_dl <- function(time_df){
  OISST_dat <- griddap(x = "ncdcOisst21Agg_LonPM180", 
                       url = "https://coastwatch.pfeg.noaa.gov/erddap/", 
                       time = c(time_df$start, time_df$end), 
                       zlev = c(0, 0),
                       latitude = c(42.75, 43),
                       longitude = c(-70.75, -70.5),
                       fields = "sst")$data %>% 
    mutate(time = as.Date(stringr::str_remove(time, "T00:00:00Z"))) %>% 
    dplyr::rename(t = time, temp = sst) %>% 
    select(lon, lat, t, temp) %>% 
    na.omit()
}


# Date download range by start and end dates per year
# Server only likes to serve 9 years at a time
dl_years <- data.frame(date_index = 1:5,
                       start = as.Date(c("1982-01-01", "1990-01-01", 
                                         "1998-01-01", "2006-01-01", "2014-01-01")),
                       end = as.Date(c("1989-12-31", "1997-12-31", 
                                       "2005-12-31", "2013-12-31", "2019-12-31")))

# Download all of the data with one nested request
# The time this takes will vary greatly based on connection speed
system.time(
  OISST_data <- dl_years %>% 
    group_by(date_index) %>% 
    group_modify(~OISST_sub_dl(.x)) %>% 
    ungroup() %>% 
    select(lon, lat, t, temp)
) # 670 seconds, ~134 seconds per batch


sml_oisst <- OISST_data %>%
  filter(lat == 42.875, lon == -70.625) %>%
  rename(datetime = t, oisst_temp = temp) %>%
  mutate(datetime = lubridate::as_datetime(datetime))


#check
library(ggplot2)
ggplot(sml_oisst,
       aes(x = datetime, y = oisst_temp)) +
  geom_line()


readr::write_csv(sml_oisst, "data/processed_data/oisst_data.csv")
