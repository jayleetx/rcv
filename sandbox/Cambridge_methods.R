# data <- cambridge_clean
tally <- function(data, n_winners = 1) {
  n_voters <- length(unique(data$pref_voter_id))
  n_cands <- length(unique(data$candidate))
  if (n_winners <= 0 | n_winners %% 1 != 0) stop("Number of winners must be a positive integer")
  if (n_winners > n_cands) {
    stop(sprintf("Number of winners must be less than the total number of candidates (%i)", n_cands))
  }

  quota <- n_voters / (n_winners + 1) + 1

  elected <- character(n_winners)
}
