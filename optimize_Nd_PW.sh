#!/bin/bash
#SBATCH --account=sethjohn_760
#SBATCH --job-name=Ndopt
#SBATCH --output=GNOM/cluster_output/Ndopt%j.out
#SBATCH --error=GNOM/cluster_output/Ndopt%j.err
#SBATCH --time=30:00:00
#SBATCH --nodes=1
#SBATCH --mem=40GB
#SBATCH --partition=main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

module purge
module load julia/1.9.0

cd /scratch1/pmwise/GNOM
julia --heap-size-hint=24G src/Nd_model/setup_and_optimization.jl