from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import logging, uvicorn


def main():
    logging.basicConfig(
        format = '%(asctime)s [%(name)s] %(levelname)s: %(message)s',
        datefmt = '%Y-%m-%d %H:%M:%S',
        level = logging.INFO
    )

    uvicorn.run("app:app")

if __name__ == "__main__":
    main()