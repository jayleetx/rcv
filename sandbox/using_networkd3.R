library(networkD3)
results <- rcv_tally(sf_bos_clean, "Board of Supervisors, District 1") #ignore this
vizresults <- results %>% select(candidate, round6, round7, round8, round9)
d3list <- make_d3list(vizresults)
sankeyNetwork(Links = d3list$values, Nodes = d3list$names, Source = "source", Target = "target", Value = "value", NodeID = "candidate", units = "voters", fontSize = 10, nodeWidth = 20)
