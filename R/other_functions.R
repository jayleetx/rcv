#' Alters ballot dataframe to have each row correspond to a single voter
#'
#' @param x A tidy dataframe that comes from ballot_tidy()
#' @return A dataframe that can be easily read and understood by humans
#' @examples
#' readable(sf_bos_clean)
#' @export
readable <- function(clean) {
  clean %>%
    dplyr::select(contest,
                  pref_voter_id,
                  precinct,
                  vote_rank,
                  candidate) %>%
    tidyr::spread(key = vote_rank, value = candidate)
}

# Added line for travis build check


#' Adds correct exhausted numbers for a `rcv_tally` dataframe
#'
#' @param results A dataframe that comes from `rcv_tally()`
#' @return The results dataframe with correct counts for the exhausted votes
#' @export
add_exhausted <- function(results) {

  total <- sum(results[, 1], na.rm = T)
  exhausted <- data.frame(matrix(rep(NA, ncol(results)), nrow = 1))
  colnames(exhausted) <- colnames(results)
  row.names(exhausted) <- c("Exhausted")
  for (i in 1:ncol(results)) {
    exhausted[1, i] <- total - sum(results[, i], na.rm = T)
  }
  exhausted[1, ] <- exhausted[1, ] + results["NA", ]
  results["NA", ] <- exhausted[1, ]

  return(results)
}
