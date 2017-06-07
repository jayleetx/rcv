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

  init <- init %>% gather(key = rank, value = candidate, 1:(ncol(init)-2))
  init <- transform(init, rank = as.numeric(rank))

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

    votepattern <- init %>% filter(id == j)

    for (i in 1:(ncol(pathframe)-1)) {

      tempelim <- data.frame(candidate = character())
      if (i >= 2) tempelim <- elim[1:(i-1),]

      path[,i] <- votepattern %>%
        filter(!(candidate %in% tempelim)) %>%
        filter(rank == min(rank)) %>%
        select(candidate)
    }

    path[,ncol(pathframe)] <- votepattern[1,"n"]

    alluvialdf <- rbind(alluvialdf, path)
  }

  # get final frequencies attempt

  names <- lapply(names(alluvialdf)[-ncol(alluvialdf)], as.name)
  alluvialdf <- alluvialdf %>%
    group_by_(.dots = names) %>%
    summarise(frequency = sum(frequency))

  # alluvial function cannot have NAs in it, so replace with "NA"
  alluvialdf[is.na(alluvialdf)] <- "NA"

  return(alluvialdf)
}

