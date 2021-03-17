#' Extract features from time series
#'
#' Calculate summary statistics of randomly sampled intervals in a time series
#'
#' @param x time series (data.frame)
#' @param tsid name of time series identifier column in \code{x} (character scalar)
#' @param intervals start and end indices of intervals (2 column integer matrix;
#'   see \code{\link{sample_intervals}})
#' @param funs list of summary functions (\code{\link{mean}}, \code{\link{sd}},
#'   and \code{\link{slope}} by default)
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
    is.integer(intervals),
    ncol(intervals) == 2,
    is.list(funs),
    sapply(funs, inherits, what = "function")
  )

  x_data <- x[-match(tsid, names(x))]
  fun_col_int <- expand.grid(names(funs),
                             setdiff(names(x), tsid),
                             as.character(seq(nrow(intervals))),
                             stringsAsFactors = FALSE)
  feat_names <- apply(fun_col_int, 1, paste, collapse = "_")
  feats <- apply(
    fun_col_int,
    1,
    function(row) {
      fun <- funs[[row[1]]]
      col <- x_data[[row[2]]]
      int <- intervals[as.integer(row[3]), ]
      tapply(col, x[[tsid]], function(col_sub) fun(col_sub[int[1]:int[2]]))
    }
  )
  if (!is.matrix(feats)) {
    feats <- t(feats)
  }
  feats <- cbind(unique(x[[tsid]]), as.data.frame(feats))
  colnames(feats) <- c(tsid, feat_names)

  feats
}
