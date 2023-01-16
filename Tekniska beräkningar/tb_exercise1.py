import numpy as np
import matplotlib.pyplot as plt
import scipy as sp

def epsilon():
    for n in range(0,1000):
        if pow(2,-n)+1 <= 1:
            return n-1 , pow(2, -n-1)

def sinx_is_x(significand):
    x = 0
    while (abs(np.sin(x)-x) < 0.5 * pow(10,-significand)):
        x += pow(10, -significand-1)
    return x

def cosx_is(significand):
    x = 0
    while (abs(np.cos(x)-(1-pow(x,2)/2)) < 0.5 * pow(10,-significand)):
        x += pow(10, -significand-1)
    return x

def c_is(significand):
    x = 0
    while (abs(1/(1-pow(x,2))-(1+pow(x,2))) < 0.5 * pow(10,-significand)):
        x += pow(10, -significand-1)
    return x

def largest_h(left, right, significand):
    x = 0
    while(abs(left(x)-right(x)) < 0.5 * pow(10, -significand)):
        x += pow(10, -significand-1)
    return x

def fixpunkt(g_x, range, xold, epsilon):
    diff = 1
    while diff >= epsilon:
        xnew = g_x(xold)
        diff = np.abs([xnew - xold])
        xold = xnew
    return xnew

if __name__ == '__main__':
    left = lambda x : 1/(1-pow(x,2))
    right = lambda x : 1 + pow(x,2)
    g_x = lambda x : (np.exp(-x) + 1)/2
    print(fixpunkt(g_x, (0,1), 0.5, 10**-6))
