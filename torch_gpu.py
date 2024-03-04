import torch

# Check if CUDA (GPU support) is available with PyTorch
if torch.cuda.is_available():
    print("CUDA (GPU support) is available and enabled!")
    device = torch.device("cuda")  # Use the first GPU available
    print(f"Using GPU: {torch.cuda.get_device_name(0)}")
else:
    print("CUDA (GPU support) is not available, using CPU instead.")
    device = torch.device("cpu")

# Create a tensor and move it to the selected device (GPU if available, else CPU)
x = torch.tensor([1.0, 2.0, 3.0], device=device)

# Perform a simple computation (e.g., scaling the tensor)
y = x * 2

print(f"Original tensor: {x}")
print(f"Computed tensor: {y}")

# Optionally, if you used the GPU, you can check the device of the tensor
print(f"Tensor device: {y.device}")

