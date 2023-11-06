import math
import numpy

def fixedToFloatData(fixedData, R):
    floatData = []

    for data in fixedData:
        floatData.append(data*math.pow(2, -R))
    
    return floatData

R = 18

rawResults = []

with open("data/hw_results.txt", 'r') as file:
    for line in file:
        if line.strip() == "":
            continue
        if line.strip()[0] == 'I':
            continue
        rawResults.append(int(line.strip()))

realResults = fixedToFloatData(rawResults, R)

realResultsPartitioned = []

start_ind = 0
for i in range(32):
    temp_list = []
    for i in range(start_ind, start_ind+32):
        temp_list.append(realResults[i])
    start_ind += 32
    realResultsPartitioned.append(temp_list)

with open("data/hw_converted_results.txt", 'w') as file:
    for i, curr_list in enumerate(realResultsPartitioned):
        file.write('\n\n')
        file.write(f'iter #{i}' + '\n')
        for val in curr_list:
            file.write(f"{val:.6f}" + '\n')
