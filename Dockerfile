# Бонус: используем slim образ для уменьшения размера
FROM python:3.12-slim

# Настройка переменных окружения
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_HOME=/app

WORKDIR $APP_HOME

# Бонус: создаем non-root пользователя для безопасности
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Установка зависимостей
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY app/ $APP_HOME/

# Меняем владельца файлов на non-root пользователя
RUN chown -R appuser:appuser $APP_HOME

# Переключаемся на non-root пользователя
USER appuser

EXPOSE 5000

# Добавляем HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Запуск через gunicorn
CMD["gunicorn", "--bind", "0.0.0.0:5000", "main:app"]