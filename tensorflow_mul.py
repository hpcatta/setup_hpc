import tensorflow as tf

# Check if GPU is available
if tf.config.list_physical_devices('GPU'):
    print("GPU is available!")
else:
    print("GPU is not available. The following code will run on CPU.")

# Create two random matrices
A = tf.random.normal([1000, 1000])
B = tf.random.normal([1000, 1000])

# Matrix multiplication
C = tf.matmul(A, B)

# Run a TensorFlow session to perform the multiplication
with tf.compat.v1.Session() as sess:
    result = sess.run(C)

print("Matrix multiplication complete!")

