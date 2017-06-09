#' Raw ballot image data from a San Francisco RCV election
#'
#' The .rda version of a raw .txt file, containing ballot data
#' in numeric form for the 2016 San Francisco Board of Supervisors
#' elections in Districts 1, 3, 5, 7, 9, and 11.
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
#' elections in Districts 1, 3, 5, 7, 9, and 11. All San Francisco
#' data is to be used with the "WinEDS" format.
#'
#' @format A data frame with 644 rows and 1 variable
#' @source \url{http://www.sfelections.org/results/20161108/data/20161206/20161206_masterlookup.txt}
"sf_bos_lookup"

#' Cleaned ballot image data from a San Francisco RCV election
#'
#' A tidied version of `sf_bos_ballot` in a "tall" format,
#' readable to see voters' information, including candidate
#' rankings, precinct, and over-/under-vote codings. Cleaned
#' with clean_ballot.
#' clean_ballot(sf_bos_ballot, b_header = T,
#'              sf_bos_lookup, l_header = T,
#'              format = "WinEDS")
#'
#' @format A data frame with 643806 rows and 9 variables:
#' \describe{
#'   \item{contest}{which election this candidate ranking applies to}
#'   \item{pref_voter_id}{a unique key identifying an individual voter }
#'   \item{serial_number}{the serial number of the voting machine used}
#'   \item{tally}{contains information about whether the ballot was cast
#'   in early voting, was filed provisionally, and other factors}
#'   \item{precinct}{which city precinct the voter voted in}
#'   \item{vote_rank}{the rank given to the candidate by the voter; in
#'   the San Francisco case can take values of 1, 2, or 3}
#'   \item{candidate}{the chosen candidate for the specified vote rank}
#'   \item{over_vote}{a dummy variable, coded 1 if the ballot shows more
#'   votes cast than the number of candidates to be elected}
#'   \item{under_vote}{a dummy variable, coded 1 if the ballot shows no
#'   valid selection made for a candidate}
#'   }
"sf_bos_clean"

#' Raw ballot image data from a Cambridge, MA RCV election
#'
#' The .rda version of a .csv from a 2005 Cambridge, MA City Council
#' multiwinner RCV election. This data is included as an example of
#' another ballot image format for use with the label function. All
#' Cambridge data is to be used with the "ChoicePlus" format.
#'
#' @format A data frame with 17959 rows and 26 variables
"cambridge_ballot"

#' Raw lookup data from a Cambridge, MA RCV election
#'
#' The .rda version of a .csv from a 2005 Cambridge, MA City Council
#' multiwinner RCV election. This data is included as an example of another
#' master lookup format for use with the label function. This data includes
#' information other than the candidate names and codes, but we only use the
#' candidate names and codes.
#'
#' @format A data frame with 588 rows and 6 variables
"cambridge_lookup"

#' Cleaned ballot image data from a San Francisco RCV election
#'
#' A tidied version of `cambridge_ballot` in a "tall" format,
#' readable to see voters' information, including candidate
#' rankings, ward, and precinct. Cleaned with clean_ballot.
#' clean_ballot(cambridge_ballot, b_header = T,
#'              cambridge_lookup, l_header = T,
#'              format = "ChoicePlus")
#'
#' @format A data frame with 108752 rows and 7 variables:
#' \describe{
#'   \item{pref_voter_id}{a unique key identifying an individual voter }
#'   \item{ward}{which city ward the voter voted in}
#'   \item{precinct}{which city precinct the voter voted in}
#'   \item{style}{which ballot style the voter had; different styles list
#'   different candidates first on the ballot to remove that advantage}
#'   \item{contest}{which election this candidate ranking applies to}
#'   \item{vote_rank}{the rank given to the candidate by the voter}
#'   \item{candidate}{the chosen candidate for the specified vote rank}
#'   }
"cambridge_clean"

#' Raw ballot data from a Minneapolis, MN RCV election
#'
#' The .rda version of a .csv from a 2013 Minneapolis, MN mayoral RCV
#' election. This data is included as an example of another ballot format
#' for use with ballot functions.
#'
#' @format A data frame with 80101 rows and 5 variables
#' @source \url{http://vote.minneapolismn.gov/www/groups/public/@clerk/documents/webcontent/2013-mayor-cvr.xlsx}
"minneapolis_mayor_2013"

#' Labelled ballot data from San Francisco RCV election
#'
#' The .rda version of sf_bos_ballot.rda after the `label()`
#' function has been applied to it.
#'
#' @format A data frame with 643806 rows and 9 variables
"sf_ballot_labelled"

#' Labelled ballot lookup data from a San Francisco RCV election.
#'
#' The .rda version of sf_bos_lookup.rda after the `label()`
#' function has been applied to it.
#'
#' @format A data frame with 644 rows and 7 variables
"sf_lookup_labelled"

#' Tabulated results from a San Francisco RCV election
#'
#' Results from the SF "Board of Supervisors, District 7" election
#' in 2016. Tabulated with rcv_tally.
#' rcv_tally(image = sf_bos_clean,
#'           rcvcontest = "Board of Supervisors, District 7")
#'
#' @format a data frame with 6 rows and 5 variables
"sf_7_results"
