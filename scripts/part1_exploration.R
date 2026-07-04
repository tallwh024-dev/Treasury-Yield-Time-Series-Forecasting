# Treasury Yield Time-Series Forecasting - Part 1
# Exploratory time-series analysis
# Author: Jackson Wang

library(quantmod)
library(tsibble)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(forecast)
library(fpp3)
library(GGally)

# ------------------------------------------------------------
# Data: FRED Treasury constant maturity yields
# ------------------------------------------------------------

from <- as.Date("1976-06-01")
to <- as.Date("2026-05-01")
symbols <- c("GS1", "GS2", "GS3", "GS5")

# Download data from FRED
invisible(getSymbols(symbols, src = "FRED", from = from, to = to))

# ------------------------------------------------------------
# Deliverable 1.1: Time series plots
# ------------------------------------------------------------

par(mfrow = c(2, 2))
plot(GS1, main = "1-Year Treasury Yield")
plot(GS2, main = "2-Year Treasury Yield")
plot(GS3, main = "3-Year Treasury Yield")
plot(GS5, main = "5-Year Treasury Yield")
par(mfrow = c(1, 1))

# ------------------------------------------------------------
# Convert to tsibble format
# ------------------------------------------------------------

GS1_tsbl <- tsibble(Month = yearmonth(time(GS1)), GS1 = as.numeric(GS1), index = Month)
GS2_tsbl <- tsibble(Month = yearmonth(time(GS2)), GS2 = as.numeric(GS2), index = Month)
GS3_tsbl <- tsibble(Month = yearmonth(time(GS3)), GS3 = as.numeric(GS3), index = Month)
GS5_tsbl <- tsibble(Month = yearmonth(time(GS5)), GS5 = as.numeric(GS5), index = Month)

# ------------------------------------------------------------
# Deliverable 1.2: STL decomposition of 3-year Treasury yield
# ------------------------------------------------------------

GS3_stl <- GS3_tsbl |>
  model(STL(GS3 ~ season(window = "periodic")))

components(GS3_stl) |>
  autoplot() +
  labs(
    title = "STL Decomposition of 3-Year Treasury Yield",
    x = "Month",
    y = "Yield (%)"
  )

GS3_tsbl |>
  ggtime::gg_season(GS3, labels = "both") +
  labs(
    title = "Seasonal 3-Year Treasury Yield",
    x = "Month",
    y = "Yield (%)"
  )

# ------------------------------------------------------------
# Deliverable 1.3: Outlier detection using STL residuals
# ------------------------------------------------------------

detect_outliers <- function(data, value_col) {
  components_tbl <- data |>
    model(stl = STL(as.formula(paste0(value_col, " ~ trend() + season()")), robust = TRUE)) |>
    components()

  components_tbl |>
    filter(
      remainder < quantile(remainder, 0.25, na.rm = TRUE) - 3 * IQR(remainder, na.rm = TRUE) |
        remainder > quantile(remainder, 0.75, na.rm = TRUE) + 3 * IQR(remainder, na.rm = TRUE)
    ) |>
    select(Month, all_of(value_col), remainder)
}

GS1_outliers <- detect_outliers(GS1_tsbl, "GS1")
GS2_outliers <- detect_outliers(GS2_tsbl, "GS2")
GS3_outliers <- detect_outliers(GS3_tsbl, "GS3")
GS5_outliers <- detect_outliers(GS5_tsbl, "GS5")

GS1_outliers
GS2_outliers
GS3_outliers
GS5_outliers

# ------------------------------------------------------------
# Deliverable 1.4: Stationarity testing and first differences
# ------------------------------------------------------------

GS1_tsbl |> features(GS1, unitroot_kpss)
GS2_tsbl |> features(GS2, unitroot_kpss)
GS3_tsbl |> features(GS3, unitroot_kpss)
GS5_tsbl |> features(GS5, unitroot_kpss)

GS1_tsbl |> features(GS1, unitroot_ndiffs)
GS2_tsbl |> features(GS2, unitroot_ndiffs)
GS3_tsbl |> features(GS3, unitroot_ndiffs)
GS5_tsbl |> features(GS5, unitroot_ndiffs)

GS1_tsbl |> features(difference(GS1), unitroot_kpss)
GS2_tsbl |> features(difference(GS2), unitroot_kpss)
GS3_tsbl |> features(difference(GS3), unitroot_kpss)
GS5_tsbl |> features(difference(GS5), unitroot_kpss)

GS1_diff <- GS1_tsbl |> mutate(d_GS1 = difference(GS1))
GS2_diff <- GS2_tsbl |> mutate(d_GS2 = difference(GS2))
GS3_diff <- GS3_tsbl |> mutate(d_GS3 = difference(GS3))
GS5_diff <- GS5_tsbl |> mutate(d_GS5 = difference(GS5))

# ------------------------------------------------------------
# Deliverable 1.5: Pairwise comparison of transformed data
# ------------------------------------------------------------

yield_diff <- data.frame(
  d_GS1 = diff(as.numeric(GS1)),
  d_GS2 = diff(as.numeric(GS2)),
  d_GS3 = diff(as.numeric(GS3)),
  d_GS5 = diff(as.numeric(GS5))
)

ggpairs(yield_diff)
