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
#' import_data("http://www.sfelections.org/results/20161108/data/20161206/20161206_masterlookup.txt",
#'  header = FALSE)
#' @export

import_data <- function(data, header) {
  if ("data.frame" %in% class(data)) data

  else if (class(data) == "character") {
# bay area, txt
    if (tools::file_ext(data) == "txt") {
      readr::read_tsv(data, col_names = header)
    }
# cambridge, csv
    else if (tools::file_ext(data) == "csv") {
      readr::read_csv(data, col_names = header)
    }
# minneapolis, excel
    else if (tools::file_ext(data) %in% c("xls", "xlsx")) {
      readxl::read_excel(data, col_names = header)
    }

    else stop('incompatible data format')
  }
  else stop('file name must be a character string (in quotes)')
}


#' Separates single column election data frames.
#'
#' Takes a data frame of a single column (i.e. sf_bos_ballot) and splits it
#' into usable named columns.
#'
#' @param data A data frame with a single column
#' @param image Whether the data is a "ballot" or "lookup" image
#' @param format A character string detailing the format. Current
#' supported formats are "WinEDS" (used in San Francisco and Alameda counties)
#' and "ChoicePlus" (in progress, used in Cambridge, MA), based on common types
#' of software used. Contact the creators with suggestions for more formats.
#' @return A data frame with multiple columns
#' @examples
#' label(data = sf_bos_ballot, image = "ballot", format = "WinEDS")
#' @export

label <- function(data, image, format) {
# initialize empty variables
  X1 <- tally_type_id <- vote_rank <- V1 <- a <- b <- V4 <- V3 <- NULL
  `1` <- candidate_id <- pref_voter_id <- record_type <- NULL
  description <- V2 <- NULL

# bay area
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

# cambridge
  else if(image == "ballot" & format == "ChoicePlus") {
    x <- data %>%
      tidyr::separate(V1, into = c("a","ward","precinct","b"),
                      sep = c(2,4,6),
                      remove = T) %>%
      dplyr::select(-a, -b) %>%
      tidyr::separate(V4, into = c("a", "1"),
                      sep = 3,
                      remove = T) %>%
      tidyr::unite(col = "contest",
                   V3, a,
                   sep = ", ") %>%
      dplyr::mutate(`1` = replace(`1`, which(`1` == ""), NA))

    colnames(x) <- c("ward","precinct", "style", "contest",
                     as.character(c(1:(ncol(x)-4))))
    tall <- x %>%
      tibble::rownames_to_column("pref_voter_id") %>%
      tidyr::gather(key = vote_rank,
                    value = candidate_id,
                    !! 6:(ncol(x)+1),
                    na.rm = T) %>%
      dplyr::mutate(candidate_id = stringr::str_replace_all(candidate_id,
                                                            "\\[\\d{1,2}\\]",
                                                            ""),
                    pref_voter_id = as.integer(pref_voter_id),
                    vote_rank = as.integer(vote_rank)) %>%
      dplyr::arrange(pref_voter_id, vote_rank)
    return(tall)
  }

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
    data %>%
      dplyr::filter(V1 == 20) %>%
      dplyr::select(V2,V3) %>%
      dplyr::rename(id = V2,
                    candidate = V3)
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
#' @param format A character string detailing the format. Current
#' supported formats are "WinEDS" and "ChoicePlus" (in progress), based on
#' common types of software used. Contact creators with suggestions for
#' more formats.
#' @return The ballot data, but now "readable" so votes can be understood
#' @examples
#' \dontrun{
#' characterize(ballot = sf_ballot_labelled, lookup = sf_lookup_labelled,
#' format = "WinEDS")
#' }
#' @export

characterize <- function(ballot, lookup, format) {
  record_type <- tally <- description <- contest <- pref_voter_id <- NULL
  serial_number <- id <- precinct <- vote_rank <- candidate <- NULL
  over_vote <- under_vote <- candidate_id <- NULL
  if (format == "WinEDS") {
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

  else if (format == "ChoicePlus") {
    dplyr::left_join(ballot, lookup, by = c("candidate_id" = "id")) %>%
      dplyr::mutate(candidate = ifelse(is.na(candidate), candidate_id, candidate)) %>%
      dplyr::select(-candidate_id)
  }
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
#' supported formats are "WinEDS" and "ChoicePlus" (in progress), based on
#' common types of software used. Contact creators with suggestions for
#' more formats.
#' @return The ballot data, but now "readable" so votes can be understood
#' @examples clean_ballot(ballot = sf_bos_ballot, b_header = TRUE,
#' lookup = sf_bos_lookup, l_header = TRUE, format = "WinEDS")
#' @export

clean_ballot <- function(ballot, b_header, lookup, l_header, format) {
  a <- import_data(data = ballot, header = b_header) %>%
    label(image = "ballot", format = format)
  b <- import_data(data = lookup, header = l_header) %>%
    label(image = "lookup", format = format)
  characterize(ballot = a, lookup = b, format = format)
}

#' Function for cleaning Minneapolis RCV data
#'
#' The Minneapolis data comes in a different form than SF or Cambridge data.
#' This function optimizes the process for formatting this data.
#' @param data The raw RCV data
#' @return The data formatted for use with rcv_tally
#' @examples clean_mn(minneapolis_mayor_2013)
#' @export

clean_mn <- function(data) {
  vote_rank <- candidate <- `1` <- `2` <- `3` <- pref_voter_id <- NULL
  colnames(data) <- c("precinct", "1", "2", "3", "count")
  a <- data %>%
    dplyr::select(1:4) %>%
    tibble::rownames_to_column("pref_voter_id") %>%
    tidyr::gather(key = vote_rank, value = candidate, `1`, `2`, `3`) %>%
    dplyr::mutate(candidate = ifelse(candidate %in% c("undervote", "overvote"),
                                     NA, candidate)) %>%
    dplyr::mutate(pref_voter_id = as.numeric(pref_voter_id),
                  vote_rank = as.numeric(vote_rank)) %>%
    dplyr::arrange(pref_voter_id)

}
