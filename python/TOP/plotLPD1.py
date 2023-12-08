import numpy as np
import math
import matplotlib.pyplot as plt


def fixedToFloatData(fixedData, R):
    floatData = []

    for data in fixedData:
        floatData.append(data*math.pow(2, -R))
    
    return floatData

rawResults = []

with open("data/lpd1.txt", 'r') as file:
    for line in file:
        rawResults.append(int(line.strip()))

R = 31

realResults = fixedToFloatData(rawResults, R)
u = []
with open("../Shat/data/u.txt", 'r') as file:
    for i, line in enumerate(file):
        if (i >= 400):
            u.append(float(line.strip()))


my_u0 = np.zeros(83196)
their_u0 = np.zeros(83196)

with open("data/u0.txt", 'r') as file:
    for i, line in enumerate(file):
        my_u0[i] = int(line.strip())

with open("data/u0_cmpr.txt", 'r') as file:
    for i, line in enumerate(file):
        if (i == 83196):
            break
        their_u0[i] = int(line.strip())

num_wrong = 0
for i in range(83196):
    if (my_u0[i] != their_u0[i]):
        num_wrong += 1

print(num_wrong)


plt.plot(u)
plt.plot(realResults)
plt.legend(["MATLAB u(n)", "RTL u(n)"])
plt.savefig("lpd1.png")
