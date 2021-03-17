#' Slope of a time series interval
#'
#' Calculates the ordinary least squares slope of the time series regressed
#' against the sequence 1:M where M is the length of the interval.
#'
#' @param y time series interval values (numeric vector)
#'
#' @return slope (numeric scalar)
#' @export
#'
#' @examples
#' slope(1:10) # 1
#' slope(runif(10000)) # ~0
slope <- function(y) {
  # slope = (sum(XY) - NXbarYbar)/(sum(X^2) - NXbar^2)
  x <- seq_along(y)
  n <- length(y)
  xbar <- (n + 1) / 2
  ybar <- mean(y)
  # Sum of consecutive squares formula
  sumx2 <- (2 * n + 1) * n * (n + 1) / 6

  (sum(x * y) - n * xbar * ybar) / (sumx2 - n * xbar^2)
}
