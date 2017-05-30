rcv_tally <- function(image, rcvcontest) {
  rcv <- image %>%
    filter(contest == rcvcontest) %>%
    mutate(candidate = ifelse(is.na(candidate), "NA", candidate)) # move this step to ballot cleaning
  n.cand <- length(unique(rcv$candidate))
  results <- data.frame(matrix(rep(NA, n.cand*(n.cand-2)), nrow = n.cand))
  row.names(results) <- unique(rcv$candidate)
  roundnames <- c()
  for (i in 1:(n.cand - 2)) {
    roundnames <- append(roundnames, paste0("round", i))
  }
  colnames(results) <- roundnames
  elim <- data.frame(candidate = character(), total = integer())
  for (i in 1:(n.cand - 2)) {
    round <- rcv %>%
      filter(!(candidate %in% elim$candidate)) %>%
      group_by(pref_voter_id) %>%
      filter(vote_rank == min(vote_rank)) %>%
      ungroup() %>%
      group_by(candidate) %>%
      summarise(total = n())
    round <- rbind(round, elim)
    results[, i] <- round %>% select(total)
    loser <- round %>%
      arrange(total) %>%
      filter(candidate != "NA") %>%
      filter(!(candidate %in% round)) %>%
      head(n = 1) %>%
      mutate(total = NA)
    elim <- rbind(elim, loser)
  }
  return(results)
}
