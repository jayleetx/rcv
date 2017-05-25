#' Alters ballot dataframe to have each row correspond to a single voter
#'
#' @param x A tidy dataframe that comes from ballot_tidy()
#' @return A dataframe that can be easily read and understood by humans
#' @examples
#' readable(sf_bos_clean)
#' @export
readable <- function(x) {
  spread(x, key = vote_rank,
              value = candidate)
}
