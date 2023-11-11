import numpy as np

reported = np.zeros(83232)
with open("data/hw_converted_results.txt", 'r') as file:
    for i, line in enumerate(file):
        reported[i] = float(line.strip())

actual = np.zeros(83232)
with open("data/lms_out.txt", 'r') as file:
    for i, line in enumerate(file):
        actual[i] = float(line.strip())

MSE = 0
for i in range(len(actual)):
    MSE += (actual[i] - reported[i])**2


print(f"MSE = {MSE/len(actual)}")