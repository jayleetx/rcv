#' Alters ballot dataframe to have each row correspond to a single voter
#'
#' @param clean A tidy dataframe that comes from ballot_tidy()
#' @return A dataframe that can be easily read and understood by humans
#' @examples readable(sf_bos_clean)
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
#' @examples elected(sf_7_results, n = 1)
#' @export

elected <- function(results, n = 1) {
  results[1:n,1]
}


#' Summarizes the approval rate of the eventual winner(s)
#'
#' Counts what proportion of voters approved of the election winners, defining
#' "approved" as a voter listing the candidate on their ballot
#'
#' @param results the tabulated election results
#' @param image the clean ballot image
#' @param rcvcontest (optional) The election to calculate results for. If the image
#' contains more than one unique contest, this must be supplied.
#' @param n the number of candidates being elected (defaults to 1)
#' @return a numerical vector of length 1
#' @examples approval(sf_7_results, sf_bos_clean,
#'                    rcvcontest = "Board of Supervisors, District 7", n = 1)
#' @export

approval <- function(results, image, rcvcontest, n = 1) {
  voters <- approved <- NULL
  if (length(unique(image$contest)) > 1) {
    image <- image %>% dplyr::filter(contest == rcvcontest)
  }
  voters <- readable(image)
  approved <- image %>%
    dplyr::filter(candidate %in% elected(results, n)) %>%
    dplyr::count(pref_voter_id)
  nrow(approved) / nrow(voters)
}
