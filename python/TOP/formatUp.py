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
R = 28

valsToWrite = []
with open("data/up.txt", 'r') as file:
    for data in file:
        valsToWrite.append(hex(convert2sCompl(fixedPointQuantizer(float(data), N, R), N))[2:])

with open("../../verilog/TOP/data/up.mem", 'w') as file:
    for cnt, val in enumerate(valsToWrite):
        if (cnt == len(valsToWrite)-1):
            file.write(val)
        else:
            file.write(val + '\n')


N = 32
R = 28

valsToWrite = []
with open("data/dp.txt", 'r') as file:
    for data in file:
        valsToWrite.append(hex(convert2sCompl(fixedPointQuantizer(float(data), N, R), N))[2:])

with open("../../verilog/TOP/data/dp.mem", 'w') as file:
    for cnt, val in enumerate(valsToWrite):
        if (cnt == len(valsToWrite)-1):
            file.write(val)
        else:
            file.write(val + '\n')


N = 32
R = 31

valsToWrite = []
with open("data/sp.txt", 'r') as file:
    for data in file:
        valsToWrite.append(hex(convert2sCompl(fixedPointQuantizer(float(data), N, R), N))[2:])

with open("../../verilog/TOP/data/sp.mem", 'w') as file:
    for cnt, val in enumerate(valsToWrite):
        if (cnt == len(valsToWrite)-1):
            file.write(val)
        else:
            file.write(val + '\n')