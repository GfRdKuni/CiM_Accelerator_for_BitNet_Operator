# Engineering rehabilitation record

## Intent and scope

Baseline: `c5d0c08697b7e70314615c0981ce3faa5d51561e`.
This is an engineering repository: `src/Top.v` implements a ternary-weight
matrix/vector operator, with a parallel wrapper, LUT generation and selection,
separate sign/magnitude reduction trees, and banked memories.

The approved account-wide rehabilitation authorizes local reversible repairs,
portable verification, accurate documentation and revision records. Preserve the
existing architecture, historical sources, presentation, data and attribution.
Do not invent a license, commit, push, publish or deploy.

Success means a fresh checkout can run a deterministic, self-checking simulation
of the public interface without MATLAB, Vivado IP or developer-specific paths.
Results must be checked against direct integer dot products. State numerical,
protocol and physical-validation limits explicitly.

## Specification

Keep `Top` and `Para_Top` interfaces and fixed 256-by-96 computation unchanged.
Supply portable inferred versions of the missing `SRAM_D4W256` and
`SRAM_D32W256` modules, with a synchronous read followed by an enabled output
register, matching the controller's existing two-stage read schedule. Do not
mix these alternatives with identically named vendor IP in one build.

Provide explicit source manifests, a Python standard-library runner, deterministic
activation/ternary-weight generation, input packing, and an independent direct
dot-product reference. A new testbench must use only public handshakes, check every
output, enforce a timeout, exercise input gaps/output backpressure and repeat
transactions. Add targeted arithmetic coverage where end-to-end small data do
not cover the encoding. Fix RTL only for failures demonstrated by these checks.

No added Python packages are required. Icarus Verilog is the portable simulator.
CI may run the same command; remote CI execution is outside this local scope.
The existing 16-bit LUT saturation/tree and 32-bit accumulation are boundaries,
not evidence of general int32 matrix multiplication.

## Plan

1. Reproduce public-top elaboration failure and inspect all datapath/control stages.
2. Add the memory alternative, manifest, deterministic generator and public-top
   testbench. Run baseline arithmetic/protocol checks and repair evidenced issues.
3. Add representative LUT/sign arithmetic checks and bounded parallel-wrapper
   coverage. Run the same portable command in CI configuration.
4. Rewrite setup/interface/numerical documentation, preserve historical README,
   add a revision record and record exact executed verification and limitations.
5. Parent agent independently reviews the resulting diff/evidence before delivery.

## Initial findings

- The repository omits both SRAM modules instantiated by `Data_top`.
- The legacy testbench uses a hard-coded `D:/Xilinx_...` input path and logs
  results without an in-simulation arithmetic comparison.
- MATLAB scripts reference absent `mynum2bin`, `bin2hexstr`, `logToMatrix` and
  `areMatricesEqual` helpers. Preserve this historical workflow but do not claim
  it is runnable from the repository alone.

## Verification

Executed locally on 2026-11-04 using Python 3 and Icarus Verilog under Ubuntu
WSL, with tool locations supplied by `IVERILOG`, `VVP` and
`IVERILOG_LIBDIR`. The reproducible command is `python3 Scripts/verify.py`.

| Check | Actual outcome |
| --- | --- |
| Baseline public `Top` elaboration without added SRAM | Failed with nine errors; two missing module types |
| All 27 ternary triples, eight activation triples | 216 LUT/sign cases passed, including positive/negative saturation and LUT register enable hold |
| Public `Para_Top`, two independent lanes, three consecutive jobs, continuous ready | All 1,536 scalar outputs matched direct integer dot products; 1,367 clock cycles |
| Same inputs with lane-dependent delayed ready | All 1,536 scalar outputs matched; 1,499 clock cycles; output valid/data remained stable during stalls |
| Completion/reset | Eight output transfers per lane/job, return to activation-ready idle, no extra output transfers, output valid/data cleared on reset |
| Clean copy on a case-sensitive Linux filesystem, in a path containing spaces, launched from another directory | Default command passed again; no original build directory, Git metadata or host-specific test paths required |
| Documented alternate command, seed 17, one lane, three jobs | 216 LUT/sign cases plus 768 scalar outputs per ready mode passed; 1,278 cycles with continuous ready and 1,418 cycles with delayed ready |

The clean-copy run used the final log-writing runner and parameter-dependent
timeout. Generated inputs, per-compile/per-simulation logs and case metadata are
retained locally under ignored `build/clean-copy/`. The original first run is
under `build/verify/`; the alternate command's logs and generated data are under
`build/single_lane/`. `git diff --check` passed. No original compute/control RTL was modified: the
demonstrated build blocker was repaired by adding the missing memory alternative.

The compiler reports a testbench sensitivity warning for the shared received
counter array. This is an Icarus `wait`-array sensitivity diagnostic; all checked
transactions completed. There were no elaboration errors in the repaired build.

The direct dot-product reference is independent of the RTL's LUT arithmetic and
uses the original unencoded weights. The Python input generator deliberately
implements the existing ternary encoding, and the separate exhaustive arithmetic
bench covers its legal codes. End-to-end comparisons use only activations in
`[-127,127]`, where intermediate widths cannot overflow. Saturation edge tests
describe the original local 16-bit behavior, including minimum-value negation;
they do not establish general int32 matrix-multiplication correctness.

Not run: hosted GitHub Actions, Vivado/vendor-IP equivalence, synthesis,
place-and-route, timing/power characterization, FPGA/silicon execution, the
incomplete legacy MATLAB workflow, and simulation of all 16 default lanes.
The portable inferred memories have no tested read/write-collision contract.
Reset during an active partially loaded/computing transaction is not covered.
Parent verification also reran the two-lane suite after adding known-vector
checks and a simulator PASS/error gate; all checks passed again. These prevent
unread or unknown expected values from being accepted as numerical evidence.

An independent verifier inspected the original data/control path, inferred SRAM
ports/latency, packing and arithmetic reference, and reran the canonical two-lane
suite successfully (216 LUT cases and 1,536 outputs per ready mode). No blocking
issue was found. A separate 16-lane/one-job attempt exceeded the runner's bounded
120-second compilation limit before simulation. This is a resource limit, not a
demonstrated numerical failure; the default sixteen-lane simulation remains
unverified. Its partial build was retained under ignored
`build/independent-default16/`; no compiler process remained running.
