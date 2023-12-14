#!/bin/bash

#SBATCH --job-name=sensitivity
#SBATCH --output=cluster_output/sensitivity%j.out
#SBATCH --error=cluster_output/sensitivity%j.err
#SBATCH --time=40:00:00
#SBATCH --nodes=1
#SBATCH --mem=64GB


# Load the julia module
module purge
module load julia/1.9.0

# Cd to the root folder
cd /scratch1/pmwise/GNOM

# Run sensitivity test!
julia --heap-size-hint=24G src/Nd_model/sensitivity_and_plot.jl