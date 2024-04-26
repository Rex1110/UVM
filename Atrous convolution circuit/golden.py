def dil_conv(image, filter):
    padding_img = [[0 for _ in range(68)] for _ in range(68)]
    
    for i in range(len(image)):
        for j in range(len(image[i])):
            padding_img[i+2][j+2] = image[i][j]
    
    # 上下 edge padding
    for col in range(68):
        for row in range(2):
            padding_img[row][col] = padding_img[2][col] # 上 edge padding
            padding_img[68-1-row][col] = padding_img[68-1-2][col]
            
            
    for row in range(68):
        for col in range(2):
            padding_img[row][col] = padding_img[row][2]
            padding_img[row][68-1-col] = padding_img[row][68-1-2]
        
    result = [[0 for _ in range(64)] for _ in range(64)]
    for X in range(64):
        for Y in range(64):
            temp = 0
            for x in range(5):
                for y in range(5):
                    temp += padding_img[X+x][Y+y] * filter[x][y]
            temp -= 0.75
            result[X][Y] = temp if temp > 0 else 0
    return result

def max_pool(image):
    result = [[0 for _ in range(32)] for _ in range(32)]
    for X in range(0, len(image), 2):
        for Y in range(0, len(image[X]), 2):
            max_num = 0
            for x in range(2):
                for y in range(2):
                    if x == 0 and y == 0:
                        max_num = image[X][Y]
                    else:
                        if image[X+x][Y+y] > max_num:
                            max_num = image[X+x][Y+y]
            if (int(max_num) - max_num) != 0:
                result[X//2][Y//2] = int(max_num) + 1
            else:
                result[X//2][Y//2] = int(max_num)
    return result

if __name__ == "__main__":
    
    image = [[0 for _ in range(64)] for _ in range(64)]   
     
    with open("./image_mem.dat", "r") as file:
        for idx, line in enumerate(file):
            acc = 0
            for i in range(1, 9):
                if line[i] == "1":
                    acc += 2 ** (8-i)
            image[idx//64][idx%64] = acc
    
    filter = [[-0.0625, 0, -0.125, 0, -0.0625],
            [ 0,      0,      0, 0,       0],
            [-0.25,   0,      1, 0,   -0.25],
            [ 0,      0,      0, 0,       0],
            [-0.0625, 0, -0.125, 0, -0.0625]]
    
    layer1_mem = dil_conv(image, filter)
    layer2_mem = max_pool(layer1_mem)
    
    with open("./layer1_golden.dat", "w") as file:
        for i in range(len(layer1_mem)):
            for j in range(len(layer1_mem[i])):
                temp = layer1_mem[i][j]
                integer = int(temp)
                decimal = temp - int(temp)
                
                rst = ""
                while integer != 0:
                    rst = "1" + rst if integer % 2 == 1 else "0" + rst
                    integer = integer // 2
                if len(rst) != 9:
                    rst = "0"*(9-len(rst)) + rst
                    
                while decimal != 0:
                    decimal *= 2
                    if decimal >= 1:
                        rst = rst + "1"
                        decimal -= 1
                    else:
                        rst = rst + "0"
                if len(rst) != 13:
                    rst += "0"*(13-len(rst))
                file.write(rst)
                file.write("\n")
    
    with open("./layer2_golden.dat", "w") as file:
        for i in range(len(layer2_mem)):
            for j in range(len(layer2_mem[i])):
                temp = layer2_mem[i][j]
                rst = "0000"
                while temp != 0:
                    if temp % 2 == 1:
                        rst = "1" + rst
                    else:
                        rst = "0" + rst
                    temp = temp // 2
                if len(rst) != 13:
                    rst = "0"*(13-len(rst)) + rst
                    
                file.write(rst)
                file.write("\n")