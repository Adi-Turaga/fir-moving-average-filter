import numpy as np
import matplotlib.pyplot as plt

num_samples = 300
t = np.arange(num_samples)

freq = np.random.uniform(0.02, 0.25)
phase = np.random.uniform(0, 2*np.pi)
amplitude = np.random.uniform(0.5, 1.0)

raw_signal = amplitude * np.sin(2 * np.pi * freq * t + phase)
noisy_signal = raw_signal + 1 * np.random.rand(len(t))

# transform into int8 samples
signal_int8 = np.round(noisy_signal * 127).astype(np.int8)


plt.plot(signal_int8)
plt.plot(noisy_signal)
plt.show()

with open('input.dat', 'w') as file:
    for number in signal_int8:
        file.write(f"{np.uint8(number):02x}\n")