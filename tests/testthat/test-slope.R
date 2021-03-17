test_that("slopes calculated accurately", {
  expect_equal(slope(1:10), 1)
  set.seed(10000)
  expect_equal(slope(runif(10000)), 0, tolerance = 1e-3)
  expect_equal(slope(rnorm(10000, mean = 1:10000)), 1, tolerance = 1e-3)
})
