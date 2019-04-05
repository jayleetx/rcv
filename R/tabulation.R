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
rcv_tally <- function (image, rcvcontest) {
  contest <- candidate <- pref_voter_id <- vote_rank <- n <- total <- ballot <- NULL
  unique.ballot.candidate. <- . <- NULL
  # filter for the specified contest
  if (!(missing(rcvcontest))) {
    image <- image %>% dplyr::filter(contest == rcvcontest)
  }
  # drop overvotes, make NA a character
  ballot <- image %>% dplyr::filter(stringr::str_detect(candidate, "=") %in% c(F, NA)) %>%
    dplyr::mutate(candidate = ifelse(is.na(candidate),"NA", candidate)) %>%
    dplyr::select(pref_voter_id, vote_rank, candidate)

  # set up empty results df
  n.cand <- length(unique(c(ballot$candidate, "NA")))
  results <- data.frame(matrix(rep(NA, n.cand * (n.cand - 2)),
                               nrow = n.cand))
  row.names(results) <- unique(c(ballot$candidate, "NA"))
  roundnames <- c()
  for (i in 1:(n.cand - 2)) {
    roundnames <- append(roundnames, paste0("round", i))
  }
  colnames(results) <- roundnames

  # run the algorithm

  # make blank df for dropped candidates
  elim <- data.frame(candidate = character())
  for (j in 1:(n.cand - 2)) {
    # if there are >= 3 cands left, select everybody who voted for an eliminated candidate
    if (j >= 2) {
      transfers <- ballot %>%
        dplyr::filter(vote_rank == min(vote_rank), candidate %in% loser) %>%
        dplyr::select(pref_voter_id)
      a <- 0
    } # else select everybody
    else transfers <- ballot %>% dplyr::select(pref_voter_id)
    if (nrow(transfers) == 0) {
      transfers <- ballot %>% dplyr::select(pref_voter_id)
      a <- 1
    }
    # drop the eliminated cands, list remaining
    ballot <- ballot %>% dplyr::filter(!(candidate %in% elim$candidate))
    candidates <- data.frame(unique(ballot$candidate)) %>%
      dplyr::transmute(candidate = as.character(unique.ballot.candidate.))
    # get new preferences for every voter, count up votes for candidates
    round <- ballot %>%
      dplyr::filter(pref_voter_id %in% transfers$pref_voter_id) %>%
      dplyr::group_by(pref_voter_id) %>%
      dplyr::filter(vote_rank == min(vote_rank)) %>%
      dplyr::ungroup() %>%
      dplyr::group_by(candidate) %>%
      dplyr::summarise(total = n()) %>%
      data.frame() %>%
      dplyr::right_join(candidates, by = c("candidate")) %>%
      dplyr::mutate(total = ifelse(is.na(total), 0, total))
    # write data into the results df
    row.names(round) <- round$candidate
    for (i in unique(round$candidate)) {
      if (j >= 2) {
        if (a != 1) {
          round[i, 2] <- (results[i, j - 1] + round[i,
                                                    2])
        }
      }
      results[i, j] <- round[i, 2]
    }
    # grab the loser, add to eliminated
    loser <- round %>% dplyr::filter(candidate != "NA") %>%
      dplyr::filter(total == min(total)) %>% dplyr::select(candidate)
    elim <- rbind(elim, loser)
  }
  # end of for loop

  # arrange results df for viewing
  results %>% dplyr::select(which(as.vector(colSums(is.na(.)) < (nrow(.) - 1)))) %>%
    tibble::rownames_to_column("candidate") %>%
    dplyr::arrange(candidate == "NA", rowSums(is.na(.)),
                   dplyr::desc(.[, ncol(.)])) %>%
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
