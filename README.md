# Finite Difference Method Option Pricer and API

This Python project contains various classes for finite difference methods related to options pricing.  The project includes the following classes:

## `FiniteDifferences`

- **Description**: The `FiniteDifferences` class is a base class that provides the core framework for implementing finite difference methods for option pricing.
- **Attributes**:
  - `S0`: Initial stock price.
  - `K`: Strike price.
  - `r`: Risk-free interest rate.
  - `T`: Time to maturity.
  - `sigma`: Volatility.
  - `Smax`: Maximum stock price for the grid.
  - `M`: Number of spatial points in the grid.
  - `N`: Number of time steps in the grid.
  - `is_call`: Boolean indicating whether it's a call option (default is True).

## `FDExplicitEu`

- **Description**: The `FDExplicitEu` class is derived from `FiniteDifferences` and implements the explicit finite difference method for European option pricing.
- **Attributes**:
  - Inherits attributes from the base class.

## `FDImplicitEu`

- **Description**: The `FDImplicitEu` class is derived from `FDExplicitEu` and implements the implicit finite difference method for European option pricing.
- **Attributes**:
  - Inherits attributes from the base class.
- **Overrides**:
  - `_setup_coefficients_`: Custom implementation for setting up coefficients.
  - `_traverse_grid_`: Custom implementation for traversing the grid.

## `FDCnEu`

- **Description**: The `FDCnEu` class is derived from `FDExplicitEu` and implements the Crank-Nicolson finite difference method for European option pricing.
- **Attributes**:
  - Inherits attributes from the base class.
- **Overrides**:
  - `_setup_coefficients_`: Custom implementation for setting up coefficients.
  - `_traverse_grid_`: Custom implementation for traversing the grid.

## Installation

To set up the project environment and dependencies, follow these steps:

1. Ensure you have Python 3.10 or higher installed on your system.

2. Install Poetry (if not already installed):

```
pip install poetry
```

3. Install dependencies

```
poetry install
```

4. Run main

```
poetry run python FDMPRICER/main.py
```



run the below if you need to put all installed packages into a file to then run the next command

```
pip freeze > installed_packages.txt
```

run the below if you need to uninstall everything

```
Get-Content installed_packages.txt | ForEach-Object { pip uninstall -y $_ }
```
