import numpy as np
# python version of the QNS Module
class QNS:
    
    # P and M are global constants throughout the program
    def __init__(self, L, P, M):
        self.L = L
        self.P = P # global
        self.M = M # global
        self.reset()
    
    def reset(self):
        self.yd = 0
        self.q = 0
        self.x = 0
        self.mem = np.zeros(self.P)
    
    def step(self, x):
        return self.stepx(x, True)
    
    def stepx(self, x, quantization):
        y = None # the variable to return

        self.x = x
        
        self.mem[0] = self.mem[0] + x - self.yd
        
        for i in range(1, self.P): # if P = 2, then just one iteration where i = 1
            self.mem[i] = self.mem[i] + self.mem[i-1] - self.yd
        
        if quantization:
            level_i = min(max((round(self.M/4*(self.mem[self.P-1]/self.L + 2)- 1/2)), 0), self.M-1)
            y = self.L * (4/self.M * (level_i.conj().T + 1/2)-2)
        else:
            y = self.mem[self.P-1]
        
        self.q = y - self.mem[self.P-1]
        self.yd = y
        
        return y