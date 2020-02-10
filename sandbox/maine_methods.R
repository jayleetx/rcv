# so what's up in Maine y'all
library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(rcv)

read_add_name <- function(file) {
  read_excel(file,
             col_types = "text",
             col_names = c('file_index',
                           'precinct',
                           'ballot',
                           1:5),
             skip = 1) %>%
    mutate(file = file)
}

me_data <- list.files(path = 'sandbox/data-raw', full.names = TRUE) %>%
  lapply(read_add_name) %>%
  bind_rows() %>%
  mutate(pref_voter_id = row_number())

cleaned <- me_data %>%
  na_if("undervote") %>%
  na_if('overvote') %>%
  mutate(`1` = stringr::str_remove(`1`, " \\(.*\\)$")) %>%
  gather(key = "vote_rank", value = "candidate", 4:8, na.rm = TRUE)

results <- rcv_tally(cleaned)
