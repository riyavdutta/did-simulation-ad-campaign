# AI use log

## Session 1: 2026-10-15

**Environment**
- R version: 4.5.2 (2025-10-31)
- Packages: none (base R only)
- Random seed: not set yet (no simulation code exists)

**What the AI did**
- Read the project folder, CLAUDE.md, SPEC.md and PREDICTIONS.md (read-only).
- Created this log file.

**What I decided / did myself**
- I learned difference-in-differences step by step with an AI tutor
  (Claude, in a separate chat), working through each worked example
  myself, including questions with new numbers.
- I wrote the specification and predictions in SPEC.md and
  PREDICTIONS.md: the simulated world, the sales formula, the three
  scenarios, the estimators, and my predictions, including the expected
  spread of the estimates. The AI tutor reviewed the drafts and helped
  with formatting.
- The working rules in CLAUDE.md were written with the AI tutor and
  approved by me.
- No simulation code exists yet.
- My specification and predictions were committed before any code
  existed (ea87761).

## Session 2: 2026-10-15

**Environment**
- R version: 4.5.2 (2025-10-31)
- Packages: none (base R only)
- Random seed: 2026
- Run command: Rscript --vanilla simulate.R

**What the AI did**
- Read CLAUDE.md, SPEC.md and PREDICTIONS.md (read-only) and confirmed
  PREDICTIONS.md has a Session 2 section with the seed and four expected
  group averages.
- Created simulate.R with set.seed(2026) and build_s1_dataset(), which
  builds one S1 dataset as in SPEC.md.
- Added a section that calls the function once, checks the dataset
  structure, and computes the four group averages and the
  difference-in-differences by hand.
- Ran simulate.R once. Results: advertised cities 109.91 (weeks 1-3) and
  135.57 (weeks 4-6); comparison cities 107.10 and 123.21;
  difference-in-differences 9.54.
- Compared the results with my Session 2 predictions without changing
  any file. All four averages were within my ±4.5 band and the
  difference-in-differences was within my ±3.3 band.
- Checked the simulate.R commit message against the commit's contents.
- Added this entry.

**What I decided / did myself**
- I chose seed 2026 and wrote my Session 2 predictions before any code
  existed (0f82542).
- I approved each step before it was made, including the structure
  checks.
- No regression and no replications this session.
- I corrected the simulate.R commit message to cover both steps
  (f08933c).

## Session 3: 2026-10-16

### Environment
- R 4.5.2 (2025-10-31), no packages installed. lm(), summary(), confint() and coef() are in base R's stats package.
- Seed 2026, set once at the top of simulate.R. Run command: Rscript --vanilla simulate.R

### AI actions
- Added a Session 3 section to simulate.R (lines 70 to 99) that fits two regressions on the Session 2 dataset and checks the difference-in-differences estimates for equality.
- Ran simulate.R once. Model 1: D:Post 9.54 (SE 2.97). Model 2: D:Post 9.54 (SE 1.61, 95% interval 6.37 to 12.71). Hand calculation, Model 1 and Model 2 all gave 9.543978.
- Revised CLAUDE.md during this period; see git history.

### Checks
- Session 2 output reprinted unchanged. git status was clean before and after the run. Every result matched or fell inside the Session 3 predictions.
- Commit 6029d27 holds both the predictions and the code, so git alone does not show the predictions came first.

## Session 4: 2026-10-16

### Environment
- R 4.5.2 (2025-10-31), no packages installed. lm() and confint() are in base R's stats package.
- Seed 2026, set once at the top of simulate.R; the 1,000 datasets continue the stream after the Session 2 dataset. Run command: Rscript --vanilla simulate.R

### AI actions
- Appended the Session 4 predictions to PREDICTIONS.md as supplied and committed them (fce3428).
- Added a Session 4 section to simulate.R (lines 101 to 159): 1,000 S1 datasets, each with d by hand, Model 1 and Model 2 standard errors and interval coverage, estimator A, and the pre-campaign gap.
- Ran simulate.R once. Mean of d 10.042, SD 1.620. Mean SE: Model 2 1.631, Model 1 2.996. Intervals containing 10: Model 2 95.7%, Model 1 100%. Estimator A: mean 10.004, SD 2.845. Pre-campaign gap: mean 0.123, SD 3.043.

### Checks
- Predictions (fce3428) were committed and pushed before the Session 4 code (19da710, 72f52ff) and before the run.
- Session 2 and 3 output reprinted unchanged. git status was clean before and after the run.
- Nine of ten results matched or fell inside the predictions. The SD of the pre-campaign gap (3.043) was 0.16 below the predicted 3.2, about 2.4 standard errors, consistent with chance in one random stream.

## Session 5: 2026-10-16

### Environment
- R 4.5.2 (2025-10-31), no packages installed. lm() and confint() are in base R's stats package.
- Seed 2026, set once at the top of simulate.R; S2 and then S3 draw 1,000 datasets each, continuing the stream after Session 4. Run command: Rscript --vanilla simulate.R

### AI actions
- Appended the Session 5 predictions to PREDICTIONS.md as supplied (committed by the author as 285c598).
- Added a Session 5 section to simulate.R (lines 161 to 251) with run_scenario(add_term), run for S2 (3 * D * week) and S3 (10 * D * Post).
- Ran simulate.R once. S2: mean d 18.981, SD 1.703, mean SE Model 2 1.646, Model 1 3.058, coverage of 10 Model 2 0%, Model 1 4.6%, estimator A 13.012 (SD 2.758), gap 6.050 (SD 3.354). S3: mean d 19.998, SD 1.602, mean SE Model 2 1.632, Model 1 3.000, coverage Model 2 0%, Model 1 0.5%, estimator A 20.002 (SD 2.878), gap 0.219 (SD 3.220).

### Checks
- Predictions (285c598) were committed and pushed before the Session 5 code (0bdc50d), and both before the run. git status was clean before and after the run; Sessions 2 to 4 output reprinted unchanged.
- 19 of 20 results fell inside the predicted ranges. S3's mean pre-campaign gap (0.219) was 0.019 above the range (-0.2 to 0.2), about 2.1 standard errors from 0, consistent with chance; S3's added term is 0 before the campaign.
- S2's SD of d (1.703) and SD of the gap (3.354) were inside their ranges but about 2 standard errors above theory.

## Session 6: 2026-10-17

### Environment
- R 4.5.2 (2025-10-31), no packages installed. png(), plot() and quantile() are in base R (grDevices, graphics, stats).
- Seed 2026, set once at the top of simulate.R; S1, S2 and S3 then draw 1,000 datasets each, continuing the stream after Session 5. Run command: Rscript --vanilla simulate.R

### AI actions
- Added a Session 6 section to simulate.R (lines 253 to 313) with run_event_study(add_term), run for S1 (nothing added), S2 (3 * D * week) and S3 (10 * D * Post).
- Ran simulate.R once. Means relative to week 3, weeks 1 to 6: S1 0.01, -0.05, 0, 10.10, 9.92, 10.02; S2 -6.00, -3.09, 0, 12.97, 15.91, 18.94; S3 -0.04, -0.09, 0, 19.99, 19.96, 20.00. Saved figures/event_study.png.
- Committed figures/event_study.png (c58d729).

### Checks
- Session 6 code (b066525) was committed and pushed before the run. The run reached its last line (exit code not captured). Only the Session 5 S3 output was displayed and it matched the previous run, so the earlier random stream is inferred unchanged; earlier lines were not displayed. The only new item after the run was figures/.
- All 18 means are within 0.10 of the Session 1 event-study predictions, about one standard error of a weekly mean (0.09, derived from the spec, not printed).
- The figure has three panels with the mean, the 2.5th to 97.5th percentile band, a dashed line between weeks 3 and 4 and a line at 0; S2 shows a pre-trend in weeks 1 and 2.

## Session 7: 2026-10-17

### Environment
- R 4.5.2 (2025-10-31), no packages installed, seed 2026. No R code was run this session.

### AI actions
- Wrote README.md under a one-off exception to rule 8, using the author's text word for word with one author-supplied correction to the Session 4 cell of the predictions table. Did not commit it.

### Checks
- Before writing, compared the README's results tables with the Session 4 to 6 output and its commit hashes with git log. All matched except the Session 4 cell, which attributed prediction lines to 72f52ff (a code-only commit); the author corrected it.
- git diff showed README.md as the only changed file (2 lines removed, 86 added). It was committed and pushed as fe42f5f.
