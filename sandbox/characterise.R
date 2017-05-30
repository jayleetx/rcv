characterise <- function(ballot, lookup) {
  for (name in colnames(ballot)) {
    a <- filter(lookup, trimws(record_type) == name)
    for (index in seq_along(nrow(a))) {
    ballot$name[ballot$name %in% a$id[index]] <- a$description[index]
    }
  }
}


#for (id in 1:nrow(df2)) {
#  df1$x2[df1$x1 %in% df2$x1[id]] <- df2$x2[id]
#}
