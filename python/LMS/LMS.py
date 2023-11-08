import numpy as np

def LMS(u1v, eh_n, mu, offset):
    start_ind = 0
    N = len(eh_n)

    final_res = []

    while(start_ind < N):
        curr_res = np.zeros(N)
        adjuster = 0
        for i in range(start_ind+1):
            adjuster += u1v[i] * u1v[i]
        
        adjuster += offset
        adjuster = mu*eh_n[start_ind] / adjuster
        
        curr_res_idx = 0
        for i in range(start_ind, -1, -1):
            curr_res[curr_res_idx] = u1v[i] * adjuster
            curr_res_idx += 1
        
        final_res.append(curr_res)
        start_ind += 1

    return final_res





u1v = np.zeros(32)
u_idx = 0
with open("data/sim_in_u1v.txt", 'r' ) as file:
    for line in file:
        u1v[u_idx] = float(line.strip())
        u_idx += 1
    
eh = np.zeros(32)
eh_idx = 0
with open("data/sim_in_eh.txt", 'r' ) as file:
    for line in file:
        eh[eh_idx] = float(line.strip())
        eh_idx += 1



eh_n = 0.0049
mu = 0.2000
offset = 0.01

results = LMS(u1v, eh, mu, offset)

with open("data/sim_out.txt", 'w') as file:
    i = 0
    for res in results:
        file.write(f"\n\niter #{i}\n")
        for val in res:
            file.write(f"{val:.6f}" + '\n')
        i = i + 1
