#!/bin/bash
#SBATCH --account=sethjohn_760
#SBATCH --job-name=Nd_single_run
#SBATCH --output=GNOM/cluster_output/Nd_single_run%j.out
#SBATCH --error=GNOM/cluster_output/Nd_single_run%j.err
#SBATCH --time=20:00:00
#SBATCH --nodes=1
#SBATCH --mem=40GB
#SBATCH --partition=main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

module purge
module load julia/1.9.0

cd /scratch1/pmwise/GNOM

julia src/Nd_model/single_run_mismatch.jl
