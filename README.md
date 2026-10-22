# CS2470 Verilator starter

Compile SystemVerilog into a C++ simulation with **Verilator 5.050** on HUIT
Open OnDemand. Simulate a small adder with a self-checking testbench. No GPU or personal software installation
is required.

## 1. Connect to the cluster

Connect to the Harvard VPN, then run this **on your laptop**, replacing
`YOUR_NETID` with your OOD username:

```bash
ssh YOUR_NETID@login.ood.huit.harvard.edu
```

If you have not set up SSH keys, follow the
[SSH setup guide](https://github.com/kevinhe5/cs2470-modal-starter/blob/main/HUIT_OOD_SSH_SETUP.md).
If you prefer not to use SSH, open the terminal in the
[HUIT Open OnDemand dashboard](https://ood.huit.harvard.edu/pun/sys/dashboard/)
and continue with the commands below.

All remaining commands run **on the cluster**. Clone into your own home directory:

```bash
cd ~
git clone https://github.com/kevinhe5/cs2470-verilator-starter.git
cd cs2470-verilator-starter
```

## 2. Start an interactive compute session

From the login node, run:

```bash
srun -p general -c 2 --mem=16G --pty bash
cd ~/cs2470-verilator-starter
```

Wait for the compute shell to open, then run the rest of the tutorial there.
This uses the partition’s default time limit. No GPU is needed.

Already in an interactive compute session? Just `cd` into the repo and continue.

## 3. Load Verilator

In your compute shell, run:

```bash
source ~/169291/verilator/activate.sh
```

This loads the course’s installed Verilator. No installation is needed.

## 4. Check Verilator is installed

```bash
verilator --version
```

You should see `Verilator 5.050` followed by build information.

## 5. Compile and simulate the RTL adder

From the repository root in your compute shell:

```bash
mkdir -p build
verilator --binary --timing --timescale 1ns/1ps \
  --top-module tb_adder -Wall -j 2 \
  --Mdir build/adder rtl/adder.sv tb/tb_adder.sv &&
./build/adder/Vtb_adder
```

The `&&` runs the simulation only if compilation succeeds.

This builds and executes the simulation in your current allocation. Expect:

```text
PASS: 19 + 23 = 42
PASS: 0 + 0 = 0
PASS: 255 + 1 = 256
PASS: 255 + 255 = 510
ALL ADDER TESTS PASSED
```

The design has two 8-bit unsigned inputs and a **9-bit output** so it retains the
carry. The testbench drives inputs, waits one simulated nanosecond for the
combinational logic to settle, then checks the result. A mismatch calls `$fatal`
and returns a nonzero exit status; `$finish` ends a successful simulation.

| File | Purpose |
| --- | --- |
| `rtl/adder.sv` | Combinational hardware design |
| `tb/tb_adder.sv` | Self-checking stimulus and expected results |
| `run.sh` | Verilator build and simulation commands |
| `build/` | Generated C++ and simulation binaries; ignored by Git |

The important Verilator options above are:

- `--binary`: generate a C++ main and build a runnable simulator.
- `--timing`: support the testbench's `#1` delay.
- `--timescale 1ns/1ps`: set the default time unit and precision.
- `--top-module tb_adder`: select the testbench as the simulation entry point.
- `-Wall`: enable additional lint warnings. Fix warnings rather than suppressing
  them broadly.
- `-j`: limit build parallelism to the CPUs allocated by Slurm.
- `--Mdir`: choose where generated files go.

## 6. Try a change

Add another `check(...)` call in `tb/tb_adder.sv`, then rerun the compile and simulate commands above.
For example:

```systemverilog
check(8'd100, 8'd200, 9'd300);
```

To see how a failure is reported, temporarily change that expected result to
`9'd301`. The test should print an error and return a nonzero exit status. Run
`echo $?` immediately afterward to see that status; your interactive shell stays
open so you can fix the test and rerun it.
Restore the correct result afterward.

For your own project, replace the RTL and testbench, update the source list and
top-module name in the compile command, and adjust Slurm resources as needed. Run one build
at a time from a checkout: concurrent builds share the same `build/` directory.


## Troubleshooting

- **Missing `~/169291`:** check that you are in the correct course and ask staff
  to confirm your shared-folder access.
- **`verilator: command not found`:** run the activation command from step 3
  in your compute shell.
- **Waiting for a node:** check `squeue -u "$USER"` from another login terminal;
  the allocation may still be pending or configuring.
- **Build or simulation failure:** read the terminal output. The `&&` in the
  compile command prevents a failed build from running an old simulation binary.
- **Cancel a job:** run `scancel JOB_ID`.

References: [HUIT course Spack setup](https://harvard-atg.github.io/huit-ondemand-user-docs/spack-course-shared/),
[HUIT package management](https://harvard-atg.github.io/huit-ondemand-user-docs/package-management/),
[Verilator](https://github.com/verilator/verilator).
