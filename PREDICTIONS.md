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
