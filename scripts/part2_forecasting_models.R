# Treasury Yield Time-Series Forecasting - Part 2
# Univariate and multivariate time-series forecasting models
# Author: Jackson Wang

library(fpp3)
library(quantmod)
library(tsbox)
library(tseries)
library(GGally)
library(moments)
library(dplyr)
library(tidyr)
library(ggplot2)
library(MTS)

# ------------------------------------------------------------
# Data preparation
# ------------------------------------------------------------

from <- as.Date("1976-06-01")
to <- as.Date("2026-05-01")
symbols <- c("GS1", "GS2", "GS3", "GS5")

invisible(getSymbols(symbols, from = from, to = to, src = "FRED"))

Yield_tsbl <- ts_tsibble(GS1) |>
  rename(GS1 = value) |>
  left_join(ts_tsibble(GS2) |> rename(GS2 = value), by = "time") |>
  left_join(ts_tsibble(GS3) |> rename(GS3 = value), by = "time") |>
  left_join(ts_tsibble(GS5) |> rename(GS5 = value), by = "time") |>
  mutate(
    Month = yearmonth(time),
    GS1 = GS1 / 100,
    GS2 = GS2 / 100,
    GS3 = GS3 / 100,
    GS5 = GS5 / 100
  ) |>
  as_tsibble(index = Month) |>
  select(Month, GS1, GS2, GS3, GS5)

Yield_tsbl <- Yield_tsbl |>
  mutate(
    d_GS1 = GS1 - lag(GS1),
    d_GS2 = GS2 - lag(GS2),
    d_GS3 = GS3 - lag(GS3),
    d_GS5 = GS5 - lag(GS5)
  )

Yield_transformed <- Yield_tsbl |>
  select(Month, d_GS1, d_GS2, d_GS3, d_GS5) |>
  drop_na()

Yield_transformed_long <- Yield_transformed |>
  pivot_longer(
    cols = c(d_GS1, d_GS2, d_GS3, d_GS5),
    names_to = "Maturity",
    values_to = "Yield_Change"
  ) |>
  as_tsibble(index = Month, key = Maturity)

# ------------------------------------------------------------
# Deliverable 2.1: AR(1) models
# ------------------------------------------------------------

ar1_fit <- Yield_transformed_long |>
  model(
    AR1 = ARIMA(Yield_Change ~ 1 + pdq(1, 0, 0) + PDQ(0, 0, 0))
  )

report(ar1_fit)
tidy(ar1_fit)
glance(ar1_fit)

ar1_coef <- tidy(ar1_fit) |>
  mutate(
    estimate_sig = signif(estimate, 3),
    std_error_sig = signif(std.error, 3),
    statistic_sig = signif(statistic, 3),
    p_value_sig = signif(p.value, 3),
    significant_95 = if_else(p.value < 0.05, "Yes", "No")
  )

ar1_coef

ar1_fit_stats <- glance(ar1_fit) |>
  mutate(
    error_volatility = sqrt(sigma2),
    error_volatility_sig = signif(error_volatility, 3),
    AICc_sig = signif(AICc, 3),
    BIC_sig = signif(BIC, 3)
  )

ar1_fit_stats

ar1_aug <- augment(ar1_fit)

ar1_aug |>
  filter(Maturity == "d_GS1") |>
  gg_tsdisplay(.innov, plot_type = "partial", lag_max = 36) +
  labs(title = "AR(1) Innovation Residuals: 1-Year Treasury Yield Change")

ar1_aug |>
  filter(Maturity == "d_GS2") |>
  gg_tsdisplay(.innov, plot_type = "partial", lag_max = 36) +
  labs(title = "AR(1) Innovation Residuals: 2-Year Treasury Yield Change")

ar1_aug |>
  filter(Maturity == "d_GS3") |>
  gg_tsdisplay(.innov, plot_type = "partial", lag_max = 36) +
  labs(title = "AR(1) Innovation Residuals: 3-Year Treasury Yield Change")

ar1_aug |>
  filter(Maturity == "d_GS5") |>
  gg_tsdisplay(.innov, plot_type = "partial", lag_max = 36) +
  labs(title = "AR(1) Innovation Residuals: 5-Year Treasury Yield Change")

ar1_forecast <- ar1_fit |> forecast(h = 4)

ar1_forecast_table_all <- ar1_forecast |>
  as_tibble() |>
  select(Maturity, Month, .mean) |>
  mutate(.mean = signif(.mean, 3))

ar1_forecast_table_all

ar1_forecast |>
  autoplot(Yield_transformed_long) +
  labs(title = "AR(1) Forecasts for Transformed Treasury Yield Series")

# ------------------------------------------------------------
# Deliverable 2.2: AR(p) models selected by BIC
# ------------------------------------------------------------

arp_fit <- Yield_transformed_long |>
  model(
    ARp = ARIMA(
      Yield_Change ~ 1 + pdq(p = 1:12, d = 0, q = 0) + PDQ(0, 0, 0),
      ic = "bic",
      stepwise = FALSE,
      approximation = FALSE
    )
  )

report(arp_fit)
tidy(arp_fit)
glance(arp_fit)

arp_selected_p <- tidy(arp_fit) |>
  filter(grepl("^ar", term)) |>
  mutate(lag = as.integer(gsub("ar", "", term))) |>
  group_by(Maturity) |>
  summarize(selected_p = max(lag), .groups = "drop")

arp_selected_p

arp_aug <- augment(arp_fit)

arp_white_noise <- arp_aug |>
  features(.innov, ljung_box, lag = 24, dof = 3) |>
  mutate(white_noise_95 = if_else(lb_pvalue > 0.05, "Yes", "No"))

arp_white_noise

arp_forecast <- arp_fit |> forecast(h = 4)

arp_forecast_table_all <- arp_forecast |>
  as_tibble() |>
  select(Maturity, Month, .mean) |>
  mutate(.mean = signif(.mean, 3))

arp_forecast_table_all

arp_forecast |>
  autoplot(Yield_transformed_long) +
  labs(title = "AR(p) Forecasts for Transformed Treasury Yield Series")

# ------------------------------------------------------------
# Deliverable 2.3: ETS(ANN) models
# ------------------------------------------------------------

ets_fit <- Yield_transformed_long |>
  model(ETS_ANN = ETS(Yield_Change ~ error("A") + trend("N") + season("N")))

report(ets_fit)
glance(ets_fit)

ets_aug <- augment(ets_fit)

ets_white_noise <- ets_aug |>
  features(.innov, ljung_box, lag = 24, dof = 0) |>
  mutate(white_noise_95 = if_else(lb_pvalue > 0.05, "Yes", "No"))

ets_white_noise

ets_forecast <- ets_fit |> forecast(h = 4)

ets_forecast |>
  as_tibble() |>
  select(Maturity, Month, .mean) |>
  mutate(.mean = signif(.mean, 3))

ets_forecast |>
  autoplot(Yield_transformed_long) +
  labs(title = "ETS(ANN) Forecasts for Transformed Treasury Yield Series")

# ------------------------------------------------------------
# Deliverable 3.1: VAR model
# ------------------------------------------------------------

Yield_var <- Yield_transformed |>
  as_tsibble(index = Month)

var_fit <- Yield_var |>
  model(VAR_model = VAR(vars(d_GS1, d_GS2, d_GS3, d_GS5), ic = "BIC"))

report(var_fit)
glance(var_fit)
tidy(var_fit)

var_forecast <- var_fit |> forecast(h = 4)

var_forecast_table <- var_forecast |>
  as_tibble() |>
  select(.model, Month, .mean)

var_forecast_table

# ------------------------------------------------------------
# Deliverable 3.2: Model comparison table
# ------------------------------------------------------------

ar1_compare <- glance(ar1_fit) |>
  mutate(model_type = "AR(1)") |>
  select(model_type, Maturity, AICc, BIC)

arp_compare <- glance(arp_fit) |>
  mutate(model_type = "AR(p)") |>
  select(model_type, Maturity, AICc, BIC)

ets_compare <- glance(ets_fit) |>
  mutate(model_type = "ETS(ANN)") |>
  select(model_type, Maturity, AICc, BIC)

comparison_table <- bind_rows(ar1_compare, arp_compare, ets_compare)
comparison_table

# ------------------------------------------------------------
# Extra: VARIMA-style multivariate analysis can be added with MTS
# depending on local package setup and object format.
# ------------------------------------------------------------
