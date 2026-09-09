# Nightlife GV Stitch Refresh Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user - do not proceed without it.**

---

**Design**: `.specs/features/nightlife-gv-stitch-refresh/design.md`
**Status**: Draft

---

## Test Coverage Matrix

> Generated from codebase sampling (`api/.github/workflows/api-ci.yml`, `mobile/.github/workflows/mobile-ci.yml`, root `Makefile`, `ARCHITECTURE.md` §8.3's Gate legend) and spec ACs — confirm before Execute. Guidelines found: `ARCHITECTURE.md` §8.3 (TDD mandatory, GIVEN/WHEN/THEN, 80% coverage gate), root `Makefile`, `api/.github/workflows/api-ci.yml`, `mobile/.github/workflows/mobile-ci.yml`.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| --- | --- | --- | --- | --- |
| `qor-api` domain/use-case (GeocodingPort, geocoding wiring into Event save, EventRepository bounding-box query) | unit | All branches; 1:1 to MAPGEO-01..04; geocode-failure edge case covered | `api/tests/Unit/**/*Test.php` | `docker compose exec api php artisan test` |
| `qor-api` HTTP/controller (`GET /events/map`) | integration (Feature test) | All routes in scope: happy + missing-params + invalid-bounds + zero-results paths | `api/tests/Feature/**/*Test.php` | `docker compose exec api php artisan test` |
| `qor-api` migration/config (`latitude`/`longitude` columns, city-radius config) | none | build gate only | `api/database/migrations/*.php`, `api/config/qor.php` | build gate only |
| `mobile/shared` domain (Favorite repo+use cases, VerifyPasswordResetCode, GetMapEvents+MapBounds) | unit | All branches; 1:1 to FAVUI-01..05 / PWDR-01..04 / MAPUI-01,03,04 | `mobile/shared/src/commonTest/kotlin/domain/**/*Test.kt` | `./gradlew test` |
| `website` pages/components (existing-screen refresh) | unit (Jest+RTL) | Structural/visual-contract assertions per changed component, existing-test floor preserved | `website/**/*.test.tsx` | `make test-website` |
| `website` new routes (`/favoritos`, `/mapa`, Hub) | unit (Jest+RTL) | Happy path + auth-gate + empty-state per FAVUI-03, HUB-03 | `website/**/*.test.tsx` | `make test-website` |
| `website` e2e smoke (route-level) | e2e (Playwright) | One smoke path through each new/changed route | `website/e2e/*.spec.ts` | `make e2e-website` |
| Android Compose screens (refresh + new) | unit/Robolectric render test | Existing repo pattern (`*RenderTest`/`*Test`) — pure logic 1:1 to ACs + render assertions | `mobile/androidApp/src/test/kotlin/**/*Test.kt` | `./gradlew test koverVerify :androidApp:koverVerifyDebug detekt` |
| iOS SwiftUI screens (refresh + new) | unit (XCTest) | Pure logic only (color/motion/validation helpers), per AD-022's documented render-test-infra gap — views themselves build-verified only | `mobile/iosApp/iosAppTests/**/*Tests.swift` | `xcodebuild test` (see Gate Check Commands) |

## Gate Check Commands

> Generated from `Makefile`, `api/.github/workflows/api-ci.yml`, `mobile/.github/workflows/mobile-ci.yml` — confirm before Execute.

| Gate Level | When to Use | Command |
| --- | --- | --- |
| Quick (api) | After an `qor-api` task with unit tests only | `docker compose exec api php artisan test` |
| Full (api) | After the `qor-api` phase completes | `docker compose exec api php artisan test && docker compose exec api vendor/bin/phpstan analyse --memory-limit=512M` |
| Quick (mobile-shared/android) | After a shared or Android task with unit tests | `./gradlew test` |
| Full (android) | After an Android-touching phase completes | `./gradlew test koverVerify :androidApp:koverVerifyDebug detekt` |
| Full (iOS) | After an iOS-touching phase completes | `cd mobile/iosApp && xcodegen generate && swiftlint lint --strict && xcodebuild test -project iosApp.xcodeproj -scheme iosApp -destination "platform=iOS Simulator,name=<first available>" CODE_SIGNING_ALLOWED=NO` |
| Quick (website) | After a website task with unit tests | `make test-website` |
| Full (website) | After a website phase completes | `make test-website && make lint-website && make build-website` |
| E2E (website) | After routing/page-flow changes, called out per task | `make e2e-website` |

---

## Execution Plan

Phases are ordered and run sequentially. **Cross-repo sequencing note**: Phase 2 (`qor-api` geo backend, T2–T8) must reach a merged PR — `review-laravel-api` findings addressed, `gh pr checks` green, root submodule pointer updated — via the T12 checkpoint, before T13 (`GetMapEvents`) and any Map-UI task (T22, T32, T42) proceeds. Each repo gets its own milestone branch/PR per `ARCHITECTURE.md` §8.10-8.11: `qor-api` → `feat/api-event-geo-map`; `qor-mobile` → `feat/mobile-nightlife-stitch-refresh` (commits split per platform boundary within); `qor-website` → `feat/website-nightlife-stitch-refresh`.

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7 → Phase 8 → Phase 9 → Phase 10
```

### Phase 1: Token reconciliation
```
T1
```

### Phase 2: `qor-api` geo backend (own PR/milestone)

Two independent chains within this phase (query/endpoint chain off T2; geocoding chain off T3), executed one after another by a single worker:

```
T2 → T6 → T7 → T8
```
```
T3 → T4 → T5
```
(T5 only calls `GeocodingPort`, it does not query the new columns, so its only real dependency is T4, not T2/T6.)

### Phase 3: `mobile/shared` domain slices

```
T9 → T10
```
```
T8 → T12 → T13
```
T11 has no in-phase dependency (runs independently). T12 is the cross-repo merge checkpoint — depends on Phase 2's last task, T8. T13, `GetMapEvents`, depends on T12 having completed, i.e. the backend being merged.

### Phase 4: Website — existing-screen refresh
```
T1 → T14
T1 → T15
T1 → T16
T1 → T17
T1 → T18
T1 → T19
T1 → T20
```

### Phase 5: Website — new routes
```
T1 → T21
T1 → T22
T13 → T22
T1 → T23
T18 → T23
```

### Phase 6: Android — existing-screen refresh + 3-step password recovery
```
T1 → T24
T1 → T25
T1 → T26
T1 → T27
T1 → T28
T1 → T29
T1 → T30
T11 → T30
```

### Phase 7: Android — new screens
```
T1 → T31
T10 → T31
T1 → T32
T13 → T32
T1 → T33
T27 → T33
```

### Phase 8: iOS — existing-screen refresh + 3-step password recovery
```
T1 → T34
T1 → T35
T1 → T36
T1 → T37
T1 → T38
T1 → T39
T1 → T40
T11 → T40
```

### Phase 9: iOS — new screens
```
T1 → T41
T10 → T41
T1 → T42
T13 → T42
T1 → T43
T37 → T43
```

### Phase 10: Interactive UAT
```
T23 → T44
T33 → T45
T43 → T46
```

**Total: 46 tasks across 10 phases.**

---

## Full Dependency Graph (every declared edge, for cross-check)

```
T3 → T4
T4 → T5
T2 → T6
T6 → T7
T7 → T8
T9 → T10
T8 → T12
T12 → T13
T1 → T14
T1 → T15
T1 → T16
T1 → T17
T1 → T18
T1 → T19
T1 → T20
T1 → T21
T1 → T22
T13 → T22
T1 → T23
T18 → T23
T1 → T24
T1 → T25
T1 → T26
T1 → T27
T1 → T28
T1 → T29
T1 → T30
T11 → T30
T1 → T31
T10 → T31
T1 → T32
T13 → T32
T1 → T33
T27 → T33
T1 → T34
T1 → T35
T1 → T36
T1 → T37
T1 → T38
T1 → T39
T1 → T40
T11 → T40
T1 → T41
T10 → T41
T1 → T42
T13 → T42
T1 → T43
T37 → T43
T23 → T44
T33 → T45
T43 → T46
```

Tasks with no incoming edges (no dependencies): T1, T2, T3, T9, T11.

---

## Task Breakdown

### T1: Token audit + reconciliation (all 4 token surfaces)

**What**: Diff `design-system.md`, `website/styles/nightlife-gv.css`, `mobile/shared/src/commonMain/kotlin/design/QualORockThemeTokens.kt`, and the iOS `ColorTokens.swift` bridge against "Nightlife Discovery"'s `designMd` (color hex, font, radius, typography role names) line-by-line; apply only real deltas (per design.md's Approach Exploration, expected: none for colors/fonts, `sm` radius stays at 6px per the logged assumption) to all four files in the same commit so no client drifts from another.
**Where**: `design-system.md`, `website/styles/nightlife-gv.css`, `mobile/shared/src/commonMain/kotlin/design/QualORockThemeTokens.kt`, `mobile/iosApp/iosApp/UI/Theme/ColorTokens.swift`
**Depends on**: None
**Reuses**: existing token file structure in all four files
**Requirement**: TOKEN-01, TOKEN-02, TOKEN-03, TOKEN-04

*Granularity note*: 4 files, but one indivisible reconciliation unit — splitting would let one client drift from another mid-commit, exactly what the "same reconciliation pass" design rule exists to prevent.

**Tools**: MCP: `stitch` (re-fetch `list_design_systems` if needed for exact values) | Skill: NONE

**Done when**:
- [x] Delta list documented (even if empty) in the commit message or a short note in `design.md`'s Tech Decisions
- [x] All four files reflect the same reconciled values — zero unexplained deltas remain
- [x] `make build-website` passes; `./gradlew build` could not run — see note

**T1 status**: ✅ Complete. Audit found zero real deltas (all four files already reconciled); no code files needed edits, only `design.md`'s new "T1 Token Audit — Delta List" section. `make build-website` passed clean. `./gradlew build` could not run in this environment (no JDK installed on this machine, and `mobile/` has no docker-compose service to fall back to) — moot for this task since neither `.kt` nor `.swift` token file changed, but this is a real environment gap that blocks every later `qor-mobile` gate (Phases 3, 6–9). Flagged to the user before proceeding past Phase 2.

**Tests**: none — Test Coverage Matrix lists config/token files as build-gate-only (no domain/route logic to unit test)
**Gate**: build

**Commit**: `chore(design-system): reconcile tokens with Nightlife Discovery Stitch theme`

---

### T2: `events` migration — nullable `latitude`/`longitude` + composite index

**What**: New Laravel migration adding nullable `latitude decimal(10,7)` and `longitude decimal(10,7)` columns to `events`, plus a plain composite btree index on `(latitude, longitude)`.
**Where**: `api/database/migrations/<timestamp>_add_coordinates_to_events_table.php`
**Depends on**: None
**Reuses**: existing migration style (see the `address` non-null migration from AD-023 for the file-editing convention on a dev-stage schema)
**Requirement**: MAPGEO-04

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [x] Migration runs clean (`docker compose exec api php artisan migrate`)
- [x] Columns are nullable (existing rows remain valid, no backfill)
- [x] Index created

**T2 status**: ✅ Complete. `2026_09_09_010000_add_coordinates_to_events_table.php` adds nullable `latitude`/`longitude` `decimal(10,7)` to `events` plus a composite btree index on `(latitude, longitude)`. `docker compose exec api php artisan migrate` ran clean (`DONE`).

**Tests**: none — matrix lists migrations as build-gate-only
**Gate**: build

**Commit**: `feat(api): add nullable lat/lng columns to events`

---

### T3: `GeocodingPort` interface + `Coordinates` value object

**What**: New domain-layer interface `GeocodingPort` with `geocode(string $address): ?Coordinates`, and a small immutable `Coordinates` value object (`latitude: float, longitude: float`).
**Where**: `api/src/Domain/Event/GeocodingPort.php`, `api/src/Domain/Event/Coordinates.php`
**Depends on**: None
**Reuses**: `NotificationSender` interface shape (`ARCHITECTURE.md` §6.1) as the pattern reference
**Requirement**: MAPGEO-01, MAPGEO-02

*Granularity note*: an interface and its one accompanying value object, authored together since the interface's signature names the type — splitting would leave either file referencing a type that doesn't exist yet.

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [x] Interface has zero framework/vendor imports (Clean Architecture §8.5)
- [x] `Coordinates` is immutable, validated (lat/lng within real-world bounds)

**T3 status**: ✅ Complete. `GeocodingPort::geocode(string): ?Coordinates` added with zero framework/vendor imports. `Coordinates` is a `final` readonly-property value object validating lat ∈ [-90,90] / lng ∈ [-180,180], throwing `InvalidArgumentException` with a pt-BR message otherwise. 6 unit tests in `CoordinatesTest.php` (valid, boundary, and all 4 out-of-bounds rejection cases). Gate: `docker compose exec api php artisan test` — 663 passed, 0 failed.

**Tests**: unit (GIVEN valid lat/lng WHEN constructing Coordinates THEN it succeeds; GIVEN out-of-bounds values THEN it rejects)
**Gate**: quick

**Commit**: `feat(api): add GeocodingPort interface and Coordinates value object`

---

### T4: `GoogleGeocodingAdapter` implementation

**What**: Infra-layer implementation of `GeocodingPort` calling the Google Geocoding API; returns `null` (not a thrown exception) on any failure (no results, API error, timeout).
**Where**: `api/src/Infrastructure/Geocoding/GoogleGeocodingAdapter.php`
**Depends on**: T3
**Reuses**: existing HTTP-client/adapter conventions in `api/src/Infrastructure/` (mirror whatever the existing S3/notification adapters use for outbound HTTP)
**Requirement**: MAPGEO-01, MAPGEO-02

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [x] Successful geocode returns a `Coordinates` instance
- [x] API error/timeout/no-results all return `null`, never throw
- [x] API key read from config/env only, never hardcoded (`ARCHITECTURE.md` §13.3)

**T4 status**: ✅ Complete. `GoogleGeocodingAdapter` calls the Google Geocoding API via `Http::get`, reading the key/endpoint from `config('qor.geocoding.google.*')` (new config block, env-driven). Zero-result/error/exception paths all return `null` and log via `Log::error`, never throw. 4 Feature tests (`Http::fake`, `Log::spy`) cover success, `ZERO_RESULTS`, HTTP 500, and a thrown `ConnectionException`. Gate: 667 passed, 0 failed (was 663 before this task).

**Tests**: unit (GIVEN a resolvable address WHEN geocode() is called THEN it returns Coordinates; GIVEN an API error/timeout/unresolvable address THEN it returns null; failure is logged)
**Gate**: quick

**Commit**: `feat(api): implement GoogleGeocodingAdapter`

---

### T5: Wire geocoding into Event create/update

**What**: Extend the existing Event create/update use case(s) to call `GeocodingPort::geocode($address)` and persist the resulting coordinates (or leave them null on failure) — non-blocking, matching MAPGEO-02's "save proceeds regardless" rule.
**Where**: the existing Event create/update use case file(s) under `api/src/Domain/Event/UseCase/` (exact file(s) found during implementation)
**Depends on**: T4
**Reuses**: existing Event create/update use case, `EventRepository` save method
**Requirement**: MAPGEO-01, MAPGEO-02

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [x] Event with a resolvable address gets coordinates persisted
- [x] Event with an unresolvable address still saves, coordinates null, failure logged
- [x] No existing Event create/update test regresses

**T5 status**: ✅ Complete. `Event` gained nullable `latitude`/`longitude`. `CreateEvent`/`EditEvent` now take `GeocodingPort` and geocode the effective address before saving (`EditEvent`'s Draft branch only re-geocodes when the address actually changed; the Published branch can't change address so it carries the existing coordinates through unchanged). `GeocodingPort::class` bound to `GoogleGeocodingAdapter` in `AppServiceProvider`. `EloquentEventRepository`/`EventModel` persist and hydrate the two new columns. All 25 pre-existing `CreateEvent`/`EditEvent` unit tests updated to inject a `GeocodingPort` mock (via a new `geocoding()` test helper, mirroring the existing `genres()` helper) — no assertion weakened. 5 new tests added (2 create, 3 edit) for the geocode-success/geocode-failure/address-unchanged paths. While validating, found `GoogleGeocodingAdapterTest`'s admin Feature-test siblings (e.g. `AdminV1\EventControllerTest`) were making real outbound HTTP calls once geocoding got wired in — fixed by adding `Http::preventStrayRequests()` to the shared `tests/TestCase::setUp()`; a stray request now throws, which `GoogleGeocodingAdapter` already treats as a non-blocking geocoding failure, so no test needed rewriting. Also fixed 3 phpstan `mixed`-offset errors in `GoogleGeocodingAdapter` (found running the Full gate early ahead of T7). Gate: 672 passed, 0 failed (was 663 before Phase 2 started); `vendor/bin/phpstan analyse` clean.

**Tests**: unit (GIVEN a new event with a real address WHEN saved THEN coordinates persist; GIVEN an unresolvable address WHEN saved THEN the event still saves with null coordinates)
**Gate**: quick

**Commit**: `feat(api): geocode event address on create/update`

---

### T6: `EventRepository` bounding-box + city-radius query method

**What**: New `EventRepository` method returning published events with non-null coordinates within a bounding box, or within a per-`City` radius (radius value read from a new `qor.map.city_radius_km` config key, per §14.2's no-magic-numbers convention).
**Where**: `api/src/Domain/Event/EventRepository.php` (interface), the Eloquent implementation, `api/config/qor.php`
**Depends on**: T2
**Reuses**: existing `EventRepository` eager-load-genre query pattern (AD-023)
**Requirement**: MAPGEO-03

*Granularity note*: interface method + its Eloquent implementation + the one new config key it reads — one cohesive query capability, not three separable concerns.

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] Bounding-box query returns only events within bounds that have coordinates
- [ ] City-radius mode resolves a city to its configured radius and returns matching events
- [ ] Events with null coordinates are excluded from both modes

**Tests**: unit/integration (repository test against a real test DB: GIVEN events inside/outside a box THEN only inside ones return; GIVEN a city radius mode THEN only that city's geocoded events return; GIVEN an event with null coordinates THEN it's excluded)
**Gate**: quick

**Commit**: `feat(api): add bounding-box and city-radius event queries`

---

### T7: `GET /events/map` endpoint

**What**: New controller action + route + Form Request validation for `GET /api/v1/events/map`, accepting either `north/south/east/west` or `city` query params, returning geocoded events with the existing public event summary shape plus `latitude`/`longitude`.
**Where**: `api/src/Http/Controllers/Api/V1/EventController.php` (or a new `MapController` if the file is already large), `api/routes/api_v1.php`, a new Form Request class
**Depends on**: T6
**Reuses**: `GET /events`'s existing public-access, response-envelope, and Form Request validation conventions
**Requirement**: MAPGEO-03, MAPGEO-04

*Granularity note*: controller action + its route registration + its Form Request — one endpoint's three obligatory parts, always shipped together.

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] Happy path (valid box or valid city) returns geocoded events
- [ ] Missing both box and city → 422 with the standard pt-BR error envelope
- [ ] Zero-result area returns an empty array, not an error
- [ ] Route is public (no auth), matching `GET /events`

**Tests**: integration (Feature test: happy path with box; happy path with city; missing params → 422; zero-result area → empty array)
**Gate**: full

**Commit**: `feat(api): add GET /events/map endpoint`

---

### T8: Postman collection update for `GET /events/map`

**What**: Add the new endpoint to `qor-api`'s existing Postman/Insomnia collection (`ARCHITECTURE.md` §8.9), with a sample box request and a sample city request.
**Where**: wherever the existing api collection file lives (found during implementation)
**Depends on**: T7
**Reuses**: existing collection structure/environments
**Requirement**: MAPGEO-03

**Tools**: MCP: `postman` (if the collection is managed there) | Skill: NONE

**Done when**:
- [ ] New endpoint documented with both query modes and sample responses

**Tests**: none — documentation artifact, not code
**Gate**: build

**Commit**: `docs(api): add GET /events/map to Postman collection`

---

### T9: `Favorite` domain entity + `FavoriteRepository` port + impl

**What**: `Favorite` entity, `FavoriteRepository` interface (`toggle(eventId): Boolean`, `list(): List<Event>`), and an HTTP-backed implementation calling `POST /events/{id}/favorite` / `GET /favorites`.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/favorite/Favorite.kt`, `FavoriteRepository.kt`, `mobile/shared/src/commonMain/kotlin/data/FavoriteRepositoryImpl.kt`
**Depends on**: None
**Reuses**: `EventRepositoryImpl`'s `AuthenticatedHttpClient` usage pattern
**Requirement**: FAVUI-01, FAVUI-02

*Granularity note*: entity + its repository interface + its one implementation — the standard three-file shape every existing `shared` domain slice already uses (`Event`/`EventRepository`/`EventRepositoryImpl`).

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] `toggle()` calls the existing endpoint and returns the new state
- [ ] `list()` calls the existing endpoint and maps to `Event`

**Tests**: unit (GIVEN a successful toggle response THEN the new favorited state returns; GIVEN a list response THEN it maps to Event correctly; GIVEN a network/auth error THEN the Result is a failure)
**Gate**: quick

**Commit**: `feat(mobile-shared): add Favorite entity and repository`

---

### T10: `ToggleFavorite` / `ListFavorites` use cases

**What**: Thin use-case wrappers over `FavoriteRepository`, following the existing use-case pattern (`GetEventDetails`, `ListUpcomingEvents`).
**Where**: `mobile/shared/src/commonMain/kotlin/domain/favorite/usecase/ToggleFavorite.kt`, `ListFavorites.kt`
**Depends on**: T9
**Reuses**: existing use-case shape/`Result` handling

*Granularity note*: two tiny sibling use cases over the same repository, always consumed together by the Favorites screen — same cohesion class as `EventRepository`'s existing `GetEventDetails`/`ListUpcomingEvents` pair.
**Requirement**: FAVUI-01, FAVUI-02, FAVUI-04

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] Both use cases delegate correctly and surface repository errors as `Result` failures

**Tests**: unit (1:1 to FAVUI-01/02/04 — toggle success, list success, un-favorite-from-list removes it)
**Gate**: quick

**Commit**: `feat(mobile-shared): add ToggleFavorite and ListFavorites use cases`

---

### T11: `VerifyPasswordResetCode` use case + `UserRepository` method

**What**: New `UserRepository.verifyPasswordResetCode(email, code): Result<Unit>` calling `qor-api`'s existing `/auth/password/verify-code`, plus a `VerifyPasswordResetCode` use case wrapping it.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/user/UserRepository.kt` (extend), `mobile/shared/src/commonMain/kotlin/domain/user/usecase/VerifyPasswordResetCode.kt`, `UserRepositoryImpl.kt` (extend)
**Depends on**: None
**Reuses**: `resendVerification`/`verifyEmailCode`'s existing pair (S12b, AD-021) as the direct pattern reference; reuses `sanitizeOtpInput`

*Granularity note*: one repository method + the one use case that wraps it + the one implementation extension — mirrors exactly how S12b added `resendVerification`/`verifyEmailCode`.
**Requirement**: PWDR-01, PWDR-02, PWDR-03

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] Valid code → success
- [ ] Invalid/expired code → failure with a pt-BR-mappable error, does not throw

**Tests**: unit (GIVEN a valid code THEN success; GIVEN an invalid/expired code THEN failure without throwing)
**Gate**: quick

**Commit**: `feat(mobile-shared): add VerifyPasswordResetCode use case`

---

### T12: Phase 2 merge checkpoint (not a code task)

**What**: Open `qor-api`'s PR (`feat/api-event-geo-map` → `main`), run `review-laravel-api`, apply fixes, confirm `gh pr checks` green, merge, update the root submodule pointer. This is the explicit checkpoint the design's sequencing rule requires before T13 and any Map-UI task (T22, T32, T42) is considered unblocked.
**Where**: `qor-api` repo (PR), root repo (submodule pointer commit)
**Depends on**: T8
**Requirement**: MAPGEO-01..04 (process gate, not a new requirement)

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] `review-laravel-api` findings addressed
- [ ] `gh pr checks <PR>` green, verified explicitly
- [ ] Merged to `qor-api` `main`
- [ ] Root repo's `api` submodule pointer updated and committed

**Tests**: none — process checkpoint, not a code change
**Gate**: n/a

**Commit**: root repo: `chore: sync api submodule pointer (event geo/map)`

---

### T13: `MapBounds` value type + `EventRepository.getMapEvents` + `GetMapEvents` use case

**What**: `MapBounds` value type, `EventRepository.getMapEvents(city: City? , bounds: MapBounds?): Result<List<Event>>`, and a `GetMapEvents` use case wrapping it, targeting the `GET /events/map` shape from T7.
**Where**: `mobile/shared/src/commonMain/kotlin/domain/event/MapBounds.kt`, `EventRepository.kt` (extend), `usecase/GetMapEvents.kt`, `EventRepositoryImpl.kt` (extend)
**Depends on**: T12
**Reuses**: `EventRepositoryImpl`'s existing HTTP-call pattern; `Event`'s DTO now carries optional lat/lng (matches T7's response shape)

*Granularity note*: one value type + one repository method + its one use case + the one implementation extension consuming it — the same four-part shape as every other `shared` query slice in this feature.
**Requirement**: MAPUI-01, MAPUI-03, MAPUI-04

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] Box-mode and city-mode calls both map correctly to `GET /events/map`
- [ ] Events with no coordinates never appear (already guaranteed server-side per MAPGEO-03, but the DTO mapping must not crash on a null-coordinate event elsewhere in the app)

**Tests**: unit (GIVEN box params THEN correct query built; GIVEN city param THEN correct query built; GIVEN a response THEN it maps to Event list correctly)
**Gate**: quick

**Commit**: `feat(mobile-shared): add GetMapEvents use case`

---

### T14–T20: Website — existing-screen refresh (one per page)

Each task follows the same shape: diff the page against its Stitch screenshot/HTML (per `design.md`'s Code Reuse Analysis), apply structural/spacing changes using reconciled tokens (T1), preserve existing animations unless the mock specifies otherwise (REFRESH-03), never copy Stitch's Tailwind HTML verbatim (REFRESH-04), update/extend the page's existing `.test.tsx` co-located test.

| Task | Page | Stitch reference | Depends on |
| --- | --- | --- | --- |
| T14 | `website/app/entrar/page.tsx` | Entrar (Login Desktop) | T1 |
| T15 | `website/app/cadastro/page.tsx` | Criar Conta (Registro Desktop) | T1 |
| T16 | `website/app/verificar-email/page.tsx` | Verificação de E-mail OTP (Desktop) | T1 |
| T17 | `website/app/recuperar-senha/page.tsx` (+`/sucesso`) | Esqueci Minha Senha / Redefinir Nova Senha / Sucesso Envio de Link (Desktop) | T1 |
| T18 | `website/app/page.tsx` | Website Landing Page (Desktop) | T1 |
| T19 | `website/app/eventos/[id]/page.tsx` | Detalhes do Evento (Desktop) | T1 |
| T20 | `website/app/perfil/page.tsx` | Meu Perfil (Desktop) | T1 |

**Reuses**: each page's existing `components/design-system/*` building blocks
**Requirement**: REFRESH-01, REFRESH-02, REFRESH-03, REFRESH-04

**Tools** (all seven): MCP: `stitch` (`get_screen` for HTML+screenshot downloads) | Skill: NONE

**Done when** (all seven):
- [ ] Rendered page structurally matches the Stitch desktop screenshot
- [ ] Uses only reconciled tokens, no new hardcoded values
- [ ] Existing animations preserved unless the mock specifies otherwise
- [ ] Co-located test updated, passing

**Tests**: unit
**Gate**: quick (full at end of Phase 4)

**Commits**: `style(website): refresh <page> per new Stitch design` (one per task)

---

### T21: Website `/favoritos` page

**What**: New page listing the fan's favorited events, reusing `EventCard`, calling new `getFavorites`/`toggleFavorite` client functions, gated by the existing `PUBLIC_PATHS` auth pattern (closes the TODO in `lib/api/http.ts`).
**Where**: `website/app/favoritos/page.tsx`, `website/lib/api/client.ts` (extend)
**Depends on**: T1
**Reuses**: `EventCard`, `EmptyState`, existing auth-gate pattern

*Granularity note*: one page + the two client functions it exclusively calls — the same page+client-extension shape every existing website page task already follows.
**Requirement**: FAVUI-01, FAVUI-02, FAVUI-03, FAVUI-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Unauthenticated visitor redirects to `/entrar`
- [ ] Authenticated fan sees their favorited events, matching Stitch's "Meus Favoritos" layout
- [ ] Un-favoriting from the list removes it without a full reload

**Tests**: unit (auth redirect; render with favorites; un-favorite removes item)
**Gate**: quick

**Commit**: `feat(website): add /favoritos page`

---

### T22: Website `/mapa` page

**What**: New page rendering a multi-pin map, extending `GoogleMap.tsx` from single-pin to multi-pin mode, calling a new `getMapEvents` client function.
**Where**: `website/app/mapa/page.tsx`, `website/components/design-system/GoogleMap.tsx` (extend), `website/lib/api/client.ts` (extend)
**Depends on**: T1, T13
**Reuses**: `GoogleMap.tsx`'s existing single-pin implementation
**Requirement**: MAPUI-01, MAPUI-02, MAPUI-03, MAPUI-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Pins render for geocoded events per Stitch's "Mapa Interativo" desktop mock
- [ ] Clicking a pin navigates to that event's detail page
- [ ] Panning/zooming or applying a city filter re-queries rather than filtering one static fetch

**Tests**: unit (pins render from mocked response; pin click navigates; viewport change triggers a new query)
**Gate**: quick

**Commit**: `feat(website): add /mapa page`

---

### T23: Website Hub route(s)

**What**: New curated per-city Hub page(s) over the existing `GET /events?city=` filter, styled per Stitch's "Hubs da Grande Vitória" mock, reachable as an additional entry point from Home's city selection alongside the existing `CityGrid`→`/eventos?city=` link.
**Where**: exact URL shape decided during implementation (candidate: `website/app/hubs/[city]/page.tsx`)
**Depends on**: T1, T18
**Reuses**: `CityGrid`, `CityFilterBar`, `EventCard`, `EmptyState`
**Requirement**: HUB-01, HUB-02, HUB-03, HUB-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Each of the 4 cities' Hub renders only that city's published events in the curated layout
- [ ] Home offers a Hub entry point alongside the existing CityGrid link
- [ ] Zero-event city shows `EmptyState`

**Tests**: unit (render per city; empty state; Home entry-point link present)
**Gate**: full (end of Phase 5) + `make e2e-website` smoke covering `/favoritos`, `/mapa`, and one Hub

**Commit**: `feat(website): add Hubs da Grande Vitória pages`

---

### T24–T29: Android — existing-screen refresh (one per screen)

Same shape as T14–T20, targeting Android's mobile Stitch screenshots.

| Task | Screen | Stitch reference | Depends on |
| --- | --- | --- | --- |
| T24 | `LoginScreen.kt` | Entrar (Login Dark) | T1 |
| T25 | `SignupScreen.kt` | Criar Conta (Registro Dark) | T1 |
| T26 | `EmailVerificationScreen.kt` | Verificação de E-mail OTP (Mobile) | T1 |
| T27 | `HomeFeedScreen.kt` | Mobile App Homepage | T1 |
| T28 | `EventDetailScreen.kt` | Detalhes do Evento (Mobile) | T1 |
| T29 | `ProfileScreen.kt` | Meu Perfil (Mobile) | T1 |

**Reuses**: existing `ui/components/*` composables
**Requirement**: REFRESH-01, REFRESH-02, REFRESH-03, REFRESH-04

**Tools** (all six): MCP: `stitch` | Skill: NONE

**Done when** (all six):
- [ ] Rendered screen structurally matches the Stitch mobile screenshot
- [ ] Uses only reconciled tokens
- [ ] Existing `*RenderTest`/`*Test` updated, passing

**Tests**: unit/Robolectric render test
**Gate**: quick (full at end of Phase 6)

**Commits**: `style(mobile-android): refresh <Screen> per new Stitch design` (one per task)

---

### T30: Android `PasswordRecoveryScreen` — rebuild to real 3 steps

**What**: Restructure the existing 2-step `PasswordRecoveryScreen` into 3 real steps (email → verify-code → new-password), consuming T11's `VerifyPasswordResetCode` use case for the middle step, styled per Stitch's "Esqueci Minha Senha" / "Redefinir Nova Senha" / "Sucesso Envio de Link" mobile mocks. This is treated as a behavior change, not additive — the existing 2-step tests are replaced, not extended (per `design.md`'s Risks & Concerns).
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/PasswordRecoveryScreen.kt`
**Depends on**: T1, T11
**Reuses**: existing OTP-entry component pattern from `EmailVerificationScreen.kt`
**Requirement**: PWDR-01, PWDR-02, PWDR-03, PWDR-04, REFRESH-01

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Full email → code → new-password → success → login path works
- [ ] Invalid/expired code rejected without advancing
- [ ] Old 2-step tests replaced with 3-step equivalents (RED→GREEN→REFACTOR on the new flow)

**Tests**: unit/Robolectric render test (full 3-step happy path; invalid-code rejection)
**Gate**: quick

**Commit**: `feat(mobile-android): rebuild PasswordRecoveryScreen to 3-step parity`

---

### T31: Android `FavoritesScreen` + nav wiring

**What**: New screen consuming T10's use cases, reusing `EventCard`; wires the existing disabled `BottomNavDestination.Favoritos` tab to a real nav-graph route instead of a stub.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/FavoritesScreen.kt`, `ui/nav/QorNavGraph.kt` (extend), `ui/components/BottomNav.kt` (enable tab)
**Depends on**: T1, T10
**Reuses**: `EventCard`, `EmptyState`

*Granularity note*: new screen + the two small edits (nav-graph route registration, un-disabling the existing tab) needed to actually reach it — inseparable, a screen with no route to it isn't a deliverable.
**Requirement**: FAVUI-01, FAVUI-02, FAVUI-04, FAVUI-05

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Favoritos tab navigates to the real screen, no longer disabled
- [ ] Favorite/un-favorite works from the list

**Tests**: unit/Robolectric render test
**Gate**: quick

**Commit**: `feat(mobile-android): add FavoritesScreen, enable nav tab`

---

### T32: Android `MapScreen`

**What**: New screen extending `EventMapState.kt`'s single-event pattern to multi-pin, consuming T13's `GetMapEvents` use case, new nav-graph route.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/MapScreen.kt`, `EventMapState.kt` (extend), `ui/nav/QorNavGraph.kt` (extend)
**Depends on**: T1, T13
**Reuses**: `EventMapState.kt`'s existing Google Maps SDK wiring
**Requirement**: MAPUI-01, MAPUI-02, MAPUI-03, MAPUI-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Pins render for geocoded events
- [ ] Tapping a pin navigates to Event Detail

**Tests**: unit/Robolectric render test
**Gate**: quick

**Commit**: `feat(mobile-android): add MapScreen`

---

### T33: Android Hub screen(s) + nav wiring

**What**: New screen(s) for the 4 city Hubs, reusing `EventCard`, new nav-graph route(s), reachable from Home alongside the existing city filter.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/HubScreen.kt`, `ui/nav/QorNavGraph.kt` (extend)
**Depends on**: T1, T27
**Reuses**: `EventCard`, `EmptyState`
**Requirement**: HUB-01, HUB-02, HUB-03, HUB-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Each city's Hub renders correctly
- [ ] Empty state for a zero-event city
- [ ] Reachable from Home

**Tests**: unit/Robolectric render test
**Gate**: full (end of Phase 7)

**Commit**: `feat(mobile-android): add Hub screen(s)`

---

### T34–T39: iOS — existing-screen refresh (mirrors T24–T29)

| Task | Screen | Stitch reference | Depends on |
| --- | --- | --- | --- |
| T34 | `LoginView.swift` | Entrar (Login Dark) | T1 |
| T35 | `SignupView.swift` | Criar Conta (Registro Dark) | T1 |
| T36 | `EmailVerificationView.swift` | Verificação de E-mail OTP (Mobile) | T1 |
| T37 | `HomeFeedView.swift` | Mobile App Homepage | T1 |
| T38 | `EventDetailView.swift` | Detalhes do Evento (Mobile) | T1 |
| T39 | `ProfileView.swift` | Meu Perfil (Mobile) | T1 |

**Reuses**: existing `UI/Components/*` SwiftUI views
**Requirement**: REFRESH-01, REFRESH-02, REFRESH-03, REFRESH-04

**Tools** (all six): MCP: `stitch` | Skill: NONE

**Done when** (all six):
- [ ] Rendered screen structurally matches the Stitch mobile screenshot
- [ ] Uses only reconciled tokens
- [ ] Any pure-logic helper touched keeps/gains XCTest coverage (views themselves build-verified only, per the documented iOS render-test-infra gap)

**Tests**: unit (pure logic only) / build-verified for views
**Gate**: quick (full at end of Phase 8)

**Commits**: `style(mobile-ios): refresh <View> per new Stitch design` (one per task)

---

### T40: iOS `PasswordRecoveryView` — rebuild to real 3 steps

**What**: Mirrors T30 for iOS.
**Where**: `mobile/iosApp/iosApp/UI/Screens/PasswordRecoveryView.swift`
**Depends on**: T1, T11
**Reuses**: `EmailVerificationView.swift`'s existing OTP-entry pattern
**Requirement**: PWDR-01, PWDR-02, PWDR-03, PWDR-04, REFRESH-01

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Full 3-step path works; invalid code rejected without advancing
- [ ] Old 2-step logic tests replaced with 3-step equivalents

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: quick

**Commit**: `feat(mobile-ios): rebuild PasswordRecoveryView to 3-step parity`

---

### T41: iOS `FavoritesView` + nav wiring

**What**: Mirrors T31 for iOS — wires the existing disabled `.favoritos` tab (`AppNavigation.swift`'s `MainTabRootView` currently renders `EmptyView()`) to a real view.
**Where**: `mobile/iosApp/iosApp/UI/Screens/FavoritesView.swift`, `UI/AppNavigation.swift` (extend), `UI/Components/BottomNav.swift` (enable tab)
**Depends on**: T1, T10
**Reuses**: `EventCard`-equivalent SwiftUI component, `EmptyState`-equivalent
**Requirement**: FAVUI-01, FAVUI-02, FAVUI-04, FAVUI-05

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Favoritos tab navigates to the real view, no longer `EmptyView()`
- [ ] Favorite/un-favorite works from the list

**Tests**: unit (pure logic) / build-verified
**Gate**: quick

**Commit**: `feat(mobile-ios): add FavoritesView, enable nav tab`

---

### T42: iOS `MapView`

**What**: Mirrors T32 for iOS, extending `EventMapState.swift`.
**Where**: `mobile/iosApp/iosApp/UI/Screens/MapView.swift`, `EventMapState.swift` (extend), `UI/AppNavigation.swift` (extend)
**Depends on**: T1, T13
**Reuses**: `EventMapState.swift`'s existing MapKit/Google Maps wiring
**Requirement**: MAPUI-01, MAPUI-02, MAPUI-03, MAPUI-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Pins render for geocoded events
- [ ] Tapping a pin navigates to Event Detail

**Tests**: unit (pure logic) / build-verified
**Gate**: quick

**Commit**: `feat(mobile-ios): add MapView`

---

### T43: iOS Hub view(s) + nav wiring

**What**: Mirrors T33 for iOS.
**Where**: `mobile/iosApp/iosApp/UI/Screens/HubView.swift`, `UI/AppNavigation.swift` (extend)
**Depends on**: T1, T37
**Reuses**: `EventCard`-equivalent, `EmptyState`-equivalent
**Requirement**: HUB-01, HUB-02, HUB-03, HUB-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Each city's Hub renders correctly
- [ ] Empty state for a zero-event city
- [ ] Reachable from Home

**Tests**: unit (pure logic) / build-verified
**Gate**: full (end of Phase 9)

**Commit**: `feat(mobile-ios): add Hub view(s)`

---

### T44: Interactive UAT — website

**What**: Side-by-side screenshot comparison of every changed/new website route against its Stitch export; human-judgment pass per `validate.md`.
**Where**: N/A (verification activity)
**Depends on**: T23
**Requirement**: REFRESH-01, FAVUI, MAPUI, HUB (all, website-side)

**Tools**: MCP: `stitch` (screenshot downloads), `claude-in-chrome` (render comparison) | Skill: NONE

**Done when**:
- [ ] Every website route in scope passes side-by-side UAT or has a logged, user-accepted deviation

**Tests**: none — UAT is a human-judgment verification activity, not an automated test
**Gate**: n/a

---

### T45: Interactive UAT — Android

**What**: Same as T44, for every changed/new Android screen (Compose preview or emulator screenshots).
**Where**: N/A
**Depends on**: T33
**Requirement**: REFRESH-01, FAVUI, MAPUI, HUB (all, Android-side)

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Every Android screen in scope passes side-by-side UAT or has a logged, user-accepted deviation

**Tests**: none
**Gate**: n/a

---

### T46: Interactive UAT — iOS

**What**: Same as T44, for every changed/new iOS screen (SwiftUI preview or simulator screenshots).
**Where**: N/A
**Depends on**: T43
**Requirement**: REFRESH-01, FAVUI, MAPUI, HUB (all, iOS-side)

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Every iOS screen in scope passes side-by-side UAT or has a logged, user-accepted deviation

**Tests**: none
**Gate**: n/a

---

## Phase Execution Notes

Within Phase 4, 6, 8 (the per-screen refresh phases) and Phase 5/7/9 (new-screen phases) and Phase 10 (UAT), tasks have no dependency on each other — each depends only on T1 (and, where noted, one other earlier task) — so a single worker executes them in any convenient order within the phase; the numeric order (T14, T15, T16...) is simply the presentation order. The authoritative dependency edges are the Full Dependency Graph above, not task-number adjacency. Phases run in order; batches (sub-agent workers) pack consecutive whole phases — see Sub-Agent Offer below.

---

## Task Granularity Check

| Task | Scope | Status |
| --- | --- | --- |
| T1 | 4 token files, one cohesive reconciliation (see task's granularity note) | ✅ Granular (cohesive) |
| T2 | 1 migration | ✅ Granular |
| T3 | 1 interface + its 1 value object (see note) | ✅ Granular (cohesive) |
| T4 | 1 adapter | ✅ Granular |
| T5 | 1 use-case wiring | ✅ Granular |
| T6 | 1 repo method + impl + 1 config key (see note) | ✅ Granular (cohesive) |
| T7 | 1 endpoint: controller + route + Form Request (see note) | ✅ Granular (cohesive) |
| T8 | 1 doc update | ✅ Granular |
| T9 | 1 entity + repo interface + 1 impl (see note) | ✅ Granular (cohesive) |
| T10 | 2 sibling use cases (see note) | ✅ Granular (cohesive) |
| T11 | 1 repo method + 1 use case + impl ext (see note) | ✅ Granular (cohesive) |
| T12 | 1 process checkpoint | ✅ Granular |
| T13 | 1 value type + 1 repo method + 1 use case + impl ext (see note) | ✅ Granular (cohesive) |
| T14–T23 | 1 page each | ✅ Granular |
| T24–T33 | 1 screen each (T31/T33 include their obligatory nav-route registration, see notes) | ✅ Granular (cohesive) |
| T34–T43 | 1 view each (T41/T43 include their obligatory nav-route registration, see notes) | ✅ Granular (cohesive) |
| T44–T46 | 1 platform-wide UAT pass each | ✅ Granular (verification activity, not code) |

---

## Diagram-Definition Cross-Check

Every `Depends on` in a task body has a matching edge in the Full Dependency Graph above, and every edge there has a matching `Depends on`. Verified pairing:

| Task | Depends On (task body) | Diagram Shows | Status |
| --- | --- | --- | --- |
| T1 | None | — | ✅ Match |
| T2 | None | — | ✅ Match |
| T3 | None | — | ✅ Match |
| T4 | T3 | T3→T4 | ✅ Match |
| T5 | T4 | T4→T5 | ✅ Match |
| T6 | T2 | T2→T6 | ✅ Match |
| T7 | T6 | T6→T7 | ✅ Match |
| T8 | T7 | T7→T8 | ✅ Match |
| T9 | None | — | ✅ Match |
| T10 | T9 | T9→T10 | ✅ Match |
| T11 | None | — | ✅ Match |
| T12 | T8 | T8→T12 | ✅ Match |
| T13 | T12 | T12→T13 | ✅ Match |
| T14 | T1 | T1→T14 | ✅ Match |
| T15 | T1 | T1→T15 | ✅ Match |
| T16 | T1 | T1→T16 | ✅ Match |
| T17 | T1 | T1→T17 | ✅ Match |
| T18 | T1 | T1→T18 | ✅ Match |
| T19 | T1 | T1→T19 | ✅ Match |
| T20 | T1 | T1→T20 | ✅ Match |
| T21 | T1 | T1→T21 | ✅ Match |
| T22 | T1, T13 | T1→T22, T13→T22 | ✅ Match |
| T23 | T1, T18 | T1→T23, T18→T23 | ✅ Match |
| T24 | T1 | T1→T24 | ✅ Match |
| T25 | T1 | T1→T25 | ✅ Match |
| T26 | T1 | T1→T26 | ✅ Match |
| T27 | T1 | T1→T27 | ✅ Match |
| T28 | T1 | T1→T28 | ✅ Match |
| T29 | T1 | T1→T29 | ✅ Match |
| T30 | T1, T11 | T1→T30, T11→T30 | ✅ Match |
| T31 | T1, T10 | T1→T31, T10→T31 | ✅ Match |
| T32 | T1, T13 | T1→T32, T13→T32 | ✅ Match |
| T33 | T1, T27 | T1→T33, T27→T33 | ✅ Match |
| T34 | T1 | T1→T34 | ✅ Match |
| T35 | T1 | T1→T35 | ✅ Match |
| T36 | T1 | T1→T36 | ✅ Match |
| T37 | T1 | T1→T37 | ✅ Match |
| T38 | T1 | T1→T38 | ✅ Match |
| T39 | T1 | T1→T39 | ✅ Match |
| T40 | T1, T11 | T1→T40, T11→T40 | ✅ Match |
| T41 | T1, T10 | T1→T41, T10→T41 | ✅ Match |
| T42 | T1, T13 | T1→T42, T13→T42 | ✅ Match |
| T43 | T1, T37 | T1→T43, T37→T43 | ✅ Match |
| T44 | T23 | T23→T44 | ✅ Match |
| T45 | T33 | T33→T45 | ✅ Match |
| T46 | T43 | T43→T46 | ✅ Match |

No forward-phase dependency: every dependency points backward (an earlier phase) or within the same phase.

---

## Test Co-location Validation

| Task | Code Layer Created/Modified | Matrix Requires | Task Says | Status |
| --- | --- | --- | --- | --- |
| T1 | design-system.md/config layer | none (entity/config) | none | ✅ OK |
| T2 | qor-api migration/config | none | none | ✅ OK |
| T3 | qor-api domain (interface+VO) | unit | unit | ✅ OK |
| T4 | qor-api domain/use-case (adapter) | unit | unit | ✅ OK |
| T5 | qor-api domain/use-case | unit | unit | ✅ OK |
| T6 | qor-api domain/use-case (repo query) | unit | unit/integration | ✅ OK |
| T7 | qor-api HTTP/controller | integration | integration | ✅ OK |
| T8 | docs only | none | none | ✅ OK |
| T9–T11 | mobile/shared domain | unit | unit | ✅ OK |
| T12 | process checkpoint | none | none | ✅ OK |
| T13 | mobile/shared domain | unit | unit | ✅ OK |
| T14–T20 | website pages (refresh) | unit | unit | ✅ OK |
| T21 | website new route | unit | unit | ✅ OK |
| T22 | website new route | unit | unit | ✅ OK |
| T23 | website new route(s) | unit + e2e (phase-end) | unit, e2e called out | ✅ OK |
| T24–T29 | Android screens (refresh) | unit/Robolectric | unit/Robolectric | ✅ OK |
| T30–T33 | Android screens (new/rebuilt) | unit/Robolectric | unit/Robolectric | ✅ OK |
| T34–T39 | iOS views (refresh) | unit (pure logic) | unit | ✅ OK |
| T40–T43 | iOS views (new/rebuilt) | unit (pure logic) | unit | ✅ OK |
| T44–T46 | verification activity | none (UAT is not a code layer) | none | ✅ OK |

No violations.

---

## Sub-Agent Offer

46 tasks across 10 phases exceeds the ~8-task inline threshold. Given real phase-size variance (1, 7, 5, 7, 3, 7, 3, 7, 3, 3 tasks) and the hard cross-repo gate at T12/T13 (Phase 2→3 boundary), the packing that both respects the ~7-task budget and never splits a phase is:

| Batch | Phases (whole, in order) | Tasks | Count |
| --- | --- | --- | --- |
| 1 | 1, 2 | T1–T8 | 8 |
| 2 | 3, 4 | T9–T13, T14–T20 | 12 (over budget — Phase 4 alone is 7; see note) |
| 3 | 5, 6 | T21–T23, T24–T30 | 10 (over budget; see note) |
| 4 | 7, 8 | T31–T33, T34–T40 | 10 (over budget; see note) |
| 5 | 9, 10 | T41–T43, T44–T46 | 6 |

Batches 2–4 exceed the ~7-task budget because their phase pairs (5+7, 3+7, 3+7) don't divide evenly at that size without splitting a 7-task phase — which the packing rule forbids. **Recommendation: one batch per phase (10 batches)** instead — costs more orchestration overhead than the ideal ~7-task packing, but guarantees phase integrity, keeps the T12 merge checkpoint an unambiguous batch boundary, and matches this feature's real shape (10 naturally-sized phases, several already near or under budget on their own). Ask the user which they prefer — 5 oversized-but-fewer batches, or 10 batches sized exactly to each phase — before dispatching Phase 1.

---

## Tools/MCP confirmation needed before Execute

Primary tool per task group: `stitch` MCP for Stitch HTML/screenshot re-fetching during every screen-refresh and new-screen task, plus each repo's own toolchain (`docker compose`, `gradlew`, `xcodebuild`) for implementation/testing. `postman` MCP is optional for T8. `claude-in-chrome` is used for the website UAT pass (T44). No other skill or MCP is needed. Confirming this, and the batching question above, with the user before dispatching Phase 1.
