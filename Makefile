.PHONY: up down test

up:
	docker compose up -d --build
	docker compose exec api php artisan db:seed --ansi

down:
	docker compose down

test:
	docker compose exec api php artisan test
