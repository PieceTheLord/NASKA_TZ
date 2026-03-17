import logging
import uuid
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field

# Настройка бонусного логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Simple App API", version="1.0.0")

# In-memory "база данных"
users_db = {}

# Pydantic модели для валидации данных (FastAPI сделает всю работу за нас)
class UserCreate(BaseModel):
    name: str = Field(..., description="Имя пользователя")
    email: str = Field(..., description="Email пользователя")

class UserResponse(UserCreate):
    id: str

@app.get("/")
def index():
    logger.info("Accessing root endpoint")
    return {"message": "Hello, World!"}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/api/users")
def get_users():
    logger.info("Fetching all users")
    return {"users": list(users_db.values())}

@app.post("/api/users", status_code=status.HTTP_201_CREATED, response_model=UserResponse)
def create_user(user: UserCreate):
    # FastAPI автоматически вернет 422 ошибку, если name или email пропущены
    user_id = str(uuid.uuid4())
    new_user = {
        "id": user_id,
        "name": user.name,
        "email": user.email
    }
    users_db[user_id] = new_user
    logger.info(f"Created new user with ID: {user_id}")
    return new_user

@app.get("/api/users/{user_id}", response_model=UserResponse)
def get_user(user_id: str):
    user = users_db.get(user_id)
    if not user:
        logger.error(f"User {user_id} not found")
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.delete("/api/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(user_id: str):
    if user_id in users_db:
        del users_db[user_id]
        logger.info(f"Deleted user: {user_id}")
        return
    logger.error(f"Failed to delete: User {user_id} not found")
    raise HTTPException(status_code=404, detail="User not found")