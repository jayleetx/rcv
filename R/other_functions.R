readable <- function(x) {
  View(spread(x, key = vote_rank,
              value = candidate))
}
