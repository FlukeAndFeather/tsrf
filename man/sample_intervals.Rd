% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/intervals.R
\name{sample_intervals}
\alias{sample_intervals}
\title{Sample intervals for time series random forest}
\usage{
sample_intervals(m)
}
\arguments{
\item{m}{time series length (numeric scalar)}
}
\value{
a matrix with two columns: start and end index of intervals.
}
\description{
Randomly samples O(M) intervals (start and end indices) from a time series,
where M is the length of the time series.
}
\examples{
# More intervals will cover the middle of the time series than the ends
n <- 1000
intervals <- sample_intervals(seq(n))
prevalence <- sapply(
  seq(n),
  function(i) sum(i >= intervals[, 1] & i <= intervals[, 2]) / nrow(intervals)
)
plot(seq(n), prevalence, type = "l", xlab = "index")
}
