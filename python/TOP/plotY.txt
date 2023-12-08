import numpy as np
import math
import matplotlib.pyplot as plt


def fixedToFloatData(fixedData, R):
    floatData = []

    for data in fixedData:
        floatData.append(data*math.pow(2, -R))
    
    return floatData

rawResults = []

with open("data/shat1.txt", 'r') as file:
    for line in file:
        rawResults.append(int(line.strip()))

R = 31

realResults = fixedToFloatData(rawResults, R)
u1 = []
with open("../LMS/data/u1.txt", 'r') as file:
    for i, line in enumerate(file):
        u1.append(float(line.strip()))


plt.plot(u1)
plt.plot(realResults)
plt.legend(["MATLAB u1(n)", "RTL u1(n)"])
plt.savefig("shat1.png")
