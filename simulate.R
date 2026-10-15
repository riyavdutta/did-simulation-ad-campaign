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

# ---- Session 3: regressions on the same S1 dataset ----
# Uses s1 and did from the Session 2 section above. The function is NOT
# called again, because a second call would draw a different dataset.

# Model 1: no fixed effects
m1 <- lm(sales ~ D * Post, data = s1)
m1_table <- summary(m1)$coefficients
cat("\nModel 1: lm(sales ~ D * Post)\n")
print(round(m1_table[, c("Estimate", "Std. Error")], 2))

# Model 2: city and week fixed effects; print only the D:Post row
m2 <- lm(sales ~ D:Post + factor(city) + factor(week), data = s1)
m2_table <- summary(m2)$coefficients
m2_ci    <- confint(m2)   # 95% intervals by default
cat("\nModel 2: lm(sales ~ D:Post + factor(city) + factor(week))\n")
cat("D:Post coefficient:", round(m2_table["D:Post", "Estimate"], 2), "\n")
cat("Standard error:", round(m2_table["D:Post", "Std. Error"], 2), "\n")
cat("95% interval:", round(m2_ci["D:Post", 1], 2), "to",
    round(m2_ci["D:Post", 2], 2), "\n")

# Are the three difference-in-differences estimates equal?
d_hand <- did
d_m1   <- unname(coef(m1)["D:Post"])
d_m2   <- unname(coef(m2)["D:Post"])
cat("\nHand DiD (Session 2):", round(d_hand, 6), "\n")
cat("Model 1 D:Post:", round(d_m1, 6), "\n")
cat("Model 2 D:Post:", round(d_m2, 6), "\n")
all_equal <- isTRUE(all.equal(d_m1, d_hand)) && isTRUE(all.equal(d_m2, d_hand))
cat("All three equal (up to computer rounding):", all_equal, "\n")

# ---- Session 4: 1,000 simulated S1 datasets ----
# No set.seed here: these draws continue the random stream after the
# Session 2 dataset. Names differ from Sessions 2 and 3 so nothing above
# is overwritten.

n_sims   <- 1000
d_sims   <- numeric(n_sims)   # d by hand
se1_sims <- numeric(n_sims)   # Model 1 standard error of D:Post
se2_sims <- numeric(n_sims)   # Model 2 standard error of D:Post
in1_sims <- logical(n_sims)   # Model 1 95% interval contains 10?
in2_sims <- logical(n_sims)   # Model 2 95% interval contains 10?
a_sims   <- numeric(n_sims)   # estimator A (week 3 versus week 4)

for (i in 1:n_sims) {
  sim <- build_s1_dataset()

  # d: advertised post minus pre, minus comparison post minus pre
  d_sims[i] <-
    (mean(sim$sales[sim$D == 1 & sim$Post == 1]) -
     mean(sim$sales[sim$D == 1 & sim$Post == 0])) -
    (mean(sim$sales[sim$D == 0 & sim$Post == 1]) -
     mean(sim$sales[sim$D == 0 & sim$Post == 0]))

  # Model 1: no fixed effects
  fit1 <- lm(sales ~ D * Post, data = sim)
  se1_sims[i] <- summary(fit1)$coefficients["D:Post", "Std. Error"]
  ci1 <- confint(fit1, parm = "D:Post")
  in1_sims[i] <- ci1[1] <= 10 && 10 <= ci1[2]

  # Model 2: city and week fixed effects
  fit2 <- lm(sales ~ D:Post + factor(city) + factor(week), data = sim)
  se2_sims[i] <- summary(fit2)$coefficients["D:Post", "Std. Error"]
  ci2 <- confint(fit2, parm = "D:Post")
  in2_sims[i] <- ci2[1] <= 10 && 10 <= ci2[2]

  # Estimator A: the same comparison using week 3 and week 4 only
  a_sims[i] <-
    (mean(sim$sales[sim$D == 1 & sim$week == 4]) -
     mean(sim$sales[sim$D == 1 & sim$week == 3])) -
    (mean(sim$sales[sim$D == 0 & sim$week == 4]) -
     mean(sim$sales[sim$D == 0 & sim$week == 3]))
}

cat("\nSession 4: 1,000 simulated S1 datasets\n")
cat("Mean of d:", round(mean(d_sims), 3), "\n")
cat("SD of d:", round(sd(d_sims), 3), "\n")
cat("Mean Model 2 standard error:", round(mean(se2_sims), 3), "\n")
cat("Mean Model 1 standard error:", round(mean(se1_sims), 3), "\n")
cat("Model 2 intervals containing 10:", round(100 * mean(in2_sims), 1), "%\n")
cat("Model 1 intervals containing 10:", round(100 * mean(in1_sims), 1), "%\n")
cat("Mean of estimator A:", round(mean(a_sims), 3), "\n")
cat("SD of estimator A:", round(sd(a_sims), 3), "\n")
