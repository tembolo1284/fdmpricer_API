import requests, math, json, logging

logging.basicConfig(level=logging.INFO)

# Can also run a curl command similar to the below
"""
curl -X 'POST' \
  'http://127.0.0.1:8000/calculate_option_price' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "S0": 50.0,
    "K": 50.0,
    "r": 0.1,
    "T": 0.416666666666667,
    "sigma": 0.4,
    "Smax": 100.0,
    "M": 100,
    "N": 1000,
    "is_call": False
}'

"""


# Define the URL for the FastAPI endpoint
url = "http://127.0.0.1:8000/calculate_option_price"

# Define the input parameters for option pricing
params = {
    "S0": 50.0,
    "K": 50.0,
    "r": 0.1,
    "T": 0.416666666666667,
    "sigma": 0.4,
    "Smax": 100.0,
    "M": 100,
    "N": 1000,
    "is_call": False
}

# Define the headers for the request
headers = {'Content-Type': 'application/json'}

# Print the input parameters
print(params)

# Send a POST request to the FastAPI endpoint
response = requests.post(url, data=json.dumps(params), headers=headers)

# Parse the response data
try:
    response_data = response.json()
    logging.info("Option price calculation complete.")
except json.decoder.JSONDecodeError:
    print("Error: Response is not valid JSON.")
    response_data = None

# Check for NaN values
if math.isnan(response_data["ExplicitSchemePrice"]) or math.isnan(response_data["ImplicitSchemePrice"]) or \
        math.isnan(response_data["CrankNicolsonSchemePrice"]):
    print("Error: NaN value detected in calculation.")
else:
    print("-------response_data-------")
    print(response_data)
