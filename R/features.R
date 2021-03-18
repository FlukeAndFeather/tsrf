assemble_feat_names <- function(funs, nintervals, vars) {
  expand.grid(funs,
              as.character(seq(nintervals)),
              vars,
              stringsAsFactors = FALSE) %>%
    apply(1, paste, collapse = "_")
}

#' Extract features from time series
#'
#' Calculate summary statistics of randomly sampled intervals in time series for
#' classification in a time series random forest.
#'
#' `extract_features()` is an R implementation and is therefore slow for larger
#' datasets. `extract_features_cpp()` uses C++ to improve feature extraction
#' performance, but the summary statistics (\code{\link{mean}},
#' \code{\link{sd}}, \code{\link{slope}}) are inflexible.
#' `extract_features_par()` applies `extract_features_cpp()` in parallel.
#' `extract_features_par()` is faster than `extract_features_cpp()` when
#' extracting features from very large datasets or using many cores. For smaller
#' datasets or fewer cores, `extract_features_cpp()` can be faster.
#'
#' @param x time series (data.frame)
#' @param tsid name of time series identifier column in \code{x} (character
#'   scalar)
#' @param intervals start and end indices of intervals (2 column integer matrix;
#'   see \code{\link{sample_intervals}})
#' @param funs list of summary functions (\code{\link{mean}}, \code{\link{sd}},
#'   and \code{\link{slope}} by default). Only used by `extract_features()`.
#'
#' @return an MxN matrix where M is the length of \code{intervals} and N is the
#'   length of \code{funs}.
#' @export
#'
#' @examples
#' ts_len <- 100
#' ts_dat <- data.frame(id = rep(1:3, each = ts_len),
#'                      val = 1:ts_len)
#' ints <- sample_intervals(ts_len)
#' extract_features(ts_dat, "id", ints)
extract_features <- function(
  x, tsid, intervals, funs = list(mean = mean, sd = sd, slope = slope)
) {
  stopifnot(
    inherits(x, "data.frame"),
    is.character(tsid),
    length(tsid) == 1,
    tsid %in% colnames(x),
    is.matrix(intervals),
    intervals == as.integer(intervals),
    ncol(intervals) == 2,
    is.list(funs),
    sapply(funs, inherits, what = "function")
  )

  x_data <- x[-match(tsid, names(x))]
  fun_col_int <- expand.grid(names(funs),
                             as.character(seq(nrow(intervals))),
                             setdiff(names(x), tsid),
                             stringsAsFactors = FALSE)
  feat_names <- assemble_feat_names(
    names(funs),
    nrow(intervals),
    setdiff(names(x), tsid)
  )
  feats <- apply(
    fun_col_int,
    1,
    function(row) {
      fun <- funs[[row[1]]]
      int <- intervals[as.integer(row[2]), ]
      col <- x_data[[row[3]]]
      tapply(col, x[[tsid]], function(col_sub) fun(col_sub[int[1]:int[2]]))
    }
  )
  # Handle edge case when there's only one time series (one row matrix turns
  # into a vector)
  if (!is.matrix(feats)) {
    feats <- t(feats)
  }
  feats <- cbind(unique(x[[tsid]]), as.data.frame(feats))
  colnames(feats) <- c(tsid, feat_names)

  feats
}

#' @rdname extract_features
#' @export
extract_features_cpp <- function(x, tsid, intervals) {
  x_data <- as.matrix(x[-match(tsid, names(x))])
  tslen <- as.integer(sum(x[[tsid]] == x[[tsid]][1]))
  stopifnot(
    is.integer(tslen),
    is.matrix(x_data),
    is.matrix(intervals)
  )
  feats <- tsfeats(tslen, x_data, intervals)
  feat_names <- assemble_feat_names(
    c("mean", "sd", "slope"),
    nrow(intervals),
    setdiff(names(x), tsid)
  )
  feats <- cbind(unique(x[[tsid]]), as.data.frame(feats))
  colnames(feats) <- c(tsid, feat_names)

  feats
}

#' @rdname extract_features
#'
#' @param ncores number of cores to use
#'
#' @importFrom foreach %dopar%
#' @export
extract_features_par <- function(x, tsid, intervals, ncores) {
  stopifnot(
    ncores == as.integer(ncores),
    length(ncores) == 1
  )
  doParallel::registerDoParallel(ncores)

  # Run C++ feature extraction in parallel
  x_data <- as.matrix(x[-match(tsid, names(x))])
  tslen <- as.integer(sum(x[[tsid]] == x[[tsid]][1]))
  tsn <- nrow(x) / tslen
  chunksz <- floor(nrow(x_data) / ncores)
  froms <- seq(1, nrow(x_data), by = chunksz)
  tos <- pmin(froms + chunksz, nrow(x_data))
  feats <- foreach::foreach(from = froms, to = tos, .combine = rbind) %dopar% {
    tsfeats(tslen, x_data[from:to, ], intervals)
  }

  # Assemble results
  feat_names <- assemble_feat_names(
    c("mean", "sd", "slope"),
    nrow(intervals),
    setdiff(names(x), tsid)
  )
  feats <- cbind(unique(x[[tsid]]), as.data.frame(feats))
  colnames(feats) <- c(tsid, feat_names)

  feats
}
