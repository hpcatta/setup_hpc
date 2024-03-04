import os
import torch
import torch.distributed as dist
from torch.multiprocessing import Process

def setup(rank, world_size):
    os.environ['MASTER_ADDR'] = 'master_node_hostname_or_ip'
    os.environ['MASTER_PORT'] = '12355'
    dist.init_process_group("nccl", rank=rank, world_size=world_size)

def cleanup():
    dist.destroy_process_group()

def run(rank, world_size):
    print(f"Running basic DDP example on rank {rank}.")
    setup(rank, world_size)

    # Create a tensor and perform a simple computation
    tensor = torch.zeros(1).cuda(rank)
    tensor += 1
    print(f"Rank {rank} has tensor {tensor}")

    cleanup()

def main():
    world_size = 4  # Adjust this to the total number of GPUs across all nodes
    processes = []

    for rank in range(world_size):
        p = Process(target=run, args=(rank, world_size))
        p.start()
        processes.append(p)

    for p in processes:
        p.join()

if __name__ == "__main__":
    main()

