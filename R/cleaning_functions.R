#1234567890123456789012345678901234567890123456789012345678901234567890123456789



#' Separates single column ballot data frames.
#'
#' Takes a data frame of a single column (i.e. sf_bos_ballot) and splits it
#' into usable named columns.
#'
#' @param data A data frame containing the ballot image data
#' @param method A character string detailing the method. Current
#' supported methods are "WinEDS" and "ChoicePlus" (forthcoming), based on
#' common types of software used. Contact creators with suggestions for
#' more methods.
#' @return A data frame with multiple columns
#' @examples
#' label_ballot(data = sf_bos_ballot)
#' @importFrom dplyr %>%

label_ballot <- function(data, method) {
  if (method == "WinEDS") {
    data %>%
      tidyr::separate(X1, into = c("contest_id",
                                   "pref_voter_id",
                                   "serial_number",
                                   "tally_type_id",
                                   "precinct_id",
                                   "vote_rank",
                                   "candidate_id",
                                   "over_vote",
                                   "under_vote"),
                      sep = c(7,16,23,26,33,36,43,44)) %>%
      dplyr::mutate(tally_type_id = as.integer(tally_type_id),
                    vote_rank = as.integer(vote_rank))
  }

  else if(method == "ChoicePlus") {
    data
  }
# Hey Jay write this part later

  else stop('incompatible ballot format')

}


#' Separates single column master lookup data frames.
#'
#' Takes a data frame of a single column (i.e. sf_bos_lookup) and splits it
#' into usable columns.
#'
#' @param data A data frame containing the master lookup data
#' @param method A character string detailing the method. Current
#' supported methods are "WinEDS" and "ChoicePlus" (forthcoming), based on
#' common types of software used. Contact creators with suggestions for
#' more methods.
#' @return A data frame with multiple columns
#' @examples
#' label_lookup(data = sf_bos_lookup)
#' @importFrom dplyr %>%
label_lookup <- function(data, method) {
  if (method == "WinEDS") {
    data %>%
      tidyr::separate(X1, into = c("record_type",
                                   "id",
                                   "description",
                                   "list_order",
                                   "condidates_contest_id",
                                   "is_writein",
                                   "is_provisional"),
                      sep = c(10,17,67,74,81,82)) %>%
      dplyr::mutate(record_type = trimws(record_type),
                    description = trimws(description))
  }

  else if (method == "ChoicePlus") {
    data
  }

  else stop('incompatible ballot format')

}

#' Replaces number string codes in ballot with character strings from lookup
#'
#' Matches codes in the `contest_id`, `tally_type_id`, `precinct_id`, and
#' `candidate_id` columns in the labelled ballot with codes from the
#' `id` column in the labelled lookup, then replaces these codes with
#' character values from the `description` column in the lookup.
#'
#' @param ballot The labelled ballot data
#' @param lookup The labelled lookup data
#' @return The ballot data, but now "readable" so votes can be understood
#' @examples
#' characterize(ballot = sf_ballot_labelled, lookup = sf_lookup_labelled)
#' @importFrom dplyr %>%
characterize <- function(ballot, lookup) {
  a_candidates <- lookup %>%
    dplyr::filter(record_type == "Candidate") %>%
    dplyr::select(id, description) %>%
    dplyr::rename(candidate = description)
  a_contests <- lookup %>%
    dplyr::filter(record_type == "Contest") %>%
    dplyr::select(id, description) %>%
    dplyr::rename(contest = description)
  a_precincts <- lookup %>%
    dplyr::filter(record_type == "Precinct") %>%
    dplyr::select(id, description) %>%
    dplyr::rename(precinct = description)
  a_tallies <- lookup %>%
    dplyr::filter(record_type == "Tally Type") %>%
    dplyr::select(id, description) %>%
    dplyr::mutate(id = as.integer(id)) %>%
    dplyr::rename(tally = description)

  dplyr::left_join(ballot, candidates, by = c("candidate_id" = "id")) %>%
    dplyr::left_join(contests, by = c("contest_id" = "id")) %>%
    dplyr::left_join(precincts, by = c("precinct_id" = "id")) %>%
    dplyr::left_join(tallies, by = c("tally_type_id" = "id")) %>%
    dplyr::select(contest,
           pref_voter_id,
           serial_number,
           tally,
           precinct,
           vote_rank,
           candidate,
           over_vote,
           under_vote)

  rm(list=ls(pattern="a_"))
  }
