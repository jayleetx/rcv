#' Determines RCV round results in a dataframe
#'
#' @param image A dataframe containing rcv election data
#' @param rules Currently, either "rcv" (one winner, ranked-choice voting) or
#' "stv" (multiwinner, single transferable vote). Later, options will be
#' available for specific cities' implementations of the STV algorithm.
#' Currently the Droop quota is used for STV, with surplus votes selected
#' randomly for further allocation.
#' @param n_winners default 1. In a multi-winner election (STV), the number
#' of candidates to be elected.
#' @param rcvcontest (optional) The election to calculate results for. If the
#' image contains more than one unique contest, this must be supplied. In most
#' cases except for some San Francisco elections, this is unnecessary.
#' @return A dataframe that contains vote tallies
#' @examples
#' rcv_tally(sf_bos_clean, rcvcontest = "Board of Supervisors, District 7")
#' rcv_tally(cambridge_clean, n_winner = )
#' @export
rcv_tally <- function(image, rules = c('rcv','stv'), n_winners = 1, rcvcontest) {
  contest <- candidate <- pref_voter_id <- vote_rank <- n <- total <- NULL
  unique.ballot.candidate. <- . <- NULL
  if (!(missing(rcvcontest))) {
    image <- image %>% dplyr::filter(contest == rcvcontest)
  }
  ballot <- image %>%
    dplyr::filter(stringr::str_detect(candidate, "=") %in% c(F, NA)) %>%
    dplyr::mutate(candidate = ifelse(is.na(candidate),
                                     "NA",
                                     candidate)) %>%
    dplyr::select(pref_voter_id,
                  vote_rank,
                  candidate)

  n_cand <- length(unique(ballot$candidate))
  n_round <- n_cand - 1 - n_winners
  results <- data.frame(matrix(rep(NA, n_cand*n_round),
                               nrow = n_cand))
  roundnames <- rep(NA, n_round)
  for (i in 1:n_round) {
    roundnames[i] <- paste0("round", i)
  }
  colnames(results) <- roundnames
  row.names(results) <- unique(ballot$candidate)

  elim <- data.frame(candidate = character())

  for (j in 1:n_round) {
    if (j >= 2) {
      transfers <- ballot %>%
        dplyr::filter(vote_rank == min(vote_rank),
                      candidate %in% loser) %>%
        dplyr::select(pref_voter_id)
      a <- 0
    } else transfers <- ballot %>% dplyr::select(pref_voter_id)

    if (nrow(transfers) == 0) {
      transfers <- ballot %>% dplyr::select(pref_voter_id)
      a <- 1
    }

    ballot <- ballot %>%
      dplyr::filter(!(candidate %in% elim$candidate))

    candidates <- data.frame(unique(ballot$candidate)) %>%
      dplyr::transmute(candidate = as.character(unique.ballot.candidate.))

    round <- ballot %>%
      dplyr::filter(pref_voter_id %in% transfers$pref_voter_id) %>%
      dplyr::group_by(pref_voter_id) %>%
      dplyr::filter(vote_rank == min(vote_rank)) %>%
      dplyr::ungroup() %>%
      dplyr::group_by(candidate) %>%
      dplyr::summarise(total = n()) %>%
      data.frame() %>%
      dplyr::right_join(candidates,
                 by = c("candidate")) %>%
        dplyr::mutate(total = ifelse(is.na(total), 0, total))

    row.names(round) <- round$candidate

    for (i in unique(round$candidate)) {
      if (j >= 2) {
        if (a != 1) {
          round[i, 2] <- (results[i, j-1] + round[i, 2])
        }
      }

      results [i, j] <- round[i, 2]

    }

    loser <- round %>%
      dplyr::filter(candidate != "NA") %>%
      dplyr::filter(total == min(total)) %>%
      dplyr::select(candidate)

    elim <- rbind(elim, loser)
  }

  results %>%
    dplyr::select(which(as.vector(colSums(is.na(.)) < (nrow(.) - 1)))) %>%
    tibble::rownames_to_column("candidate") %>%
    dplyr::arrange(candidate == "NA",
                   rowSums(is.na(.)),
                   dplyr::desc(.[ ,ncol(.)])) %>%
    tibble::column_to_rownames("candidate") %>%
    add_exhausted()

}


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
    exhausted[1, i] <- sum(exhausted[1, i], results["NA", i], na.rm = T)
  }
  results["NA", ] <- exhausted[1, ]
  results <- results %>%
    tibble::rownames_to_column("candidate")

  return(results)
}
