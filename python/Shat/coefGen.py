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
R = 30

valsToWrite = []
with open("data/sh.txt", 'r') as file:
    for data in file:
        valsToWrite.append(hex(convert2sCompl(fixedPointQuantizer(float(data.strip()), N, R), N))[2:])

with open("../../verilog/Shat/data/shVals.mem", 'w') as file:
    for cnt, val in enumerate(valsToWrite):
        if (cnt == len(valsToWrite)-1):
            file.write(val)
        else:
            file.write(val + '\n')
