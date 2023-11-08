import numpy as np

def Shat(u, sh):
    start_ind = 0
    end_ind = 0
    N = len(u)
    s_num = 0

    answers = []

    while(start_ind < N):
        curr_sum = 0
        cnt = 0
        for i in range(start_ind - end_ind + 1):
            curr_sum += sh[i] * u[start_ind - i]
        
        answers.append(curr_sum)

        start_ind += 1
        if (start_ind >= len(sh)):
            end_ind += 1
    
    return answers
    

NS_OR_NW = 32

sh = np.zeros(32)
u = np.zeros(64)

with open("data/floatVals.txt", 'r') as file:
    i = 0
    for line in file:
        sh[i] = float(line.strip())
        i += 1

with open("data/inputVals.txt", 'r') as file:
    i = 0
    for line in file:
        u[i] = float(line.strip())
        i += 1
    
sum = 0
for i in range(len(sh)):
    sum += sh[i] * sh[i]

print(sum)

results = Shat(u, sh)

with open("data/sim_results.txt", 'w') as file:
    for res in results:
        file.write(str(res) + '\n')
