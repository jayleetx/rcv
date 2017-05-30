#' Function for reading in CA style ballot images
#'
#' @param rawimage File containing the raw ballot image
#' @param key File containing the lookup file
#' @param df True/False depending on whether the rawimage and key are stored as dataframes
#' @return A dataframe that can be easily read and used for calculating results
#' @examples
#' ballot_tidy(rawimage = "http://www.acgov.org/rov/rcv/results/230/BerkeleyMayor/ballot_image.txt",
#' key = "http://www.acgov.org/rov/rcv/results/230/BerkeleyMayor/master_lookup.txt", df = F)
#' ballot_tidy(rawimage = sf_bos_ballot, key = sf_bos_lookup, df = T)
#' @export
ballot_tidy <- function(rawimage, key, df) {
  if (df == F) {
    BallotImage <- read_tsv(rawimage, col_names = F)
    MasterLookup <- read_tsv(key, col_names = F)
  } else {BallotImage <- rawimage
  MasterLookup <- key}
  BallotImage <- BallotImage %>%
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

  MasterLookup <- MasterLookup %>%
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

  return(BallotImage)
}
