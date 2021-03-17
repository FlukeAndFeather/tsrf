n <- 1000
intervals <- sample_intervals(n)
prevalence <- sapply(
  seq(n),
  function(i) sum(i >= intervals[, 1] & i <= intervals[, 2]) / nrow(intervals)
)

test_that("sample intervals cover middle more than edges", {
  expect_gt(prevalence[n/2], prevalence[1])
  expect_gt(prevalence[n/2], prevalence[length(prevalence)])
})

test_that("sample intervals returns O(M) intervals", {
  expect_length(intervals, as.integer(sqrt(n))^2 * 2)
})
