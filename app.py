import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/health")
def health():
    return jsonify(status="healthy", version="1.0.0")

@app.get("/orders")
def orders():
    if os.getenv("SIMULATE_FAILURE", "false").lower() == "true":
        return jsonify(error="simulated incident"), 500
    return jsonify(orders=[{"id": 1, "total": 42}])
