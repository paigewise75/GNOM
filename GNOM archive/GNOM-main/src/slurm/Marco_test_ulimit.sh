#!/bin/bash
#SBATCH --account=sethjohn_760
#SBATCH --job-name=Marco_test
#SBATCH --output=GNOM-main/cluster_output/Ndopt%j.out
#SBATCH --error=GNOM-main/cluster_output/Ndopt%j.err
#SBATCH --time=20:00:00
#SBATCH --nodes=1
#SBATCH --mem=40GB
#SBATCH --partition=main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
ulimit -Sv 32500000
ulimit -Sd 32500000

module purge
module load julia/1.9.0

cd /scratch1/pmwise/GNOM-main

julia -- src/Nd_model/setup_and_optimization.jl
