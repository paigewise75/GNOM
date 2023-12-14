#!/bin/bash

#SBATCH --job-name=Ndopt
#SBATCH --output=GNOM/cluster_output/Ndopt%j.out
#SBATCH --error=GNOM/cluster_output/Ndopt%j.err
#SBATCH --time=30:00:00
#SBATCH --account=sethjohn_760
#SBATCH --nodes=1
#SBATCH --mem=64GB
#SBATCH --partition=main


# Load the julia module
module purge
module load julia/1.9.0

# Cd to the root folder
cd /home1/pmwise/GNOM_Project/GNOM

# Optimize it!
julia --heap-size-hint=24G /home1/pmwise/GNOM_Project/GNOM/src/Nd_model/setup_and_optimization.jl