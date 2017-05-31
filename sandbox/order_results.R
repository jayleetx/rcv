results %>%
  arrange(rowSums(is.na(.)), desc(.[]))
