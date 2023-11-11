import numpy as np
import math

def fixedPointQuantizer(dataPoint, N, R):
    maxVal = int((1 << (N-1)) - 1)
    minVal = int(-(1 << (N-1)))

    toReturn = round(dataPoint*(math.pow(2, R)))
    
    if (toReturn < minVal):
        # print("clipping low")
        return minVal
    elif (toReturn > maxVal):
        # print("clipping high")
        return maxVal
    else:
        return toReturn

def fixedPointDataQuantizer(data, N, R):
    fixedPointData = np.empty(0)

    for dataPoint in data:
        fixedPointData = np.append(fixedPointData, fixedPointQuantizer(dataPoint, N, R))
        
    return fixedPointData


def fixedToFloat(data, R):
    return data*math.pow(2, -R)

# these should be the most accurate overall
# N1 = 9
# R1 = 5

# however, going to build one from this for now
N1 = 8
R1 = 4


originalVals = []
with open ("data/adjVals.txt", 'r') as file:
    for line in file:
        originalVals.append(float(line.strip()))

originalVals.sort()
print(originalVals[0])
print(originalVals[len(originalVals)-1])

fixedPointVals = fixedPointDataQuantizer(originalVals, N1, R1)

convertedVals = np.zeros(len(fixedPointVals))

for i, val in enumerate(fixedPointVals):
    convertedVals[i] = fixedToFloat(val, R1)

MSE = 0
for i in range(len(convertedVals)):
    MSE += (convertedVals[i] - originalVals[i])**2

print(f"\nfor ({N1},{R1}), we have the following actual MSE")
print(f"MSE of original = {MSE/len(convertedVals)}")

# more ideal for entire system
# N2 = 12
# R2 = 5

N2 = 13
R2 = 5

originalRecip = np.zeros(len(originalVals))
for val in originalVals:
    originalRecip[i] = 1/float(val)

fixedPointRecip = fixedPointDataQuantizer(originalRecip, N2, R2)

convertedRecip = np.zeros(len(fixedPointRecip))

for i, val in enumerate(fixedPointRecip):
    convertedRecip[i] = fixedToFloat(val, R2)

MSE = 0
for i in range(len(convertedRecip)):
    MSE += (convertedRecip[i] - originalRecip[i])**2

print(f"\nfor ({N2},{R2}), we have the following actual MSE for the reciprocol values")
print(f"MSE of reciprocol = {MSE/len(convertedRecip)}")

# Create the LUT
maxVal = int((1 << (N1-1)))
lut_vals = np.zeros(maxVal)
MSE = 0
for i in range(maxVal):
    if (i == 0):
        continue
    curr_num = fixedToFloat(i, R1)
    curr_recip = 1/(float(curr_num))
    # print(curr_recip)
    fp_recip = fixedPointQuantizer(curr_recip, N2, R2)
    float_recip = fixedToFloat(fp_recip, R2)
    # print(float_recip)
    # print()
    lut_vals[i] = int(fp_recip)
    MSE += (float_recip - curr_recip)**2

print(f"\n for ({N1}, {R1}) to ({N2}, {R2}) LUT")
print(f"MSE = {MSE/maxVal}")

with open("../../verilog/LMS/data/adjRecipLutVals.mem",'w') as file:
    for val in lut_vals:
        file.write(hex(int(val))[2:] + '\n')