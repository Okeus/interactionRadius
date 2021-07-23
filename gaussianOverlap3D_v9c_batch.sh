#!/bin/sh
#SBATCH --tasks 1
#SBATCH --cpus-per-task 8
#SBATCH --partition shared-cpu
#SBATCH --time 600:00
#SBATCH --mem-per-cpu=5000

module load foss/2020a matlab/2019b CUDA

BASE_MFILE_NAME=gaussianOverlap3D_v9c_batch
echo "Running ${BASE_MFILE_NAME}.m on ${hostname}"
srun ./gaussianOverlap3D_v9c_batch
