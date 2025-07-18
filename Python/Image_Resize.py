from PIL import Image

image = Image.open("image.jpg")

resized_image = image.resize((512, 512), Image.BICUBIC)

resized_image.save("image_512_512.bmp")
