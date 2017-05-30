#1234567890123456789012345678901234567890123456789012345678901234567890123456789

#' Separates single column ballot data frames.
#'
#' Takes a data frame of a single column (i.e. sf_bos_ballot) and splits it
#' into usable named columns.
#'
#' @param data A data frame containing the ballot image data
#' @return A data frame with multiple columns
#' @examples
#' label_ballot(data = sf_bos_ballot)
#' @importFrom dplyr %>%

label_ballot <- function(data) {
  if (nchar(data[1,1]) == 45) {
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
                      sep = c(7,16,23,26,33,36,43,44))
  }

#  else if(tools::file_ext(data) == "csv" & nchar(data[1,1]) == 14) {
#    data
#  }
# Hey Jay write this part next week when you hear back from Theo

  else stop('incompatible ballot format')

}


#' Separates single column master lookup data frames.
#'
#' Takes a data frame of a single column (i.e. sf_bos_lookup) and splits it
#' into usable columns.
#'
#' @param data A data frame containing the master lookup data
#' @return A data frame with multiple columns
#' @examples
#' label_lookup(data = sf_bos_lookup)
#' @importFrom dplyr %>%
label_lookup <- function(data) {
  if (nchar(data[1,1]) == 83) {
    data %>%
      tidyr::separate(X1, into = c("record_type",
                                   "id",
                                   "description",
                                   "list_order",
                                   "condidates_contest_id",
                                   "is_writein",
                                   "is_provisional"),
                      sep = c(10,17,67,74,81,82))
  }

  else stop('incompatible ballot format')

}


