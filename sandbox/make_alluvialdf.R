make_alluvialdf <- function(ballot, results) {
  voters <- ballot %>% unique(select(ballot, pref_voter_id))

  person <- ballot %>% filter(pref_voter_id = voters[x,1])

  elim <- data.frame(candidate = character())

  for (j in 2:(ncol(results)-1)) {
    temp <- results %>%
      select(candidate, j) %>%
      filter(!(is.na(results[, j]))) %>%
      dplyr::filter(candidate != "NA")

    loser <- temp %>%
      filter(temp[, 2] == min(temp[, 2])) %>%
      dplyr::select(candidate)

    elim <- rbind(elim, loser)
  }

}

