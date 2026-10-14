# Specification (written by the author, 2026-10-15, before any code)

Purpose: simulate difference-in-differences to show how random noise,
parallel trends and violations of parallel trends affect estimates of an
ad campaign's impact.

World: 100 cities (50 advertised, 50 comparison), weeks t = 1..6, the
campaign starts after t = 3 (no week 0), 1,000 simulations per scenario.

Sales: Y_it = 100 + 5t + a_i + 10*D_i*Post_t + e_it
- a_i ~ Normal(0, 15^2), drawn once per city
- e_it ~ Normal(0, 10^2), drawn fresh for every city-week
- D_i = 1 for advertised cities; Post_t = 1 for t >= 4
- the ad effect is a constant +10 in every post week

Scenarios
- S1: parallel trends hold
- S2: add 3*D_i*t (extra weekly growth in advertised cities)
- S3: add 10*D_i*Post_t (an unrelated shock that starts with the campaign
  and persists in all three post weeks)

Estimators
- B (main): regression with city and week fixed effects and a D*Post
  term, using all six weeks
- A (hand check): compare weeks 3 and 4 only
- Event study: week-by-week coefficients relative to week 3

Checks
- regression coefficients match the four group means
- B equals the simple pre/post difference in means (balanced panel, one
  start date); if it does not, treat it as a bug
- fixed random seed
- optional: a fixed +10 level gap for advertised cities