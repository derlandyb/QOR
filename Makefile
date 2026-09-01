.PHONY: up down test test-api test-admin lint-admin build-admin

up:
	docker compose up -d --build
	docker compose exec api php artisan db:seed --ansi

down:
	docker compose down

# Aggregate — runs every submodule's test target in sequence.
test: test-api test-admin

test-api:
	docker compose exec api php artisan test

test-admin:
	docker compose exec admin npm run test

lint-admin:
	docker compose exec admin npm run lint

build-admin:
	docker compose exec admin npm run build
