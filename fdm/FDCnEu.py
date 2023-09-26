import numpy as np
import scipy.linalg as linalg

from .FDExplicitEu import FDExplicitEu

class FDCnEu(FDExplicitEu):
    def _setup_coefficients_(self):
        self.a = 0.25*self.dt*((self.sigma*self.sigma)*(self.i_values*self.i_values)-self.r*self.i_values)
        self.b = -self.dt*0.5*((self.sigma*self.sigma)*(self.i_values*self.i_values)+self.r)
        self.c = 0.25*self.dt*((self.sigma*self.sigma)*(self.i_values*self.i_values)+self.r*self.i_values)

        self.M1 = -np.diag(self.a[2:self.M], -1) + np.diag(1-self.b[1:self.M]) - np.diag(self.c[1:self.M-1], 1)
        self.M2 = np.diag(self.a[2:self.M], -1) + np.diag(1+self.b[1:self.M]) + np.diag(self.c[1:self.M-1], 1)

    def _traverse_grid_(self):
        """
            Solve using linear systems of equations
        """

        P, L, U = linalg.lu(self.M1)

        for j in reversed(range(self.N)):
            x1 = linalg.solve(L, np.dot(self.M2, self.grid[1:self.M, j+1]))
            x2 = linalg.solve(U, x1)
            self.grid[1:self.M, j] = x2
