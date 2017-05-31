characterise <- function(ballot, lookup) {
  for (i in seq_along(colnames(ballot))) {
    a <- dplyr::filter(lookup, trimws(record_type) == colnames(ballot)[i])
    for (j in seq_along(nrow(a))) {
    ballot$i[ballot$i %in% a[j, "id"]] <- a[j, "description"]
    }
  }
}


#for (id in 1:nrow(df2)) {
#  df1$x2[df1$x1 %in% df2$x1[id]] <- df2$x2[id]
#}

# a[j, "description"] -> ballot %>%
#   select(i) %>%
#   filter(i %in% a[j, "id"])
