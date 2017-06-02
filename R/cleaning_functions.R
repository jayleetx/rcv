#1234567890123456789012345678901234567890123456789012345678901234567890123456789

#' Imports election data
#'
#' Takes data argument supplied, checks file type, and uses appropriate read-in
#' functions to import the data
#'
#' @param data The file, containing ballot or lookup data
#' @param header Whether the first row of the file is a header or not
#' @return A data frame
#' @examples
#' import_data("http://www.sfelections.org/results/20161108/data/20161206/20161206_masterlookup.txt", header = F)
#' @export
import_data <- function(data, header) {
  if ("data.frame" %in% class(data)) {
    data
  }
  else if (tools::file_ext(data) == "txt") {
    readr::read_tsv(data, col_names = header)
  }
  else if (tools::file_ext(data) == "csv") {
    readr::read_csv(data, col_names = header)
  }
  else stop('incompatible data format')
}


#' Separates single column election data frames.
#'
#' Takes a data frame of a single column (i.e. sf_bos_ballot) and splits it
#' into usable named columns.
#'
#' @param data A data frame with a single column
#' @param image Whether the data is a "ballot" or "lookup" image
#' @param format A character string detailing the format. Current
#' supported formats are "WinEDS" and "ChoicePlus" (forthcoming), based on
#' common types of software used. Contact creators with suggestions for
#' more formats.
#' @return A data frame with multiple columns
#' @examples
#' label(data = sf_bos_ballot, image = "ballot", format = "WinEDS")
#' @importFrom dplyr %>%
#' @export

label <- function(data, image, format) {
  if (image == "ballot" & format == "WinEDS") {
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

  else if(image == "ballot" & format == "ChoicePlus") {
    data
  }
# Hey Jay write this part later

  else if (image == "lookup" & format == "WinEDS") {
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

  else if (image == "lookup" & format == "ChoicePlus") {
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
#' @export
characterize <- function(ballot, lookup) {
  candidates <- lookup %>%
    dplyr::filter(record_type == "Candidate") %>%
    dplyr::select(id, description) %>%
    dplyr::rename(candidate = description)
  contests <- lookup %>%
    dplyr::filter(record_type == "Contest") %>%
    dplyr::select(id, description) %>%
    dplyr::rename(contest = description)
  precincts <- lookup %>%
    dplyr::filter(record_type == "Precinct") %>%
    dplyr::select(id, description) %>%
    dplyr::rename(precinct = description)
  tallies <- lookup %>%
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
  }

#' Master one-step cleaning function
#'
#' Wraps `import_data`, `label`, and `characterize` to clean the ballot
#' image in one step.
#'
#' @param ballot The raw ballot image
#' @param b_header Whether the ballot image has a header line or not
#' @param lookup The raw lookup image
#' @param l_header Whether the lookup image has a header line or not
#' @param format A character string detailing the format. Current
#' supported formats are "WinEDS" and "ChoicePlus" (forthcoming), based on
#' common types of software used. Contact creators with suggestions for
#' more formats.
#' @return The ballot data, but now "readable" so votes can be understood
#' @examples clean_ballot(ballot = sf_bos_ballot, b_header = T,
#' lookup = sf_bos_lookup, l_header = T, format = "WinEDS")
#' @importFrom dplyr %>%
#' @export

clean_ballot <- function(ballot, b_header, lookup, l_header, format) {
  a <- import_data(data = ballot, header = b_header) %>%
    label(image = "ballot", format = format)
  b <- import_data(data = lookup, header = l_header) %>%
    label(image = "lookup", format = format)
  characterize(ballot = a, lookup = b)
}
