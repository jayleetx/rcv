winner <- function(results) {
  results[1,1]
}

approval <- function(results, full) {
  full %>%
    group_by(pref_voter_id) %>%
    summarize(approve = winner(results) %in% Candidate) %>%
    ungroup()
}
