#' Alters ballot dataframe to have each row correspond to a single voter
#'
#' @param clean A tidy dataframe that comes from ballot_tidy()
#' @return A dataframe that can be easily read and understood by humans
#' @examples
#' readable(sf_bos_clean)
#' @export
readable <- function(clean) {
  contest <- pref_voter_id <- vote_rank <- candidate <- NULL
  clean %>%
    dplyr::select(contest,
                  pref_voter_id,
                  vote_rank,
                  candidate) %>%
    tidyr::spread(key = vote_rank, value = candidate)
}


#' Summarizes which candidates were elected from the results tally
#'
#' @param results the results tabulated from the election in question
#' @param n the number of candidates being elected (defaults to 1)
#' @return a vector of the candidates successfully elected
#' @export

elected <- function(results, n = 1) {
  results[1:n,1]
}
