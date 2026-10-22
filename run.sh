#!/usr/bin/env bash
# Run from a Slurm allocation; generated C++ and binaries stay in build/.
set -euo pipefail
cd "$(dirname "$0")"
example=${1:-adder}
jobs=${SLURM_CPUS_PER_TASK:-2}
command -v verilator >/dev/null || {
  echo 'Load the course Verilator environment first; see README.md.' >&2
  exit 1
}
verilator --version
mkdir -p build
case "$example" in
  smoke)
    verilator --binary --top-module smoke -j "$jobs" \
      --Mdir build/smoke smoke.sv
    ./build/smoke/Vsmoke
    ;;
  adder)
    # --binary generates a C++ main and builds the executable.
    # --timing enables the testbench's #1 simulation delay.
    verilator --binary --timing --timescale 1ns/1ps --top-module tb_adder \
      -Wall -j "$jobs" --Mdir build/adder rtl/adder.sv tb/tb_adder.sv
    ./build/adder/Vtb_adder
    ;;
  *) echo "Usage: bash run.sh [smoke|adder]" >&2; exit 2 ;;
esac
