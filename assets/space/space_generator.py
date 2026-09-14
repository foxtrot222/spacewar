from PIL import Image

import matplotlib.pyplot as plt
import numpy as np

np.random.seed(2500)
size = 1024 # size x size image
empty = 0.99975 # how much empty space
img = np.random.choice([0,1], size=(size,size), p=[empty, 1 - empty])
plt.imsave("space_background.png", img, cmap="gray")
