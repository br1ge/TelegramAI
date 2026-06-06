.PHONY: up down build rebuild logs train list-admins add-admin remove-admin

## Run without recompiling (quickly)
up:
	@if [ -f .env ] && grep -q '^GEMINI_API_KEY=.' .env; then \
		echo "Starting only Bot service (using Gemini API)..."; \
		docker compose up bot; \
	else \
		echo "Starting Bot and AI Service (using local models)..."; \
		docker compose up; \
	fi

## Rebuild only the changed images and run
build:
	@if [ -f .env ] && grep -q '^GEMINI_API_KEY=.' .env; then \
		echo "Building and starting only Bot service (using Gemini API)..."; \
		DOCKER_BUILDKIT=1 docker compose up --build bot; \
	else \
		echo "Building and starting all services (using local models)..."; \
		DOCKER_BUILDKIT=1 docker compose up --build; \
	fi

## Complete rebuild from scratch (without cache)
rebuild:
	@if [ -f .env ] && grep -q '^GEMINI_API_KEY=.' .env; then \
		echo "Complete rebuild from scratch (using Gemini API)..."; \
		DOCKER_BUILDKIT=1 docker compose build --no-cache bot && docker compose up bot; \
	else \
		echo "Complete rebuild from scratch (using local models)..."; \
		DOCKER_BUILDKIT=1 docker compose build --no-cache && docker compose up; \
	fi

down:
	docker compose down

logs:
	docker compose logs -f

## Run fine-tuning. Set USE_GPU=true in .env to enable GPU.
train:
	$(eval USE_GPU ?= false)
	@if [ "$$(grep -s '^USE_GPU=true' .env)" ]; then \
		echo "Training with GPU..."; \
		DOCKER_BUILDKIT=1 docker compose -f docker-compose.yml -f docker-compose.gpu.yml run --rm train python train.py; \
	else \
		echo "Training with CPU..."; \
		DOCKER_BUILDKIT=1 docker compose run --rm train python train.py; \
	fi

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
