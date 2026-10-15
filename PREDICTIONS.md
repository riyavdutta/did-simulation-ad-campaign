# Predictions (written by the author, 2026-10-15, before any code)

Averages are over 1,000 simulations.

- S1: mean of d about +10; SD of d about 1.6; event study about 0 in
  weeks 1 to 2 and about +10 in weeks 4 to 6
- S2: estimator B about +19; estimator A about +13; event study relative
  to week 3 = -6, -3, 0, +13, +16, +19
- S3: d about +20; event study about 0 in weeks 1 to 2 and about +20 in
  weeks 4 to 6
- Level gap: the group-difference coefficient rises by 10; d unchanged

## Session 2: one simulated S1 dataset (written before any code ran)

Seed: 2026 (chosen before any code ran)

Expected group averages from this one dataset (units per city-week):
- Advertised cities, weeks 1 to 3: 110
- Advertised cities, weeks 4 to 6: 135
- Comparison cities, weeks 1 to 3: 110
- Comparison cities, weeks 4 to 6: 125
- Difference-in-differences computed from these four: 10

How far I expect each actual average to land from my number, and why:
within about 4.5 units, mostly because 50 cities do not average out the
city effects exactly (SD 15 / sqrt(50) = 2.1; noise adds little, SD
10 / sqrt(150) = 0.8; combined SD about 2.3, so 2 SD is about 4.5). The
difference-in-differences should land within about 3.3 of 10, because the
city effects cancel in it and only noise remains (SD about 1.6).


## Session 3: regression on the same dataset (written before any code ran)

Same dataset as Session 2 (seed 2026, built by build_s1_dataset()).

Model 1: lm(sales ~ D * Post), no fixed effects
- Intercept (a): about 107.10 (comparison cities, weeks 1 to 3)
- D (b): about 2.81 (advertised minus comparison, weeks 1 to 3)
- Post (c): about 16.12 (change in comparison cities)
- D:Post (d): about 9.54 (equal to the hand difference-in-differences)
- a + b + c + d: about 135.57 (advertised cities, weeks 4 to 6)
- Standard error of d: about 2.9 (anywhere from 2.6 to 3.3), because
  Model 1 ignores that the same cities appear before and after, so the
  city effects (SD 15) stay in the residuals

Model 2: lm(sales ~ D:Post + factor(city) + factor(week))
- Coefficient on D:Post: about 9.54, identical to Model 1 and to the
  hand difference-in-differences (balanced panel, one start date)
- Standard error of d: about 1.6 (anywhere from 1.5 to 1.8), because the
  city effects cancel and only the noise (SD 10) remains
- 95% interval for d: about 6.3 to 12.7, which contains the true +10

Why the two standard errors differ: both models estimate d identically,
but Model 1 treats the 600 rows as unrelated and leaves the city effects
in its error, so its standard error is nearly double. The city fixed
effects remove each city's constant level, which gives the correct,
smaller standard error.