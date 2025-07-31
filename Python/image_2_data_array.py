from PIL import Image
import numpy as np

# Input and output file paths
INPUT_IMAGE = "input_image.bmp"
OUTPUT_HEADER = "ImageData_RGB.h"

# Image dimensions
WIDTH = 512
HEIGHT = 512

# Load image using PIL and ensure it's in RGB mode
img = Image.open(INPUT_IMAGE).convert("RGB")
img = img.resize((WIDTH, HEIGHT))  # Enforce correct size

# Convert to numpy array and reshape
img_np = np.array(img).astype(np.uint8)  # Shape: (512, 512, 3)

# Flatten to 1D array: [R, G, B, R, G, B, ...]
flat_rgb = img_np.reshape(-1, 3)

# Open header file for writing
with open(OUTPUT_HEADER, "w") as f:
    f.write("#ifndef IMAGE_DATA_H\n#define IMAGE_DATA_H\n\n")
    f.write("#include \"xil_types.h\"\n\n")
    f.write(f"#define IMAGE_WIDTH {WIDTH}\n")
    f.write(f"#define IMAGE_HEIGHT {HEIGHT}\n\n")
    f.write(f"const u8 imageData[{WIDTH * HEIGHT * 3}] = {{\n")

    # Write RGB values in formatted blocks
    values_per_line = 12  # 12 RGB values (i.e., 36 bytes)
    for i, pixel in enumerate(flat_rgb):
        r, g, b = pixel
        f.write(f"{r}, {g}, {b}, ")
        if (i + 1) % values_per_line == 0:
            f.write("\n")

    f.write("\n};\n\n#endif // IMAGE_DATA_H\n")

print(f"Header file '{OUTPUT_HEADER}' successfully generated.")
