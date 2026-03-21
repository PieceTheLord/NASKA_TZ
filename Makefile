.PHONY: help install lint test run server-info docker-build docker-run compose-up compose-down compose-logs ansible-check ansible-dry ansible-run

APP_DIR = app
SCRIPTS_DIR = scripts
ANSIBLE_DIR = ansible

help:
	@echo "Доступные команды:"
	@echo "  help            Показать все доступные команды"
	@echo "  install         Установить зависимости Python локально"
	@echo "  lint            Проверить качество кода (ruff для Python, shellcheck для Bash)"
	@echo "  test            Запустить тесты"
	@echo "  run             Запустить приложение локально (FastAPI)"
	@echo "  server-info     Запустить Bash-скрипт диагностики сервера"
	@echo "  docker-build    Собрать Docker образ"
	@echo "  docker-run      Запустить контейнер"
	@echo "  compose-up      Запустить Docker Compose (в фоне)"
	@echo "  compose-down    Остановить Docker Compose"
	@echo "  compose-logs    Просмотреть логи Docker Compose"
	@echo "  ansible-check   Проверить синтаксис Ansible playbook"
	@echo "  ansible-dry     Запустить Ansible playbook в режиме dry-run"
	@echo "  ansible-run     Запустить Ansible playbook на серверах"

install:
	pip install -r $(APP_DIR)/requirements.txt
	pip install ruff

lint:
	ruff check $(APP_DIR)/
	bash -c "shellcheck $(SCRIPTS_DIR)/*.sh"

test:
	python -m pytest $(APP_DIR)/tests/ -v

run:
	uvicorn main:app --app-dir $(APP_DIR) --host 0.0.0.0 --port 5000 --reload

server-info:
	bash $(SCRIPTS_DIR)/server-info.sh http://localhost:5000/health

docker-build:
	docker build -t simple-app:latest .

docker-run:
	docker run -p 5000:5000 --rm --name simple-app-api simple-app:latest

compose-up:
	docker compose up -d

compose-down:
	docker compose down

docker-ps:
	docker ps

compose-logs:
	docker compose logs -f app

ansible-check:
	ansible-playbook --syntax-check -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml

ansible-dry:
	ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml --check

ansible-run:
	ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml