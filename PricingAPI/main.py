import logging, uvicorn

from PricingAPI.app import app


def start():
    logging.basicConfig(
        format = '%(asctime)s [%(name)s] %(levelname)s: %(message)s',
        datefmt = '%Y-%m-%d %H:%M:%S',
        level = logging.INFO
    )

    uvicorn.run(app, host="0.0.0.0", port=8000)

if __name__ == "__main__":
    start()
