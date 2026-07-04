# Part 2: Treasury Yield Forecasting Summary

This report develops forecasting models for monthly U.S. Treasury yields using 1-year, 2-year, 3-year, and 5-year constant maturity series from FRED.

## Objective

Compare univariate and multivariate time-series models for forecasting Treasury yield changes.

## Data transformation

The original yield levels are transformed into first differences:

- d_GS1
- d_GS2
- d_GS3
- d_GS5

These transformed series are used because the original yield levels are nonstationary.

## Models estimated

### AR(1)

AR(1) models were estimated separately for each transformed Treasury yield series. The AR(1) coefficients are statistically significant for all four maturities, while the constants are not statistically significant.

### AR(p)

AR(p) models were estimated with lag order selected by BIC.

Selected lag orders:

| Maturity | Selected p |
|---|---:|
| d_GS1 | 6 |
| d_GS2 | 6 |
| d_GS3 | 2 |
| d_GS5 | 2 |

The AR(p) models generally improve model fit compared with AR(1), and estimated error volatility decreases as maturity increases.

### ETS(ANN)

ETS(ANN) models were used as simple exponential smoothing benchmarks for the transformed yield changes.

### VAR

A VAR model was estimated to capture cross-maturity relationships among d_GS1, d_GS2, d_GS3, and d_GS5.

### VARIMA extension

The project also included a VARIMA-style multivariate extension as extra analysis.

## Forecasting

The project produces four-month-ahead forecasts for transformed Treasury yield changes. Across models, forecasts tend to remain close to zero, reflecting the near-zero long-run average monthly change in first-differenced Treasury yields.

## Main interpretation

- Treasury yield changes show short-run persistence.
- Shorter-maturity yield changes are more volatile than longer-maturity yield changes.
- AR(p) models capture more residual dependence than AR(1).
- Cross-maturity relationships motivate the use of VAR models.
- Forecasted monthly changes are small and tend to mean-revert toward zero.
