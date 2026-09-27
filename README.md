# RISC-V CPU

A personal project to learn CPU design with Verilog. It's a simple single-cycle
32-bit RISC-V CPU, with separate instruction and data memories.

The core supports integer arithmetic, logic, shifts, branches, `jal`/`jalr`,
`lui`/`auipc`, and word loads and stores (`lw`/`sw`). It implements a subset of
RV32I: byte and half-word memory accesses, system instructions, and `fence`
aren't supported. There is no pipeline, cache, or interrupt handling.

## Running it

Install Icarus Verilog (`iverilog` and `vvp`) and Python 3, then run:

```sh
make test
```

This runs five module testbenches and three CPU programs. Each testbench prints
`RESULT: PASS` or a failure message. Individual tests can also be run with
`make test-alu`, `make test-pc`, or `make test-cpu`.

The CPU programs cover arithmetic, a loop that sums 1 through 10, memory
accesses, and jumps. These are basic simulation checks; the core hasn't been
validated with a full ISA compliance suite.

## Files

- `rtl/` — CPU modules, with `riscv_cpu.v` as the top level
- `testbench/` — testbenches and small assembly programs
- `tools/assemble.py` — assembler for the supported instructions
- `docs/notes.md` — design and simulation notes
- `diagrams/` — datapath diagram

To assemble a program after editing it:

```sh
make asm SRC=testbench/programs/test_loop.s
make test-cpu
```

Build output goes in `build/`. Use `make clean` to remove it.
