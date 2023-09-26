# Pricing_API

Pricing_API is a FastAPI-based microservice designed to calculate option prices using
3 different finite difference methods. This package is part of a larger project, along with FDMPRICER.

## Installation

Use the pyproject.toml file in the root directory to install the project and its dependencies.

## Usage

Run the application by using the command: `uvicorn pricing_API.main:app --reload`

This will launch a FastAPI application, by default on `localhost:8000`.

## API Endpoints

### GET `/calculate_option_price`

This endpoint calculates option prices using different pricing schemes (explicit, implicit, Crank-Nicolson) based on the provided option inputs.

#### Parameters

* S0: Initial stock price (float).
* K: Strike price (float).
* r: Risk-free interest rate (float).
* T: Time to maturity (float).
* sigma: Volatility (float).
* Smax: Maximum stock price for the grid (float).
* M: Number of spatial points in the grid (integer).
* N: Number of time steps in the grid (integer).
* is_call: Boolean indicating whether it's a call option (boolean).

Example input:

```
{
    "S0": 50.0,
    "K": 50.0,
    "r": 0.1,
    "T": 0.4166666666666667,
    "sigma": 0.4,
    "Smax": 100.0,
    "M": 100,
    "N": 1000,
    "is_call": false
}

```

#### Response

The response is a JSON object containing the following fields:

* ExplicitSchemePrice: Option price using the explicit scheme (float).
* ImplicitSchemePrice: Option price using the implicit scheme (float).
* CrankNicolsonSchemePrice: Option price using the Crank-Nicolson scheme (float).

#### Example

```
{
  "ExplicitSchemePrice": 4.072882,
  "ImplicitSchemePrice": 4.071594,
  "CrankNicolsonSchemePrice": 4.072238
}
```