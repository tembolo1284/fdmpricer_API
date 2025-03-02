import numpy as np
import scipy.linalg as linalg

from fdm.FDExplicitEu import FDExplicitEu

class FDImplicitEu(FDExplicitEu):
    def _setup_coefficients_(self):
        self.a = 0.5*(self.r*self.dt*self.i_values-(self.sigma*self.sigma)*self.dt*(self.i_values*self.i_values))

        self.b = 1 + (self.sigma*self.sigma)*self.dt*(self.i_values*self.i_values) + self.r*self.dt

        self.c = -0.5*(self.r*self.dt*self.i_values + (self.sigma*self.sigma)*self.dt*(self.i_values*self.i_values))

        self.coeffs = np.diag(self.a[2:self.M], -1) + np.diag(self.b[1:self.M]) + np.diag(self.c[1:self.M-1], 1)

    def _traverse_grid_(self):
        """
            Solve using linear systems of equations
        """
        P, L, U = linalg.lu(self.coeffs)
        aux = np.zeros(self.M-1)

        for j in reversed(range(self.N)):
            aux[0] = np.dot(-self.a[1], self.grid[0, j])
            x1 = linalg.solve(L, self.grid[1:self.M, j+1] + aux)
            x2 = linalg.solve(U, x1)
            self.grid[1:self.M, j] = x2

