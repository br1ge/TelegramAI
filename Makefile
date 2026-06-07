.PHONY: up down build rebuild logs list-admins add-admin remove-admin deploy

## Start the Bot service
up:
	docker compose up

## Rebuild and start the Bot service
build:
	DOCKER_BUILDKIT=1 docker compose up --build

## Complete rebuild from scratch (without cache)
rebuild:
	DOCKER_BUILDKIT=1 docker compose build --no-cache && docker compose up

## Deploy in background (daemon mode)
deploy:
	DOCKER_BUILDKIT=1 docker compose up --build -d

down:
	docker compose down

logs:
	docker compose logs -f

list-admins:
	docker compose exec -w /app/bot bot python3 admin_cli.py list

add-admin:
	@if [ -z "$(ID)" ]; then \
		echo "Usage: make add-admin ID=<telegram_user_id>"; \
		exit 1; \
	fi
	docker compose exec -w /app/bot bot python3 admin_cli.py add $(ID)

remove-admin:
	@if [ -z "$(ID)" ]; then \
		echo "Usage: make remove-admin ID=<telegram_user_id>"; \
		exit 1; \
	fi
	docker compose exec -w /app/bot bot python3 admin_cli.py remove $(ID)
