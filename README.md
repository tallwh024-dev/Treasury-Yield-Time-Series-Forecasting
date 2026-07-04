# Treasury Yield Time-Series Forecasting

This repository contains a CFRM 586 time-series forecasting project analyzing monthly U.S. Treasury constant maturity yields.

The project studies the 1-year, 2-year, 3-year, and 5-year Treasury yield series from FRED, covering June 1976 through May 2026. It includes exploratory analysis, stationarity testing, univariate models, multivariate models, residual diagnostics, and four-month-ahead forecasts.

## Project objective

The goal is to compare statistical time-series methods for forecasting Treasury yield movements and evaluating whether separate univariate models or multivariate models better capture yield-curve dynamics.

## Data

- Source: Federal Reserve Economic Data (FRED)
- Series:
  - `GS1`: 1-Year Treasury Constant Maturity Rate
  - `GS2`: 2-Year Treasury Constant Maturity Rate
  - `GS3`: 3-Year Treasury Constant Maturity Rate
  - `GS5`: 5-Year Treasury Constant Maturity Rate
- Frequency: Monthly
- Sample period: June 1976 to May 2026

The original yield levels are nonstationary, so the main forecasting models use first differences:

- `d_GS1`
- `d_GS2`
- `d_GS3`
- `d_GS5`

## Methods

### Part 1: Exploratory time-series analysis

- Time-series plots for each maturity
- STL decomposition of the 3-year Treasury yield
- Seasonal pattern review
- Outlier detection using STL residuals and IQR rules
- KPSS stationarity testing
- First-difference transformation
- Pairwise comparison of transformed yield changes

### Part 2: Forecasting models

The forecasting section compares:

- AR(1) models on transformed yield changes
- AR(p) models with lag order selected by BIC
- ETS(ANN) models
- VAR models for multivariate yield dynamics
- VARIMA(1,1,1) as an additional multivariate extension
- Ljung-Box residual diagnostics
- Four-month-ahead forecasts with point forecasts and uncertainty bands

## Key findings

- Treasury yield levels move closely together across maturities.
- The 3-year yield is mainly driven by long-term trend rather than economically meaningful seasonality.
- Yield levels are nonstationary, so first differences are used for modeling.
- Transformed yield changes show positive relationships across maturities, supporting multivariate modeling.
- AR(1) coefficients are statistically significant across all four maturities, but constants are not significant.
- AR(p) models improve model fit compared with AR(1), with BIC selecting p = 6 for 1-year and 2-year yields and p = 2 for 3-year and 5-year yields.
- VAR models are used to capture cross-maturity relationships in Treasury yield changes.

## Repository structure

```text
Treasury-Yield-Time-Series-Forecasting/
├── README.md
├── scripts/
│   ├── part1_exploration.R
│   └── part2_forecasting_models.R
├── source/
│   ├── part1_report.Rmd
│   └── part2_report.Rmd
├── reports/
│   ├── part1_exploration_summary.md
│   └── part2_forecasting_summary.md
├── data/
│   └── README.md
└── requirements.txt
```

## How to run

1. Install the required R packages listed in `requirements.txt`.
2. Run the scripts in order:

```r
source("scripts/part1_exploration.R")
source("scripts/part2_forecasting_models.R")
```

The Part 2 script downloads the FRED Treasury yield series directly using `quantmod::getSymbols()`.

## Tools used

- R
- fpp3
- quantmod
- tsibble
- forecast
- ggplot2
- GGally
- MTS
- dplyr / tidyr

## Author

Jackson Wang  
M.S. Computational Finance and Risk Management  
University of Washington
