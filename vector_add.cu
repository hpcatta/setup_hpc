#include <iostream>
#include <cuda_runtime.h>

const int N = 1 << 20; // 1 million elements

__global__ void vector_add(float *out, float *a, float *b, int n) {
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;
    for(int i = index; i < n; i += stride) {
        out[i] = a[i] + b[i];
    }
}

int main() {
    float *a, *b, *out;
    float *d_a, *d_b, *d_out;

    // Allocate memory on CPU
    a = new float[N];
    b = new float[N];
    out = new float[N];

    // Initialize arrays
    for(int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i;
    }

    // Allocate memory on GPU
    cudaMalloc((void**)&d_a, sizeof(float) * N);
    cudaMalloc((void**)&d_b, sizeof(float) * N);
    cudaMalloc((void**)&d_out, sizeof(float) * N);

    // Copy data from CPU to GPU
    cudaMemcpy(d_a, a, sizeof(float) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeof(float) * N, cudaMemcpyHostToDevice);

    // Launch kernel
    vector_add<<<(N + 255) / 256, 256>>>(d_out, d_a, d_b, N);

    // Copy results back to CPU
    cudaMemcpy(out, d_out, sizeof(float) * N, cudaMemcpyDeviceToHost);

    // Free GPU memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_out);

    // Check results
    for(int i = 0; i < N; i++) {
        if(a[i] + b[i] != out[i]) {
            std::cerr << "Error: " << a[i] + b[i] << " != " << out[i] << std::endl;
            delete[] a;
            delete[] b;
            delete[] out;
            return -1;
        }
    }

    std::cout << "Vector addition successful!" << std::endl;

    delete[] a;
    delete[] b;
    delete[] out;

    return 0;
}

