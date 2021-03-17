#' Sample intervals for time series random forest
#'
#' Randomly samples O(M) intervals (start and end indices) from a time series,
#' where M is the length of the time series.
#'
#' @param m time series length (numeric scalar)
#'
#' @return a matrix with two columns: start and end index of intervals.
#' @export
#'
#' @examples
#' # More intervals will cover the middle of the time series than the ends
#' n <- 1000
#' intervals <- sample_intervals(seq(n))
#' prevalence <- sapply(
#'   seq(n),
#'   function(i) sum(i >= intervals[, 1] & i <= intervals[, 2]) / nrow(intervals)
#' )
#' plot(seq(n), prevalence, type = "l", xlab = "index")
sample_intervals <- function(m) {
  stopifnot(
    is.numeric(m),
    length(m) == 1
  )

  # m: time series length
  root_m <- as.integer(sqrt(m))
  m2 <- root_m^2

  # w: window lengths
  w <- rep(sample(seq(m), root_m), each = root_m)

  # i1, i2: interval start and end indices
  i1 <- as.integer(runif(m2) * (m - w) + 1)
  i2 <- i1 + w

  cbind(i1, i2)
}
