# 🚀 Simple App (DevOps Junior Test Task)

Простое REST API приложение на FastAPI, упакованное в Docker и автоматизированное с помощью Makefile, GitHub Actions и Ansible.

## 🛠 Технологии
- **Backend:** Python 3.12, FastAPI, Uvicorn, Pytest
- **DevOps:** Docker, Docker Compose, Ansible, GitHub Actions, Makefile
- **Скриптинг:** Bash (shellcheck)

## 📋 Требования
Для локального запуска вам понадобятся:
- Python 3.12+
- Docker и Docker Compose
- Ansible (для деплоя на сервер)
- Make (для удобного запуска команд)

---

## 🚀 Быстрый старт

### Локальный запуск (через Makefile)
```bash
# 1. Установить зависимости
make install

# 2. Запустить приложение (FastAPI)
make run

# Приложение будет доступно по адресу: http://localhost:5000
# Swagger-документация: http://localhost:5000/docs