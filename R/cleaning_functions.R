read_ballot <- function(data, format) {
  if (format == "California") {
  data %>%
    separate(X1, into = c("contest_id",
                          "pref_voter_id",
                          "serial_number",
                          "tally_type_id",
                          "precinct_id",
                          "vote_rank",
                          "candidate_id",
                          "over_vote",
                          "under_vote"),
             sep = c(7,16,23,26,33,36,43,44))
  }

  else if (format == "Cambridge") {
    data %>%
      separate()
  }

  else stop('unknown ballot format')

}
