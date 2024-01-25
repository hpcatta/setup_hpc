from mpi4py import MPI
import time

def compute_sum_of_squares(start, end, rank):
    # Debugging: Starting computation
    print(f"Process {rank}: Starting computation for range {start} to {end}")
    total = 0
    for i in range(start, end):
        total += i * i
    # Debugging: Finished computation
    print(f"Process {rank}: Finished computation. Partial sum is {total}")
    return total

if __name__ == "__main__":
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    # Debugging: Process starting
    print(f"Process {rank}: Starting with {size} total processes")

    base_n = 50000000  # Base workload for a single process
    n = base_n * size  # Scale workload with the number of processes

    elements_per_process = n // size
    start = rank * elements_per_process
    end = start + elements_per_process

    start_time = time.time()
    partial_sum = compute_sum_of_squares(start, end, rank)

    # Debugging: Starting reduction
    if rank == 0:
        print(f"Process {rank}: Starting reduction operation")

    total_sum = comm.reduce(partial_sum, op=MPI.SUM, root=0)

    if rank == 0:
        print(f"Process {rank}: Finished reduction operation")
        end_time = time.time()
        print(f"Total sum of squares: {total_sum}")
        print(f"Completed in {end_time - start_time:.2f} seconds using {size} processes.")

