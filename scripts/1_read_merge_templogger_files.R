#'---------------------------------------------------
#' Read and merge all temperature logger info files
#'---------------------------------------------------

library(readxl)
library(dplyr)
library(purrr)
setwd(here::here())

#what are the files we want to use
files <- list.files("data/logger_info/", full.names = TRUE)%>%
  stringr::str_subset("~", negate = TRUE)

#read in files for fun and profit
all_files <- map(files, read_excel) 


#bind this into a data frame
all_files <- bind_rows(all_files) %>%
  filter(!is.na(`Logger ID`)) %>%
  dplyr::select(-Region)

library(ggplot2)
ggplot(all_files,
       aes(x = factor(`Logger ID`), y = Year, color = Site)) +
  geom_point(position = position_dodge(width = 1)) +
  geom_line(position = position_dodge(width = 1)) +
  facet_wrap(~Site, scale = "free_x") +
  theme(axis.text.x = element_text(angle = -90)) +
  labs(x = "") 

#write out products
ggsave("figures/logger_history.jpg")
readr::write_csv(all_files, "data/processed_data/logger_history.csv")
