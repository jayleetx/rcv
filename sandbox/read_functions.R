read_data <- function(data, header) {
  if ("data.frame" %in% class(data)) {
    data
  }
  else if (tools::file_ext(data) == "txt") {
    readr::read_tsv(data, col_names = header)
  }
  else if (tools::file_ext(data) == "csv") {
    readr::read_csv(data, col_names = header)
  }
  else stop('incompatible data format')
}
