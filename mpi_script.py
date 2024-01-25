from mpi4py import MPI
import numpy as np
import time

def compute_sum_of_squares(n, rank, size):
    # Divide the workload among processes
    elements_per_process = n // size

    # Determine the start and end indices for each process
    start = rank * elements_per_process
    end = start + elements_per_process

    # Each process calculates its partial sum
    partial_sum = np.sum(np.square(np.arange(start, end)))

    # Gather all partial sums to the root process
    total_sum = comm.reduce(partial_sum, op=MPI.SUM, root=0)
    
    if rank == 0:
        print(f"Total sum of squares: {total_sum}")

if __name__ == "__main__":
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    n = 100000000  # Total number of elements

    start_time = time.time()
    compute_sum_of_squares(n, rank, size)
    end_time = time.time()

    if rank == 0:
        print(f"Completed in {end_time - start_time:.2f} seconds using {size} processes.")

