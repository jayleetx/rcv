#' Alters ballot dataframe to have each row correspond to a single voter
#'
#' @param clean A tidy dataframe that comes from ballot_tidy()
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
