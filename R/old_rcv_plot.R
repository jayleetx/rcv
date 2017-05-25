#' Old function for creating a single style of sankey plot from rcv results
#'
#' @param rcvresults A specifically formatted dataframe of rcv results
#' @return A sankey plot
#' @examples
#' old_rcv_plot(mayorresults)
#' @export
old_rcv_plot <- function(rcvresults) {
  f <- length(unique(rcvresults$candidate))
  if (f > 3) {
    d <- (ncol(rcvresults) - 1)/2
    temp1 <- rcvresults$round1total
    source <- c((f+2):(2*f +1))
    target <- c(1:f)
    value <- c(temp1)
    for (j in 0:(f-4)) {source <- append(source, rep((f-1-j), (f-1-j)))}
    source <- append(source, c(f+2, f+3, 2*f+1, 2*f+2))
    for(j in 1:(f-3)){target <- append(target, c(1:(f-1-j), f+1))}
    target <- append(target, c(2*f +2, 2*f +2, 2*f +2, f-1))
    for (j in 2:d) {
      assign(paste0("temp", j), rcvresults[ ,2*j] - rcvresults[ ,2*(j-1)])
      assign(paste0("temp", j), as.integer(na.omit(get(paste0("temp", j)))))
      value <- append(value, get(paste0("temp", j)))
    }
    value <- append(value, c(0, 0, 0, 0))
    name <- c("voters", unique(rcvresults$candidate), "Exhausted", unique(rcvresults$candidate), ".")
    sankey_d1_values <- data.frame(source, target, value)
    sankey_d1_nodes <- data.frame(name)
    sankeyplot <- sankeyNetwork(Links = sankey_d1_values, Nodes = sankey_d1_nodes, Source = "source", Target = "target", Value = "value", NodeID = "name", units = "voters", fontSize = 12, nodeWidth = 20)
    return(sankeyplot)
  }
  else {return(print("Too few candidates to create plot."))}
}
