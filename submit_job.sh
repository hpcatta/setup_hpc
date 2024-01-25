#!/bin/bash
#SBATCH --job-name=mpi_stress_test
#SBATCH --output=mpi_out_%j.txt
#SBATCH --nodes=4            # Adjust the number of nodes
#SBATCH --ntasks-per-node=1  # Assuming 1 task per node
#SBATCH --cpus-per-task=64  # Assuming 1 task per node
#SBATCH --time=00:10:00      # Maximum run time

#module load mpi  # Load the MPI module, adjust as per your HPC environment

/usr/bin/mpirun python /data/setup_hpc/mpi_script.py

