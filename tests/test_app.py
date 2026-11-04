from app import app

def test_health():
    response = app.test_client().get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"

def test_orders(monkeypatch):
    monkeypatch.delenv("SIMULATE_FAILURE", raising=False)
    response = app.test_client().get("/orders")
    assert response.status_code == 200
    assert response.json["orders"][0]["total"] == 42

def test_simulated_incident(monkeypatch):
    monkeypatch.setenv("SIMULATE_FAILURE", "true")
    response = app.test_client().get("/orders")
    assert response.status_code == 500
    assert response.json["error"] == "simulated incident"
