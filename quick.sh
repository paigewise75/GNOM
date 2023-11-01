#!/bin/bash
#SBATCH --account=sethjohn_760
#SBATCH --job-name=quick
#SBATCH --output=GNOM/cluster_output/quick%j.out
#SBATCH --error=GNOM/cluster_output/quick%j.err
#SBATCH --time=20:00:00
#SBATCH --nodes=1
#SBATCH --mem=40GB
#SBATCH --partition=main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

module purge
module load julia/1.9.0

cd /scratch1/pmwise/GNOM

julia src/Nd_model/quick.jl