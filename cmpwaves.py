import numpy as np
import matplotlib.pyplot as plt

# ---------- helpers ----------
def hex_twos_to_int(h: str, bits: int) -> int:
    """Hex string -> signed int (two's complement) with given bit width."""
    h = h.strip().lower().replace("0x", "")
    if not h:
        raise ValueError("empty token")
    v = int(h, 16)
    sign = 1 << (bits - 1)
    if v & sign:
        v -= 1 << bits
    return v

def read_hex_file(path: str, bits: int) -> np.ndarray:
    vals = []
    with open(path, "r") as f:
        for line in f:
            s = line.strip()
            if s:
                vals.append(hex_twos_to_int(s, bits))
    return np.array(vals, dtype=np.int32)

INPUT_FILE  = "./dat_files/input.dat"
OUTPUT_FILE = "./dat_files/output_32taps.dat"

INPUT_BITS  = 8             
OUTPUT_BITS = 17       

# If you know your FIR DC gain (sum of taps), put it here.
# Example: 4 taps each = 32  => gain = 128
TAP_SUM = None                    # set to None to auto-scale by peak

# ---------- load ----------
x = read_hex_file(INPUT_FILE, INPUT_BITS)
y = read_hex_file(OUTPUT_FILE, OUTPUT_BITS)

n = min(len(x), len(y))
x = x[:n]
y = y[:n]

# ---------- scale output for visualization ----------
if TAP_SUM is not None:
    y_plot = y / float(TAP_SUM)
else:
    y_plot = y * (np.max(np.abs(x)) / (np.max(np.abs(y)) + 1e-12))

# ---------- plot ----------
t = np.arange(n)

plt.figure()
plt.plot(t, x, label="input (int8 decoded)")
plt.plot(t, y_plot, label="output (scaled)", linewidth=2)
plt.title("FIR smoothing: input vs output")
plt.xlabel("sample")
plt.ylabel("amplitude")
plt.grid(True)
plt.legend()
plt.show()