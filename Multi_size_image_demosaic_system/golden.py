import sys
import cv2
import numpy as np
import matplotlib.pyplot as plt

def rgb2bayer_image(img, out_dat=0, filename=""):
    height, width, _ = img.shape
    r_ch = np.zeros((height, width), dtype=np.uint8)
    g_ch = np.zeros((height, width), dtype=np.uint8)
    b_ch = np.zeros((height, width), dtype=np.uint8)
    
    for row in range(height):
        for col in range(width):
            if row % 2 == 0:
                if col % 2 == 0:
                    g_ch[row][col] = img[row, col, 1]
                else:
                    r_ch[row][col] = img[row, col, 0]
            else:
                if col % 2 == 0:
                    b_ch[row][col] = img[row, col, 2]
                else:
                    g_ch[row][col] = img[row, col, 1]
                
    image = np.zeros((height, width, 3), dtype=np.uint8)
    image[:, :, 0], image[:, :, 1], image[:, :, 2] = r_ch, g_ch, b_ch   
    
    if out_dat == 1:
        with open(filename, 'w') as file:
            for row in range(height):
                for col in range(width):
                    if row % 2 == 0:
                        if col % 2 == 0:
                            data = hex(image[row, col, 1])
                        else:
                            data = hex(image[row, col, 0])
                    else:
                        if col % 2 == 0:
                            data = hex(image[row, col, 2])
                        else:
                            data = hex(image[row, col, 1])

                    file.write(data[2:])
                    file.write("\n")
    return image

# bayer to rgb
def interpolation(img):
    height, width, _ = img.shape
    r_ch = np.zeros((height, width), dtype=np.uint8)
    g_ch = np.zeros((height, width), dtype=np.uint8)
    b_ch = np.zeros((height, width), dtype=np.uint8)
    for row in range(height):
        for col in range(width):
            if row == 0 or row == (height-1) or col == 0 or col == (width-1):
                r_ch[row][col] = img[row, col, 0]
                g_ch[row][col] = img[row, col, 1]
                b_ch[row][col] = img[row, col, 2]
            else:
                if row % 2 == 0:
                    if col % 2 == 0:
                        r_ch[row][col] = (int(img[row, col-1, 0]) + int(img[row, col+1, 0])) // 2
                        g_ch[row][col] = img[row, col, 1]
                        b_ch[row][col] = (int(img[row-1, col, 2]) + int(img[row+1, col, 2])) // 2
                    else:
                        r_ch[row][col] = img[row, col, 0]
                        g_ch[row][col] = (int(img[row-1, col, 1]) + int(img[row+1, col, 1]) + int(img[row, col-1, 1]) + int(img[row, col+1, 1])) // 4
                        b_ch[row][col] = (int(img[row-1, col-1, 2]) + int(img[row-1, col+1, 2]) + int(img[row+1, col-1, 2]) + int(img[row+1, col+1, 2])) // 4
                else:
                    
                    if col % 2 == 0:
                        r_ch[row][col] = (int(img[row-1, col-1, 0]) + int(img[row-1, col+1, 0]) + int(img[row+1, col-1, 0]) + int(img[row+1, col+1, 0])) // 4
                        g_ch[row][col] = (int(img[row-1, col, 1]) + int(img[row+1, col, 1]) + int(img[row, col-1, 1]) + int(img[row, col+1, 1])) // 4
                        b_ch[row][col] = img[row, col, 2]
                    else:
                        r_ch[row][col] = (int(img[row-1, col, 0]) + int(img[row+1, col, 0])) // 2
                        g_ch[row][col] = img[row, col, 1]
                        b_ch[row][col] = (int(img[row, col-1, 2]) + int(img[row, col+1, 2])) // 2

    image = np.zeros((height, width, 3), dtype=np.uint8)
    image[:, :, 0], image[:, :, 1], image[:, :, 2] = r_ch, g_ch, b_ch
    
    return image

                    
# dat to image
def bayer_image(path="./bayer.dat", width=1024, height=512):
    r_ch = np.zeros((height, width), dtype=np.uint8)
    g_ch = np.zeros((height, width), dtype=np.uint8)
    b_ch = np.zeros((height, width), dtype=np.uint8)
    
    with open(path, 'r') as file:
        for idx, line in enumerate(file):
            if line.strip() == 'xx':
                break
            if (idx // width)  % 2 == 0:
                if (idx % width) % 2 == 0:
                    g_ch[idx//width, idx%width] = int(line.strip(), 16)
                else:
                    r_ch[idx//width, idx%width] = int(line.strip(), 16)
            else:
                if (idx % width) % 2 == 0:
                    b_ch[idx//width, idx%width] = int(line.strip(), 16)
                else:
                    g_ch[idx//width, idx%width] = int(line.strip(), 16)
    image = np.zeros((height, width, 3), dtype=np.uint8)
    image[:, :, 0], image[:, :, 1], image[:, :, 2] = r_ch, g_ch, b_ch                
    
    return image

def output_rgb(img):
    
    with open("./golden_channel_r.dat", "w") as file:
        for i in range(img.shape[0]):
            for j in range(img.shape[1]):
                file.write(str(hex(img[i, j, 0])[2:]))
                file.write("\n")
                
    with open("./golden_channel_g.dat", "w") as file:
        for i in range(img.shape[0]):
            for j in range(img.shape[1]):
                file.write(str(hex(img[i, j, 1])[2:]))
                file.write("\n")
                
    with open("./golden_channel_b.dat", "w") as file:
        for i in range(img.shape[0]):
            for j in range(img.shape[1]):
                file.write(str(hex(img[i, j, 2])[2:]))
                file.write("\n")
    
if __name__ == "__main__":

    if len(sys.argv) > 1:
        if sys.argv[1] == "save_image":
            with open("./size.dat", 'r') as file:
                for idx, line in enumerate(file):
                    if idx == 0:
                        height = int(line.strip())
                    else:
                        width = int(line.strip())
            filename = sys.argv[2].split('.', 1)[0]
            
            image = bayer_image(path="./image/"+filename+"_rgb.dat", width=width, height=height)
            image = interpolation(image)
            cv2.imwrite("./image/"+filename+".png", image)
            
            test = cv2.imread("./image/"+filename+".png")
        elif sys.argv[1] == "bayer2dat":
            image = cv2.imread("./image/"+sys.argv[2])
            filename = sys.argv[2].split('.', 1)[0]
            if image.shape[0] > 512:
                if image.shape[1] > 1024:
                    WIDTH  = 1024
                    HEIGHT = 512
                else:
                    WIDTH  = image.shape[1]
                    HEIGHT = 512
            else:
                if image.shape[1] > 1024:
                    WIDTH  = 1024
                    HEIGHT = image.shape[0]
                else:
                    WIDTH  = image.shape[1]
                    HEIGHT = image.shape[0]
                    
            with open("./image/"+filename+"_size.dat", 'w') as file:
                file.write(str(HEIGHT))
                file.write("\n")
                file.write(str(WIDTH))
            image = cv2.resize(image, (WIDTH, HEIGHT), interpolation=cv2.INTER_AREA)
            image = rgb2bayer_image(image, 1, "./image/"+filename+"_bayer.dat")
            image = interpolation(image)       
            output_rgb(image)
    else:              
        with open("./size.dat", 'r') as file:
            for idx, line in enumerate(file):
                if idx == 0:
                    height = int(line.strip())
                else:
                    width = int(line.strip())
        image = bayer_image(width=width, height=height)
        image = interpolation(image)
        output_rgb(image)
    