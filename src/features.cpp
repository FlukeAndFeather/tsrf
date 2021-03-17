#include <Rcpp.h>
using namespace Rcpp;

double slope(NumericVector y) {
  // Assume x = 1:length(y)
  double n = y.length();
  double sumxy = 0;
  for (int x = 0; x < n; x++) {
    sumxy += (x + 1) * y[x];
  }
  double xbar = (n + 1) / 2;
  double ybar = mean(y);
  // Sum of consecutive squares formula
  double sumx2 = (2 * n + 1) * n * (n + 1) / 6;
  return (sumxy - n * xbar * ybar) / (sumx2 - n * xbar * xbar);
}

//' Extract time series features from intervals
//'
//' @param tslen length of each time series
//' @param tsmat a matrix of time series data
//' @param tsints interval start and end indices
// [[Rcpp::export]]
NumericMatrix tsfeats(
    const int tslen, NumericMatrix& tsmat, const NumericMatrix& tsints
  ) {
  // Number of time series
  int tsn = tsmat.nrow() / tslen;

  // Allocate result
  int funn = 3;
  int colsn = funn * tsmat.ncol() * tsints.nrow();
  NumericMatrix result = NumericMatrix(tsn, colsn);

  int j;
  int offset = 0;
  for (int i = 0; i < tsn; i++) {
    j = 0;
    for (int tscolj = 0; tscolj < tsmat.ncol(); tscolj++) {
      for (int tsintj = 0; tsintj < tsints.nrow(); tsintj++) {
        for (int funj = 0; funj < funn; funj++) {
          // Subset interval
          int t1 = offset + tsints(tsintj, 0) - 1;
          int t2 = offset + tsints(tsintj, 1) - 1;
          NumericMatrix intvals = tsmat(Range(t1, t2), Range(tscolj, tscolj));
          // Extract feature
          double feat;
          switch (funj) {
          case 0:
            feat = mean(intvals);
            break;
          case 1:
            feat = sd(intvals);
            break;
          case 2:
            feat = slope(intvals);
            break;
          }
          // Set result
          result(i, j) = feat;
          j++;
        }
      }
    }
    offset += tslen;
  }

  return result;
}
