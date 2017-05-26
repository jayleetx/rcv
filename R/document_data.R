#' Raw ballot image data from a San Francisco RCV election
#'
#' The .rda version of a raw .txt file, containing ballot data
#' in numeric form for the 2016 San Francisco Board of Supervisors
#' elections in Districts 1, 3, 5, 7, 9, and 11. Separating it to
#' be made more useful is done in other functions.
#'
#' @format A data frame with 643806 rows and 1 variable
#' @source \url{http://www.sfelections.org/results/20161108/data/20161206/20161206_ballotimage.txt}
"sf_bos_ballot"

#' Raw ballot lookup data from a San Francisco RCV election.
#'
#' The .rda version of a raw .txt file, containing numeric and
#' character information to match the numeric data in the raw
#' ballot image with the objects these numeric strings refer to.
#' Data refers to the 2016 San Francisco Board of Supervisors
#' elections in Districts 1, 3, 5, 7, 9, and 11. Separating it to
#' be made more useful with `sf_bos_ballot` is done in other functions.
#'
#' @format A data frame with 644 rows and 1 variable
#' @ source \url{http://www.sfelections.org/results/20161108/data/20161206/20161206_masterlookup.txt}
"sf_bos_lookup"

#' Cleaned ballot image data from a San Francisco RCV election
#'
#' A tidied version of `sf_bos_ballot` in a "tall" format,
#' readable to see voters' information, including candidate
#' rankings, precinct, and over-/under-vote codings.
#'
#' @format A data frame with 643806 rows and 9 variables:
#' \describe{
#'   \item{pref_voter_id}{a unique key identifying an individual voter }
#'   \item{contest}{which election this candidate ranking applies to}
#'   \item{vote_rank}{the rank given to the candidate by the voter; in
#'   the San Francisco case can take values of 1, 2, or 3}
#'   \item{candidate}{the chosen candidate for the specified vote rank}
#'   \item{over_vote}{a dummy variable, coded 1 if the ballot shows more
#'   votes cast than the number of candidates to be elected}
#'   \item{under_vote}{a dummy variable, coded 1 if the ballot shows no
#'   valid selection made for a candidate}
#'   \item{precinct}{which city precinct the voter voted in}
#'   \item{tally}{contains information about whether the ballot was cast
#'   in early voting, was filed provisionally, and other factors}
#'   \item{serial_number}{the serial number of the voting machine used}
#'   }
"sf_bos_clean"

#' Raw ballot image data from a Cambridge, MA RCV election
#'
#' The .rda version of a .csv from a 2005 Cambridge, MA City Council
#' multiwinner RCV election. This data is included as an example of
#' another ballot image format for use with read_ballot.
#'
#' @format A data frame with 17959 rows and 26 variables
"cambridge_ballot"

#' Raw lookup data from a Cambridge, MA RCV election
#'
#' The .rda version of a .csv from a 2005 Cambridge, MA City Council
#' multiwinner RCV election. This data is included as an example of
#' another master lookup format for use with read_lookup.
#'
#' @format A data frame with 46 rows and 2 variables
"cambridge_lookup"
