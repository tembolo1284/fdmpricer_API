from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from fdm.FDExplicitEu import FDExplicitEu
from fdm.FDImplicitEu import FDImplicitEu
from fdm.FDCnEu import FDCnEu
import logging

logging.basicConfig(level=logging.INFO)

app = FastAPI(
    title="Option Pricing API",
    description="API for calculating option prices using various finite difference methods",
    version="1.0.0"
)

class OptionInput(BaseModel):
    S0: float = Field(
        50.0, 
        description="Initial stock price", 
        example=50.0,
        gt=0
    )
    K: float = Field(
        50.0, 
        description="Strike price", 
        example=50.0,
        gt=0
    )
    r: float = Field(
        0.1, 
        description="Risk-free interest rate (decimal form, e.g., 0.1 for 10%)", 
        example=0.1,
        ge=0
    )
    T: float = Field(
        0.4166666666666667, 
        description="Time to maturity in years (e.g., 0.4167 for 5 months)", 
        example=0.4166666666666667,
        gt=0
    )
    sigma: float = Field(
        0.4, 
        description="Volatility (decimal form, e.g., 0.4 for 40%)", 
        example=0.4,
        gt=0
    )
    Smax: float = Field(
        100.0, 
        description="Maximum stock price for the grid", 
        example=100.0,
        gt=0
    )
    M: int = Field(
        100, 
        description="Number of spatial points in the grid", 
        example=100,
        gt=10
    )
    N: int = Field(
        1000, 
        description="Number of time steps in the grid", 
        example=1000,
        gt=10
    )
    is_call: bool = Field(
        False, 
        description="Option type: True for call option, False for put option",
        example=False
    )
    
    class Config:
        schema_extra = {
            "example": {
                "S0": 50.0,
                "K": 50.0,
                "r": 0.1,
                "T": 0.4166666666666667,
                "sigma": 0.4,
                "Smax": 100.0,
                "M": 100,
                "N": 1000,
                "is_call": False
            }
        }

@app.get("/")
async def root():
    return {
        "message": "Welcome to the Option Pricing API",
        "documentation": "Visit /docs for API documentation",
        "endpoint": "Use POST /calculate_option_price to price options"
    }

@app.post("/calculate_option_price", 
    summary="Calculate option prices using finite difference methods",
    description="Calculates option prices using explicit, implicit, and Crank-Nicolson finite difference methods. Returns all three prices for comparison."
)
async def calculate_option_price(option_input: OptionInput):
    try:
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