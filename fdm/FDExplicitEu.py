import numpy as np

from fdm.FiniteDifferences import FiniteDifferences

class FDExplicitEu(FiniteDifferences):

    def _setup_boundary_conditions_(self):
        if self.is_call:
            self.grid[:, -1] = np.maximum(self.boundary_conds - self.K, 0)
            self.grid[-1, :-1] = (self.Smax - self.K)*np.exp(-self.r*self.dt*(self.N-self.j_values))

        else:
            self.grid[:, -1] = np.maximum(self.K-self.boundary_conds, 0)
            self.grid[0, :-1] = (self.K - self.Smax)*np.exp(-self.r*self.dt*(self.N-self.j_values))

    def _setup_coefficients_(self):
        self.a = 0.5*self.dt*((self.sigma*self.sigma)*(self.i_values*self.i_values) - self.r*self.i_values)
        self.b = 1 - self.dt*((self.sigma*self.sigma)*(self.i_values*self.i_values)+self.r)
        self.c = 0.5*self.dt*((self.sigma*self.sigma)*(self.i_values*self.i_values)+self.r*self.i_values)

    def _traverse_grid_(self):
        for j in reversed(self.j_values):
            for i in range(self.M)[2:]:
                self.grid[i,j] = self.a[i]*self.grid[i-1, j+1] + self.b[i]*self.grid[i, j+1] + self.c[i]*self.grid[i+1, j+1]

