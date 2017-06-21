# data <- cambridge_clean
cambridge_tally <- function(data, n) {
  data <- data %>%
    dplyr::filter(stringr::str_detect(candidate, "=") %in% c(F, NA)) %>%
    dplyr::mutate(candidate = ifelse(is.na(candidate),
                                     "NA",
                                     candidate)) %>%
    dplyr::select(pref_voter_id,
                  vote_rank,
                  candidate)

  voters <- length(unique(data$pref_voter_id))

  quota <- floor(voters / (n+1) + 1)

  quota
}
