import cupy as cp
import numpy as np

# Create two random vectors on the CPU using NumPy
a_cpu = np.random.random(1000000)
b_cpu = np.random.random(1000000)

# Transfer data from CPU (NumPy array) to GPU (CuPy array)
a_gpu = cp.array(a_cpu)
b_gpu = cp.array(b_cpu)

# Perform vector addition on GPU
c_gpu = a_gpu + b_gpu

# Transfer result back to CPU if needed
c_cpu = cp.asnumpy(c_gpu)

# Validate results
assert np.allclose(a_cpu + b_cpu, c_cpu)

print("Vector addition successful!")

