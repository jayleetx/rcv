add_exhausted <- function(results) {

  total <- sum(results[, 1], na.rm = T)
  exhausted <- data.frame(matrix(rep(NA, ncol(results)), nrow = 1))
  colnames(exhausted) <- colnames(results)
  row.names(exhausted) <- c("Exhausted")
  for (i in 1:ncol(results)) {
    exhausted[1, i] <- total - sum(results[, i], na.rm = T)
  }
  exhausted[1, ] <- exhausted[1, ] + results["NA", ]
  results["NA", ] <- exhausted[1, ]

  return(results)
}

add_proportions <- function(results) {}
add_transfer <- function(results) {}

clean_results <- function(results){
  results <- results %>%
    add_exhausted() %>%
    add_proportions() %>%
    add_transfer()
  return(results)
}
