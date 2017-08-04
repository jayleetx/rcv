#' Creates a data frame for use with the alluvial package
#'
#' @param image A dataframe containing rcv election data
#' @param rcvcontest The election to calculate results for
#' @return A dataframe that counts how many ballots follow each unique "path"
#' of candidates through the election rounds
#' @examples
#' \dontrun{
#' make_alluvialdf(image = sf_bos_clean, rcvcontest = "Board of Supervisors, District 7")
#' }
#' @export

make_alluvialdf <- function(image, rcvcontest) {
  contest <- . <- candidate <- id <- frequency <- NULL
  # create df of all voting combinations in election
  init <- readable(image)
  if (!(missing(rcvcontest))) {
    init <- init %>% dplyr::filter(contest == rcvcontest)
  }
  init <- init %>%
    dplyr::filter(contest == rcvcontest) %>%
    dplyr::select(3:ncol(.)) %>%
    dplyr::count_(lapply(names(.), as.name), sort = T) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(id = rownames(.)) %>%
    tidyr::gather(key = rank, value = candidate, !! 1:(ncol(.)-2)) %>%
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

#' Creates a data frame for use with the networkD3 package
#'
#' @param results A dataframe containing rcv election results in the format
#' produced by `rcv_tally()`
#' @return A list of 2 dataframes that can be used to construct sankey diagrams
#' via the networkD3 package's `sankeyNetwork()` function
#' @examples
#' make_d3list(results = sf_7_results)
#' @export
make_d3list <- function(results) {
  count <- . <- candidate <- cand_id <- NULL

  names <- results %>%
    tidyr::gather(key = round, value = count, !! 2:ncol(results)) %>%
    dplyr::filter(!is.na(count))

  names_id <- names %>%
    tibble::rownames_to_column("cand_id") %>%
    dplyr::mutate(cand_id = as.numeric(cand_id) - 1) %>%
    dplyr::select(cand_id, candidate, round) %>%
    tidyr::spread(key = round, value = cand_id, fill = NA) %>%
    dplyr::select(2:ncol(results)) %>%
    dplyr::arrange(.[, 1])

  names <- names %>% dplyr::select(candidate)

  for (j in 3:ncol(results)) {
    temp <- data.frame(results[, 1], results[, j] - results[, j-1])
    colnames(temp) <- c("candidate", paste0("transfer", j-2))
    if (j == 3) {transfers <- temp
    } else transfers <- dplyr::left_join(transfers, temp, by = "candidate")
  }

  transfers <- transfers %>% dplyr::select(-candidate)

  round_totals <- results %>% dplyr::select(-candidate)

  source <- data.frame(source = numeric())

  for (j in 1:(ncol(names_id) - 1)) {
    source_temp <- data.frame(source = numeric())
    source_temp1 <- names_id %>%
      dplyr::filter(!is.na(names_id[, j+1])) %>%
      dplyr::select(j)
    colnames(source_temp1) <- c("source")
    source_temp2 <- names_id %>%
      dplyr::filter(is.na(names_id[, j+1])) %>%
      dplyr::select(j)
    source_temp2 <- data.frame(source = rep(source_temp2[1,1], nrow(source_temp1)))
    source_temp <- rbind(source_temp1, source_temp2)
    source <- rbind(source, source_temp)
  }

  target <- data.frame(target = numeric())

  for (j in 2:ncol(names_id)) {
    target_temp <- names_id %>%
      dplyr::filter(!is.na(names_id[, j])) %>%
      dplyr::select(j)
    colnames(target_temp) <- c("target")
    target <- rbind(target, target_temp, target_temp)
  }

  value <- data.frame(value = numeric())

  for (j in 1:ncol(transfers)) {
    temp_round <- round_totals %>%
      dplyr::filter(!is.na(round_totals[, j+1])) %>%
      dplyr::select(j)
    colnames(temp_round) <- c("value")
    temp_transfers <- transfers %>%
      dplyr::filter(!is.na(transfers[, j])) %>%
      dplyr::select(j)
    colnames(temp_transfers) <- c("value")
    temp_value <- rbind(temp_round, temp_transfers)
    value <- rbind(value, temp_value)
  }

  values <- data.frame(source, target, value)

  d3list <- list(values = values, names = names)
  return(d3list)
}

