import math

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
R = 32

mu = 0.2
offset = 0.01

mu_fixed = fixedPointQuantizer(mu, N, R)
offset_fixed = fixedPointQuantizer(offset, 32, 31)

print(f"mu = {mu_fixed}")
print(f"offset = {offset_fixed}")