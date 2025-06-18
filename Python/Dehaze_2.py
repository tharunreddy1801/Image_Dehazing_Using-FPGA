import numpy as np
import matplotlib.pyplot as plt

def get_dark_channel(img, patch_size):
    h, w, _ = img.shape
    dark_channel = np.zeros((h, w), dtype=np.uint8)
    offset = patch_size // 2

    for i in range(offset, h - offset):
        for j in range(offset, w - offset):
            dark_channel[i, j] = np.min(img[i - offset:i + offset + 1, j - offset:j + offset + 1])

    return dark_channel


def estimate_atmospheric_light(img, dark_channel):
    h, w = dark_channel.shape
    num_pixels = h * w
    top_pixels = max(1, num_pixels // 1000)  # Approximate 0.1%

    flat_dark = dark_channel.flatten()
    indices = np.argsort(flat_dark)[-top_pixels:]

    flat_img = img.reshape((-1, 3))
    A = np.max(flat_img[indices], axis=0)
    return A


def guided_filter(I, p, r, eps):
    h, w = I.shape
    mean_I = np.zeros((h, w), dtype=np.uint8)
    mean_p = np.zeros((h, w), dtype=np.uint8)
    var_I = np.zeros((h, w), dtype=np.uint8)
    cov_Ip = np.zeros((h, w), dtype=np.uint8)

    for i in range(r, h - r):
        for j in range(r, w - r):
            region_I = I[i - r:i + r + 1, j - r:j + r + 1]
            region_p = p[i - r:i + r + 1, j - r:j + r + 1]
            mean_I[i, j] = np.mean(region_I)
            mean_p[i, j] = np.mean(region_p)
            var_I[i, j] = np.mean(region_I ** 2) - mean_I[i, j] ** 2
            cov_Ip[i, j] = np.mean(region_I * region_p) - mean_I[i, j] * mean_p[i, j]

    a = cov_Ip // (var_I + eps)
    b = mean_p - a * mean_I
    mean_a = np.zeros((h, w), dtype=np.uint8)
    mean_b = np.zeros((h, w), dtype=np.uint8)

    for i in range(r, h - r):
        for j in range(r, w - r):
            mean_a[i, j] = np.mean(a[i - r:i + r + 1, j - r:j + r + 1])
            mean_b[i, j] = np.mean(b[i - r:i + r + 1, j - r:j + r + 1])

    return mean_a * I + mean_b


def dehaze_image(hazy_img, patch_size=15, omega=230, t0=25, r=30, eps=1):
    dark_channel = get_dark_channel(hazy_img, patch_size)
    A = estimate_atmospheric_light(hazy_img, dark_channel)

    raw_transmission = 255 - (omega * dark_channel // 255)
    gray_img = (hazy_img[:, :, 0] * 76 + hazy_img[:, :, 1] * 150 + hazy_img[:, :, 2] * 29) // 255
    refined_transmission = guided_filter(gray_img, raw_transmission, r, eps)

    refined_transmission = np.maximum(refined_transmission, t0)
    dehazed_img = np.zeros_like(hazy_img, dtype=np.uint8)

    for c in range(3):
        dehazed_img[:, :, c] = ((hazy_img[:, :, c] - A[c]) * 255 // refined_transmission) + A[c]

    return np.clip(dehazed_img, 0, 255)


# Load the hazy image
hazy_img = np.random.randint(0, 256, (480, 640, 3), dtype=np.uint8)  # Example fixed-size image

dehaized_img = dehaze_image(hazy_img)
plt.imshow(dehaized_img)
plt.title("Dehazed Image")
plt.axis("off")

plt.show()
