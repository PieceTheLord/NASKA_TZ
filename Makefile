.PHONY: help install lint test run server-info docker-build docker-run compose-up compose-down compose-logs ansible-check ansible-dry ansible-run

# Переменные
APP_DIR = app
SCRIPTS_DIR = scripts
ANSIBLE_DIR = ansible

help: ## Показать все доступные команды
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Установить зависимости Python локально
	pip install -r $(APP_DIR)/requirements.txt
	pip install ruff  # Устанавливаем линтер

lint: ## Проверить качество кода (ruff для Python, shellcheck для Bash)
	@echo "--- Запуск ruff для Python ---"
	ruff check $(APP_DIR)/
	@echo "--- Запуск shellcheck для Bash ---"
	shellcheck $(SCRIPTS_DIR)/*.sh

test: ## Запустить тесты
	PYTHONPATH=. pytest $(APP_DIR)/tests/ -v

run: ## Запустить приложение локально (FastAPI)
	uvicorn main:app --app-dir $(APP_DIR) --host 0.0.0.0 --port 5000 --reload

server-info: ## Запустить Bash-скрипт диагностики сервера
	bash $(SCRIPTS_DIR)/server-info.sh http://localhost:5000/health

docker-build: ## Собрать Docker образ
	docker build -t simple-app:latest .

docker-run: ## Запустить контейнер
	docker run -p 5000:5000 --rm --name simple-app-api simple-app:latest

compose-up: ## Запустить Docker Compose (в фоне)
	docker-compose up -d

compose-down: ## Остановить Docker Compose
	docker-compose down

compose-logs: ## Просмотреть логи Docker Compose
	docker-compose logs -f app

ansible-check: ## Проверить синтаксис Ansible playbook
	ansible-playbook --syntax-check -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml

ansible-dry: ## Запустить Ansible playbook в режиме dry-run (проверка изменений)
	ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml --check

ansible-run: ## Запустить Ansible playbook на серверах
	ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml