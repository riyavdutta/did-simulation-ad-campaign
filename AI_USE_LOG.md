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
