#!/bin/bash

#SBATCH --job-name=Siopt
#SBATCH --output=cluster_output/Siopt%j.out
#SBATCH --error=cluster_output/Siopt%j.err
#SBATCH --time=20:00:00
#SBATCH --nodes=1
#SBATCH --mem=64GB

# Note: This file is specific to Sophie Hines' WHOI HPC cluster directory structure.
# You will likely need to ensure Julia is available and
# edit the paths to access Julia and the GNOM code

# Load the julia module
module load julia

# Cd to the root folder
cd /vortexfs1/home/shines/GNOM

# Optimize it!
julia src/Si_model/setup_and_optimization.jl
