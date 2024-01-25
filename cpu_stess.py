import multiprocessing
import math

def cpu_intensive_task():
    while True:
        math.factorial(10000)

if __name__ == "__main__":
    # Number of CPUs on the node
    num_cpus = multiprocessing.cpu_count()

    processes = []
    for _ in range(num_cpus):
        p = multiprocessing.Process(target=cpu_intensive_task)
        p.start()
        processes.append(p)

    for process in processes:
        process.join()

