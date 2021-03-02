#'---------------------------------------------------
#' Read and merge all temperature logger info files
#'---------------------------------------------------

library(readxl)
library(dplyr)
library(purrr)
setwd(here::here())

#what are the 
files <- list.files("logger_info/", full.names = TRUE)

all_files <- map(files, read_excel)
