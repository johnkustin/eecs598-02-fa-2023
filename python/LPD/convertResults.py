import math
import numpy

def fixedToFloatData(fixedData, R):
    floatData = []

    for data in fixedData:
        floatData.append(data*math.pow(2, -R))
    
    return floatData

R = 31

rawResults = []

with open("data/hw_results.txt", 'r') as file:
    for line in file:
        if line.strip() == "":
            continue
        if line.strip()[0] == 'I':
            continue
        rawResults.append(int(line.strip()))

realResults = fixedToFloatData(rawResults, R)

with open("data/hw_converted_results.txt", 'w') as file:
    for val in realResults:
        file.write(str(val) + '\n')
