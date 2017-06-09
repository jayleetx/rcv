#' Creates a data frame for use with the alluvial package
#'
#' @param image A dataframe containing rcv election data
#' @param rcvcontest The election to calculate results for
#' @return A dataframe that counts how many ballots follow each unique "path"
#' of candidates through the election rounds
#' @examples
#' make_alluvialdf(image = sf_bos_clean, rcvcontest = "Board of Supervisors, District 7")
#' @export

make_alluvialdf <- function(image, rcvcontest) {
  contest <- . <- candidate <- id <- frequency <- NULL
  # create df of all voting combinations in election
  init <- readable(image)
  if (length(unique(init$contest)) > 1) {
    init <- init %>% dplyr::filter(contest == rcvcontest)
  }
  init <- init %>%
    dplyr::filter(contest == rcvcontest) %>%
    dplyr::select(3:ncol(.)) %>%
    dplyr::count_(lapply(names(.), as.name), sort = T) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(id = rownames(.)) %>%
    tidyr::gather(key = rank, value = candidate, 1:(ncol(.)-2)) %>%
    dplyr::mutate(rank = as.numeric(rank))

  # create a losers df from the results df

  elim <- data.frame(candidate = character())

  results <- rcv_tally(image, rcvcontest)

  for (j in 2:(ncol(results)-1)) {
    loser <- results %>%
      dplyr::select(candidate, j) %>%
      dplyr::filter(!(is.na(results[, j]))) %>%
      dplyr::filter(candidate != "NA") %>%
      dplyr::filter(.[, 2] == min(.[, 2])) %>%
      dplyr::select(candidate)

    elim <- rbind(elim, loser)
  }

  alluvialdf <- data.frame(matrix(nrow = 0, ncol = ncol(results)))
  col_names <- c()
  for (i in 1:(ncol(results) - 1)) {
    col_names <- append(col_names, paste0("round", i))
  }
  colnames(alluvialdf) <- append(col_names, "frequency")

  pathframe <- data.frame(matrix(ncol = ncol(results)))
  colnames(pathframe) <- colnames(alluvialdf)

  for (j in unique(init$id)) {
    path <- pathframe

    votepattern <- init %>% dplyr::filter(id == j)

    for (i in 1:(ncol(pathframe)-1)) {

      tempelim <- data.frame(candidate = character())
      if (i >= 2) tempelim <- elim[1:(i-1),]

      path[,i] <- votepattern %>%
        dplyr::filter(!(candidate %in% tempelim)) %>%
        dplyr::filter(rank == min(rank)) %>%
        dplyr::select(candidate)
    }

    path[,ncol(pathframe)] <- votepattern[1,"n"]

    alluvialdf <- rbind(alluvialdf, path)
  }

  # get final frequencies attempt

  names <- lapply(names(alluvialdf)[-ncol(alluvialdf)], as.name)
  alluvialdf <- alluvialdf %>%
    dplyr::group_by_(.dots = names) %>%
    dplyr::summarise(frequency = sum(frequency)) %>%
    dplyr::arrange(dplyr::desc(frequency))

  # alluvial function cannot have NAs in it, so replace with "NA"
  alluvialdf[is.na(alluvialdf)] <- "NA"

  return(alluvialdf)
}

