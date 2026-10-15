# simulate.R
# Difference-in-differences simulation for an ad campaign (see SPEC.md).
# Session 2: build one S1 dataset, where parallel trends hold.

set.seed(2026)

build_s1_dataset <- function() {
  n_cities <- 100
  n_weeks  <- 6

  # One row per city-week: 100 cities x 6 weeks = 600 rows.
  # Rows 1-6 are city 1 in weeks 1-6, rows 7-12 are city 2, and so on.
  data <- data.frame(
    city = rep(1:n_cities, each = n_weeks),
    week = rep(1:n_weeks, times = n_cities)
  )

  # D = 1 for advertised cities (1 to 50), 0 for comparison cities (51 to 100)
  data$D <- ifelse(data$city <= 50, 1, 0)

  # Post = 1 for weeks 4 to 6, 0 for weeks 1 to 3
  data$Post <- ifelse(data$week >= 4, 1, 0)

  # City effect a_i ~ Normal(0, 15^2): one draw per city,
  # then copied to all six weeks of that city
  city_effect <- rnorm(n_cities, mean = 0, sd = 15)
  data$city_effect <- city_effect[data$city]

  # Noise e_it ~ Normal(0, 10^2): a fresh draw for every city-week
  data$noise <- rnorm(nrow(data), mean = 0, sd = 10)

  # Sales: Y_it = 100 + 5t + a_i + 10*D_i*Post_t + e_it
  data$sales <- 100 + 5 * data$week + data$city_effect +
                10 * data$D * data$Post + data$noise

  data
}

# ---- Session 2: one S1 dataset, four group averages, DiD by hand ----

s1 <- build_s1_dataset()

# Structure checks: R stops with an error if any line here is FALSE
stopifnot(
  nrow(s1) == 600,                         # 100 cities x 6 weeks
  sum(s1$D) == 300,                        # 50 advertised cities x 6 weeks
  sum(s1$Post) == 300,                     # 100 cities x 3 post weeks
  all(s1$city_effect ==
      rep(s1$city_effect[s1$week == 1], each = 6))  # one city effect per city
)

# The four group averages
adv_pre  <- mean(s1$sales[s1$D == 1 & s1$Post == 0])  # advertised, weeks 1-3
adv_post <- mean(s1$sales[s1$D == 1 & s1$Post == 1])  # advertised, weeks 4-6
cmp_pre  <- mean(s1$sales[s1$D == 0 & s1$Post == 0])  # comparison, weeks 1-3
cmp_post <- mean(s1$sales[s1$D == 0 & s1$Post == 1])  # comparison, weeks 4-6

# Difference-in-differences by hand
change_adv <- adv_post - adv_pre   # how much advertised cities changed
change_cmp <- cmp_post - cmp_pre   # how much comparison cities changed
did        <- change_adv - change_cmp

cat("Advertised cities, weeks 1 to 3:", round(adv_pre, 2), "\n")
cat("Advertised cities, weeks 4 to 6:", round(adv_post, 2), "\n")
cat("Comparison cities, weeks 1 to 3:", round(cmp_pre, 2), "\n")
cat("Comparison cities, weeks 4 to 6:", round(cmp_post, 2), "\n")
cat("Change, advertised:", round(change_adv, 2), "\n")
cat("Change, comparison:", round(change_cmp, 2), "\n")
cat("Difference-in-differences:", round(did, 2), "\n")
