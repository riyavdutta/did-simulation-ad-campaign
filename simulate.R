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
gap_sims <- numeric(n_sims)   # pre-campaign gap, advertised minus comparison, weeks 1 to 3

for (i in 1:n_sims) {
  sim <- build_s1_dataset()

  # d: advertised post minus pre, minus comparison post minus pre
  d_sims[i] <-
    (mean(sim$sales[sim$D == 1 & sim$Post == 1]) -
     mean(sim$sales[sim$D == 1 & sim$Post == 0])) -
    (mean(sim$sales[sim$D == 0 & sim$Post == 1]) -
     mean(sim$sales[sim$D == 0 & sim$Post == 0]))

  # Pre-campaign gap: advertised minus comparison average, weeks 1 to 3
  gap_sims[i] <- mean(sim$sales[sim$D == 1 & sim$Post == 0]) -
                 mean(sim$sales[sim$D == 0 & sim$Post == 0])

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
cat("Mean of pre-campaign gap:", round(mean(gap_sims), 3), "\n")
cat("SD of pre-campaign gap:", round(sd(gap_sims), 3), "\n")

# ---- Session 5: scenarios S2 and S3, 1,000 new datasets each ----
# No set.seed here: these draws continue the random stream after the
# Session 4 run. S2's 1,000 datasets are drawn first, then S3's 1,000.

# Runs 1,000 rounds. Each round builds an S1 dataset, adds add_term(sim)
# to sales, and records the same ten quantities as the Session 4 block.
# Everything made inside the function stays inside it, so nothing from
# earlier sessions is overwritten.
run_scenario <- function(add_term) {
  n_rounds <- 1000
  d_v   <- numeric(n_rounds)   # d by hand
  se1_v <- numeric(n_rounds)   # Model 1 standard error of D:Post
  se2_v <- numeric(n_rounds)   # Model 2 standard error of D:Post
  in1_v <- logical(n_rounds)   # Model 1 95% interval contains 10?
  in2_v <- logical(n_rounds)   # Model 2 95% interval contains 10?
  a_v   <- numeric(n_rounds)   # estimator A (week 3 versus week 4)
  gap_v <- numeric(n_rounds)   # pre-campaign gap, weeks 1 to 3

  for (r in 1:n_rounds) {
    sim <- build_s1_dataset()
    sim$sales <- sim$sales + add_term(sim)

    adv_pre  <- mean(sim$sales[sim$D == 1 & sim$Post == 0])
    adv_post <- mean(sim$sales[sim$D == 1 & sim$Post == 1])
    cmp_pre  <- mean(sim$sales[sim$D == 0 & sim$Post == 0])
    cmp_post <- mean(sim$sales[sim$D == 0 & sim$Post == 1])

    # d: advertised post minus pre, minus comparison post minus pre
    d_v[r] <- (adv_post - adv_pre) - (cmp_post - cmp_pre)

    # Pre-campaign gap: advertised minus comparison average, weeks 1 to 3
    gap_v[r] <- adv_pre - cmp_pre

    # Model 1: no fixed effects
    fit1 <- lm(sales ~ D * Post, data = sim)
    se1_v[r] <- summary(fit1)$coefficients["D:Post", "Std. Error"]
    ci1 <- confint(fit1, parm = "D:Post")
    in1_v[r] <- ci1[1] <= 10 && 10 <= ci1[2]

    # Model 2: city and week fixed effects
    fit2 <- lm(sales ~ D:Post + factor(city) + factor(week), data = sim)
    se2_v[r] <- summary(fit2)$coefficients["D:Post", "Std. Error"]
    ci2 <- confint(fit2, parm = "D:Post")
    in2_v[r] <- ci2[1] <= 10 && 10 <= ci2[2]

    # Estimator A: the same comparison using week 3 and week 4 only
    a_v[r] <-
      (mean(sim$sales[sim$D == 1 & sim$week == 4]) -
       mean(sim$sales[sim$D == 1 & sim$week == 3])) -
      (mean(sim$sales[sim$D == 0 & sim$week == 4]) -
       mean(sim$sales[sim$D == 0 & sim$week == 3]))
  }

  c(mean_d   = mean(d_v),
    sd_d     = sd(d_v),
    mean_se2 = mean(se2_v),
    mean_se1 = mean(se1_v),
    in2_pct  = 100 * mean(in2_v),
    in1_pct  = 100 * mean(in1_v),
    mean_a   = mean(a_v),
    sd_a     = sd(a_v),
    mean_gap = mean(gap_v),
    sd_gap   = sd(gap_v))
}

s5_labels <- c(mean_d   = "Mean of d",
               sd_d     = "SD of d",
               mean_se2 = "Mean Model 2 standard error",
               mean_se1 = "Mean Model 1 standard error",
               in2_pct  = "Model 2 intervals containing 10 (%)",
               in1_pct  = "Model 1 intervals containing 10 (%)",
               mean_a   = "Mean of estimator A",
               sd_a     = "SD of estimator A",
               mean_gap = "Mean of pre-campaign gap",
               sd_gap   = "SD of pre-campaign gap")

# S2: extra weekly growth in advertised cities
s5_s2 <- run_scenario(function(sim) 3 * sim$D * sim$week)

# S3: an unrelated shock that starts with the campaign
s5_s3 <- run_scenario(function(sim) 10 * sim$D * sim$Post)

cat("\nSession 5, S2: sales + 3 * D * week\n")
for (s5_name in names(s5_labels)) {
  cat(s5_labels[s5_name], ":", round(s5_s2[s5_name], 3), "\n")
}

cat("\nSession 5, S3: sales + 10 * D * Post\n")
for (s5_name in names(s5_labels)) {
  cat(s5_labels[s5_name], ":", round(s5_s3[s5_name], 3), "\n")
}

# ---- Session 6: event study for S1, S2 and S3, 1,000 new datasets each ----
# No set.seed here: these draws continue the random stream after the
# Session 5 run. S1's 1,000 datasets are drawn first, then S2's, then S3's.

# For each of 1,000 datasets: the advertised-minus-comparison gap in each
# week 1 to 6, minus the week 3 gap. Returns a 1,000 by 6 matrix, one row
# per dataset and one column per week.
run_event_study <- function(add_term) {
  n_rounds <- 1000
  es <- matrix(0, nrow = n_rounds, ncol = 6)

  for (r in 1:n_rounds) {
    sim <- build_s1_dataset()
    sim$sales <- sim$sales + add_term(sim)

    gap_by_week <- numeric(6)
    for (w in 1:6) {
      gap_by_week[w] <- mean(sim$sales[sim$D == 1 & sim$week == w]) -
                        mean(sim$sales[sim$D == 0 & sim$week == w])
    }
    es[r, ] <- gap_by_week - gap_by_week[3]
  }

  es
}

s6_s1 <- run_event_study(function(sim) rep(0, nrow(sim)))      # S1
s6_s2 <- run_event_study(function(sim) 3 * sim$D * sim$week)   # S2
s6_s3 <- run_event_study(function(sim) 10 * sim$D * sim$Post)  # S3

# Mean and 2.5th and 97.5th percentiles across the 1,000 datasets, per week
s6_mean <- rbind(S1 = colMeans(s6_s1),
                 S2 = colMeans(s6_s2),
                 S3 = colMeans(s6_s3))
s6_lo   <- rbind(S1 = apply(s6_s1, 2, quantile, probs = 0.025),
                 S2 = apply(s6_s2, 2, quantile, probs = 0.025),
                 S3 = apply(s6_s3, 2, quantile, probs = 0.025))
s6_hi   <- rbind(S1 = apply(s6_s1, 2, quantile, probs = 0.975),
                 S2 = apply(s6_s2, 2, quantile, probs = 0.975),
                 S3 = apply(s6_s3, 2, quantile, probs = 0.975))
colnames(s6_mean) <- paste("Week", 1:6)

cat("\nSession 6: event study, mean of (week gap minus week 3 gap)\n")
print(round(s6_mean, 2))

# Figure: three panels, saved to figures/event_study.png in this project
dir.create("figures", showWarnings = FALSE)
png(file.path("figures", "event_study.png"),
    width = 1500, height = 500, res = 120)
par(mfrow = c(1, 3))
for (s6_sc in c("S1", "S2", "S3")) {
  plot(1:6, s6_mean[s6_sc, ], type = "b", pch = 19,
       ylim = range(s6_lo, s6_hi),
       xlab = "Week", ylab = "Gap minus week 3 gap", main = s6_sc)
  lines(1:6, s6_lo[s6_sc, ], lty = 2)   # 2.5th percentile
  lines(1:6, s6_hi[s6_sc, ], lty = 2)   # 97.5th percentile
  abline(v = 3.5, lty = 2)              # campaign starts after week 3
  abline(h = 0)
}
invisible(dev.off())
cat("Figure saved: figures/event_study.png\n")
