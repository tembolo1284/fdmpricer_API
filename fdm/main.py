from FDExplicitEu import FDExplicitEu
from FDImplicitEu import FDImplicitEu
from FDCnEu import FDCnEu

def main():
    S0 = 50
    K = 50
    r = 0.1
    T = 5.0 / 12.0
    sigma = 0.4
    Smax = 100
    M = 100
    N = 1000
    is_call = False

    option_pricer_explicit = FDExplicitEu(S0, K, r, T, sigma, Smax, M, N, is_call)
    option_pricer_implicit = FDImplicitEu(S0, K, r, T, sigma, Smax, M, N, is_call)
    option_pricer_cn = FDCnEu(S0, K, r, T, sigma, Smax, M, N, is_call)
    
    price_explicit = option_pricer_explicit.price()
    price_implicit = option_pricer_implicit.price()
    price_cn = option_pricer_cn.price()

    print(f"Option Price using explicit scheme: {price_explicit:.6f}")
    print(f"Option Price using implicit scheme: {price_implicit:.6f}")
    print(f"Option Price using crank-nicolson scheme: {price_cn:.6f}")

if __name__ == "__main__":
    main()
