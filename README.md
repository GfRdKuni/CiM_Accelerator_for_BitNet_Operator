# CiM Accelerator for the BitNet Operator

Verilog implementation of a LUT-based ternary-weight matrix/vector operator.
`Top` computes a fixed `(256 x 96) x (96 x 1)` operation. `Para_Top` instantiates
independent lanes (default 16), permitting multiple activation vectors and weight
matrices. Activation quantization, scaling and a BitNet inference runtime are
outside the RTL interface.

The design retains its banked activation/weight storage, eight precomputation
groups reused by 32 output rows, hierarchical LUT selection, separate positive
and negative magnitude adder trees, and four-step accumulation. It is a digital
RTL model inspired by compute-in-memory techniques; this repository does not
provide a characterized SRAM compute macro or physical power/timing evidence.

## Run the portable verification

Requirements: Python 3.9+ and Icarus Verilog 11+ (`iverilog` and `vvp` on `PATH`).
No Python packages, MATLAB installation, Vivado project or downloaded data are
required for this path. From the repository root, on Linux, macOS with Icarus,
Windows with Icarus on `PATH`, or WSL:

```sh
python3 Scripts/verify.py
```

Use `python` instead of `python3` if that is your Python executable. On Ubuntu,
the simulator can be installed with `sudo apt-get install iverilog`.

The runner creates deterministic inputs and direct integer dot-product reference
results under `build/verify/`, compiles the complete public top including portable
memories, and runs checks that fail with a nonzero exit status on mismatch or
timeout:

- all 27 ternary triples across eight activation triples, including LUT saturation
  and enabled-register hold (216 arithmetic cases);
- two independent `Para_Top` lanes, three transactions per lane without reset,
  mixed signed data, zero weights and activation extrema in `[-127,127]`;
- every one of 1,536 matrix outputs against the original unencoded weights;
- both continuously asserted output ready and delayed ready, input gaps, stable
  results during backpressure, return to idle and output reset.

Alternative runs and generated-input locations:

```sh
python3 Scripts/verify.py --seed 17 --lanes 1 --jobs 3 --out build/single_lane
```

`IVERILOG`, `VVP` and optional `IVERILOG_LIBDIR` select non-default tool binaries
and the Icarus backend directory. The explicit source manifest is
[`sim/sources.f`](sim/sources.f). The same command is configured in
[the verification workflow](.github/workflows/verify.yml); local results do not
imply that hosted CI has run.

## Public interface and packing

All transfers occur on the rising clock edge when that stream's `valid` and
`ready` are both high. Keep valid and data stable until acceptance. Reset
`rst_n_i` is active low and asynchronously clears the controller and datapath
registers. Memory contents are uninitialized; a complete load is required before
computation after reset.

For each lane, one operation uses three sequential load phases:

| Phase | Accepted 256-bit beats | Packing, from least significant bits |
| --- | ---: | --- |
| Activation | 12 | Eight consecutive signed 32-bit activations per beat, in increasing K order |
| Weight magnitude | 128 | Output row block (8), K block (4), then memory bank (4). Each beat holds eight rows, eight 4-bit triple codes per row |
| Weight sign | 32 | Output row block (8), K block (4). Each beat holds 32 rows, eight sign bits per row |

Only the stream for the current phase is ready. Weights represent 256 output
rows and 96 K elements. Each ternary triple is encoded as a low four-bit LUT code
and a high sign bit; [`Scripts/encode_ternary_matrix.m`](Scripts/encode_ternary_matrix.m)
and [`Scripts/verify.py`](Scripts/verify.py) contain the matching mapping.
Codes 11 and 12 are unused; callers must supply valid ternary encodings.

After loading, `valid_out_o` accompanies eight result transfers. Transfer `b`
contains matrix rows `32*b` through `32*b+31` on `result_0_o` through
`result_31_o`, respectively. Each result is a signed 32-bit two's-complement
value. Output data and valid hold during backpressure. After the eighth output
is accepted, the activation input becomes ready for the next complete operation.
No separate start or completion input is needed. Every operation reloads all
three input memories. In `Para_Top`, lane `i` uses input slice `i*256 +: 256`,
result slice `i*32 +: 32` and handshake bit `i`.

## Numerical and memory boundaries

The intended verification domain is signed quantized activations `[-127,127]`
and weights `{-1,0,+1}`. A 24-term tile then has magnitude at most 3,048, and
a 96-term result at most 12,192, so the original 16-bit intermediate datapath
does not overflow in this domain.

For larger inputs, the precomputation arithmetic uses 32-bit operations, LUT
selection saturates to signed 16 bits, the sign operation has 16-bit wraparound,
and both reduction trees retain only 16 bits before sign extension into the
32-bit accumulator. For example, negating the saturated value -32,768 remains
-32,768 in the 16-bit sign stage. General int32 matrix multiplication and
saturating end-to-end accumulation are not supported contracts.

[`src/portable/SRAM.v`](src/portable/SRAM.v) supplies synthesizable inferred
alternatives for the two missing vendor-generated memory blocks. Read data is
registered on `enb`, then copied into the output register on `regceb` at the
following rising edge. Output and internal read registers hold when their
respective enables are low. This latency matches the existing control schedule.
Read/write same-address collisions are outside the contract; the controller
separates loading from computation. No vendor-IP equivalence, RAM inference for
a particular device, synthesis, place-and-route, or FPGA execution is claimed.
Select either these portable definitions or vendor IP with the same module
names, never both in the same build.

## Repository and design history

| Path | Purpose |
| --- | --- |
| `src/` | Original controller, LUT datapath, dual adder trees, accumulator and parallel wrapper |
| `src/portable/` | Portable memory alternative for open-source simulation/inference |
| `sim/tb_portable.sv`, `sim/tb_lut.sv` | Self-checking portable benches |
| `sim/tb_top.sv` | Historical Vivado/file-logging bench, with original local paths |
| `Scripts/verify.py` | Standard-library data packing, independent reference and simulator runner |
| `Scripts/` | Preserved MATLAB generators, historical hex inputs and output log |
| `docs/` | Original presentation, original README, rehabilitation record and revision log |

The original explanation, diagrams and reported architectural motivations are
preserved in [`docs/README_original.md`](docs/README_original.md). The original
presentation is [`docs/BITNET&存算一体.pptx`](docs/BITNET%26%E5%AD%98%E7%AE%97%E4%B8%80%E4%BD%93.pptx).
Original area/power/critical-path benefits remain design motivations, not measured
results established by this verification.

The legacy MATLAB flow is incomplete in this checkout: it references absent
`mynum2bin`, `bin2hexstr`, `logToMatrix` and `areMatricesEqual` helpers. The legacy
testbench also embeds a developer-specific input path. These historical files
are retained; use the portable verification command above for a repeatable run.

No license file was present in the baseline. This rehabilitation does not assign
a new license or alter the original author's attribution. Third-party media and
BitNet references retain their respective rights.

See [the revision log](docs/revisions.md) and
[the verification record](docs/engineering-review.md) for executed evidence and
remaining limits.
