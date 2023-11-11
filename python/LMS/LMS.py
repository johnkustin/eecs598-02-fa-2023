import numpy as np
import copy


def LMS(u1v, eh_n, mu, offset):
    curr_res = np.zeros(32)
    adjuster = 0
    for i in range(32):
        adjuster += u1v[i] * u1v[i]
    
    adjuster += offset
    adjuster = mu*eh_n / adjuster

    for i in range(32):
        curr_res[i] = u1v[i] * adjuster

    return curr_res





u1 = np.zeros(2601)
with open("data/u1.txt", 'r' ) as file:
    for i, line in enumerate(file):
        u1[i] = np.float64(line.strip())
    
eh = np.zeros(2601)
with open("data/eh.txt", 'r' ) as file:
    for i, line in enumerate(file):
        eh[i] = np.float64(line.strip())



mu = 0.2000
offset = 0.01

u1v = np.zeros(32)
full_results = []

for i in range(2601):
    u1v_temp = copy.deepcopy(u1v)
    u1v[0] = u1[i]
    # shift values over
    for k in range(1, 32):
        u1v[k] = u1v_temp[k-1]
    
    full_results.append(LMS(u1v, eh[i], mu, offset))

with open("data/sim_out.txt", 'w') as file:
    for lists in full_results:
        for val in lists:
            file.write(str(val) + '\n')
