# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' Extract time series features from intervals
#'
#' @param tslen length of each time series
#' @param tsmat a matrix of time series data
#' @param tsints interval start and end indices
tsfeats <- function(tslen, tsmat, tsints) {
    .Call(`_tsrf_tsfeats`, tslen, tsmat, tsints)
}

