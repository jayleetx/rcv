# tibbles mess this code up, fix namespace and imports

#' Determines RCV round results in a dataframe
#'
#' @param image A dataframe containing rcv election data
#' @param rcvcontest The election to calculate results for
#' @return A dataframe that contains vote tallies
#' @examples
#' rcv_tally(image = "sf_bos_clean", rcvcontest = "Board of Supervisors, District 1")
#' @export
rcv_tally <- function(image, rcvcontest) {
  ballot <- image %>%
    filter(contest == rcvcontest) %>%
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

  for (j in 1:(n.cand - 2)) {
    if (j >= 2) {
      transfers <- ballot %>%
        filter(vote_rank == min(vote_rank), candidate %in% loser) %>%
        select(pref_voter_id)
    } else transfers <- ballot %>% select(pref_voter_id)

    ballot <- ballot %>%
      filter(!(candidate %in% elim$candidate))

    round <- ballot %>%
      filter(pref_voter_id %in% transfers$pref_voter_id) %>%
      group_by(pref_voter_id) %>%
      filter(vote_rank == min(vote_rank)) %>%
      ungroup() %>%
      group_by(candidate) %>%
      summarise(total = n()) %>%
      data.frame()

    row.names(round) <- round$candidate

    for (i in unique(round$candidate)) {
      if (j >= 2) {
        round[i, 2] <- (results[i, j-1] + round[i, 2])
      }

      results [i, j] <- round[i, 2]

    }

    loser <- round %>%
      filter(candidate != "NA") %>%
      filter(total == min(total)) %>%
      select(candidate)

    elim <- rbind(elim, loser)
  }

  results <- results %>%
    rownames_to_column("names") %>%
    arrange(names == "NA", rowSums(is.na(.)), desc(.[ ,ncol(.)])) %>%
    column_to_rownames("names")

  return(results)
}
