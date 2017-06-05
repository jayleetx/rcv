make_d3list <- function(results) {

  values <- data.frame()

  names <- data.frame()

  d3list <- list(values, names)
  return(d3list)
}

# district 7 reference:
# value <- c(14154,7630,6475,4927,4305,490,330,334,607,234,14644,7960,6809,4539,986,1400,1653,1495,15630,9360,6034,1554,2690,4218)
# name <- c("Yee","Yee","Joel","Joel","Ben","Ben","John","John","NA", "NA", "Mike", "Yee", "Joel", "Ben", "NA", "Yee", "Joel", "NA")
# source <- c(0,2,4,6,8,10,10,10,10,10,1,3,5,9,7,7,7,7,11,12,14,13,13,13)
# target <- c(1,3,5,7,9,1,3,5,7,9,11,12,13,14,11,12,13,14,15,16,17,15,16,17)
# names <- data.frame(name)
# values <- data.frame(source, target, value)
# sankeyNetwork(Links = values, Nodes = names, Source = "source", Target = "target", Value = "value", NodeID = "name", units = "voters", fontSize = 12, nodeWidth = 20)
