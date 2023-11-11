import numpy as np

skippedLinesBlank = 0
skippedLinesA = 0
i = 0
allVals = np.zeros(83232)
with open ("data/a.txt", 'r') as file:
    for line in file:
        curr = line.strip()
        if curr == "":
            skippedLinesBlank += 1
            continue
        if curr == "a =":
            skippedLinesA += 1
            continue
        allVals[i] = float(curr)
        i += 1

with open ("data/lms_out.txt", 'w') as file:
    for val in allVals:
        file.write(str(val) + '\n')

