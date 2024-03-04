import os
import time
import torch
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP

class SimpleModel(torch.nn.Module):
    def __init__(self, size):
        super(SimpleModel, self).__init__()
        self.linear = torch.nn.Linear(size, size)

    def forward(self, x):
        return self.linear(x)

def setup(rank, world_size):
    os.environ['MASTER_ADDR'] = '10.0.0.2'  # Use the actual IP address
    os.environ['MASTER_PORT'] = '12355'
    dist.init_process_group("nccl", rank=rank, world_size=world_size)

def cleanup():
    dist.destroy_process_group()

def run(rank, world_size):
    print(f"Running on rank {rank}.")
    setup(rank, world_size)

    # Use LOCAL_RANK to select the GPU
    local_rank = int(os.getenv('LOCAL_RANK', '0'))

    # Ensure operations are performed on the correct device
    device = torch.device(f"cuda:{local_rank}")
    torch.cuda.set_device(device)

    # Initialize model and wrap it with DDP
    size = 5000  # Size of the matrix
    model = SimpleModel(size).to(device)
    model = DDP(model, device_ids=[local_rank])

    # Generate random input data
    inputs = torch.randn(size, size, device=device)

    # Start timer
    start_time = time.time()

    # Perform forward pass (matrix multiplication in this case)
    outputs = model(inputs)

    # End timer
    end_time = time.time() - start_time

    # Aggregate computation times from all ranks
    total_time = torch.tensor(end_time, device=device)
    dist.reduce(total_time, dst=0, op=dist.ReduceOp.MAX)

    if rank == 0:
        # Rank 0 will have the total time after reduction
        print(f"Total computation time: {total_time.item():.2f} seconds")

    cleanup()

def main():
    world_size = 2  # Adjust this based on the total number of processes across all nodes
    rank = int(os.getenv('RANK', '0'))  # Use RANK for global rank

    run(rank, world_size)

if __name__ == "__main__":
    main()

