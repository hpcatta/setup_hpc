#!/bin/bash

# Install required dependencies
sudo apt update
sudo apt install -y gcc gfortran make libopenblas-dev

# Download and compile STREAM benchmark
wget https://www.cs.virginia.edu/stream/FTP/Code/stream.c
gcc -O2 -fopenmp -DNTIMES=10 -DSTREAM_ARRAY_SIZE=50000000 stream.c -o stream -lm
mv stream ~/stream_benchmark

# For HPL, assuming you have a precompiled binary and input file named `HPL.dat` in your home directory

# Create Slurm job scripts

# STREAM Slurm job script
cat <<EOF > ~/stream_slurm_job.sh
#!/bin/bash
#SBATCH --job-name=stream_benchmark
#SBATCH --output=stream_output.txt

~/stream_benchmark
EOF
