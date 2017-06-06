#read
data <- readr::read_csv(path,
                 col_names = paste0("V",
                                    seq_len(max(count.fields(path,
                                                             sep = ',')))))

#label
a <- data %>%
  tidyr::separate(V1, into = c("a",
                               "ward",
                               "precinct",
                               "b",
                               "unique"),
                  sep = c(2,4,6,10),
                  remove = T) %>%
  select(-a, -b) %>%
  tidyr::separate(V4, into = c("a", "1"),
                  sep = 3,
                  remove = T) %>%
  tidyr::unite(col = "contest",
               V3, a,
               sep = ", ") %>%
  dplyr::mutate(`1` = replace(`1`, which(`1` == ""), NA))

colnames(a) <- c("ward","precinct", "unique", "style", "contest",
                 as.character(c(1:(ncol(a)-5))))
tall <- a %>%
  tidyr::gather(key = vote_rank,
                value = candidate_id,
                c(6:(ncol(a))),
                na.rm = T) %>%
  dplyr::arrange(ward, precinct, unique) %>%
  tidyr::separate(candidate_id,
                  into = c("candidate_id", "a"),
                  sep = "\\[",
                  extra = "merge",
                  remove = T) %>%
  select(-a)
return(tall)
