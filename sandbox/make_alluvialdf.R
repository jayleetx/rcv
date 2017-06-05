make_alluvialdf <- function(ballot, results) {
  voters <- ballot %>% unique(select(ballot, pref_voter_id))

}

