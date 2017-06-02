clean_results <- function(results) {

  total <- sum(results[, 1], na.rm = T)
  exhausted <- data.frame(matrix(rep(NA, ncol(results)), nrow = 1))
  colnames(exhausted) <- colnames(results)
  row.names(exhausted) <- c("Exhausted")
  for (i in 1:ncol(results)) {
    exhausted[1, i] <- total - sum(results[, i], na.rm = T)
  }
  exhausted[1, ] <- exhausted[1, ] + results["NA", ]
  results["NA", ] <- exhausted[1, ]

  # create proprotion and transfer dataframes that will be attached to clean

  return(results)
}
