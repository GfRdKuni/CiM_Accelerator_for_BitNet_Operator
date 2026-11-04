# Revision log

## 2026-11-04 — Portable verification and missing memory implementation

Baseline: `c5d0c08697b7e70314615c0981ce3faa5d51561e`.

- Reproduced public `Top` elaboration failure caused by absent `SRAM_D4W256`
  and `SRAM_D32W256` definitions (nine elaboration errors).
- Added a portable inferred-memory alternative with the two-stage read/output
  register behavior required by the existing controller.
- Added an explicit complete-source manifest and Python standard-library runner.
  Deterministic inputs use original integer weights for the reference dot products.
- Added self-checking LUT/sign and public `Para_Top` tests, including independent
  lanes, repeated operations, input gaps, output stalls, reset and timeout checks.
- Added a workflow using the same portable command; it has not been run remotely.
- Preserved original RTL architecture, original README, presentation, MATLAB
  sources, historical input data and logs. Documented missing legacy helpers,
  original intermediate-width limits and absent physical implementation evidence.
- Retained the baseline's unlicensed status; no license was invented.

Executed outcomes are recorded in [engineering-review.md](engineering-review.md).
