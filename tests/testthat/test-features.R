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
  expect_equal(feats[[paste("mean", i, "val", sep = "_")]], mean(vals))
  expect_equal(feats[[paste("sd", i, "val", sep = "_")]], sd(vals))
  expect_equal(feats[[paste("slope", i, "val", sep = "_")]], slope(vals))
})

test_that("C++ and parallel implementations are accurate", {
  tsn <- 100
  tslen <- 50
  tsmat <- lapply(seq(tsn),
                  function(id) cbind(id=id, y=seq(tslen), z=rnorm(tslen))) %>%
    do.call(rbind, .)
  tsdf <- as.data.frame(tsmat)
  tslen2 <- as.integer(tslen / 2)
  tsints <- cbind(1:tslen2, tslen:(tslen - tslen2 + 1))

  feats_r <- extract_features(tsdf, "id", tsints)
  feats_cpp <- extract_features_cpp(tsdf, "id", tsints)
  feats_par <- extract_features_par(tsdf, "id", tsints, parallel::detectCores())

  expect_equal(feats_r, feats_cpp, ignore_attr = TRUE)
  expect_equal(feats_r, feats_par, ignore_attr = TRUE)
})

test_that("Parallel implementation improves performance for large datasets", {
  skip_if(parallel::detectCores() < 2,
          "Skip parallel performance test on single core")
  skip_on_cran()
  tsn <- 10000
  tslen <- 1000
  tsmat <- lapply(seq(tsn),
                  function(id) cbind(id=id, y=seq(tslen), z=rnorm(tslen))) %>%
    do.call(rbind, .)
  tsdf <- as.data.frame(tsmat)
  tslen2 <- as.integer(tslen / 2)
  tsints <- cbind(1:tslen2, tslen:(tslen - tslen2 + 1))

  cpp_time <- system.time(extract_features_cpp(tsdf, "id", tsints))
  par_time <- system.time(extract_features_par(tsdf, "id", tsints,
                                               parallel::detectCores()))
  expect_lt(par_time["elapsed"], cpp_time["elapsed"])
})
