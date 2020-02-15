library(tidyverse)
devtools::load_all()

ballot_orig <- cambridge_clean %>%
  filter(contest == "001, 1) ") %>%
  mutate(candidate = ifelse(str_detect(candidate, "="), NA, candidate))

# BEFORE RUNNING FUNCTION
# this should only be run with a single contest, bc it will pull all rows as data
# replace all ties with NA

new_tally <- function(ballot,
                      voter_col = "pref_voter_id",
                      rank_cols = "vote_rank",
                      cand_col = "candidate",
                      rules) {
  # things that should break
  # giving a column name that's not in ballot
  # supplying cand_col AND multiple rank_cols - if multiple ranks, cand is values
  # any number in rank_col that's not the actual ranking
  # having NAs for voter/rank/candidate will get dropped

  # drop columns not needed for counting
  ballot <- ballot %>%
    dplyr::select(voter = voter_col,
                  rank_cols,
                  candidate = cand_col)

  if (length(rank_cols) > 1) {
    # tidy ballot, if it came in wide format
    ballot <- ballot %>%
      tidyr::pivot_longer(cols = rank_cols,
                          names_to = "rank",
                          values_to = "candidate",
                          values_drop_na = TRUE)
  } else {
    # standardize last column name
    ballot <- ballot %>%
      dplyr::rename(rank = rank_cols)
  }

  # at this stage, we should always have the same three columns
  # voter, rank, and candidate
  # make rank numeric and arrange accordingly
  ballot <- ballot %>%
    dplyr::select(voter, rank, candidate) %>%
    dplyr::mutate(rank = stringr::str_extract(rank, "\\d+")) %>%
    dplyr::arrange(voter, rank)

  # drop duplicate candidates and intermediate NAs
  ballot <- ballot %>%
    dplyr::distinct(voter, candidate, .keep_all = TRUE) %>%
    dplyr::filter(complete.cases(.))

  # at this point, the ballot should be ready to count
  # no duplicates, no missing cases, standardized column

  candidates <- unique(ballot$candidate)

  # make it wide to group into a "tree" format
  ballot <- ballot %>%
    tidyr::pivot_wider(names_from = rank,
                       values_from = candidate)

  ranks <- colnames(ballot)[-1]

  tree_count <- ballot %>%
    dplyr::group_by_at(dplyr::vars(ranks)) %>%
    dplyr::tally() %>%
    dplyr::ungroup() %>%
    dplyr::mutate(index = dplyr::row_number()) %>%
    dplyr::select(index, n, dplyr::everything())

  tall_tree <- tree_count %>%
    tidyr::pivot_longer(cols = ranks,
                        names_to = "rank",
                        values_to = "candidate",
                        values_drop_na = TRUE)

  first_tally <- tall_tree %>%
    dplyr::arrange(index, rank) %>%
    dplyr::group_by(index) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(candidate) %>%
    dplyr::summarize(votes = sum(n)) %>%
    dplyr::arrange(desc(votes))
}
