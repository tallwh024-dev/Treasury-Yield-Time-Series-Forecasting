# Part 1: Treasury Yield Exploration Summary

This report reviews the monthly 1-year, 2-year, 3-year, and 5-year Treasury yield series from June 1976 to May 2026.

## Main tasks

- Plot the four Treasury yield series.
- Decompose the 3-year Treasury yield using STL.
- Review seasonal behavior.
- Detect outliers using STL remainder values and an IQR rule.
- Test stationarity using KPSS-based diagnostics.
- Transform the yield levels using first differences.
- Compare transformed yield changes across maturities.

## Main findings

- The four Treasury yield series move closely together over time.
- Yields were high in the early 1980s, declined over the following decades, stayed low after the 2008 financial crisis and COVID period, and rose again after 2021.
- STL decomposition shows that the 3-year Treasury yield is mainly driven by trend rather than seasonality.
- The seasonal component is very small relative to the yield level, so seasonality does not appear economically meaningful.
- Outliers are concentrated in periods of major interest-rate movement, especially the late 1970s and early 1980s.
- The original yield levels are nonstationary.
- First differences produce stationary transformed series for later forecasting.
- Pairwise comparisons of the transformed data show positive relationships across maturities.

## Modeling implication

Because the original levels are nonstationary, Part 2 uses first-differenced Treasury yield series:

- d_GS1
- d_GS2
- d_GS3
- d_GS5

The positive relationships across maturities support comparing both separate univariate models and multivariate models.
