import math
import numpy as np

# convert fixed point data vector to corresponding floating point data vector
def fixedToFloatData(fixedData, R):
    floatData = []

    for data in fixedData:
        floatData.append(data*math.pow(2, -R))
    
    return floatData

rawResults = []

with open("data/hw_results.txt", 'r') as file:
    for line in file:
        rawResults.append(int(line.strip()))

R = 31

realResults = fixedToFloatData(rawResults, R)

with open("data/hw_converted_results.txt", 'w') as file:
    for res in realResults:
        file.write(str(res) + '\n')
