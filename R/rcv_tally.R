#' Determines RCV round results in a dataframe
#'
#' @param image A dataframe containing rcv election data
#' @param rcvcontest (optional) The election to calculate results for. If the image
#' contains more than one unique contest, this must be supplied.
#' @return A dataframe that contains vote tallies
#' @examples
#' rcv_tally(image = sf_bos_clean, rcvcontest = "Board of Supervisors, District 7")
#' @export
rcv_tally <- function(image, rcvcontest) {
  if (length(unique(image$contest)) > 1) {
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

  n.cand <- length(unique(ballot$candidate))
  results <- data.frame(matrix(rep(NA, n.cand*(n.cand-2)),
                               nrow = n.cand))
  roundnames <- c()
  for (i in 1:(n.cand - 2)) {
    roundnames <- append(roundnames, paste0("round", i))
  }
  colnames(results) <- roundnames
  row.names(results) <- unique(ballot$candidate)

  elim <- data.frame(candidate = character())

  for (j in 1:(n.cand - 2)) {
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
      transmute(candidate = as.character(unique.ballot.candidate.))

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
    tibble::rownames_to_column("candidate") %>%
    dplyr::arrange(candidate == "NA", rowSums(is.na(.)), desc(.[ ,ncol(.)])) %>%
    tibble::column_to_rownames("candidate") %>%
    add_exhausted()

}
