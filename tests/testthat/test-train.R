set.seed(1622)
# Generate 10 time series of two different classes, each 100 points long
tsnum <- 100
tslbl <- factor(rep(c("A", "B"), each = tsnum))
tslen <- 20
Aval <- replicate(tsnum, rnorm(tslen))
Bval <- replicate(tsnum, c(rnorm(tslen / 2), cumsum(rnorm(tslen / 2, 0.1))))
tsdat <- data.frame(
  id = rep(1:(2 * tsnum), each = tslen),
  val = c(as.numeric(Aval), as.numeric(Bval))
)

# Extract features
tsints <- sample_intervals(tslen)
tsfeat <- extract_features(tsdat, "id", tsints)

# Split data
train_index <- sample(seq(nrow(tsfeat)), 0.9 * nrow(tsfeat))
train_feat <- tsfeat[train_index, ]
test_feat <- tsfeat[-train_index, ]
train_lbl <- tslbl[train_index]
test_lbl <- tslbl[-train_index]

# Train model
tsrf <- train_tsrf(train_feat, train_lbl, "id")

# Test predictions
pred_lbl <- predict(tsrf, test_feat)
right <- sum(pred_lbl == test_lbl)
wrong <- sum(pred_lbl != test_lbl)

test_that("model is accurate", {
  expect_gte(right / (right + wrong), 0.9)
})
