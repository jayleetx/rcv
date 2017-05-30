#' Old function for reading in raw CA rcv ballot images
#'
#' @param rawimage A .csv or similar file containing the raw ballot image
#' @param masterkey A .csv or similar file containing the lookup file
#' @return A dataframe that can be easily read and used for calculating results
#' @examples
#' old_ballot_tidy(rawimage = "http://www.acgov.org/rov/rcv/results/230/BerkeleyMayor/ballot_image.txt",
#' masterkey = "http://www.acgov.org/rov/rcv/results/230/BerkeleyMayor/master_lookup.txt")
#' @export
old_ballot_tidy <- function(rawimage, masterkey) {

  BallotImage <- read_tsv(rawimage, col_names = F) %>%
    separate(X1, c("contest_id",
                   "pref_voter_id",
                   "serial_number",
                   "tally_type_id",
                   "precinct_id",
                   "vote_rank",
                   "candidate_id",
                   "over_vote",
                   "under_vote"),
             sep = c(7,16,23,26,33,36,43,44)) %>%
    mutate(tally_type_id = as.integer(tally_type_id),
           vote_rank = factor(vote_rank,
                              ordered = T,
                              levels = c("001","002","003")),
           vote_rank = fct_recode(vote_rank,
                                  "1" = "001",
                                  "2" = "002",
                                  "3" = "003"),
           over_vote = as.integer(over_vote),
           under_vote = as.integer(under_vote))

  MasterLookup <- read_tsv(masterkey, col_names = F) %>%
    separate(X1, c("record_type",
                   "id",
                   "description",
                   "list_order",
                   "candidates_contest_id",
                   "is_writein",
                   "is_provisional"),
             sep = c(10,17,67,74,81,82)) %>%

    mutate(record_type = trimws(record_type),
           description = trimws(description),
           is_writein = as.integer(is_writein),
           is_provisional = as.integer(is_provisional))

  Candidates <- MasterLookup %>%
    filter(record_type == "Candidate") %>%
    select(id, description) %>%
    rename(candidate = description)
  Contests <- MasterLookup %>%
    filter(record_type == "Contest") %>%
    select(id, description) %>%
    rename(contest = description)
  Precincts <- MasterLookup %>%
    filter(record_type == "Precinct") %>%
    select(id, description) %>%
    rename(precinct = description)
  Tallies <- MasterLookup %>%
    filter(record_type == "Tally Type") %>%
    select(id, description) %>%
    mutate(id = as.integer(id)) %>%
    rename(tally = description)

  BallotImage <- left_join(BallotImage, Candidates, by = c("candidate_id" = "id"))
  BallotImage <- left_join(BallotImage, Contests, by = c("contest_id" = "id"))
  BallotImage <- left_join(BallotImage, Precincts, by = c("precinct_id" = "id"))
  BallotImage <- left_join(BallotImage, Tallies, by = c("tally_type_id" = "id"))

  BallotImage <- BallotImage %>%
    select(pref_voter_id, contest, vote_rank, candidate, precinct)
  dummyballot <- BallotImage %>%
    group_by(pref_voter_id) %>%
    filter(vote_rank == min(vote_rank)) %>%
    ungroup()
  dummyballot$vote_rank <- '4'
  dummyballot$candidate <- NA
  BallotImage <- rbind(BallotImage, dummyballot)

  return(BallotImage)
}


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


#' Old function for creating a single style of sankey plot from rcv results
#'
#' @param rcvresults A specifically formatted dataframe of rcv results
#' @return A sankey plot
#' @examples
#' old_rcv_plot(mayorresults)
#' @export
old_rcv_plot <- function(rcvresults) {
  f <- length(unique(rcvresults$candidate))
  if (f > 3) {
    d <- (ncol(rcvresults) - 1)/2
    temp1 <- rcvresults$round1total
    source <- c((f+2):(2*f +1))
    target <- c(1:f)
    value <- c(temp1)
    for (j in 0:(f-4)) {source <- append(source, rep((f-1-j), (f-1-j)))}
    source <- append(source, c(f+2, f+3, 2*f+1, 2*f+2))
    for(j in 1:(f-3)){target <- append(target, c(1:(f-1-j), f+1))}
    target <- append(target, c(2*f +2, 2*f +2, 2*f +2, f-1))
    for (j in 2:d) {
      assign(paste0("temp", j), rcvresults[ ,2*j] - rcvresults[ ,2*(j-1)])
      assign(paste0("temp", j), as.integer(na.omit(get(paste0("temp", j)))))
      value <- append(value, get(paste0("temp", j)))
    }
    value <- append(value, c(0, 0, 0, 0))
    name <- c("voters", unique(rcvresults$candidate), "Exhausted", unique(rcvresults$candidate), ".")
    sankey_d1_values <- data.frame(source, target, value)
    sankey_d1_nodes <- data.frame(name)
    sankeyplot <- sankeyNetwork(Links = sankey_d1_values, Nodes = sankey_d1_nodes, Source = "source", Target = "target", Value = "value", NodeID = "name", units = "voters", fontSize = 12, nodeWidth = 20)
    return(sankeyplot)
  }
  else {return(print("Too few candidates to create plot."))}
}
