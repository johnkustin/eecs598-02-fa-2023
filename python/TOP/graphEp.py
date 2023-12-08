import numpy as np
import math
import matplotlib.pyplot as plt


def fixedToFloatData(fixedData, R):
    floatData = []

    for data in fixedData:
        floatData.append(data*math.pow(2, -R))
    
    return floatData

rawResults = []

with open("data/ep_hw_raw.txt", 'r') as file:
    for line in file:
        rawResults.append(int(line.strip()))

R = 26

realResults = fixedToFloatData(rawResults, R)
N_AAF = 3565

AAF = np.zeros(N_AAF)

with open ("../LPD/data/AAF.txt", 'r') as file:
    for i, line in enumerate(file):
        AAF[i] = float(line.strip())

plt.plot(realResults)
plt.savefig("data/ep.png")


filtered = np.convolve(realResults, AAF)

downSampled = []

for i in range(len(filtered)):
    if (i % 32 == 0):
        downSampled.append(filtered[i])

plt.figure()
plt.plot(downSampled)
plt.savefig("data/ep_filtered_ds.png")

e = np.zeros(2488)
with open ("data/e.txt", 'r') as file:
    for i, line in enumerate(file):
        e[i] = float(line.strip())

R = 31
e = fixedToFloatData(e, R)
plt.plot(e)
plt.savefig("data/e.png")
