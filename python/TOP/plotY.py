import numpy as np
import math
import matplotlib.pyplot as plt


def fixedToFloatData(fixedData, R):
    floatData = []

    for data in fixedData:
        floatData.append(data*math.pow(2, -R))
    
    return floatData

rawResults = []

with open("data/y.txt", 'r') as file:
    for line in file:
        rawResults.append(int(line.strip()))

R = 31

realResults = fixedToFloatData(rawResults, R)
y = []
with open("data/y_ml.txt", 'r') as file:
    for i, line in enumerate(file):
        y.append(float(line.strip()))


plt.plot(y)
plt.plot(realResults)
plt.legend(["MATLAB y(n)", "RTL y(n)"])
plt.savefig("y_rtl.png")
