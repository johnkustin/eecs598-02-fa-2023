import numpy as np
import math

def convert2sCompl(data, N):
    toReturn = data
    if (data < 0):
        toReturn = int(data + (1 << N))

    return toReturn

def fixedToFloat(data, R):
    return data*math.pow(2, -R)

def fixedPointQuantizer(dataPoint, N, R):
    maxVal = int((1 << (N-1)) - 1)
    minVal = int(-(1 << (N-1)))

    toReturn = round(dataPoint*(math.pow(2, R)))
    
    if (toReturn < minVal):
        print("clipping low")
        return minVal
    elif (toReturn > maxVal):
        print("clipping high")
        return maxVal
    else:
        return toReturn

N = 32
R = 36

valsToWrite = []
with open("data/AAF.txt", 'r') as file:
    for i in range(9):
        valsToWrite.append("0")
    for i, data in enumerate(file):
        valsToWrite.append(hex(convert2sCompl(fixedPointQuantizer(float(data), N, R), N))[2:])

valsToWrite = valsToWrite[0:1792]
with open("../../verilog/LPD/data/AAF.mem", 'w') as file:
    for i in range(len(valsToWrite)):
        file.write(valsToWrite[i] + '\n')

with open("../../verilog/LPD/src/AAF.svh", 'w') as file:
    file.write("logic signed [31:0] AAF [56] [32] = '{\n")
    for i in range(int(len(valsToWrite)/32)):
        file.write("'{")
        for j in range(32):
            if (j == 31):
                file.write(f"32'h{valsToWrite[i*32 + j]}")
            else:
                file.write(f"32'h{valsToWrite[i*32 + j]},")
        if (i == (int(len(valsToWrite)/32)-1)):
            file.write("}\n")
        else:
            file.write("},\n")
    file.write("};")
    

valsToWrite = []
N = 3
R = 0
with open("data/u0.txt", 'r') as file:
    for data in file:
        valsToWrite.append(hex(convert2sCompl(fixedPointQuantizer(float(data), N, R), N))[2:])
valsToWrite = valsToWrite[12800-1:]
with open("../../verilog/LPD/data/u0.mem", 'w') as file:
    for cnt, val in enumerate(valsToWrite):
        if (cnt == len(valsToWrite)-1):
            file.write(val)
        else:
            file.write(val + '\n')