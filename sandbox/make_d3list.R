make_d3list <- function(results) {

  names <- results %>%
    tidyr::gather(key = round, value = count, 2:ncol(results)) %>%
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
