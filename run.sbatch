#!/bin/bash
#SBATCH --job-name=verilator-starter
#SBATCH --partition=general
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --output=slurm-%j.out
set -eo pipefail

# Submit from the repository root. Slurm runs a copy of this script elsewhere,
# so use SLURM_SUBMIT_DIR rather than the script's own location.
cd "$SLURM_SUBMIT_DIR"
# This loads the installed Spack view quickly, without indexing recipes.
source ~/169291/verilator/activate.sh
bash run.sh "${1:-adder}"
