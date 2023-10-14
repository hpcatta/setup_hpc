#!/bin/bash

#SBATCH --job-name=mpi_hello_world
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:05:00
#SBATCH --output=mpi_hello_world_output.txt

srun ./hello_mpi

