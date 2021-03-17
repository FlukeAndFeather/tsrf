timeseries <- data.frame(id = 1, val = 1:1000)
rand_intervals <- sample_intervals(max(timeseries))
feats <- extract_features(timeseries, "id", rand_intervals)

test_that("correct feature dimensions", {
  expect_equal(nrow(feats), 1)
  expect_equal(ncol(feats), 1 + as.integer(sqrt(1000))^2 * 3)
})

test_that("correct feature values", {
  i <- 100
  vals <- timeseries$val[rand_intervals[i, 1]:rand_intervals[i, 2]]
  expect_equal(feats[[paste0("mean_val_", i)]], mean(vals))
  expect_equal(feats[[paste0("sd_val_", i)]], sd(vals))
  expect_equal(feats[[paste0("slope_val_", i)]], slope(vals))
})
