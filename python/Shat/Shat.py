import numpy as np

NS_OR_NW = 32

sh = np.zeros(32)

with open("floatVals.txt", 'r') as file:
    i = 0
    for line in file:
        sh[i] = float(line.strip())
        i += 1

u = np.zeros(32)

with open("inputVals.txt", 'r') as file:
    i = 0
    for line in file:
        u[i] = float(line.strip())
        i += 1
    
sum = 0
for i in range(len(u)):
    sum += u[i]*sh[i]


print(f"sum = {sum}")