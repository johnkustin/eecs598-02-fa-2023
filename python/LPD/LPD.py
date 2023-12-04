import numpy as np

N_AAF = 3565

AAF = np.zeros(N_AAF)

with open ("data/AAF.txt", 'r') as file:
    for i, line in enumerate(file):
        AAF[i] = float(line.strip())

u0 = np.zeros(96000)

with open("data/u0.txt", 'r') as file:
    for i, line in enumerate(file):
        u0[i] = int(line.strip())

u0_idx = 12800 - N_AAF

u = np.zeros(3000)

for i in range(2600):
    for j in range(N_AAF):
        u[i + 399] += AAF[j] * u0[j + u0_idx]
    
    u0_idx += 32

with open("data/sim_u.txt", 'w') as file:
    for data in u:
        file.write(str(data) + '\n')



u0_idx = 12799
u = np.zeros(2488) # (96000 - 12800 - 3584)/32
modified_AAF = np.zeros(3583)

for i in range(9):
    modified_AAF[i] = 0

for i in range(9, N_AAF + 9):
    modified_AAF[i] = AAF[i-9]

for i in range(9 + N_AAF, 9 + N_AAF + 9):
    modified_AAF[i] = 0
    
with open("data/modified_AAF.txt", 'w') as file:
    for data in modified_AAF:
        file.write(str(data) + '\n')

for i in range(2488):
    for j in range(3583):
        u[i] += modified_AAF[j] * u0[j + u0_idx]
    
    u0_idx += 32

with open("data/sim_u_hw.txt", 'w') as file:
    for data in u:
        file.write(str(data) + '\n')