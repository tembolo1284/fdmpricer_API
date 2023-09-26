from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fdm.FDExplicitEu import FDExplicitEu
from fdm.FDImplicitEu import FDImplicitEu
from fdm.FDCnEu import FDCnEu
import logging

logging.basicConfig(level=logging.INFO)

app = FastAPI()

class OptionInput(BaseModel):
    S0: float
    K: float
    r: float
    T: float
    sigma: float
    Smax: float
    M: int
    N: int
    is_call: bool

@app.post("/calculate_option_price")
async def calculate_option_price(option_input: OptionInput):
    try:
        # Implement option pricing logic here for each scheme (explicit, implicit, Crank-Nicolson)
        # Calculate prices using Finite Difference Methods
        
        option_pricer_explicit = FDExplicitEu(option_input.S0, option_input.K, option_input.r, option_input.T, option_input.sigma, option_input.Smax, option_input.M, option_input.N, option_input.is_call)
        option_pricer_implicit = FDImplicitEu(option_input.S0, option_input.K, option_input.r, option_input.T, option_input.sigma, option_input.Smax, option_input.M, option_input.N, option_input.is_call)
        option_pricer_cn = FDCnEu(option_input.S0, option_input.K, option_input.r, option_input.T, option_input.sigma, option_input.Smax, option_input.M, option_input.N, option_input.is_call)
    
        logging.info("Calculating Option Prices using each scheme...")
        price_explicit = option_pricer_explicit.price()
        logging.info("Explicit scheme complete.")
        price_implicit = option_pricer_implicit.price()
        logging.info("Implicit scheme complete.")
        price_cn = option_pricer_cn.price()
        logging.info("Crank Nicolson scheme complete.")

        return {
            "ExplicitSchemePrice": round(price_explicit, 6),
            "ImplicitSchemePrice": round(price_implicit, 6),
            "CrankNicolsonSchemePrice": round(price_cn, 6)
        }
    except ValueError as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")