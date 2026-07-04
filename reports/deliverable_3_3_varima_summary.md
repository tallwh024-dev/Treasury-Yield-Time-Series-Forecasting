# Deliverable 3.3: VARIMA(1,1,1) Summary

This deliverable fits a VARIMA(1,1,1) model to the Treasury yield level series GS1, GS2, GS3, and GS5.

The purpose is to extend the multivariate analysis beyond the VAR model by allowing differencing and moving-average dynamics in a joint model for the four maturities.

## Model

The fitted model is:

```r
VARIMA_111 = VARIMA(vars(GS1, GS2, GS3, GS5) ~ pdq(1, 1, 1))
```

## Diagnostics

The analysis reports model fit statistics, including AIC, BIC, and a manually calculated AICc value. It also plots innovation residuals for each maturity to review remaining structure after fitting the VARIMA model.

## Interpretation

This model is included as an extra multivariate time-series extension. It is useful because Treasury yields across maturities move together, and a VARIMA framework can capture both cross-maturity relationships and dynamic dependence after differencing.
