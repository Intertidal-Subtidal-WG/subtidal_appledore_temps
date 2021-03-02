#'---------------------------------------------------
#' Read and merge all temperature logger info files
#'---------------------------------------------------

library(readxl)
library(dplyr)
library(purrr)
setwd(here::here())

#what are the files we want to use
files <- list.files("logger_info/", full.names = TRUE)

#read in files
all_files <- map(files, read_excel)

#bind this into a data frame
all_files <- bind_rows(all_files)
