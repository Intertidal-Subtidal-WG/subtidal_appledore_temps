#'------------------------------------------------------
#' Read buoy data
#' from Jan 1, 2013 to Jan 1, 2020
#'------------------------------------------------------

library(rnoaa)
library(purrr)
library(dplyr)
library(readr)

#get the data
buoy_dat <- map(c(2004:2008, 2011:2020),
                   ~buoy(dataset = "stdmet", buoyid = 44030, year = .x)) %>%
  map(~.x$data) #coerce from class buoy
  
  
buoy_dat_df <- buoy_dat %>% 
  bind_rows(buoy_dat) %>% #make into a df
  mutate(time = lubridate::ymd_hms(time)) %>%
  mutate(time = lubridate::with_tz(time, tzone = "EST")) %>%
  rename(datetime = time)

#write
write_csv(buoy_dat_df, "data/buoy_data/44030_2013_2019.csv")
