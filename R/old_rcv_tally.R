#' Old function for determining rcv election results
#'
#' @param rcvimage A specifically formatted dataframe of an rcv ballot image
#' @param rcvcontest The specific contest that one wants to determine results for
#' @return A dataframe containing round by round sums
#' @examples
#' old_rcv_tally(rcvimage = sf_bos_clean, rcvcontest = "Board of Supervisors, District 1")
#' @export
old_rcv_tally <- function(rcvimage, rcvcontest) {

  assign(paste0("Election: ", rcvcontest),
         rcvimage %>%
           filter(contest == rcvcontest))

  assign("round0", data.frame(unique(get(paste0("Election: ", rcvcontest))['candidate'])))
  colnames(round0) <- c("candidate")
  assign("loser0", data.frame(candidate = character()))

  a <- (nrow(round0) - 3)
  for (i in 0:a) {
    assign(
      paste0("round", i+1),
      get(paste0("Election: ", rcvcontest)) %>%
        filter(!(candidate %in% get(paste0("loser", i))[['candidate']])) %>%
        group_by(pref_voter_id) %>%
        filter(vote_rank == min(vote_rank)) %>%
        ungroup() %>%
        group_by(candidate) %>%
        summarise(total = n()) %>%
        arrange(desc(total)))
    b <- get(paste0("round", i+1)) %>% filter(!is.na(candidate))
    assign(paste0("round", i+1),
           mutate(
             get(paste0("round", i+1)),
             prop = total/sum(b$total)))
    assign(
      paste0("loser", i+1),
      get(paste0("round", i+1)) %>%
        arrange(total) %>%
        filter(!is.na(candidate)) %>%
        head(n = 1) %>%
        select(candidate) %>%
        rbind(get(paste0("loser", i))))
    temprcvround <- get(paste0("round", i+1))
    rcvcolnames <- c(paste0("candidate"), paste0("round", i+1, "total"), paste0("round", i+1, "prop"))
    colnames(temprcvround) <- rcvcolnames
    assign(paste0("round", i+1), temprcvround)
    assign(
      paste0("round", i+1),
      left_join(get(paste0("round", i)),
                get(paste0("round", i+1)),
                by = "candidate"))
  }
  assign(paste0("Election: ", rcvcontest, " (Results)"), get(paste0("round", a+1)))
  assign(paste0("Election: ", rcvcontest, " (Results)"), get(paste0("Election: ", rcvcontest, " (Results)"))[order(rowSums(is.na(get(paste0("Election: ", rcvcontest, " (Results)"))))), ])
  assign(paste0("Election: ", rcvcontest, " (Results)"), get(paste0("Election: ", rcvcontest, " (Results)")) %>%
           arrange(is.na(candidate)))

  return(get(paste0("Election: ", rcvcontest, " (Results)")))

}


