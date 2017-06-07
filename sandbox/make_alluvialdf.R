make_alluvialdf <- function(image, rcvcontest, results) {
  # create df of all voting combinations in election
  readim <- readable(image) %>%
    dplyr::filter(contest == rcvcontest) %>%
    dplyr::select(3:ncol(.))

  init <- readim %>%
    count_(lapply(names(readim), as.name), sort = T) %>%
    ungroup() %>%
    mutate(id = rownames(.))

  # create a losers df from the results df
  elim <- data.frame(candidate = character())

  for (j in 2:(ncol(results)-1)) {
    temp <- results %>%
      select(candidate, j) %>%
      filter(!(is.na(results[, j]))) %>%
      dplyr::filter(candidate != "NA")

    loser <- temp %>%
      filter(temp[, 2] == min(temp[, 2])) %>%
      dplyr::select(candidate)

    elim <- rbind(elim, loser)
  }

  #alluvial function cannot have NAs in it, so replace with "NA"
  alluvialdf[is.na(alluvialdf)] <- "NA"

  return(alluvialdf)
}

