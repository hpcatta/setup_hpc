import tensorflow as tf

print("=== TensorFlow ===")

if tf.config.list_physical_devices('GPU'):
    print("GPU is available for TensorFlow!")
else:
    print("GPU is not available for TensorFlow. The following code will run on CPU.")

# Create two random matrices
A_tf = tf.random.normal([1000, 1000])
B_tf = tf.random.normal([1000, 1000])

# Matrix multiplication
C_tf = tf.matmul(A_tf, B_tf)
print("TensorFlow matrix multiplication complete!")

