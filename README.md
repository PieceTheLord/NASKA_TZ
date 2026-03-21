# 🚀 Naska App: CI/CD & Cloud Infrastructure

Это демонстрационное REST API приложение на **FastAPI**, развернутое по принципам современного GitOps. Проект включает в себя полную автоматизацию: от тестирования кода до деплоя на удаленный VPS с автоматическим выпуском SSL-сертификатов.

## 🏗 Архитектура системы

Система построена на базе микросервисной архитектуры внутри Docker:
- **Reverse Proxy (Traefik v3):** Центральная точка входа. Занимается маршрутизацией трафика, SSL-терминацией (Let's Encrypt) и мониторингом состояния контейнеров через Docker Socket.
- **Backend (FastAPI):** Приложение Naska, упакованное в оптимизированный Docker-образ.
- **CI/CD (GitHub Actions):** Автоматизированный конвейер сборки, тестирования и доставки.
- **Registry (GHCR.io):** Хранилище образов GitHub Container Registry.

---

## 🛠 Технологический стек

- **Язык:** Python 3.12 (FastAPI, Pydantic, Uvicorn)
- **Контейнеризация:** Docker, Docker Compose
- **Инфраструктура:** Traefik v3, Let's Encrypt (Auto-SSL)
- **CI/CD:** GitHub Actions, GHCR
- **Сервер:** Ubuntu VPS (Beget)

---

## 📡 API Endpoints

Приложение доступно по адресу: `https://naska.alexey-web-dev.ru`

| Метод | Endpoint | Описание |
| :--- | :--- | :--- |
| GET | `/` | Приветственное сообщение |
| GET | `/health` | Проверка состояния системы (Healthcheck) |
| GET | `/api/users` | Получение списка пользователей |

---

## 🚀 CI/CD Пайплайн

Настроен автоматический деплой при каждом пуше в ветку `main`. Пайплайн состоит из трех этапов:

1. **Lint & Test:** Проверка качества кода с помощью `Ruff` и запуск модульных тестов `Pytest`.
2. **Build & Push:** Сборка Docker-образа и отправка в **GitHub Container Registry (GHCR)** с тегами `latest` и `sha-{commit}`.
3. **Deploy:** 
    - Копирование `docker-compose.prod.yml` на сервер через **SCP**.
    - Авторизация в GHCR на сервере.
    - Обновление контейнеров через `docker compose pull` и `up -d` (Zero Downtime).

### Настройка Secrets на GitHub
Для работы деплоя в репозитории настроены следующие переменные:
- `SERVER_IP`: IP-адрес вашего VPS.
- `SERVER_USER`: Пользователь (например, `root`).
- `SSH_PRIVATE_KEY`: Приватный SSH-ключ для доступа к серверу.

---

## 🔧 Настройка инфраструктуры (Traefik)

Traefik настроен как глобальный сервис в папке `/opt/traefik`. Он автоматически обнаруживает новые приложения по меткам (labels).

**Пример меток для подключения нового приложения:**
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.naska.rule=Host(`naska.alexey-web-dev.ru`)"
  - "traefik.http.routers.naska.entrypoints=websecure"
  - "traefik.http.routers.naska.tls.certresolver=myresolver"
  - "traefik.http.services.naska.loadbalancer.server.port=5000"
```

---

## 💻 Локальная разработка

Если вы хотите запустить проект локально:

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/ваш-ник/simple-app.git
   cd simple-app
   ```

2. **Запустите через Docker Compose:**
   ```bash
   docker-compose up --build
   ```

3. **Запустите тесты:**
   ```bash
   make test
   ```

---

## 📈 Мониторинг

Состояние всех маршрутов и сервисов можно отслеживать через Traefik Dashboard (доступ ограничен базовой авторизацией):
`https://traefik.alexey-web-dev.ru`

---

## 🛠 Устранение неполадок (Troubleshooting)

- **Ошибка 404:** Убедитесь, что контейнер запущен и имеет метку `traefik.enable=true`. Проверьте, что приложение слушает на `0.0.0.0`, а не на `127.0.0.1`.
- **SSL "Не защищено":** Проверьте логи Traefik (`docker logs traefik`). Обычно это связано с лимитами Let's Encrypt или не обновившимися DNS-записями.
- **Контейнер Unhealthy:** Проверьте логи приложения (`docker logs naska-api`). Скорее всего, команда Healthcheck в Dockerfile не может достучаться до порта приложения.

---
*Выполнено в рамках тестового задания на позицию DevOps Engineer.*

