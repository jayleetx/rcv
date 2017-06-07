# read
read <- function(path) {
  readr::read_csv(path,
                 col_names = paste0("V",
                                    seq_len(max(count.fields(path,
                                                             sep = ',')))))
}
# label
label <- function(data) { x <- data %>%
  tidyr::separate(V1, into = c("a","ward","precinct","b"),
                  sep = c(2,4,6),
                  remove = T) %>%
  select(-a, -b) %>%
  tidyr::separate(V4, into = c("a", "1"),
                  sep = 3,
                  remove = T) %>%
  tidyr::unite(col = "contest",
               V3, a,
               sep = ", ") %>%
  dplyr::mutate(`1` = replace(`1`, which(`1` == ""), NA))

colnames(x) <- c("ward","precinct", "style", "contest",
                 as.character(c(1:(ncol(x)-4))))
tall <- x %>%
  tibble::rownames_to_column("pref_voter_id") %>%
  tidyr::gather(key = vote_rank,
                value = candidate_id,
                c(6:(ncol(x)+1)),
                na.rm = T) %>%
  dplyr::mutate(candidate_id = stringr::str_replace_all(candidate_id,
                                                        "\\[[0-9]{1,2}\\]",
                                                        ""),
                pref_voter_id = as.integer(pref_voter_id)) %>%
  dplyr::arrange(pref_voter_id, vote_rank)
return(tall)
}

# label image

label <- function(data) {
  data %>%
    dplyr::filter(V1 == "20") %>%
    dplyr::select(V2,V3) %>%
    dplyr::rename(id = V2,
                  description = V3)
}
