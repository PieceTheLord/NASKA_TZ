import pytest
from fastapi.testclient import TestClient
from app.main import app, users_db

client = TestClient(app)

@pytest.fixture(autouse=True)
def clear_db():
    # Очищаем БД перед каждым тестом
    users_db.clear()

def test_index():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, World!"}

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_get_empty_users():
    response = client.get("/api/users")
    assert response.status_code == 200
    assert response.json() == {"users":[]}

def test_create_user_success():
    response = client.post("/api/users", json={"name": "Ivan", "email": "ivan@example.com"})
    assert response.status_code == 201
    data = response.json()
    assert "id" in data
    assert data["name"] == "Ivan"

def test_create_user_validation_error():
    # Пропуск поля email вызовет ошибку валидации
    response = client.post("/api/users", json={"name": "Ivan"})
    # FastAPI стандартно возвращает 422 Unprocessable Entity при ошибке валидации
    assert response.status_code == 422 
    assert "detail" in response.json()