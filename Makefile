.PHONY: up down test test-api test-admin lint-admin build-admin e2e-admin test-website lint-website build-website e2e-website

up:
	docker compose up -d --build
	docker compose exec api php artisan db:seed --ansi

down:
	docker compose down

# Aggregate — runs every submodule's test target in sequence.
test: test-api test-admin test-website

test-api:
	docker compose exec api php artisan test

# Coverage-enabled per ARCHITECTURE.md §8.3's Gate legend — this is the
# command the 80%-coverage gate actually checks, not a plain test run.
test-admin:
	docker compose exec admin npm run test:coverage

lint-admin:
	docker compose exec admin npm run lint

build-admin:
	docker compose exec admin npm run build

# E2E smoke tests (Playwright) — run against the full `make up` stack, in
# the admin container's own browser install (see admin/Dockerfile), never
# on the host. Not part of Gate: full — called out per-task in tasks.md.
e2e-admin:
	docker compose exec admin npx playwright test

# Coverage-enabled — same rationale as test-admin above.
test-website:
	docker compose exec website npm run test:coverage

lint-website:
	docker compose exec website npm run lint

build-website:
	docker compose exec website npm run build

# E2E smoke tests (Playwright) — run against the full `make up` stack, in
# the website container's own browser install (see website/Dockerfile),
# never on the host. Not part of Gate: full — called out per-task in tasks.md.
e2e-website:
	docker compose exec website npx playwright test
