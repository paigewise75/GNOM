#!/bin/bash

#SBATCH --job-name=Ndopt
#SBATCH --output=cluster_output/Ndopt%j.out
#SBATCH --error=cluster_output/Ndopt%j.err
#SBATCH --time=40:00:00
#SBATCH --nodes=1
#SBATCH --mem=64GB


# Load the julia module
module purge
module load julia/1.9.0

# Cd to the root folder
cd /scratch1/pmwise/GNOM

# Optimize it!
julia --heap-size-hint=24G src/Nd_model/setup_and_optimization.jl