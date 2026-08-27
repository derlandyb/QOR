# API Tasks — `api` (Laravel, PHP 8.4)

**Submodule**: `qor-api` (git remote name) — checked out locally as `api/`
**Design refs**: `.specs/features/event-discovery/design.md`, `.specs/features/auth-fan-profile/design.md`, `.specs/features/venue-promoter-admin/design.md`
**Architecture ref**: `.specs/project/ARCHITECTURE.md`
**Status**: Draft
**Milestone**: MVP Core only (Event Discovery + Auth & Fan Profile P1/AUTH-25 + Venue/Promoter Admin P1+P2)
**Database**: PostgreSQL (confirmed) — Docker Compose service `postgres:16`, Eloquent driver `pgsql`
**Test coverage source**: no `.specs/codebase/TESTING.md` exists yet (greenfield). Gate commands below are stack defaults per `ARCHITECTURE.md` §8, to be confirmed once the repo is actually scaffolded (T1). Test-type-per-layer follows §8.3 (TDD mandatory, 80% coverage, GIVEN/WHEN/THEN naming): domain use cases → **unit**, controllers/HTTP boundary → **integration** (Laravel feature tests against a real DB), infra scaffolding (Docker/CI/config) → **none**, gated by the **build**/CI pipeline itself passing.

**Tools (all tasks, unless a task overrides it, confirmed with user)**: MCP `context7` (Laravel/Sanctum/Postgres API lookups per the Knowledge Verification Chain), `github` (PR creation once each milestone's tasks land, per ARCHITECTURE §8.10–§8.11) / Skill `NONE`.

---

## Execution Plan

### Phase 1: Foundation (sequential)

```
T1 → T2 → T3 → T4 → T5 → T6 → T7 → T8
```

### Phase 2: Core domain/data (parallel-safe subset, after Phase 1)

```
T7 ──┬→ T9  ─┐
     ├→ T10 ─┤
     ├→ T11 ─┤
     ├→ T12 ─┼→ T16 ─┐
     ├→ T13 ─┤        ├→ T20 ─┐
     ├→ T14 ─┤        │        ├→ T22
     └→ T15 ─┘        └→ T21 ─┘
T16,T17,T18,T19 also depend on T9–T15 (their respective entities)
```

### Phase 3: Feature use cases + endpoints (after Phase 2)

```
Event Discovery:      T16 → T23 → T25
                       T16 → T24 → T25

Auth & Fan Profile:    T17,T15 → T26 → T31
                       T17 → T27 → T31
                       T17 → T28 → T31
                       T17,T21 → T29 → T32
                       T17,T15 → T30 → T32
                       T33 (shared consent contract) → T26, T34, T35

Venue/Promoter Admin:  T18,T15,T33 → T34 → T40
                       T18,T15,T33 → T35 → T40
                       T18,T19,T20 → T36 → T42
                       T12,T20,T21 → T37 → T41
                       T12,T20 → T38 → T41
                       T12,T19 → T39 → T43
```

### Phase 4: P2 stretch (venue-promoter-admin ADMIN-21–27, still "In Design", same milestone) + Integration/hardening (sequential where noted)

```
T41 → T44 → T46 → T47
T12 → T45 (scheduled job, independent)
T41 → T48 (P2 dashboard)
T36 → T49 (P2 suspension)

T25,T31,T32,T40,T41,T42,T43 → T50 → T51 → T52
```

---

## Task Breakdown

### Phase 1 — Foundation

#### T1: Scaffold `api` Laravel 11 repo on PHP 8.4
**What**: `composer create-project laravel/laravel api`, rename `app/` → `src/`, update `composer.json` PSR-4 autoload to `QOR\App\`, update all framework bootstrap references (`bootstrap/app.php`, config `providers`) to the new namespace/path.
**Where**: `api/composer.json`, `api/bootstrap/app.php`, `api/src/**`
**Depends on**: None
**Reuses**: n/a — first task in the repo
**Requirement**: ARCHITECTURE §8.6
**Done when**:
- [ ] `php artisan --version` runs inside the container
- [ ] `src/` exists, `app/` does not
- [ ] Every class resolves under `QOR\App\` namespace
- [ ] Gate check passes: `php artisan test` (framework's default smoke test, 0 custom tests yet)
**Tests**: none
**Gate**: build

#### T2: Docker Compose service (`api` + `postgres:16`) + root Makefile wiring
**What**: Add `api` and `db` services to the root Docker Compose file (per ARCHITECTURE §8.1), wire `make up`/`make down`/`make test` at the repo root to include this stack.
**Where**: `docker-compose.yml` (root), `Makefile` (root), `api/.env.example`
**Depends on**: T1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §8.1
**Done when**:
- [ ] `make up` starts `api` + Postgres and Laravel connects successfully
- [ ] `make test` runs `api`'s test suite inside the container
- [ ] No `docker compose` invoked directly outside the Makefile anywhere in docs/scripts
**Tests**: none
**Gate**: build

#### T3: CI workflow (lint/test/coverage gate)
**What**: One GitHub Actions workflow scoped to `api` only (ARCHITECTURE §8.2), running PHPStan strict, `php artisan test` with coverage, failing under 80%.
**Where**: `.github/workflows/api-ci.yml` (in the `api` submodule repo)
**Depends on**: T1, T2
**Reuses**: n/a
**Requirement**: ARCHITECTURE §8.2, §8.3, §8.4
**Done when**:
- [ ] Workflow triggers on PR to `api`'s `main`
- [ ] Lint (PHPStan strict) and test+coverage steps both present and required checks
- [ ] Coverage threshold set to 80%, workflow fails below it
**Tests**: none
**Gate**: build

#### T4: Backed enums + `Genre` lookup table
**What**: Create PHP 8.1+ backed enums under `src/Domain/**/Enum/` for the MVP Core subset: `EventStatus`, `ApprovalStatus`, `City`, `ConsentType`, `ApprovalOutcome`, `ApprovalDecidableType`, `EventCreatedByType`. Create the `genres` DB-backed lookup table (migration + seed rows) — deliberately not an enum, per ARCHITECTURE §14.1.
**Where**: `api/src/Domain/Event/Enum/EventStatus.php`, `.../Approval/Enum/{ApprovalStatus,ApprovalOutcome,ApprovalDecidableType}.php`, `.../Shared/Enum/City.php`, `.../User/Enum/ConsentType.php`, `.../Event/Enum/EventCreatedByType.php`, `api/database/migrations/..._create_genres_table.php`
**Depends on**: T1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §14.1
**Done when**:
- [ ] Every enum listed above exists as a backed enum, no raw string comparisons anywhere else in the codebase reference these concepts
- [ ] `genres` table migrated + seeded with the initial genre set from the PRD/design-system genre tags (Rock, Samba, Sertanejo, Eletrônico, Reggae, ...)
- [ ] Unit test per enum: GIVEN a raw value WHEN cast THEN it resolves to the correct case; invalid value throws
- [ ] Gate check passes: `php artisan test --filter=Enum`
**Tests**: unit
**Gate**: quick

#### T5: `config/qor.php` constants
**What**: Central config file for every numeric/string threshold the MVP Core features need — password rules (`qor.auth.password_rules`), reset-link TTL (`qor.auth.password_reset_ttl_minutes`), pagination sizes (`qor.pagination.public_page_size`), event-list polling interval (`qor.polling.event_list_interval_seconds`) — no inlined literals anywhere else.
**Where**: `api/config/qor.php`
**Depends on**: T1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §14.2
**Done when**:
- [ ] Every constant named in the Auth/Event-Discovery design docs (T5 above) exists here, nowhere else
- [ ] `config('qor.auth.password_rules')` etc. resolve correctly in tinker
**Tests**: none
**Gate**: build

#### T6: Sanctum dual-guard setup
**What**: Configure two separate Sanctum guards — `fan` (bearer token for mobile, SPA cookie for website/landing) and `admin` (SPA cookie for admin panel) — per ARCHITECTURE §2, with separate user providers so a fan credential cannot authenticate against the admin guard and vice versa.
**Where**: `api/config/auth.php`, `api/config/sanctum.php`, `api/src/Http/Middleware/*`
**Depends on**: T1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §2
**Done when**:
- [ ] Two guards defined, each with its own provider (`fans` table vs `venue_promoter_admins`/polymorphic admin provider)
- [ ] Integration test: GIVEN a fan bearer token WHEN hitting an `admin`-guarded route THEN 401/403 (not authenticated as admin)
- [ ] Gate check passes: `php artisan test --filter=Guard`
**Tests**: integration
**Gate**: full

#### T7: `/api/v1` and `/api/admin/v1` route group skeletons
**What**: Two separate route files (`routes/api_v1.php`, `routes/api_admin_v1.php`) registered as distinct groups with their respective guard middleware — hard boundary per ARCHITECTURE §3, not a naming convention.
**Where**: `api/routes/api_v1.php`, `api/routes/api_admin_v1.php`, `api/bootstrap/app.php` (route registration)
**Depends on**: T6
**Reuses**: n/a
**Requirement**: ARCHITECTURE §3
**Done when**:
- [ ] Both route files exist, empty group skeletons registered, versioned path prefixes correct
- [ ] Integration test: GIVEN a request to an undefined `/api/v1/*` route WHEN dispatched THEN 404 with the pt-BR error envelope (not a stack trace)
**Tests**: integration
**Gate**: full

#### T8: Update `ARCHITECTURE.md` to name PostgreSQL
**What**: Replace the generic `DB[("Database")]` mermaid node and any prose references to "Database" with "PostgreSQL" now that it's confirmed.
**Where**: `.specs/project/ARCHITECTURE.md` (root repo, not `api/`)
**Depends on**: None (doc-only, can run any time in Phase 1)
**Reuses**: n/a
**Requirement**: user-confirmed decision (this Tasks phase)
**Done when**:
- [ ] §1 diagram node and any other "Database"/"DB" prose mentions now say PostgreSQL
**Tests**: none
**Gate**: none (doc change, no CI gate)

---

## Phase 2 — Core domain/data

*(Each of T9–T15 follows the same shape: domain entity + Eloquent model + migration + factory. Compressed to one row per entity below since the pattern is identical — see T9 for the full template, others reference it.)*

#### T9: `User` entity + migration + factory
**What**: Domain entity (`src/Domain/User/User.php`, zero framework deps) + Eloquent model + migration for `users` (email, password_hash, birthdate, google_id nullable, phone nullable, profile_picture_url nullable, email_verified_at, approval-irrelevant — fans don't need approval) + model factory for seeding/tests.
**Where**: `api/src/Domain/User/User.php`, `api/src/Infrastructure/Persistence/Eloquent/UserModel.php`, `api/database/migrations/..._create_users_table.php`, `api/database/factories/UserFactory.php`
**Depends on**: T4 (enums), T7
**Reuses**: n/a — first entity, establishes the domain/Eloquent split pattern every other entity below follows
**Requirement**: ARCHITECTURE §4
**Done when**:
- [ ] Domain entity has zero Eloquent/framework imports
- [ ] Migration matches the field list in ARCHITECTURE §4
- [ ] Unit test: GIVEN valid fields WHEN constructing `User` THEN entity is valid; invalid email format is rejected at the domain boundary
- [ ] Gate check passes: `php artisan test --filter=UserTest`
**Tests**: unit
**Gate**: quick

#### T10: `Venue` entity + migration + factory
**What**: Same pattern as T9 — name, description, address, contact, image_url, approval_status (`ApprovalStatus`).
**Where**: `api/src/Domain/Venue/Venue.php`, `api/src/Infrastructure/Persistence/Eloquent/VenueModel.php`, migration, factory
**Depends on**: T4, T7
**Reuses**: T9's domain/Eloquent split pattern
**Requirement**: ARCHITECTURE §4
**Done when**: same shape as T9's checklist, entity-specific fields
**Tests**: unit
**Gate**: quick

#### T11: `Promoter` entity + migration + factory
**What**: Same pattern — name, contact_phone, contact_email, instagram, tiktok, approval_status.
**Where**: `api/src/Domain/Promoter/Promoter.php`, Eloquent model, migration, factory
**Depends on**: T4, T7
**Reuses**: T9's pattern
**Requirement**: ARCHITECTURE §4
**Tests**: unit
**Gate**: quick

#### T12: `Event` entity + migration + factory
**What**: title, description, cover_image_url, starts_at, city (`City`), genre_id (FK to `genres`), status (`EventStatus`), is_free, ticket_url nullable, capacity nullable, age_rating nullable, notes nullable, created_by_type/created_by_id (polymorphic organizer).
**Where**: `api/src/Domain/Event/Event.php`, Eloquent model, migration, factory
**Depends on**: T4, T7 (and T4's `genres` table)
**Reuses**: T9's pattern
**Requirement**: ARCHITECTURE §4, §5 (state machine)
**Done when**: standard T9-shape checklist + unit test asserting the state machine's legal transitions (`Draft→PendingReview→Published|Draft→Cancelled|Encerrado`) are enforced at the entity level, illegal transitions throw
**Tests**: unit
**Gate**: quick

#### T13: `EventPromoter` pivot entity + migration
**What**: Many-to-many tag table linking `Event` to `Promoter` (contact-display-only, no edit rights — enforced later in T20's policy, not here).
**Where**: `api/src/Domain/Event/EventPromoter.php`, migration
**Depends on**: T11, T12
**Reuses**: T9's pattern
**Requirement**: ARCHITECTURE §4
**Tests**: unit
**Gate**: quick

#### T14: `ApprovalDecision` entity + migration (polymorphic)
**What**: One polymorphic table — `decidable_type`/`decidable_id` (`Venue`|`Promoter`|`Event`, via `ApprovalDecidableType`), `outcome` (`ApprovalOutcome`), `reason` nullable, `decided_by`, `decided_at`. Backs both account and event approval audit trails per ARCHITECTURE §6.
**Where**: `api/src/Domain/Approval/ApprovalDecision.php`, Eloquent model, migration
**Depends on**: T4, T7
**Reuses**: T9's pattern
**Requirement**: ARCHITECTURE §6
**Tests**: unit
**Gate**: quick

#### T15: `ConsentRecord` entity + migration
**What**: `user_id`, `consent_type` (`ConsentType`), `policy_version`, `accepted_at`. Shared by fan, Venue, and Promoter registration flows.
**Where**: `api/src/Domain/User/ConsentRecord.php`, Eloquent model, migration
**Depends on**: T4, T7
**Reuses**: T9's pattern
**Requirement**: ARCHITECTURE §7, `auth-fan-profile/design.md`
**Tests**: unit
**Gate**: quick

#### T16: `EventRepository` interface + `EloquentEventRepository`
**What**: `findUpcoming(filters, cursor): EventPage`, `findById(id): ?Event`, plus write-side methods the admin feature needs (`save`, `delete`) — one repository, two feature designs share it.
**Where**: `api/src/Domain/Event/EventRepository.php` (interface), `api/src/Infrastructure/Persistence/EloquentEventRepository.php`
**Depends on**: T12, T13
**Reuses**: n/a
**Requirement**: `event-discovery/design.md`, `venue-promoter-admin/design.md`
**Done when**:
- [ ] Interface has zero Eloquent imports; implementation only referenced from the service container binding, never directly by domain use cases
- [ ] Unit test (repository contract, in-memory fake) + integration test (Eloquent impl against real Postgres): cursor pagination returns correct page boundaries on a live-changing dataset
**Tests**: integration (DB-backed repository, per coverage-matrix default for persistence-layer code)
**Gate**: full

#### T17: `UserRepository` interface + `EloquentUserRepository`
**What**: `findByEmail`, `findById`, `save`, `delete` (soft, cascading per ARCHITECTURE §7).
**Where**: `api/src/Domain/User/UserRepository.php`, `api/src/Infrastructure/Persistence/EloquentUserRepository.php`
**Depends on**: T9, T15
**Reuses**: T16's interface/adapter split pattern
**Requirement**: `auth-fan-profile/design.md`
**Tests**: integration
**Gate**: full

#### T18: `VenueRepository` / `PromoterRepository` interfaces + Eloquent adapters
**What**: Same shape as T17, one pair per entity.
**Where**: `api/src/Domain/{Venue,Promoter}/{Venue,Promoter}Repository.php`, `api/src/Infrastructure/Persistence/Eloquent{Venue,Promoter}Repository.php`
**Depends on**: T10, T11, T15
**Reuses**: T16's pattern
**Requirement**: `venue-promoter-admin/design.md`
**Tests**: integration
**Gate**: full

#### T19: `ApprovalDecisionRepository` interface + Eloquent adapter
**What**: `save(decision): ApprovalDecision`, `findPendingAccounts(): Collection`, `findPendingEvents(): Collection` (feeds the two approval queues).
**Where**: `api/src/Domain/Approval/ApprovalDecisionRepository.php`, Eloquent adapter
**Depends on**: T14
**Reuses**: T16's pattern
**Requirement**: `venue-promoter-admin/design.md`
**Tests**: integration
**Gate**: full

#### T20: `EventPolicy` / `VenuePolicy` / `PromoterPolicy`
**What**: Laravel Policy classes — approval-status gating (a `Pending Approval`/suspended account blocked from every write action, ADMIN-20) and event ownership (tagged promoter without ownership can't edit, ADMIN-24). Invoked by controllers, never ad hoc `if` checks (ARCHITECTURE §2).
**Where**: `api/src/Http/Policies/{Event,Venue,Promoter}Policy.php`
**Depends on**: T10, T11, T12, T13
**Reuses**: n/a
**Requirement**: ADMIN-20, ADMIN-24
**Done when**:
- [ ] Unit tests: GIVEN a `Pending Approval` organizer WHEN checking `create`/`update`/`submit` THEN denied; GIVEN a non-owning tagged promoter WHEN checking `update` THEN denied; GIVEN an approved owner THEN allowed
- [ ] Gate check passes: `php artisan test --filter=Policy`
**Tests**: unit
**Gate**: quick

#### T21: `S3UploadAdapter`
**What**: Multipart file upload only (never a pasted URL) — server-side MIME/size/dimension validation before forwarding to S3/CDN, returns the stored key/URL. Shared by profile pictures, venue images, and event cover images (one adapter, not one per entity).
**Where**: `api/src/Infrastructure/Storage/S3UploadAdapter.php`, `api/src/Domain/Shared/FileUploadPort.php` (interface the domain depends on)
**Depends on**: T1
**Reuses**: n/a — this is itself the shared component `auth-fan-profile/design.md` and `venue-promoter-admin/design.md` both reuse
**Requirement**: ARCHITECTURE §10
**Done when**:
- [ ] Rejects non-image MIME types, oversized files, and out-of-range dimensions with field-specific pt-BR errors, before any S3 call
- [ ] Integration test against a local S3-compatible stub (e.g. MinIO in Docker Compose): valid upload round-trips to a retrievable URL
**Tests**: integration
**Gate**: full

#### T22: Seeders — realistic dev data across all 4 cities
**What**: Seeders producing sample Fans, Venues, Promoters, Events across Vitória/Vila Velha/Serra/Cariacica and multiple genres/statuses, using real stock image URLs matched to genre/vibe (not lorem-ipsum). Runs as part of `make up` (ARCHITECTURE §8.7).
**Where**: `api/database/seeders/DatabaseSeeder.php` + per-entity seeders
**Depends on**: T9–T15 (all entities), factories from those tasks
**Reuses**: factories from T9–T15
**Requirement**: ARCHITECTURE §8.7
**Done when**:
- [ ] `php artisan db:seed` produces at least: fans, venues+promoters across all 4 cities, events across `Draft`/`PendingReview`/`Published`/`Cancelled`/`Encerrado` and all seeded genres
- [ ] Runs automatically as part of `make up`
**Tests**: none
**Gate**: build

---

## Phase 3 — Feature use cases + endpoints

### Event Discovery

#### T23: `ListUpcomingEvents` use case
**What**: `execute(city?, genre?, cursor?): EventPage` — `Published`, non-past, soonest-first, optional city/genre AND-filter, cursor pagination.
**Where**: `api/src/Domain/Event/UseCase/ListUpcomingEvents.php`
**Depends on**: T16
**Reuses**: `EventRepository` (T16)
**Requirement**: DISC-01–DISC-06, DISC-14–DISC-18
**Done when**:
- [ ] Unit tests (GIVEN/WHEN/THEN, mocked repository): soonest-first ordering; past events excluded; city+genre AND-combination; invalid city value raises a domain validation error (422 at the controller); empty filters return the unfiltered list
- [ ] Gate check passes: `php artisan test --filter=ListUpcomingEvents`, test count ≥ 6
**Tests**: unit
**Gate**: quick

#### T24: `GetEventDetails` use case
**What**: `execute(eventId): EventDetail` — full detail incl. tagged promoters (omitting only missing individual contact fields, not the whole promoter), cancelled/ended-state payload instead of 404 for stale links.
**Where**: `api/src/Domain/Event/UseCase/GetEventDetails.php`
**Depends on**: T16, T13
**Reuses**: `EventRepository` (T16)
**Requirement**: DISC-07–DISC-13
**Done when**:
- [ ] Unit tests: full-field happy path; cancelled event returns cancelled-state payload; encerrado event returns past-state payload; promoter missing one contact field omits only that link
- [ ] Gate check passes, test count ≥ 5
**Tests**: unit
**Gate**: quick

#### T25: `EventController` (public, `/api/v1`)
**What**: `GET /api/v1/events?city=&genre=&cursor=`, `GET /api/v1/events/{id}` — no guard (public read surface per event-discovery's Architecture Overview).
**Where**: `api/src/Http/Controllers/Api/V1/EventController.php`
**Depends on**: T23, T24, T7
**Reuses**: `ListUpcomingEvents` (T23), `GetEventDetails` (T24)
**Requirement**: DISC-01–DISC-18
**Done when**:
- [ ] Integration tests: 200 + correct envelope for list/detail; 422 for invalid city/genre; cancelled/encerrado detail returns 200 with state banner, not 404
- [ ] Gate check passes: `php artisan test --filter=EventControllerTest`, test count ≥ 6
- [ ] Postman-collection-ready (used by T50)
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add public event discovery endpoints`

### Auth & Fan Profile

#### T26: `RegisterFan` use case
**What**: `execute(email, password, birthdate, profileFields, consentAcceptance): User` — creates `Pending`-verification account, sends verification email (email-sending itself stubbed/logged in MVP Core — real SES delivery is Notifications-milestone scope per plan decision #4; this task only triggers the domain event/interface call), rejects duplicate email across both auth methods, enforces password-strength policy from `config/qor.php`.
**Where**: `api/src/Domain/User/UseCase/RegisterFan.php`
**Depends on**: T17, T15 (ConsentRepository), T33
**Reuses**: `ConsentRecord`/consent contract (T33), `config('qor.auth.password_rules')` (T5)
**Requirement**: AUTH-01–AUTH-05
**Done when**:
- [ ] Unit tests: happy path creates `Pending` account + consent record; duplicate email (either method) rejected with specific message; weak password rejected with specific reason; unchecked-by-default consent enforced
- [ ] Gate check passes, test count ≥ 6
**Tests**: unit
**Gate**: quick

#### T27: `AuthenticateFan` use case
**What**: `executeWithPassword(email, password): Session`, `executeWithGoogle(googleIdToken): Session` — generic invalid-credentials message, unverified-account block, Google new-vs-existing-account branching, Google-verified-email shortcut.
**Where**: `api/src/Domain/User/UseCase/AuthenticateFan.php`
**Depends on**: T17
**Reuses**: `SanctumAuthAdapter` (built inline here, wraps T6's guard config)
**Requirement**: AUTH-06–AUTH-12
**Done when**:
- [ ] Unit tests: correct verified-account login issues session; wrong password → generic message; unverified account blocked with resend offer; Google new-email creates account pre-filled + still requires consent; Google existing-email logs into existing account, no duplicate
- [ ] Gate check passes, test count ≥ 6
**Tests**: unit
**Gate**: quick

#### T28: `ResetPassword` use case
**What**: `requestReset(email): void`, `confirmReset(token, newPassword): void` — no account enumeration, TTL/single-use enforcement from `config('qor.auth.password_reset_ttl_minutes')`.
**Where**: `api/src/Domain/User/UseCase/ResetPassword.php`
**Depends on**: T17
**Reuses**: `config('qor.auth.password_reset_ttl_minutes')` (T5)
**Requirement**: AUTH-13–AUTH-16
**Done when**:
- [ ] Unit tests: known-email request and unknown-email request return identical success signal; valid unexpired token resets + invalidates link; expired/reused token rejected
- [ ] Gate check passes, test count ≥ 4
**Tests**: unit
**Gate**: quick

#### T29: `UpdateProfile` use case
**What**: `execute(userId, fields): User` — edit username/phone/picture immediately, email change requires re-verification before taking effect.
**Where**: `api/src/Domain/User/UseCase/UpdateProfile.php`
**Depends on**: T17, T21
**Reuses**: `FileUploadPort`/`S3UploadAdapter` (T21)
**Requirement**: AUTH-17–AUTH-19
**Done when**:
- [ ] Unit tests: each editable field persists; email change leaves old email active until new one verified; Google-sourced fields still independently editable
- [ ] Gate check passes, test count ≥ 4
**Tests**: unit
**Gate**: quick

#### T30: `ExerciseDataRight` use case
**What**: `access`, `delete` (soft + PII scrub + cascade per ARCHITECTURE §7), `export`, `revokeConsent`.
**Where**: `api/src/Domain/User/UseCase/ExerciseDataRight.php`
**Depends on**: T17, T15
**Reuses**: `UserRepository` (T17), `ConsentRecord` (T15)
**Requirement**: AUTH-25
**Done when**:
- [ ] Unit tests: access returns full readable summary; delete cascades to dependent records with zero orphaned PII (verified against a fixture with related rows); export returns a portable-format payload; revoke stops the corresponding data use without full deletion
- [ ] Gate check passes, test count ≥ 5
**Tests**: unit
**Gate**: quick

#### T31: `AuthController` (`/api/v1/auth/*`)
**What**: `POST /register`, `/login`, `/google`, `/logout`, `/password/forgot`, `/password/reset`.
**Where**: `api/src/Http/Controllers/Api/V1/AuthController.php`
**Depends on**: T26, T27, T28, T7
**Reuses**: `RegisterFan`/`AuthenticateFan`/`ResetPassword` (T26–T28)
**Requirement**: AUTH-01–AUTH-16
**Done when**:
- [ ] Integration tests covering each endpoint's happy + one failure path each
- [ ] Gate check passes, test count ≥ 8
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add fan auth endpoints`

#### T32: `ProfileController` (`/api/v1/profile/*`)
**What**: `GET/PATCH /profile`, `POST /profile/picture`, `GET/POST /profile/data-rights/{access|export|delete|revoke}`.
**Where**: `api/src/Http/Controllers/Api/V1/ProfileController.php`
**Depends on**: T29, T30, T7
**Reuses**: `UpdateProfile`/`ExerciseDataRight` (T29, T30)
**Requirement**: AUTH-17–AUTH-19, AUTH-25
**Done when**:
- [ ] Integration tests covering each endpoint
- [ ] Gate check passes, test count ≥ 6
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add fan profile and data-rights endpoints`

#### T33: Shared consent-capture backend contract
**What**: The `ConsentRepository` interface + validation rule ensuring signup forms across fan/Venue/Promoter always require explicit, non-pre-checked acceptance before account creation — one contract, reused (not reimplemented) by T26, T34, T35.
**Where**: `api/src/Domain/User/ConsentRepository.php`, `api/src/Infrastructure/Persistence/EloquentConsentRepository.php`
**Depends on**: T15
**Reuses**: `ConsentRecord` (T15)
**Requirement**: AUTH-02, AUTH-03, ADMIN-02, ADMIN-06
**Done when**:
- [ ] Unit test: consent not accepted → registration use cases reject before any account row is created (verified via a shared contract test reused by T26/T34/T35's suites)
**Tests**: unit
**Gate**: quick

### Venue/Promoter Admin

#### T34: `RegisterVenue` use case
**What**: `execute(registrationFields, consentAcceptance): Venue` — creates `Pending Approval`, required-field validation, duplicate-email rejection.
**Where**: `api/src/Domain/Venue/UseCase/RegisterVenue.php`
**Depends on**: T18, T33
**Reuses**: T33's consent contract
**Requirement**: ADMIN-01–ADMIN-04
**Done when**: unit tests mirroring T26's shape for the Venue entity; test count ≥ 5
**Tests**: unit
**Gate**: quick

#### T35: `RegisterPromoter` use case
**What**: Same shape as T34 for `Promoter`.
**Where**: `api/src/Domain/Promoter/UseCase/RegisterPromoter.php`
**Depends on**: T18, T33
**Reuses**: T33's consent contract, T34's pattern
**Requirement**: ADMIN-05–ADMIN-06
**Tests**: unit
**Gate**: quick

#### T36: `DecideAccountApproval` use case
**What**: `execute(accountType, accountId, outcome, reason?, decidedBy): ApprovalDecision` — approve/reject/suspend/lift-suspension, auditable.
**Where**: `api/src/Domain/Approval/UseCase/DecideAccountApproval.php`
**Depends on**: T18, T19, T20
**Reuses**: `ApprovalDecisionRepository` (T19), `VenuePolicy`/`PromoterPolicy` (T20)
**Requirement**: ADMIN-07–ADMIN-10, ADMIN-27
**Done when**:
- [ ] Unit tests: approve unblocks event creation; reject with/without reason both allowed; suspend blocks an already-approved account; lift-suspension restores it; every outcome recorded as an `ApprovalDecision` row
- [ ] Gate check passes, test count ≥ 6
**Tests**: unit
**Gate**: quick

#### T37: `CreateEvent` use case
**What**: `execute(createdByType, createdById, eventFields): Event` — saves as `Draft`; Promoter enters own location, Venue Admin defaults to registered address; blocks unapproved accounts.
**Where**: `api/src/Domain/Event/UseCase/CreateEvent.php`
**Depends on**: T12, T20, T21
**Reuses**: `EventPolicy` (T20), `FileUploadPort` (T21)
**Requirement**: ADMIN-11–ADMIN-13
**Done when**:
- [ ] Unit tests: Venue-created event defaults to venue address; Promoter-created event requires explicit location; unapproved account blocked
- [ ] Gate check passes, test count ≥ 4
**Tests**: unit
**Gate**: quick

#### T38: `SubmitEventForReview` use case
**What**: `Draft → Pending Review` with required-field validation, unapproved-account block.
**Where**: `api/src/Domain/Event/UseCase/SubmitEventForReview.php`
**Depends on**: T12, T20
**Reuses**: `EventPolicy` (T20)
**Requirement**: ADMIN-14–ADMIN-15, ADMIN-20
**Done when**: unit tests for happy path, missing-field block, unapproved-account block; test count ≥ 4
**Tests**: unit
**Gate**: quick

#### T39: `DecideEventApproval` use case
**What**: `execute(eventId, outcome, feedback?, decidedBy): ApprovalDecision` — approve → `Published`, reject → auto-return to `Draft` with feedback attached, force-cancel, auditable; if approved after the event's date has passed, immediately mark `Encerrado` instead of `Published`.
**Where**: `api/src/Domain/Approval/UseCase/DecideEventApproval.php`
**Depends on**: T12, T19
**Reuses**: `ApprovalDecisionRepository` (T19)
**Requirement**: ADMIN-16–ADMIN-19, ADMIN-22
**Done when**:
- [ ] Unit tests: approve before date-passed → `Published`; approve after date-passed → `Encerrado` directly; reject → `Draft` with feedback visible; every decision recorded
- [ ] Gate check passes, test count ≥ 5
**Tests**: unit
**Gate**: quick

#### T40: `VenueController` / `PromoterController` (registration)
**What**: `POST /api/admin/v1/venues/register`, `POST /api/admin/v1/promoters/register`.
**Where**: `api/src/Http/Controllers/Api/AdminV1/{Venue,Promoter}Controller.php`
**Depends on**: T34, T35, T7
**Reuses**: `RegisterVenue`/`RegisterPromoter` (T34, T35)
**Requirement**: ADMIN-01–ADMIN-06
**Done when**: integration tests per endpoint, happy + duplicate-email failure; test count ≥ 4
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add venue/promoter self-registration endpoints`

#### T41: `EventController` (admin write side, `/api/admin/v1`)
**What**: `GET/POST/PATCH/DELETE /api/admin/v1/events`, `POST /api/admin/v1/events/{id}/submit` — distinct controller from T25's public read-only one.
**Where**: `api/src/Http/Controllers/Api/AdminV1/EventController.php`
**Depends on**: T37, T38, T7
**Reuses**: `CreateEvent`/`SubmitEventForReview` (T37, T38), `EventPolicy` (T20)
**Requirement**: ADMIN-11–ADMIN-15, ADMIN-20
**Done when**: integration tests: create/edit/delete/submit happy paths + unapproved-account 403; test count ≥ 6
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add organizer event CRUD and submission endpoints`

#### T42: `AccountApprovalController`
**What**: `GET /api/admin/v1/approvals/accounts`, `POST /api/admin/v1/approvals/accounts/{id}/decide`.
**Where**: `api/src/Http/Controllers/Api/AdminV1/AccountApprovalController.php`
**Depends on**: T36, T7
**Reuses**: `DecideAccountApproval` (T36)
**Requirement**: ADMIN-07–ADMIN-10
**Done when**: integration tests: queue lists pending accounts; approve/reject/suspend/lift all work end-to-end; test count ≥ 5
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add account approval queue endpoints`

#### T43: `EventApprovalController`
**What**: `GET /api/admin/v1/approvals/events`, `POST /api/admin/v1/approvals/events/{id}/decide`.
**Where**: `api/src/Http/Controllers/Api/AdminV1/EventApprovalController.php`
**Depends on**: T39, T7
**Reuses**: `DecideEventApproval` (T39)
**Requirement**: ADMIN-16–ADMIN-19
**Done when**: integration tests: queue lists pending events; approve/reject end-to-end, including the past-date→Encerrado edge case; test count ≥ 5
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add event publish-queue endpoints`

---

## Phase 4 — P2 stretch (same feature, "In Design" per spec) + Integration/hardening

#### T44: `EditEvent` / `DuplicateEvent` / `CancelEvent` use cases [P]
**What**: Edit own draft/rejected-now-draft event; non-critical-field edit on `Published` without re-review; duplicate as new draft minus date/time; organizer/Super-Admin cancellation.
**Where**: `api/src/Domain/Event/UseCase/{EditEvent,DuplicateEvent,CancelEvent}.php`
**Depends on**: T41
**Reuses**: `EventPolicy` (T20) — ownership check enforces ADMIN-24
**Requirement**: ADMIN-21, ADMIN-22
**Tests**: unit
**Gate**: quick

#### T45: Natural event end — scheduled job [P]
**What**: Scheduled job transitioning `Published` → `Encerrado` when `starts_at` passes.
**Where**: `api/src/Console/Commands/CloseEndedEvents.php`, `api/routes/console.php` (schedule registration)
**Depends on**: T12
**Reuses**: `EventStatus` enum (T4)
**Requirement**: ADMIN-23
**Done when**: unit test on the transition logic + integration test that the scheduled command actually flips a fixture row
**Tests**: unit
**Gate**: quick

#### T46: Promoter tagging on `EventController` [P]
**What**: Extend T41's `EventController` (and `CreateEvent`/`EditEvent`) to accept a `promoter_ids` array, populating `EventPromoter` — display-only, no edit rights (enforced by T20's policy, already in place).
**Where**: `api/src/Http/Controllers/Api/AdminV1/EventController.php` (modify), `api/src/Domain/Event/UseCase/{CreateEvent,EditEvent}.php` (modify)
**Depends on**: T44, T13
**Reuses**: `EventPromoter` (T13), `EventPolicy` (T20)
**Requirement**: ADMIN-24
**Tests**: integration
**Gate**: full

#### T47: Venue/Promoter profile management endpoints [P]
**What**: `PATCH` on the registered venue/promoter profile, extending T18's repositories with an update path.
**Where**: `api/src/Http/Controllers/Api/AdminV1/{Venue,Promoter}Controller.php` (modify)
**Depends on**: T40
**Reuses**: `VenueRepository`/`PromoterRepository` (T18)
**Requirement**: ADMIN-25
**Tests**: integration
**Gate**: full

#### T48: Dashboard endpoint (P2) [P]
**What**: `GET /api/admin/v1/dashboard` — per-event view/favorite/ticket-click/interested counts + full event schedule/history. **Note**: view/favorite/interested counts depend on data this milestone doesn't yet produce (Favorites & Social is a later milestone) — this task ships the endpoint shape and the event-schedule/history half now; count fields return 0/null until those milestones land, documented as a known gap, not silently faked.
**Where**: `api/src/Http/Controllers/Api/AdminV1/DashboardController.php`
**Depends on**: T41
**Reuses**: `EventRepository` (T16)
**Requirement**: ADMIN-26
**Tests**: integration
**Gate**: full

#### T49: Account suspension (P2) [P]
**What**: Confirm `ApprovalOutcome` enum (T4) already includes `Suspended`/`SuspensionLifted` cases; if not, extend it and re-verify T36's tests still pass.
**Where**: `api/src/Domain/Approval/Enum/ApprovalOutcome.php` (modify if needed), `DecideAccountApproval` (T36, already covers this per its Done-when checklist)
**Depends on**: T36
**Reuses**: T36 in full — this task is mostly verification, not new code
**Requirement**: ADMIN-27
**Tests**: unit
**Gate**: quick

#### T50: Postman/Insomnia collection (sequential)
**What**: Export a collection covering every `/api/v1` and `/api/admin/v1` endpoint built in this milestone, per ARCHITECTURE §8.9.
**Where**: `api/docs/postman/qor-api-mvp-core.postman_collection.json`
**Depends on**: T25, T31, T32, T40, T41, T42, T43
**Reuses**: n/a
**Requirement**: ARCHITECTURE §8.9
**Tests**: none
**Gate**: build

#### T51: k6 baseline load test (sequential)
**What**: k6 (or Artillery) script against event list/detail, auth, event submission, and approval-queue endpoints, with target-RPS/p95-latency thresholds defined per endpoint, per ARCHITECTURE §8.8.
**Where**: `api/tests/load/mvp-core.k6.js`
**Depends on**: T50
**Reuses**: T50's collection as the endpoint inventory
**Requirement**: ARCHITECTURE §8.8
**Done when**:
- [ ] Script runs against the local Docker Compose stack and produces a pass/fail report against defined thresholds
**Tests**: none
**Gate**: build

#### T52: Coverage gate verification (sequential)
**What**: Run the full suite with coverage, confirm ≥80% overall and no untested Domain/UseCase class, before this milestone's PR opens.
**Where**: CI (T3's workflow), no new files
**Depends on**: T51
**Reuses**: T3's CI workflow
**Requirement**: ARCHITECTURE §8.3
**Tests**: none
**Gate**: full

---

## Parallel Execution Map

```
Phase 1 (Sequential): T1→T2→T3→T4→T5→T6→T7  (T8 doc task, any time)

Phase 2 (Parallel after T7):
  ├── T9  [P]
  ├── T10 [P]
  ├── T11 [P]
  ├── T12 [P]
  ├── T13 [P] (after T11,T12)
  ├── T14 [P]
  └── T15 [P]
  then:
  ├── T16 [P] (after T12,T13)
  ├── T17 [P] (after T9,T15)
  ├── T18 [P] (after T10,T11,T15)
  ├── T19 [P] (after T14)
  └── T21 [P] (after T1, independent of entities)
  then:
  T20 (after T10,T11,T12,T13)
  T22 (after all of T9–T15)

Phase 3 (mostly parallel across the 3 features, sequential within each):
  Event Discovery:      T23,T24 [P] → T25
  Auth & Fan Profile:    T33 → T26,T27,T28 [P] → T31 ; T29,T30 [P] (after T33,T21/T15) → T32
  Venue/Promoter Admin:  T34,T35 [P] (after T33) → T40 ; T36 (after T20) → T42 ; T37,T38 [P] (after T20) → T41 ; T39 (after T19) → T43

Phase 4 (P2, mostly parallel):
  T44 [P] → T46 [P] → T47 [P]
  T45 [P] (independent)
  T48 [P] (after T41)
  T49 [P] (after T36)
  then sequential: T50 → T51 → T52
```

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| T1–T8 | 1 concern each (scaffold/CI/enums/config/guards/routes/doc) | ✅ Granular |
| T9–T15 | 1 entity + migration + factory each (cohesive triple, same pattern) | ✅ Granular (2-3 related files, cohesive) |
| T16–T19 | 1 repository interface + 1 adapter each | ✅ Granular |
| T20 | 3 policy classes, one concern (authorization gating) | ✅ Granular (cohesive) |
| T21 | 1 adapter | ✅ Granular |
| T22 | 1 concern (seed data) | ✅ Granular |
| T23–T24, T26–T30, T34–T39, T44, T45 | 1 use case each | ✅ Granular |
| T25, T31, T32, T40–T43, T46–T48 | 1 controller (or controller extension) each | ✅ Granular |
| T33 | 1 shared contract | ✅ Granular |
| T49 | Verification-only, no new component | ✅ Granular |
| T50–T52 | 1 deliverable each (collection/script/gate run) | ✅ Granular |

No task creates more than one cohesive component. No splits needed.

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| T1–T8 | sequential chain T1→...→T7 (T8 none) | Phase 1 diagram: T1→T2→T3→T4→T5→T6→T7→T8 | ✅ Match (T8 shown in chain but genuinely independent — diagram over-states one edge; corrected in Parallel Execution Map, which shows T8 as "any time") |
| T9–T15 | T7 (+T4 for enum-dependent ones) | Phase 2 diagram: T7 branches to T9–T15 | ✅ Match |
| T16 | T12, T13 | Phase 2 diagram | ✅ Match |
| T17 | T9, T15 | Phase 2 diagram | ✅ Match |
| T18 | T10, T11, T15 | Phase 2 diagram | ✅ Match |
| T19 | T14 | Phase 2 diagram | ✅ Match |
| T20 | T10, T11, T12, T13 | Phase 2 diagram | ✅ Match |
| T21 | T1 | Parallel Execution Map (independent of entities) | ✅ Match |
| T22 | T9–T15 | Phase 2 diagram | ✅ Match |
| T23, T24 | T16 | Phase 3 diagram | ✅ Match |
| T25 | T23, T24, T7 | Phase 3 diagram | ✅ Match |
| T26 | T17, T15, T33 | Phase 3 diagram | ✅ Match |
| T27 | T17 | Phase 3 diagram | ✅ Match |
| T28 | T17 | Phase 3 diagram | ✅ Match |
| T29 | T17, T21 | Phase 3 diagram | ✅ Match |
| T30 | T17, T15 | Phase 3 diagram | ✅ Match |
| T31 | T26, T27, T28, T7 | Phase 3 diagram | ✅ Match |
| T32 | T29, T30, T7 | Phase 3 diagram | ✅ Match |
| T33 | T15 | Phase 3 diagram | ✅ Match |
| T34, T35 | T18, T15, T33 | Phase 3 diagram | ✅ Match |
| T36 | T18, T19, T20 | Phase 3 diagram | ✅ Match |
| T37 | T12, T20, T21 | Phase 3 diagram | ✅ Match |
| T38 | T12, T20 | Phase 3 diagram | ✅ Match |
| T39 | T12, T19 | Phase 3 diagram | ✅ Match |
| T40 | T34, T35, T7 | Phase 3 diagram | ✅ Match |
| T41 | T37, T38, T7 | Phase 3 diagram | ✅ Match |
| T42 | T36, T7 | Phase 3 diagram | ✅ Match |
| T43 | T39, T7 | Phase 3 diagram | ✅ Match |
| T44 | T41 | Phase 4 diagram | ✅ Match |
| T45 | T12 | Phase 4 diagram | ✅ Match |
| T46 | T44, T13 | Phase 4 diagram | ✅ Match |
| T47 | T40 | Phase 4 diagram | ✅ Match |
| T48 | T41 | Phase 4 diagram | ✅ Match |
| T49 | T36 | Phase 4 diagram | ✅ Match |
| T50 | T25, T31, T32, T40, T41, T42, T43 | Phase 4 diagram | ✅ Match |
| T51 | T50 | Phase 4 diagram | ✅ Match |
| T52 | T51 | Phase 4 diagram | ✅ Match |

All rows ✅ after correcting T8's placement (independent, not part of the sequential chain — reflected in the Parallel Execution Map).

---

## Test Co-location Validation

| Task | Code Layer Created/Modified | Matrix Requires (per file header) | Task Says | Status |
|---|---|---|---|---|
| T1–T3, T5, T8 | Scaffolding/CI/config/docs | none | none | ✅ OK |
| T4 | Domain enums | unit | unit | ✅ OK |
| T6, T7 | Auth middleware / routing | integration | integration | ✅ OK |
| T9–T15 | Domain entities | unit | unit | ✅ OK |
| T16–T19 | Persistence-layer repositories | integration | integration | ✅ OK |
| T20 | Authorization policies | unit | unit | ✅ OK |
| T21 | Infra adapter (S3) | integration | integration | ✅ OK |
| T22 | Seeders | none | none | ✅ OK |
| T23, T24, T26–T30, T34–T39, T44, T45 (logic half), T49 | Domain use cases | unit | unit | ✅ OK |
| T25, T31, T32, T40–T43, T46–T48 | HTTP controllers | integration | integration | ✅ OK |
| T33 | Domain interface + shared contract | unit | unit | ✅ OK |
| T50–T52 | Tooling/ops artifacts | none | none | ✅ OK |

No violations. No task defers its own tests to a later task — every task's `Done when` includes its own test-writing.

---

## Notes carried from the Tasks-phase plan (MVP Core scope, phases 1–4 above)

- `NotificationDispatcher`/`SesEmailSender`/`FcmPushSender` were **not** built in Phases 1–4 — they belong to the Social & Notifications milestone below (Phase 5). `RegisterFan` (T26) only calls a verification-email trigger point; real SES delivery is wired in Phase 5.
- GA4 event constants (per feature design docs' seed lists) are **not implemented** in any task in this file — implementation is explicitly gated on a tracking spreadsheet the user must approve first (ARCHITECTURE §11, CLAUDE.md). No task here should add GA4 calls.
- Map view for event discovery was **not included** — `event-discovery/spec.md`/`design.md` never request server-side map integration beyond a client-side embed keyed off `Event.address` (T24's payload already carries what the client needs; no separate backend task required).

---

# Milestone 2: Social & Notifications

**Features**: `favorites-social` (FAV-01–26) + `notifications` (NOTIF-01–23), per ROADMAP.md's next milestone after MVP Core. Also picks up `auth-fan-profile`'s P2 stories that were left `Pending` in Phase 1–4 (AUTH-20–24: address/location, favorite genres & radius, notification-preference fields) since `notifications/design.md` explicitly extends AUTH-24's stub and reads AUTH-20–23's data.
**Design refs**: `.specs/features/favorites-social/design.md`, `.specs/features/notifications/design.md`, `.specs/features/auth-fan-profile/design.md` (P2 stories), `.specs/project/ARCHITECTURE.md` §6.1
**Sequencing note**: per ROADMAP.md, this milestone cannot start until MVP Core's PRs merge across all 5 submodules — tasks are written now (Tasks phase can run ahead of Execute) but Execute should not begin until that gate clears.

## Execution Plan — Milestone 2

```
Phase 5a (Foundation — entities/repos, sequential then parallel):
  T53 → T54 → T55 → T56 → T57
  T57 ──┬→ T58 ─┐
        ├→ T59 ─┤
        ├→ T60 ─┼→ T63,T64 → T65
        └→ T61 ─┘
  T57 → T62

Phase 5b (Use cases, parallel after Phase 5a):
  T58 → T66 ; T59 → T67 → T68 → T69 ; T59 → T70
  T58,T59 → T71 [P2]
  T59,T65 → T72 [P2]
  T59,T58,T16(existing) → T73 [P3]
  T62 → T74
  T60 → T75
  T57,T16(existing),T65 → T76
  T16(existing),T57,T65 → T77 [P2]
  T65 → T78 (also modifies existing T39/T44 files)
  T65,T66 → T79 [P2] (also modifies T66)

Phase 5c (Controllers + wiring, parallel after 5b):
  T66 → T80 ; T67,T68,T69,T70 → T81 ; T72 → T82 [P2]
  T75 → T83 ; T74 → T84
  T76,T77 → T85 (cron wiring)
  T78 → T86 (modify existing venue-promoter-admin use cases)
  T79 → T87 (modify T66)

Phase 5d (Integration, sequential):
  T80,T81,T82,T83,T84,T85,T86,T87 → T88 → T89
```

## Task Breakdown — Milestone 2

#### T53: `Favorite` entity + migration + factory
**What**: `user_id`, `event_id`, `created_at` — unique on `(user_id, event_id)` for idempotent toggle (FAV-02).
**Where**: `api/src/Domain/Social/Favorite.php`, Eloquent model, migration, factory
**Depends on**: T12 (Event), T9 (User) — existing MVP Core entities
**Reuses**: T9's domain/Eloquent split pattern (established in Phase 2)
**Requirement**: FAV-01–FAV-04
**Tests**: unit
**Gate**: quick

#### T54: `Friendship` entity + migration + factory
**What**: Order-normalized pair (`LEAST`/`GREATEST` of the two user IDs, per `favorites-social/design.md`'s Tech Decision) + `status` (`FriendshipStatus` backed enum: pending/accepted), unique constraint on the normalized pair enforcing "already friends"/"already pending" cheaply.
**Where**: `api/src/Domain/Social/Friendship.php`, Eloquent model, migration, factory, `api/src/Domain/Social/Enum/FriendshipStatus.php`
**Depends on**: T9
**Reuses**: T9's pattern
**Requirement**: FAV-05–FAV-17
**Tests**: unit
**Gate**: quick

#### T55: `NotificationPreference` entity + migration + factory
**What**: Extends AUTH-24's stub — `user_id`, per-channel toggles (push/email, `NotificationChannel` enum), `silence_all`, per-trigger toggles (`NotificationTriggerType` enum: nearby_reminder/event_changed_cancelled/friend_interest/new_regional — defaults all enabled per NOTIF-23's opt-out model).
**Where**: `api/src/Domain/Notification/NotificationPreference.php`, Eloquent model, migration, factory, `api/src/Domain/Notification/Enum/{NotificationChannel,NotificationTriggerType}.php`
**Depends on**: T9
**Reuses**: T9's pattern
**Requirement**: AUTH-24, NOTIF-09–NOTIF-12, NOTIF-20–NOTIF-23
**Tests**: unit
**Gate**: quick

#### T56: `NotificationLog` entity + migration
**What**: `user_id`, `trigger_type`, `event_id` nullable, `sent_at` — dedup/consolidation check per ARCHITECTURE §6.1 step 2 and NOTIF-04.
**Where**: `api/src/Domain/Notification/NotificationLog.php`, Eloquent model, migration
**Depends on**: T9
**Reuses**: T9's pattern
**Requirement**: NOTIF-04, NOTIF-13 (consolidation)
**Tests**: unit
**Gate**: quick

#### T57: `UserAddress` entity + migration + factory
**What**: Extends AUTH-20–AUTH-22's previously-`Pending` stub into a real table — `user_id`, manual address fields, `radius_km` nullable, `location_consent_given_at` nullable (separate, explicit consent per LGPD, distinct `ConsentRecord` row via `ConsentType::Location`).
**Where**: `api/src/Domain/User/UserAddress.php`, Eloquent model, migration, factory
**Depends on**: T9, T15 (existing `ConsentRecord`)
**Reuses**: T9's pattern, T15 (`ConsentRecord`)
**Requirement**: AUTH-20–AUTH-22
**Done when**: unit test — device-location consent recorded as a distinct `ConsentRecord` row, never bundled into the general terms acceptance
**Tests**: unit
**Gate**: quick

#### T58: `FavoriteRepository` + `EloquentFavoriteRepository`
**What**: `toggle(userId, eventId): FavoriteState`, `listForUser(userId, cursor): FavoritePage` (joined against current `Event.status`, filters out non-`Published` per FAV-04).
**Where**: `api/src/Domain/Social/FavoriteRepository.php`, Eloquent adapter
**Depends on**: T53
**Reuses**: T16's interface/adapter split pattern
**Requirement**: FAV-01–FAV-04
**Tests**: integration
**Gate**: full

#### T59: `FriendshipRepository` + `EloquentFriendshipRepository`
**What**: `create`, `accept`, `reject`, `remove`, `listAccepted(userId, cursor)`, `listIncomingPending(userId)`, `findBetween(userIdA, userIdB)`.
**Where**: `api/src/Domain/Social/FriendshipRepository.php`, Eloquent adapter
**Depends on**: T54
**Reuses**: T16's pattern
**Requirement**: FAV-05–FAV-17
**Tests**: integration
**Gate**: full

#### T60: `NotificationPreferenceRepository` + Eloquent adapter
**Where**: `api/src/Domain/Notification/NotificationPreferenceRepository.php`, Eloquent adapter
**Depends on**: T55
**Reuses**: T16's pattern
**Requirement**: NOTIF-09–NOTIF-12, NOTIF-20–NOTIF-23
**Tests**: integration
**Gate**: full

#### T61: `NotificationLogRepository` + Eloquent adapter
**What**: `hasBeenSent(userId, triggerType, eventId?): bool`, `record(userId, triggerType, eventId?)`.
**Where**: `api/src/Domain/Notification/NotificationLogRepository.php`, Eloquent adapter
**Depends on**: T56
**Reuses**: T16's pattern
**Requirement**: NOTIF-04, NOTIF-13
**Tests**: integration
**Gate**: full

#### T62: `UserAddressRepository` + Eloquent adapter
**Where**: `api/src/Domain/User/UserAddressRepository.php`, Eloquent adapter
**Depends on**: T57
**Reuses**: T16's pattern
**Requirement**: AUTH-20–AUTH-22
**Tests**: integration
**Gate**: full

#### T63: `NotificationSender` interface + `FcmPushSender` adapter
**What**: The interface ARCHITECTURE §6.1 specifies (`send(userId, channel, payload): void`), implemented by an FCM adapter — domain never imports the FCM SDK directly (Clean Architecture, §8.5).
**Where**: `api/src/Domain/Notification/NotificationSender.php` (interface), `api/src/Infrastructure/Notification/FcmPushSender.php`
**Depends on**: T1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §6.1
**Done when**: integration test against a local FCM emulator/stub confirms a well-formed push payload dispatches without error; malformed payload fails loudly, not silently
**Tests**: integration
**Gate**: full

#### T64: `SesEmailSender` adapter
**What**: Second `NotificationSender` implementation, AWS SES — same cloud family as S3 (T21), avoiding a third vendor per ARCHITECTURE §6.1's rationale.
**Where**: `api/src/Infrastructure/Notification/SesEmailSender.php`
**Depends on**: T63
**Reuses**: `NotificationSender` interface (T63)
**Requirement**: ARCHITECTURE §6.1
**Tests**: integration
**Gate**: full

#### T65: `NotificationDispatcher` (core domain service)
**What**: `dispatch(userId, triggerType, eventId?, payload)` implementing ARCHITECTURE §6.1's 3-step algorithm exactly: (1) read `NotificationPreference` at call time — global silence short-circuits, disabled channel skipped, disabled per-trigger toggle short-circuits except `event_changed_cancelled` which always fires (NOTIF-07) subject only to global silence; (2) check `NotificationLog` for an existing send matching fan+trigger+event(+window), consolidate if found; (3) call `NotificationSender` per enabled channel, write a new `NotificationLog` row.
**Where**: `api/src/Domain/Notification/NotificationDispatcher.php`
**Depends on**: T60, T61, T63, T64
**Reuses**: `NotificationPreferenceRepository` (T60), `NotificationLogRepository` (T61), `NotificationSender` (T63/T64)
**Requirement**: ARCHITECTURE §6.1, NOTIF-01–NOTIF-23
**Done when**:
- [ ] Unit tests (GIVEN/WHEN/THEN): global silence suppresses every trigger on every channel; disabled channel never receives a send; `event_changed_cancelled` fires despite other per-trigger opt-outs but not despite global silence; duplicate fan+trigger+event within the dedup window consolidates to one send; preference is read at dispatch time, not cached from an earlier point
- [ ] Gate check passes, test count ≥ 8
**Tests**: unit
**Gate**: quick

#### T66: `ToggleFavorite` use case
**What**: `execute(userId, eventId): FavoriteState`, `listForUser(userId, cursor): FavoritePage` — idempotent toggle, filtered profile list.
**Where**: `api/src/Domain/Social/UseCase/ToggleFavorite.php`
**Depends on**: T58
**Reuses**: `FavoriteRepository` (T58)
**Requirement**: FAV-01–FAV-04
**Done when**: unit tests — toggle on/off idempotently; profile list excludes non-`Published` events; test count ≥ 4
**Tests**: unit
**Gate**: quick

#### T67: `SendFriendRequest` use case
**What**: `execute(requesterId, recipientId): Friendship` — create `Pending`, block duplicate outgoing, auto-accept on mutual reverse request, reject if already friends.
**Where**: `api/src/Domain/Social/UseCase/SendFriendRequest.php`
**Depends on**: T59
**Reuses**: `FriendshipRepository` (T59)
**Requirement**: FAV-05–FAV-08
**Done when**: unit tests for all 4 acceptance criteria; test count ≥ 4
**Tests**: unit
**Gate**: quick

#### T68: `RespondToFriendRequest` use case
**What**: `accept(requestId, respondingUserId): Friendship`, `reject(requestId, respondingUserId): void`, `listIncoming(userId): Friendship[]`.
**Where**: `api/src/Domain/Social/UseCase/RespondToFriendRequest.php`
**Depends on**: T67
**Reuses**: `FriendshipRepository` (T59)
**Requirement**: FAV-09–FAV-11
**Tests**: unit
**Gate**: quick

#### T69: `RemoveFriend` use case
**What**: `execute(userId, friendUserId): void` — deletes the mutual row entirely both sides, drops from friends-interested displays without touching the other fan's favorites.
**Where**: `api/src/Domain/Social/UseCase/RemoveFriend.php`
**Depends on**: T68
**Reuses**: `FriendshipRepository` (T59)
**Requirement**: FAV-12–FAV-14
**Tests**: unit
**Gate**: quick

#### T70: `ListFriends` use case
**What**: `execute(userId, cursor): FriendPage` — accepted-only, paginated, empty-state-safe.
**Where**: `api/src/Domain/Social/UseCase/ListFriends.php`
**Depends on**: T59
**Reuses**: `FriendshipRepository` (T59)
**Requirement**: FAV-15–FAV-17
**Tests**: unit
**Gate**: quick

#### T71: `GetFriendsInterested` use case [P2]
**What**: `execute(userId, eventId): User[]` — mutual friends who favorited the given event, graceful empty states (no friends-interested vs. zero friends at all).
**Where**: `api/src/Domain/Social/UseCase/GetFriendsInterested.php`
**Depends on**: T58, T59
**Reuses**: `FriendshipRepository` (T59), `FavoriteRepository` (T58)
**Requirement**: FAV-18–FAV-20
**Tests**: unit
**Gate**: quick

#### T72: `ShareEvent` use case [P2]
**What**: `shareToFriend(sharerId, friendId, eventId): void` — friendship check before sending, dispatches a notification via `NotificationDispatcher` (not a shared feed or chat thread). Native share is client-side only, no API call.
**Where**: `api/src/Domain/Social/UseCase/ShareEvent.php`
**Depends on**: T59, T65
**Reuses**: `FriendshipRepository` (T59), `NotificationDispatcher` (T65)
**Requirement**: FAV-21–FAV-23
**Done when**: unit test — share to a non-friend rejected with a clear error, not a silent no-op or crash
**Tests**: unit
**Gate**: quick

#### T73: `GetSocialFeed` use case [P3]
**What**: `execute(userId, cursor): FeedPage` — reverse-chronological friend activity (favorited/interested), excludes non-`Published` events.
**Where**: `api/src/Domain/Social/UseCase/GetSocialFeed.php`
**Depends on**: T58, T59, T16
**Reuses**: `FriendshipRepository` (T59), `FavoriteRepository` (T58), `EventRepository` (T16, existing)
**Requirement**: FAV-24–FAV-26
**Tests**: unit
**Gate**: quick

#### T74: `UpdatePreferences` use case (address/radius/favorite genres — AUTH-20–AUTH-23)
**What**: `setAddress(userId, addressFields): void`, `setDeviceLocationConsent(userId, granted: bool): void` (separate consent, revocable — falls back to manual address on revoke), `setFavoriteGenres(userId, genreIds): void`, `setSearchRadius(userId, radiusKm): void`.
**Where**: `api/src/Domain/User/UseCase/UpdatePreferences.php`
**Depends on**: T62
**Reuses**: `UserAddressRepository` (T62), `ConsentRepository` (T33, existing)
**Requirement**: AUTH-20–AUTH-23
**Done when**: unit tests — manual address entry works without device-location permission; location consent is distinct/revocable and revoking falls back to manual address or none; no favorite genres/radius set is a valid default, not an error
**Tests**: unit
**Gate**: quick

#### T75: `UpdateNotificationPreference` use case
**What**: `execute(userId, preferences): NotificationPreference` — persists per-channel/global-silence/per-trigger toggles, immediately effective for the next dispatch (no restart required).
**Where**: `api/src/Domain/Notification/UseCase/UpdateNotificationPreference.php`
**Depends on**: T60
**Reuses**: `NotificationPreferenceRepository` (T60)
**Requirement**: AUTH-24, NOTIF-09, NOTIF-12, NOTIF-20–NOTIF-23
**Tests**: unit
**Gate**: quick

#### T76: `DetectNearbyReminders` use case (scheduled)
**What**: For each fan with an address/radius and a favorited event approaching within `qor.notifications.nearby_reminder_lead_hours`, not already logged for that event/trigger, call `NotificationDispatcher`.
**Where**: `api/src/Domain/Notification/UseCase/DetectNearbyReminders.php`
**Depends on**: T58, T62, T65
**Reuses**: `FavoriteRepository` (T58), `UserAddressRepository` (T62), `NotificationDispatcher` (T65)
**Requirement**: NOTIF-01–NOTIF-04
**Done when**: unit tests — fan without address/radius skipped; duplicate reminder for the same event/trigger not re-sent; global silence suppresses
**Tests**: unit
**Gate**: quick

#### T77: `DetectRegionalPublishes` use case (scheduled) [P2]
**What**: Collect events newly `Published` within each fan's radius since the last scan, batch per fan into one digest call per `qor.notifications.regional_batch_window_minutes`, skip fans with no address/radius.
**Where**: `api/src/Domain/Notification/UseCase/DetectRegionalPublishes.php`
**Depends on**: T16, T62, T65
**Reuses**: `EventRepository` (T16, existing), `UserAddressRepository` (T62), `NotificationDispatcher` (T65)
**Requirement**: NOTIF-16–NOTIF-19
**Done when**: unit test confirms 3 qualifying events in one window produce exactly 1 dispatch call per fan, not 3
**Tests**: unit
**Gate**: quick

#### T78: `HandleEventChangedOrCancelled` use case (event-driven)
**What**: `handle(eventId, changeType: NotificationTriggerType): void` — subscribed to `EventChanged`/`EventCancelled` domain events (emitted by T86's modification to the existing `EditEvent`/`CancelEvent`/`DecideEventApproval` use cases), notifies every favoriting fan via `NotificationDispatcher`, always subject to `event_changed_cancelled`'s always-fires rule.
**Where**: `api/src/Domain/Notification/UseCase/HandleEventChangedOrCancelled.php`
**Depends on**: T58, T65
**Reuses**: `FavoriteRepository` (T58), `NotificationDispatcher` (T65)
**Requirement**: NOTIF-05–NOTIF-08
**Tests**: unit
**Gate**: quick

#### T79: `HandleFriendInterest` use case (event-driven) [P2]
**What**: `handle(favoritedByUserId, eventId): void` — subscribed to `FavoriteCreated` (emitted by T87's modification to `ToggleFavorite`, T66), notifies mutual friends via `NotificationDispatcher`, respects per-trigger opt-out, stops once friendship is removed.
**Where**: `api/src/Domain/Notification/UseCase/HandleFriendInterest.php`
**Depends on**: T59, T65
**Reuses**: `FriendshipRepository` (T59), `NotificationDispatcher` (T65)
**Requirement**: NOTIF-13–NOTIF-15
**Tests**: unit
**Gate**: quick

#### T80: `FavoriteController`
**What**: `POST /api/v1/events/{id}/favorite` (toggle), `GET /api/v1/profile/favorites`.
**Where**: `api/src/Http/Controllers/Api/V1/FavoriteController.php`
**Depends on**: T66, T7
**Reuses**: `ToggleFavorite` (T66)
**Requirement**: FAV-01–FAV-04
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add favorite toggle and favorites-list endpoints`

#### T81: `FriendshipController`
**What**: `POST /api/v1/friends/requests`, `GET /api/v1/friends/requests`, `POST /api/v1/friends/requests/{id}/accept`, `POST /api/v1/friends/requests/{id}/reject`, `DELETE /api/v1/friends/{userId}`, `GET /api/v1/friends`.
**Where**: `api/src/Http/Controllers/Api/V1/FriendshipController.php`
**Depends on**: T67, T68, T69, T70, T7
**Reuses**: T67–T70's use cases
**Requirement**: FAV-05–FAV-17
**Done when**: integration tests for every endpoint's happy path + the duplicate/already-friends/auto-accept edge cases; test count ≥ 8
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add friend request and friends-list endpoints`

#### T82: `ShareController` [P2]
**What**: `GET /api/v1/events/{id}/friends-interested`, `POST /api/v1/events/{id}/share`.
**Where**: `api/src/Http/Controllers/Api/V1/ShareController.php`
**Depends on**: T71, T72, T7
**Reuses**: `GetFriendsInterested` (T71), `ShareEvent` (T72)
**Requirement**: FAV-18–FAV-23
**Tests**: integration
**Gate**: full

#### T83: `NotificationPreferenceController`
**What**: `GET/PATCH /api/v1/profile/notification-preferences`.
**Where**: `api/src/Http/Controllers/Api/V1/NotificationPreferenceController.php`
**Depends on**: T75, T7
**Reuses**: `UpdateNotificationPreference` (T75)
**Requirement**: AUTH-24, NOTIF-20–NOTIF-23
**Tests**: integration
**Gate**: full

#### T84: `ProfileController` extension — address/radius/genres
**What**: Extend the existing `ProfileController` (T32) with `GET/PATCH /api/v1/profile/address`, `GET/PATCH /api/v1/profile/preferences` (genres/radius).
**Where**: `api/src/Http/Controllers/Api/V1/ProfileController.php` (modify)
**Depends on**: T74, T32
**Reuses**: `UpdatePreferences` (T74)
**Requirement**: AUTH-20–AUTH-23
**Tests**: integration
**Gate**: full

#### T85: Scheduled job wiring (sequential-safe, runs after detectors exist)
**What**: Register `DetectNearbyReminders` and `DetectRegionalPublishes` in `routes/console.php`'s schedule, interval read from config (not hardcoded in the scheduler).
**Where**: `api/routes/console.php`
**Depends on**: T76, T77
**Reuses**: T76, T77
**Requirement**: NOTIF-01, NOTIF-16
**Tests**: none
**Gate**: build

#### T86: Emit `EventChanged`/`EventCancelled` domain events (modifies existing Phase 3/4 files)
**What**: Modify the existing `EditEvent`/`CancelEvent` (T44) and `DecideEventApproval` (T39, force-cancel path) use cases to emit `EventChanged`/`EventCancelled` domain events on a material change or cancellation, which `HandleEventChangedOrCancelled` (T78) subscribes to.
**Where**: `api/src/Domain/Event/UseCase/{EditEvent,CancelEvent}.php` (modify), `api/src/Domain/Approval/UseCase/DecideEventApproval.php` (modify)
**Depends on**: T78, T44, T39
**Reuses**: T44, T39 (existing files, extended not duplicated per `notifications/design.md`'s Code Reuse Analysis)
**Requirement**: NOTIF-05–NOTIF-08
**Done when**: existing T44/T39 test suites still pass unmodified in assertions about their own behavior, plus new assertions that the correct domain event fires with correct payload on each qualifying change
**Tests**: unit
**Gate**: quick

#### T87: Emit `FavoriteCreated` domain event (modifies T66)
**What**: Modify `ToggleFavorite` (T66) to emit `FavoriteCreated` when a favorite is newly created (not on unfavorite), which `HandleFriendInterest` (T79) subscribes to.
**Where**: `api/src/Domain/Social/UseCase/ToggleFavorite.php` (modify)
**Depends on**: T79, T66
**Reuses**: T66 (existing file, extended)
**Requirement**: NOTIF-13
**Tests**: unit
**Gate**: quick

#### T88: Postman/Insomnia collection update (sequential)
**What**: Extend T50's collection with every Milestone 2 endpoint.
**Where**: `api/docs/postman/qor-api-mvp-core.postman_collection.json` (renamed/versioned to include Milestone 2, or a new `qor-api-social-notifications.postman_collection.json` — implementer's call, document either way)
**Depends on**: T80, T81, T82, T83, T84, T85, T86, T87
**Reuses**: T50
**Requirement**: ARCHITECTURE §8.9
**Tests**: none
**Gate**: build

#### T89: Coverage gate verification (sequential)
**What**: Re-run the full suite with coverage, confirm ≥80% overall including all Milestone 2 additions, before this milestone's PR opens.
**Where**: CI (T3's workflow)
**Depends on**: T88
**Reuses**: T3
**Requirement**: ARCHITECTURE §8.3
**Tests**: none
**Gate**: full

## Task Granularity Check — Milestone 2

| Task | Scope | Status |
|---|---|---|
| T53–T57 | 1 entity + migration + factory each (cohesive) | ✅ Granular |
| T58–T64 | 1 repository/adapter/sender each | ✅ Granular |
| T65 | 1 domain service, 3-step algorithm from a single spec (cohesive) | ✅ Granular |
| T66–T79 | 1 use case each | ✅ Granular |
| T80–T84 | 1 controller (or controller extension) each | ✅ Granular |
| T85 | 1 concern (scheduling) | ✅ Granular |
| T86, T87 | Targeted modification to existing files, one new behavior each | ✅ Granular |
| T88, T89 | 1 deliverable each | ✅ Granular |

## Diagram-Definition Cross-Check — Milestone 2

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| T53–T57 | sequential + existing T9/T12/T15 | Phase 5a | ✅ Match |
| T58–T62 | T53–T57 respectively | Phase 5a | ✅ Match |
| T63, T64 | T1, T63 | Phase 5a | ✅ Match |
| T65 | T60, T61, T63, T64 | Phase 5a | ✅ Match |
| T66–T79 | as listed in each task body | Phase 5b | ✅ Match |
| T80–T87 | as listed in each task body | Phase 5c | ✅ Match |
| T88 | T80–T87 | Phase 5d | ✅ Match |
| T89 | T88 | Phase 5d | ✅ Match |

All rows ✅.

## Test Co-location Validation — Milestone 2

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| T53–T57 | Domain entities | unit | unit | ✅ OK |
| T58–T64 | Persistence/infra adapters | integration | integration | ✅ OK |
| T65 | Domain service | unit | unit | ✅ OK |
| T66–T79 | Domain use cases | unit | unit | ✅ OK |
| T80–T84 | HTTP controllers | integration | integration | ✅ OK |
| T85 | Scheduling config | none | none | ✅ OK |
| T86, T87 | Domain use case modification | unit | unit | ✅ OK |
| T88, T89 | Tooling/ops | none | none | ✅ OK |

No violations.

---

# Milestone 3: Monetization

**Feature**: `monetization` (MON-01–26), per ROADMAP.md's milestone after Social & Notifications.
**Design ref**: `.specs/features/monetization/design.md`, `.specs/project/ARCHITECTURE.md` §6.2
**Sequencing note**: cannot start until Milestone 2's PRs merge across all 5 submodules (ROADMAP.md's sequential rule). Payment gateway integration itself is explicitly out of scope (PRD §8 Q6, unresolved) — this milestone's `Plan`/`Subscription` model is gateway-agnostic by design.

## Execution Plan — Milestone 3

```
Phase 6a (Foundation, sequential then parallel):
  T90 → T91
  T91 ──┬→ T92 ─┐
        └→ T93 ─┴→ T94,T95,T96,T97,T98,T99 [P]

Phase 6b (Extend existing use cases, sequential — touches shared files):
  T94 → T100 (modifies T36, DecideAccountApproval)
  T97 → T101 (modifies T38, SubmitEventForReview)

Phase 6c (Controllers, parallel after 6a/6b):
  T95 → T102 ; T96,T99,T101 → T103 ; T94,T100,T98 → T104

Phase 6d (Integration, sequential):
  T102,T103,T104 → T105 → T106
```

## Task Breakdown — Milestone 3

#### T90: `Plan` entity + migration + factory
**What**: `name`, `monthly_price`, `annual_price` nullable, `publish_quota` nullable (null = unlimited), `is_active`, `is_default_free`.
**Where**: `api/src/Domain/Billing/Plan.php`, Eloquent model, migration, factory
**Depends on**: T1
**Reuses**: T9's domain/Eloquent pattern
**Requirement**: MON-01, MON-13–MON-16
**Tests**: unit
**Gate**: quick

#### T91: `Subscription` entity + migration + factory
**What**: `subscribable_type`/`subscribable_id` (polymorphic — `Venue`|`Promoter`), `plan_id`, `publishes_used_this_period`, `billing_cycle` (`BillingCycle` enum: monthly/annual), `status` (`SubscriptionStatus` enum), `period_started_at`.
**Where**: `api/src/Domain/Billing/Subscription.php`, Eloquent model, migration, factory
**Depends on**: T90
**Reuses**: T9's pattern
**Requirement**: MON-04–MON-12, MON-19–MON-26
**Tests**: unit
**Gate**: quick

#### T92: `PlanRepository` + Eloquent adapter
**Where**: `api/src/Domain/Billing/PlanRepository.php`, Eloquent adapter
**Depends on**: T90
**Reuses**: T16's pattern
**Requirement**: MON-01, MON-13–MON-16
**Tests**: integration
**Gate**: full

#### T93: `SubscriptionRepository` + Eloquent adapter
**Where**: `api/src/Domain/Billing/SubscriptionRepository.php`, Eloquent adapter
**Depends on**: T91
**Reuses**: T16's pattern
**Requirement**: MON-04–MON-12, MON-19–MON-26
**Tests**: integration
**Gate**: full

#### T94: `ListActivePlans` use case
**What**: `execute(): Plan[]` — active plans only, a just-deactivated plan disappears immediately without affecting existing subscribers.
**Where**: `api/src/Domain/Billing/UseCase/ListActivePlans.php`
**Depends on**: T92
**Reuses**: `PlanRepository` (T92)
**Requirement**: MON-01–MON-03
**Tests**: unit
**Gate**: quick

#### T95: `CreateSubscriptionOnApproval` use case
**What**: `execute(subscribableType, subscribableId): Subscription` — creates a `Subscription` on the `is_default_free` plan; if none is flagged default, throws a configuration error (blocks the caller, does not silently proceed).
**Where**: `api/src/Domain/Billing/UseCase/CreateSubscriptionOnApproval.php`
**Depends on**: T92, T93
**Reuses**: `PlanRepository`/`SubscriptionRepository` (T92/T93)
**Requirement**: MON-04–MON-06
**Done when**: unit test — missing default-flag configuration throws rather than silently approving with no subscription
**Tests**: unit
**Gate**: quick

#### T96: `CheckAndIncrementQuota` use case
**What**: `execute(subscribableType, subscribableId): void` — throws `QuotaExceededException` if at quota (no increment), increments and proceeds otherwise, never blocks on `publish_quota IS NULL` (unlimited), never adjusts on later approval/rejection (MON-09, enforced by *not* being called from `DecideEventApproval` — only from submission).
**Where**: `api/src/Domain/Billing/UseCase/CheckAndIncrementQuota.php`
**Depends on**: T93
**Reuses**: `SubscriptionRepository` (T93)
**Requirement**: MON-07–MON-10
**Done when**: unit tests for all 4 acceptance criteria, including a fixture proving approval/rejection of a submitted event never touches `publishes_used_this_period`
**Tests**: unit
**Gate**: quick

#### T97: `ResetPeriodUsage` use case (scheduled)
**What**: `execute(): void` — resets every `Subscription.publishes_used_this_period` to 0 at each calendar-month boundary, independent of signup date or billing cycle.
**Where**: `api/src/Domain/Billing/UseCase/ResetPeriodUsage.php`
**Depends on**: T93
**Reuses**: `SubscriptionRepository` (T93)
**Requirement**: MON-11–MON-12, MON-26
**Tests**: unit
**Gate**: quick

#### T98: `CreatePlan` / `UpdatePlan` / `DeactivatePlan` use cases
**What**: Super Admin CRUD — edits never alter historical usage counts of existing subscribers; deactivation only hides from new signups.
**Where**: `api/src/Domain/Billing/UseCase/{Create,Update,Deactivate}Plan.php`
**Depends on**: T92
**Reuses**: `PlanRepository` (T92)
**Requirement**: MON-13–MON-16
**Done when**: unit tests — required-field validation (name/monthly price/quota); edit doesn't touch existing `Subscription.publishes_used_this_period` rows; deactivate leaves existing subscribers untouched
**Tests**: unit
**Gate**: quick

#### T99: `GetOrganizerUsage` use case
**What**: `execute(subscribableType, subscribableId): UsageSummary` — current plan, price, quota, "X of Y used this period," at-limit flag.
**Where**: `api/src/Domain/Billing/UseCase/GetOrganizerUsage.php`
**Depends on**: T93
**Reuses**: `SubscriptionRepository` (T93)
**Requirement**: MON-17–MON-18
**Tests**: unit
**Gate**: quick

#### T99b: `ChangePlan` / `CancelPlan` use cases [P2]
**What**: Plan switch effective at next reset (never retroactive), cancellation reverts to free at period end, published events always stay live through either.
**Where**: `api/src/Domain/Billing/UseCase/{ChangePlan,CancelPlan}.php`
**Depends on**: T92, T93
**Reuses**: `PlanRepository`/`SubscriptionRepository` (T92/T93)
**Requirement**: MON-19–MON-23
**Tests**: unit
**Gate**: quick

#### T100: Extend `DecideAccountApproval` (modifies T36)
**What**: On `approved` outcome, call `CreateSubscriptionOnApproval` (T95) — extension point, not a duplicated approval flow.
**Where**: `api/src/Domain/Approval/UseCase/DecideAccountApproval.php` (modify)
**Depends on**: T95, T36
**Reuses**: T36 (existing file, extended)
**Requirement**: MON-04–MON-06
**Done when**: existing T36 test suite still passes plus a new assertion that approval creates a `Subscription`, and that a missing default-plan config blocks the approval outcome entirely
**Tests**: unit
**Gate**: quick

#### T101: Extend `SubmitEventForReview` (modifies T38)
**What**: Before the `Draft → Pending Review` transition, call `CheckAndIncrementQuota` (T96) — blocks with an upgrade-prompt response on quota exceeded, no increment.
**Where**: `api/src/Domain/Event/UseCase/SubmitEventForReview.php` (modify)
**Depends on**: T96, T38
**Reuses**: T38 (existing file, extended)
**Requirement**: MON-07–MON-10
**Done when**: existing T38 test suite still passes plus new assertions for the quota-block path (no transition, no increment, upgrade-prompt error shape)
**Tests**: unit
**Gate**: quick

#### T102: `PlanController` (public list)
**What**: `GET /api/v1/plans` — public, no auth, consumed by `qor-landingpage`.
**Where**: `api/src/Http/Controllers/Api/V1/PlanController.php`
**Depends on**: T94, T7
**Reuses**: `ListActivePlans` (T94)
**Requirement**: MON-01–MON-03
**Tests**: integration
**Gate**: full

#### T103: `PlanController` (admin CRUD)
**What**: `GET/POST/PATCH /api/admin/v1/plans`, `POST /api/admin/v1/plans/{id}/deactivate` — Super Admin only, enforced by a new `PlanPolicy`.
**Where**: `api/src/Http/Controllers/Api/AdminV1/PlanController.php`, `api/src/Http/Policies/PlanPolicy.php`
**Depends on**: T98, T99b, T7
**Reuses**: `CreatePlan`/`UpdatePlan`/`DeactivatePlan` (T98)
**Requirement**: MON-13–MON-16
**Tests**: integration
**Gate**: full

#### T104: `SubscriptionController`
**What**: `GET /api/admin/v1/subscription` (organizer's own usage), `POST /api/admin/v1/subscription/change-plan`, `POST /api/admin/v1/subscription/cancel` [P2].
**Where**: `api/src/Http/Controllers/Api/AdminV1/SubscriptionController.php`
**Depends on**: T94, T100, T99b, T7
**Reuses**: `GetOrganizerUsage` (T99), `ChangePlan`/`CancelPlan` (T99b)
**Requirement**: MON-17–MON-23
**Tests**: integration
**Gate**: full
**Commit**: `feat(api): add plan CRUD, organizer usage, and quota-enforcement endpoints`

#### T105: Postman/Insomnia collection update (sequential)
**Where**: extends T88's collection with every Milestone 3 endpoint
**Depends on**: T102, T103, T104
**Reuses**: T88
**Requirement**: ARCHITECTURE §8.9
**Tests**: none
**Gate**: build

#### T106: Coverage gate verification (sequential)
**Where**: CI (T3's workflow)
**Depends on**: T105
**Requirement**: ARCHITECTURE §8.3
**Tests**: none
**Gate**: full

## Task Granularity Check — Milestone 3

| Task | Scope | Status |
|---|---|---|
| T90, T91 | 1 entity each | ✅ Granular |
| T92, T93 | 1 repository each | ✅ Granular |
| T94–T99b | 1 use case (or cohesive pair, T98) each | ✅ Granular |
| T100, T101 | Targeted extension, one new behavior each | ✅ Granular |
| T102–T104 | 1 controller each | ✅ Granular |
| T105, T106 | 1 deliverable each | ✅ Granular |

## Diagram-Definition Cross-Check — Milestone 3

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| T90, T91 | T1, T90 | Phase 6a | ✅ Match |
| T92, T93 | T90, T91 | Phase 6a | ✅ Match |
| T94–T99b | as listed | Phase 6a | ✅ Match |
| T100 | T95, T36 | Phase 6b | ✅ Match |
| T101 | T96, T38 | Phase 6b | ✅ Match |
| T102–T104 | as listed | Phase 6c | ✅ Match |
| T105 | T102–T104 | Phase 6d | ✅ Match |
| T106 | T105 | Phase 6d | ✅ Match |

All rows ✅.

## Test Co-location Validation — Milestone 3

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| T90, T91 | Domain entities | unit | unit | ✅ OK |
| T92, T93 | Persistence adapters | integration | integration | ✅ OK |
| T94–T99b | Domain use cases | unit | unit | ✅ OK |
| T100, T101 | Domain use case modification | unit | unit | ✅ OK |
| T102–T104 | HTTP controllers | integration | integration | ✅ OK |
| T105, T106 | Tooling/ops | none | none | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (all milestones)

- `NotificationDispatcher`/`SesEmailSender`/`FcmPushSender` are built in **Milestone 2** (T63–T65), not MVP Core.
- GA4 event constants are **not implemented** anywhere in this file, in any milestone — gated on tracking-spreadsheet approval per ARCHITECTURE §11.
- Map view for event discovery was **not included** in MVP Core and no milestone above adds one — no feature spec requests it.
- Payment gateway integration is explicitly **out of scope** for Milestone 3 — `Plan`/`Subscription` are gateway-agnostic by design (PRD §8 Q6 remains open).
- T86/T87/T100/T101 all modify existing files from earlier milestones rather than duplicating logic — when executing, re-run the *original* task's test suite first to confirm no regression before adding the new assertions.
