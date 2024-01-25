from mpi4py import MPI
import time
import random

def monte_carlo_pi(num_samples, rank):
    inside_circle = 0
    for _ in range(num_samples):
        x, y = random.random(), random.random()
        if x**2 + y**2 <= 1.0:
            inside_circle += 1
    print(f"Process {rank}: Number of points inside circle = {inside_circle}", flush=True)
    return inside_circle

if __name__ == "__main__":
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    samples_per_process = 10000000  # Adjust this to increase computational workload

    comm.Barrier()  # Synchronize processes

    start_time = time.time()

    # Each process performs its part of the Monte Carlo simulation
    inside_circle_count = monte_carlo_pi(samples_per_process, rank)

    comm.Barrier()  # Synchronize processes

    if rank == 0:
        print("Starting reduction operation", flush=True)

    # Sum up the results from all processes
    total_inside_circle = comm.reduce(inside_circle_count, op=MPI.SUM, root=0)

    if rank == 0:
        pi_estimate = (4 * total_inside_circle) / (size * samples_per_process)
        end_time = time.time()
        print(f"Pi Estimate: {pi_estimate}", flush=True)
        print(f"Total time: {end_time - start_time:.2f} seconds with {size} processes", flush=True)

    comm.Barrier()  # Synchronize processes

