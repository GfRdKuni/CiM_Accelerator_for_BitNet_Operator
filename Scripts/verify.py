#!/usr/bin/env python3
"""Generate deterministic data and compare real RTL outputs to direct dot products."""

import argparse
import itertools
import os
from pathlib import Path
import random
import shlex
import subprocess

ROOT = Path(__file__).resolve().parents[1]
# Canonical positive-leading ternary triples; high code bit negates the triple.
CODES = {
    (0, 0, 0): 0, (0, 0, 1): 1, (0, 1, 0): 2, (0, 1, 1): 3,
    (1, 0, 0): 4, (1, 0, 1): 5, (1, 1, 0): 6, (0, 1, -1): 7,
    (1, -1, -1): 8, (1, -1, 0): 9, (1, 0, -1): 10,
    (1, -1, 1): 13, (1, 1, -1): 14, (1, 1, 1): 15,
}


def encode(triple):
    triple = tuple(triple)
    if triple in CODES:
        return CODES[triple]
    return 16 | CODES[tuple(-value for value in triple)]


def pack(values, width):
    mask = (1 << width) - 1
    return sum((value & mask) << (width * index)
               for index, value in enumerate(values))


def write_hex(path, values, digits):
    path.write_text("".join(f"{value:0{digits}x}\n" for value in values),
                    encoding="ascii")


def generate(out, seed, lanes, jobs):
    rng = random.Random(seed)
    act_words, wm_words, ws_words, expected = [], [], [], []
    labels = ["mixed", "zero_weights", "mixed_extrema"]
    for job in range(jobs):
        for lane in range(lanes):
            activations = [rng.randint(-127, 127) for _ in range(96)]
            if job % 3 == 2:
                activations = [(-127, 0, 127)[(k + lane) % 3] for k in range(96)]
            weights = [[rng.choice((-1, 0, 1)) for _ in range(96)]
                       for _ in range(256)]
            if job % 3 == 1:
                weights = [[0] * 96 for _ in range(256)]
            codes = [[encode(row[k:k+3]) for k in range(0, 96, 3)]
                     for row in weights]
            act_words.extend(pack(activations[k:k+8], 32)
                             for k in range(0, 96, 8))
            for row_block in range(8):
                for k_block in range(4):
                    block = [codes[row_block*32+row][k_block*8+group]
                             for row in range(32) for group in range(8)]
                    wm_words.extend(pack([code & 15 for code in block[k:k+64]], 4)
                                    for k in range(0, 256, 64))
                    ws_words.append(pack([code >> 4 for code in block], 1))
            # Reference uses original weights, never encoded LUT formulas.
            expected.extend(sum(a*w for a, w in zip(activations, row)) & 0xffffffff
                            for row in weights)
    write_hex(out / "act.hex", act_words, 64)
    write_hex(out / "wm.hex", wm_words, 64)
    write_hex(out / "ws.hex", ws_words, 64)
    write_hex(out / "expected.hex", expected, 8)

    samples = [(0, 0, 0), (3, -5, 7), (-127, 127, -1), (127, -127, 0),
               (32767, 1, -1), (-32768, -1, 1), (20000, 20000, 20000),
               (-20000, -20000, -20000)]
    cases = []
    for acts, triple in itertools.product(samples, itertools.product((-1, 0, 1), repeat=3)):
        code = encode(triple)
        # LUT clips the canonical partial before the separate 16-bit sign step.
        canonical = tuple(-w for w in triple) if code & 16 else triple
        partial = max(-32768, min(32767, sum(a*w for a, w in zip(acts, canonical))))
        result = (-partial if code & 16 else partial) & 0xffff
        cases.append(pack(acts, 32) | (code << 96) | (result << 101))
    write_hex(out / "lut_cases.hex", cases, 30)
    (out / "case_manifest.txt").write_text(
        f"seed={seed}\nlanes={lanes}\njobs={jobs}\n"
        f"job_patterns={','.join(labels[j % 3] for j in range(jobs))}\n"
        f"expected_outputs={lanes * jobs * 256}\nlut_cases={len(cases)}\n",
        encoding="ascii")
    return len(cases)


def run(command, cwd, log, simulation=False):
    print("+ " + shlex.join(str(part) for part in command), flush=True)
    result = subprocess.run(command, cwd=cwd, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, timeout=120)
    log.write_text(result.stdout, encoding="utf-8")
    print(result.stdout, end="", flush=True)
    result.check_returncode()
    if simulation and ('PASS ' not in result.stdout or
                       any(marker in result.stdout for marker in ('ERROR:', 'FATAL:'))):
        raise RuntimeError(f"Simulator did not complete cleanly: {log}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed", type=int, default=20261104)
    parser.add_argument("--lanes", type=int, default=2)
    parser.add_argument("--jobs", type=int, default=3)
    parser.add_argument("--out", type=Path, default=ROOT / "build" / "verify")
    args = parser.parse_args()
    if not 1 <= args.lanes <= 16 or not 1 <= args.jobs <= 20:
        parser.error("--lanes must be 1..16 and --jobs must be 1..20")
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    cases = generate(out, args.seed, args.lanes, args.jobs)
    compiler = [os.environ.get("IVERILOG", "iverilog")]
    if os.environ.get("IVERILOG_LIBDIR"):
        compiler += ["-B", os.environ["IVERILOG_LIBDIR"]]
    sources = [str(ROOT / name.strip()) for name in
               (ROOT / "sim" / "sources.f").read_text().splitlines() if name.strip()]
    for top, params, bench in [
        ("tb_lut", [f"-Ptb_lut.CASES={cases}"], "tb_lut.sv"),
        ("tb_portable", [f"-Ptb_portable.LANES={args.lanes}",
                         f"-Ptb_portable.JOBS={args.jobs}"], "tb_portable.sv"),
    ]:
        executable = out / f"{top}.vvp"
        run(compiler + ["-g2012", "-Wall", "-s", top] + params +
            ["-o", str(executable)] + sources + [str(ROOT / "sim" / bench)],
            ROOT, out / f"{top}_compile.log")
        for stall in ([0, 1] if top == "tb_portable" else [0]):
            run([os.environ.get("VVP", "vvp"), str(executable), f"+STALL={stall}"],
                out, out / f"{top}_stall{stall}.log", simulation=True)
    print(f"PASS: {cases} LUT/sign cases; {args.lanes * args.jobs * 256} "
          "matrix outputs per ready mode; continuous-ready and stalled transactions")


if __name__ == "__main__":
    main()
