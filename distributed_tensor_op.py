import os
import torch
import torch.distributed as dist

def setup(rank, world_size):
    os.environ['MASTER_ADDR'] = '10.0.0.2'  # Use the actual IP address
    os.environ['MASTER_PORT'] = '12355'
    dist.init_process_group("nccl", rank=rank, world_size=world_size)

def cleanup():
    dist.destroy_process_group()

def run(rank, world_size):
    print(f"Running basic DDP example on rank {rank}.")
    setup(rank, world_size)

    # Use LOCAL_RANK to select the GPU
    local_rank = int(os.getenv('LOCAL_RANK', '0'))

    # Ensure tensor operations are performed on the correct device
    device = torch.device(f"cuda:{local_rank}")
    tensor = torch.zeros(1, device=device)
    tensor += 1
    print(f"Rank {rank}, local rank {local_rank}, has tensor {tensor}")

    cleanup()

def main():
    world_size = 2  # Adjust based on the total number of processes across all nodes
    rank = int(os.getenv('RANK', '0'))  # Use RANK for global rank, set by torch.distributed.launch or torchrun

    run(rank, world_size)

if __name__ == "__main__":
    main()

