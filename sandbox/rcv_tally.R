# tibbles mess this code up, fix namespace and imports

rcv_tallyv1 <- function(image, rcvcontest) {
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


rcv_tally <- function(image, contest) {
  ballot <- image %>%
    filter(contest == contest) %>%
    mutate(candidate = ifelse(is.na(candidate), "NA", candidate)) %>%
    select(pref_voter_id, vote_rank, candidate)

  n.cand <- length(unique(ballot$candidate))
  results <- data.frame(matrix(rep(NA, n.cand*(n.cand-2)), nrow = n.cand))
  roundnames <- c()
  for (i in 1:(n.cand - 2)) {
    roundnames <- append(roundnames, paste0("round", i))
  }
  colnames(results) <- roundnames
  row.names(results) <- unique(ballot$candidate)

  elim <- data.frame(candidate = character())

  round1 <- ballot %>%
    group_by(pref_voter_id) %>%
    filter(vote_rank == min(vote_rank)) %>%
    ungroup() %>%
    group_by(candidate) %>%
    summarise(total = n())

  round1 <- data.frame(round1)
  row.names(round1) <- round1$candidate

  for(i in unique(round1$candidate)) {
    results[i, 1] <- round1[i, 2]
    }

  loser <- round1 %>%
    filter(candidate != "NA") %>%
    filter(round1 == min(round1)) %>%
    select(candidate)

  elim <- rbind(elim, loser)

  transfers <- ballot %>%
    filter(vote_rank == min(vote_rank), candidate %in% loser) %>%
    select(pref_voter_id)

  round2 <- ballot %>%
    filter(pref_voter_id %in% transfers$pref_voter_id) %>%
    filter(!(candidate %in% elim$candidate)) %>%
    group_by(pref_voter_id) %>%
    filter(vote_rank == min(vote_rank)) %>%
    ungroup() %>%
    group_by(candidate) %>%
    summarise(round2 = n())

  round2 <- data.frame(round2)
  row.names(round2) <- round2$candidate

  for(i in unique(round2$candidate)) {
    results[i, 2] <- (results[i, 1] + round2[i, 2])
  }

  return(results)
}
