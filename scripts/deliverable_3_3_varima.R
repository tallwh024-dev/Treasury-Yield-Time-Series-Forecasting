# Deliverable 3.3: VARIMA model
# Author: Jackson Wang

library(fpp3)
library(quantmod)
library(tsbox)
library(dplyr)

from <- as.Date("1976-06-01")
to <- as.Date("2026-05-01")
symbols <- c("GS1", "GS2", "GS3", "GS5")

invisible(getSymbols(symbols, from = from, to = to, src = "FRED"))

Yield_tsbl <- ts_tsibble(GS1) |>
  rename(GS1 = value) |>
  left_join(ts_tsibble(GS2) |> rename(GS2 = value), by = "time") |>
  left_join(ts_tsibble(GS3) |> rename(GS3 = value), by = "time") |>
  left_join(ts_tsibble(GS5) |> rename(GS5 = value), by = "time") |>
  mutate(Month = yearmonth(time), GS1 = GS1 / 100, GS2 = GS2 / 100, GS3 = GS3 / 100, GS5 = GS5 / 100) |>
  as_tsibble(index = Month) |>
  select(Month, GS1, GS2, GS3, GS5)

fit <- Yield_tsbl |>
  model(VARIMA_111 = VARIMA(vars(GS1, GS2, GS3, GS5) ~ pdq(1, 1, 1)))

report(fit)

glance(fit)
