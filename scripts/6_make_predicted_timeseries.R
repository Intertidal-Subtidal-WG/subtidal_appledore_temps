#'--------------------------------------------------------------
#' Create extrapolated records based on model fits & Real data
#'--------------------------------------------------------------

setwd(here::here())

#load the timeseries and a few libraries
source("scripts/load_temp_timeseries.R")

#load the models
mod_buoy <- readRDS("models/44030_hobo_fit.R")
mod_oisst <- readRDS("models/oisst_hobo_fit.R")


#make buoy predicted DF

make_pred_ts <- function(dat, mod){
  pred_frame <- tidyr::crossing(dat, 
                                tibble(Site = unique(logger_dat$Site)))
  
  pred_frame <-pred_frame %>%
    modelr::add_predictions(mod)
  
  pred_frame <- left_join(pred_frame, logger_dat)
  
  pred_frame %>%
    mutate(temp_c_combined = ifelse(is.na(temp_c), pred, temp_c))
}

#Make those predictions!
buoy_pred <- make_pred_ts(buoy_dat, mod_buoy)
oisst_pred <- make_pred_ts(sml_oisst, mod_oisst)

#Save those predictions!
saveRDS(buoy_dat, "data/processed_data/buoy_predicted_temps.RDS")
saveRDS(oisst_pred, "data/processed_data/oisst_predicted_temps.RDS")

readr::write_csv(buoy_dat, "data/processed_data/buoy_predicted_temps.csv")
readr::write_csv(oisst_pred, "data/processed_data/oisst_predicted_temps.csv")


#test
library(ggplot2)

ggplot(buoy_pred,
       aes(x = datetime)) +
  geom_line(aes(y = temp_c_combined), color = "red") +
  geom_point(aes(y = temp_c), color = "blue", size = 0.1)


ggplot(oisst_pred,
       aes(x = datetime)) +
  geom_line(aes(y = pred), color = "red") +
  geom_point(aes(y = temp_c), color = "blue", size = 0.1) + 
  facet_wrap(~Site)

ggplot(oisst_pred %>% 
         group_by(Site, datetime = floor_date(datetime, "year")) %>%
         summarize(mean = mean(pred, na.rm=TRUE),
                   max = max(pred, na.rm=TRUE),
                   min = min(pred, na.rm=TRUE)) %>%
         tidyr::pivot_longer(c(mean, min, max), names_to = "type", values_to = "pred"),
       aes(x = datetime)) +
  geom_line(aes(y = pred), color = "red") +
  facet_grid(type~Site, scale = "free_y")

