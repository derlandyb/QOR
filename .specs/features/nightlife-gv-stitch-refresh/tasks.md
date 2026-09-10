# Nightlife GV Stitch Refresh Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user - do not proceed without it.**

---

**Design**: `.specs/features/nightlife-gv-stitch-refresh/design.md`
**Status**: Draft

**Addendum note (2026-09-10)**: Phases 10–15 (T47–T68) below implement the Stitch Fidelity Audit addendum recorded in `spec.md`/`design.md`/`context.md`. They are `mobile`-only (Android + iOS + `mobile/shared`) — the addendum explicitly excludes `qor-website` and needs no new `qor-api` work (design.md:232; every data need is served by `GET /events?city=&genre=` and the already-live `GET/PATCH /preferences`). The former "Phase 10: Interactive UAT" is renumbered **Phase 16** so it runs after all addendum work, not before it.

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
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7 → Phase 8 → Phase 9 → Phase 10 → Phase 11 → Phase 12 → Phase 13 → Phase 14 → Phase 15 → Phase 16
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

### Phase 10: Regression fixes (BUGFIX-01..12)

All six tasks are independent of each other — no dependency beyond the already-built files they patch. Presentation order: shared session fix first (both platforms inherit it), then Android, then iOS.

```
T47
T31 → T48
T32 → T48
T33 → T48
T49
T25 → T50
T51
T35 → T52
```

### Phase 11: Login/Signup component fidelity + 5-tab bottom nav

```
T1 → T53
T24 → T53
T25 → T53
T31 → T54
T32 → T54
T33 → T54
T1 → T55
T34 → T55
T35 → T55
T41 → T56
T42 → T56
T43 → T56
```

### Phase 12: Hub curated-layout rebuild (Android fix; iOS built correctly the first time via the T43 amendment below)

```
T1 → T57
T33 → T57
T54 → T57
```

### Phase 13: EventDetail + Profile content parity

```
T58
T1 → T59
T28 → T59
T58 → T59
T1 → T60
T29 → T60
T58 → T60
T1 → T61
T38 → T61
T58 → T61
T1 → T62
T39 → T62
T58 → T62
```

### Phase 14: Guest browsing (GUEST-01..04)

```
T1 → T63
T31 → T63
T60 → T63
T1 → T64
T41 → T64
T62 → T64
```

### Phase 15: General screen fidelity (item 1a — Home & Email Verification, the two screens not already touched by Phases 11/13)

```
T1 → T65
T27 → T65
T63 → T65
T1 → T66
T26 → T66
T65 → T66
T1 → T67
T37 → T67
T64 → T67
T1 → T68
T36 → T68
T67 → T68
```

### Phase 16: Interactive UAT
```
T23 → T44
T33 → T45
T66 → T45
T43 → T46
T68 → T46
```

**Total: 68 tasks across 16 phases.**

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
T66 → T45
T43 → T46
T68 → T46
T31 → T48
T32 → T48
T33 → T48
T25 → T50
T35 → T52
T1 → T53
T24 → T53
T25 → T53
T31 → T54
T32 → T54
T33 → T54
T1 → T55
T34 → T55
T35 → T55
T41 → T56
T42 → T56
T43 → T56
T1 → T57
T33 → T57
T54 → T57
T1 → T59
T28 → T59
T58 → T59
T1 → T60
T29 → T60
T58 → T60
T1 → T61
T38 → T61
T58 → T61
T1 → T62
T39 → T62
T58 → T62
T1 → T63
T31 → T63
T60 → T63
T1 → T64
T41 → T64
T62 → T64
T1 → T65
T27 → T65
T63 → T65
T1 → T66
T26 → T66
T65 → T66
T1 → T67
T37 → T67
T64 → T67
T1 → T68
T36 → T68
T67 → T68
```

Tasks with no incoming edges (no dependencies): T1, T2, T3, T9, T11, T47, T49, T51, T58.

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
- [x] Bounding-box query returns only events within bounds that have coordinates
- [x] City-radius mode resolves a city to its configured radius and returns matching events
- [x] Events with null coordinates are excluded from both modes

**T6 status**: ✅ Complete. `EventRepository::findMapEvents(?MapBounds, ?City): list<Event>` added; `EloquentEventRepository` implements it with `whereNotNull`/`whereBetween` on `latitude`/`longitude`, published-only (mirrors `GET /events`'s existing public-query base). City mode resolves a fixed per-city center point (private const, same "fixed set of 4" status as the `City` enum) to a bounding box using the new `qor.map.city_radius_km` config key, converted via a km-per-degree approximation (no circular-radius SQL, staying inside Approach A's plain-bounding-box shape). New `MapBounds` domain value object (validated: north>south, east>west). `InMemoryEventRepository` (the domain contract-test fake) updated with a stub implementation and lat/lng passthrough in `save()`. 8 new tests (3 `MapBoundsTest`, 5 `EloquentEventRepositoryTest`: box in/out, city mode, null-coords excluded, draft-status excluded) against the real test DB. Gate: 679 passed, 0 failed; `phpstan analyse` clean.

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
- [x] Happy path (valid box or valid city) returns geocoded events
- [x] Missing both box and city → 422 with the standard pt-BR error envelope
- [x] Zero-result area returns an empty array, not an error
- [x] Route is public (no auth), matching `GET /events`

**T7 status**: ✅ Complete. `GET /api/v1/events/map` added to the existing `EventController` (`map` action) alongside a new `GetMapEvents` use case (thin wrapper over `EventRepository::findMapEvents`, mirroring `ListUpcomingEvents`) and a new `MapEventsRequest` Form Request — `north`/`south`/`east`/`west` are `required_with` each other (a partial box 422s cleanly), and an `after()` validator hook 422s when neither a city nor a full box is given. Route registered public/no-auth in the same `throttle:qor-public-api` group as `GET /events`, placed before the `{id}` route (static-segment `map` never collides with the numeric `whereNumber('id')` constraint regardless of order). `eventToArray()` now includes `latitude`/`longitude` (additive — verified `assertJsonStructure` on `index`/`show` still passes since it doesn't forbid extra keys). 5 new Feature tests (box happy path, city happy path, missing-both 422, zero-result empty array, no-auth-token succeeds). Gate (full): 684 passed, 0 failed; `phpstan analyse` clean.

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
- [x] New endpoint documented with both query modes and sample responses

**T8 status**: ✅ Complete. Two new requests added to the "Events (Public)" folder in `docs/postman/qor-api-mvp-core.postman_collection.json`: "Get Map Events (Bounding Box)" and "Get Map Events (City)", each with a sample query and a sample 200 response documented in its description (matching the collection's existing description-as-docs convention). Gate: file re-parses as valid JSON; no code changed.

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
- [x] `toggle()` calls the existing endpoint and returns the new state
- [x] `list()` calls the existing endpoint and maps to `Event`

**T9 status**: ✅ Complete. `list()` targets the actual routed endpoint (`GET /profile/favorites` — tasks.md's `/favorites` doesn't exist in `qor-api`'s `routes/api_v1.php`). `EventDto.genre` gained a `""` default (SPEC_DEVIATION) because the real favorites payload (`FavoriteController::eventToArray`) omits `genre` and sends `genre_id` instead, which would otherwise crash decoding.

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
- [x] Both use cases delegate correctly and surface repository errors as `Result` failures

**T10 status**: ✅ Complete. "Un-favorite-from-list removes it" (FAVUI-04) is a screen-level list-state behavior with no shared-module concept to test yet — covered in the later Android/iOS ViewModel tasks, not here.

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
- [x] Valid code → success
- [x] Invalid/expired code → failure with a pt-BR-mappable error, does not throw

**T11 status**: ✅ Complete — already satisfied by prior work, no new code added. SPEC_DEVIATION:
`UserRepository.verifyResetCode(email, code): VerifyResetCodeResult` and
`ResetPassword.verifyResetCode(email, code)` (`mobile/shared/.../domain/user/UserRepository.kt`,
`.../usecase/ResetPassword.kt`) already call `qor-api`'s `/auth/password/verify-code` and cover
PWDR-01/02/03 exactly, added in commit `1f7ebf3` ("retrofit ResetPassword to 3-step OTP
contract") before this batch ran. Tested in `ResetPasswordTest.kt` (valid/invalid/expired code)
and `UserRepositoryImplTest.kt` (POST to `/auth/password/verify-code`, response mapping).
Adding a second, parallel `VerifyPasswordResetCode` use case + `verifyPasswordResetCode`
repository method per this task's literal `Result<Unit>` signature would duplicate this and
regress it: `Result<Unit>` discards the reset token `VerifyResetCodeResult.Success` carries,
which step 3 (`confirmPasswordReset`) requires. No files touched; no commit needed beyond this
status update.

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
- [x] `review-laravel-api` findings addressed
- [x] `gh pr checks <PR>` green, verified explicitly
- [x] Merged to `qor-api` `main`
- [x] Root repo's `api` submodule pointer updated and committed

**Tests**: none — process checkpoint, not a code change
**Gate**: n/a

**Commit**: root repo: `chore: sync api submodule pointer (event geo/map)`

**T12 status**: ✅ Complete. PR #26 (`feat/api-event-geo-map` → `main`), reviewed by `review-laravel-api` — no blocking findings (two minor non-blocking notes: `GetMapEvents` use case lacks a dedicated unit test vs. its sibling pattern; synchronous geocoding call is an accepted design.md tradeoff). `gh pr checks 26` confirmed 2/2 passed before merge. Merged via `gh pr merge --merge`, api's `main` now at `627455c`. Root submodule pointer updated in the commit that closes this task.

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
- [x] Box-mode and city-mode calls both map correctly to `GET /events/map`
- [x] Events with no coordinates never appear (already guaranteed server-side per MAPGEO-03, but the DTO mapping must not crash on a null-coordinate event elsewhere in the app)

**T13 status**: ✅ Complete. `EventRepository.getMapEvents`/`EventRepositoryImpl` return the
plain (throwing) `List<Event>` per the existing `findUpcoming`/`findById` pattern; `Result<List<Event>>`
wrapping happens only in `GetMapEvents`, matching design.md's Interfaces section and T9/T10's
layering (SPEC_DEVIATION from this task's literal "`EventRepository.getMapEvents(...): Result<...>`"
wording, kept consistent with the rest of the repo). `Event`/`EventDto` gained nullable
`latitude`/`longitude`. Extending `EventRepository` required adding `getMapEvents` overrides to 7
pre-existing `androidApp` test-only fakes (`ExploreViewModelTest`, `HomeFeedViewModelTest`,
`EventDetailViewModelTest`, `ExploreScreenTest`, `EventDetailScreenTest`, `HomeFeedScreenTest`,
`QorNavGraphTest`) so the build keeps compiling — a direct, unavoidable consequence of the
interface change, not scope creep.

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
- [x] Rendered page structurally matches the Stitch desktop screenshot
- [x] Uses only reconciled tokens, no new hardcoded values
- [x] Existing animations preserved unless the mock specifies otherwise
- [x] Co-located test updated, passing

**T14 status**: ✅ Complete. `entrar/page.tsx` restyled to a two-panel split-screen (branding/live-highlight panel + form panel) per the Stitch desktop mock, reusing existing `TextField`/`Button`; all copy stayed within already-reconciled hex tokens. No animation existed on this page pre-refresh, so REFRESH-03 (preserve existing) is a no-op here.

**T15 status**: ✅ Complete. `cadastro/page.tsx` restyled to the same two-panel split-screen pattern as `entrar`, matching the "Criar Conta (Registro Desktop)" mock; existing `TextField`/`Button`/`ConsentCapture` reused as-is, no new hex values. No animation existed pre-refresh.

**T16 status**: ✅ Complete. `verificar-email/page.tsx` wrapped in a centered bordered card matching the "Verificação de E-mail OTP (Desktop)" mock's centered-card layout; added the destination email display; reused `OtpCodeInput`'s existing resend/cooldown UI as-is rather than rebuilding the mock's countdown chrome. No animation existed pre-refresh.

**T17 status**: ✅ Complete. `recuperar-senha/page.tsx` (all 3 wizard steps) and `recuperar-senha/sucesso/page.tsx` wrapped in the same centered bordered card as `verificar-email`, matching the "Esqueci Minha Senha" / "Redefinir Nova Senha" / "Sucesso Envio de Link" desktop mocks; no route/logic changes, only the wrapper's structure/tokens. No animation existed pre-refresh.

**T18 status**: ✅ Complete. `app/page.tsx` gains the Stitch landing mock's descriptive tagline below `HeroFeature`, still composed from the existing `HeroFeature`/`Marquee`/`EventCarousel`/`CityGrid` reuse chain per design.md. The mock's top nav and genre-category grid are out of scope: nav is `NavBar`'s global-layout concern (a separate component, untouched here) and a genre-browse grid is a not-yet-built feature with no "Done when" criterion covering it — adding one would be scope creep beyond this task's structural-refresh remit. Existing "Próximos eventos"/"Explore por cidade" headings and all functional behavior preserved unchanged (existing tests still pass). No animation change needed — `animate-card-enter`/`animate-pulse-glow` untouched.

**T19 status**: ✅ Complete. `eventos/[id]/page.tsx` gains "Sobre o evento" and "Localização" section headings matching the "Detalhes do Evento (Desktop)" mock's labeled sections; the existing two-column layout (description/map/organizers + sticky ticket sidebar) and `EventHero`/`GoogleMap`/`CtaButton`/`EventCarousel` reuse were already structurally aligned. The mock's lineup/schedule block has no backing `Event` field, so it wasn't rebuilt (REFRESH-04). No animation existed on this page pre-refresh.

**T20 status**: ✅ Complete. `perfil/page.tsx` wrapped in the same centered bordered card as the other refreshed pages, matching "Meu Perfil (Desktop)"; account-management heading renamed to "Segurança & Configurações da Conta" per the mock's wording for the fields this page actually has (export/delete). The mock's stats/favorite-genres/followed-venues/saved-events/sidebar-nav sections remain out of scope per this task's pre-existing scope note (Milestone 2's W35) — not rebuilt. No animation existed pre-refresh.

**Phase 4 (T14–T20) status**: ✅ All seven website existing-screen refresh tasks complete. Full gate (`test:coverage` + `lint` + `build`) run at the end of Phase 4.

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
- [x] Unauthenticated visitor redirects to `/entrar`
- [x] Authenticated fan sees their favorited events, matching Stitch's "Meus Favoritos" layout
- [x] Un-favoriting from the list removes it without a full reload

**Tests**: unit (auth redirect; render with favorites; un-favorite removes item)
**Gate**: quick

**Status**: ✅ Complete — `getFavorites`/`toggleFavorite` added to `lib/api/client.ts`, `hooks/useFavorites.ts` handles optimistic remove + rollback, `/favoritos` left out of `PUBLIC_PATHS` so the existing 401 handler redirects to `/entrar`. 222/222 website tests pass (quick gate).

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
- [x] Pins render for geocoded events per Stitch's "Mapa Interativo" desktop mock
- [x] Clicking a pin navigates to that event's detail page
- [x] Panning/zooming or applying a city filter re-queries rather than filtering one static fetch

**Tests**: unit (pins render from mocked response; pin click navigates; viewport change triggers a new query)
**Gate**: quick

**Status**: ✅ Complete — `getMapEvents` added to `lib/api/client.ts`, `GoogleMap.tsx` extended with a multi-pin mode (`pins`/`onPinClick`/`onBoundsChanged`, backward-compatible with the existing single-`address` mode), `useMapEvents` hook re-queries on city or bounds change. 238/238 website tests pass (quick gate).

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
- [x] Each of the 4 cities' Hub renders only that city's published events in the curated layout
- [x] Home offers a Hub entry point alongside the existing CityGrid link
- [x] Zero-event city shows `EmptyState`

**Tests**: unit (render per city; empty state; Home entry-point link present)
**Gate**: full (end of Phase 5) + `make e2e-website` smoke covering `/favoritos`, `/mapa`, and one Hub

**Status**: ✅ Complete — `website/app/hubs/[city]/page.tsx` added (curated per-city hero + EventCard grid over the existing `GET /events?city=`), Home's city section gets a "Hubs da Grande Vitória" link row alongside CityGrid. 249/249 unit tests pass, lint clean, build succeeds, e2e smoke (`/favoritos`, `/mapa`, `/hubs/vitoria`) 4/4 passing. The e2e run caught a real bug: `/mapa` and `/hubs` were missing from `lib/api/http.ts`'s `PUBLIC_PATHS`/`PUBLIC_PATH_PREFIXES`, so NavBar's background session check 401 was bouncing anonymous visitors to `/entrar` on both new public routes — fixed in the same commit since T23's own gate requires the smoke to pass across all three routes.

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
- [x] Rendered screen structurally matches the Stitch mobile screenshot
- [x] Uses only reconciled tokens
- [x] Existing `*RenderTest`/`*Test` updated, passing

**Tests**: unit/Robolectric render test
**Gate**: quick (full at end of Phase 6)

**Commits**: `style(mobile-android): refresh <Screen> per new Stitch design` (one per task)

**T24 status**: ✅ Complete. `LoginScreen.kt` reordered to match "Entrar (Login Dark)": the (disabled-stub) Google CTA and a new "OU" divider now lead the form, ahead of the email/password fields, and the "Esqueci minha senha" link moved to sit directly under the password field (above the submit button) per the mock's field order. All values remain `QualORockThemeTokens` constants — no new hardcoded colors/spacing. No animation existed on this screen pre-refresh (REFRESH-03 no-op). Existing `LoginScreenTest` assertions are all text-existence based (order-independent), so none needed rewriting; one new test asserts the "OU" divider renders.

**T25 status**: ✅ Complete. `SignupScreen.kt` reordered the same way as T24's Login refresh, matching "Criar Conta (Registro Dark)": the (disabled-stub) Google CTA and the shared `auth_divider_or` ("OU") divider now lead the form, ahead of name/email/password/birthdate. Tokens/animations unchanged. Existing `SignupScreenTest` assertions unaffected (text-existence based); one new test asserts the "OU" divider renders. 7/7 tests pass.

**T26 status**: ✅ Complete. `EmailVerificationScreen.kt`'s existing title/instructions/OTP-field/submit/resend order already matched "Verificação de E-mail OTP (Mobile)" — the one structural gap was the mock's trust-footer line, added as a new `email_verification_security_footer` Text at the bottom, tokens only. One new test asserts the footer renders. 6/6 tests pass.

**T27 status**: ✅ Complete. `HomeFeedScreen.kt` gains the "Eventos em Destaque" section heading from "Mobile App Homepage", rendered above the card list (Content state only — no change to Loading/Empty/Error states). The mock's city-filter chips and Hubs/Mapa/Salvos bottom-nav tabs are out of scope — they belong to not-yet-built screens (T31-T33), not this refresh task. One new test asserts the heading renders. 5/5 tests pass.

**T28 status**: ✅ Complete. `EventDetailScreen.kt` gains a back-link header row ("‹ Voltar") from "Detalhes do Evento (Mobile)"'s back-button header, wired through a new `onBackClick: () -> Unit = {}` param (default no-op — same injectable-seam pattern as `launchIntent`; actually wiring it to `navController.popBackStack()` is A14/`QorNavGraph.kt`'s job, out of this file's scope). The rest of the screen's section order (hero, title/badges, date/venue, embedded map, description, ticket CTA, promoter contacts, share) already matched the mock. The mock's "Outros rocks rolando" related-events section has no backing `EventDetail` field and stays out of scope (REFRESH-04). One new test asserts tapping the back link fires the callback. 12/12 tests pass.

**T29 status**: ✅ Complete. `ProfileScreen.kt` reorders the editable name field to sit directly under the avatar/"Alterar foto" block (above the read-only birthdate row), matching "Meu Perfil (Mobile)"'s "name right under the avatar" order. The mock's location badge, activity level, like/saved/hub counters, genre/venue preferences, and account-settings list have no backing data on `ProfileViewModel`/`User` and stay out of scope (REFRESH-04). One new test asserts the name field's semantics position sits above the birthdate row's. 5/5 tests pass.

---

### T30: Android `PasswordRecoveryScreen` — rebuild to real 3 steps

**What**: Restructure the existing 2-step `PasswordRecoveryScreen` into 3 real steps (email → verify-code → new-password), consuming T11's `VerifyPasswordResetCode` use case for the middle step, styled per Stitch's "Esqueci Minha Senha" / "Redefinir Nova Senha" / "Sucesso Envio de Link" mobile mocks. This is treated as a behavior change, not additive — the existing 2-step tests are replaced, not extended (per `design.md`'s Risks & Concerns).
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/PasswordRecoveryScreen.kt`
**Depends on**: T1, T11
**Reuses**: existing OTP-entry component pattern from `EmailVerificationScreen.kt`
**Requirement**: PWDR-01, PWDR-02, PWDR-03, PWDR-04, REFRESH-01

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [x] Full email → code → new-password → success → login path works
- [x] Invalid/expired code rejected without advancing
- [x] Old 2-step tests replaced with 3-step equivalents (RED→GREEN→REFACTOR on the new flow)

**Tests**: unit/Robolectric render test (full 3-step happy path; invalid-code rejection)
**Gate**: quick

**T30 status**: ✅ Complete. `PasswordRecoveryViewModel`/`PasswordRecoveryScreen` already rendered real 3 steps (email → verify-code → new-password) as of prior work (commit `1f7ebf3`, confirmed in T11's status note) — the gap this task closes is PWDR-04: `ConfirmResetResult.Success` now advances to a new `PasswordRecoveryStep.Success` state (styled per Stitch's "Sucesso Envio de Link" mock: title, message, "Voltar para o login" CTA) instead of firing `PasswordRecoveryEvent.ResetSuccess` immediately; a new `onSuccessContinue()` fires that event only once the fan acknowledges the success screen. The redundant "Lembrou da senha? Fazer login" footer link is hidden on the Success step. Per design.md's Risks table, the step-3-success test was replaced (not extended): `GIVEN step 3 WHEN confirmReset succeeds THEN onResetSuccess fires` became `...THEN the success screen renders instead of navigating immediately`, plus a new `GIVEN the success screen WHEN the CTA is tapped THEN onResetSuccess fires`. The spec.md edge case (abandoned mid-flow verify-code step requires restarting from step 1, no persisted partial state) is covered at both layers: `PasswordRecoveryViewModelTest` proves a fresh instance never inherits an abandoned instance's step, `PasswordRecoveryScreenTest` proves a fresh render starts at the email step. `PasswordRecoveryScreenTest`: 10/10 pass. `PasswordRecoveryViewModelTest`: 15/15 pass.

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
- [x] Favoritos tab navigates to the real screen, no longer disabled
- [x] Favorite/un-favorite works from the list

**Tests**: unit/Robolectric render test
**Gate**: quick

**T31 status**: ✅ Complete. `FavoritesScreen`/`FavoritesViewModel` consume T10's `ToggleFavorite`/`ListFavorites`, reusing `EventCard`/`EmptyState`. `BottomNavDestination.Favoritos` is now `enabled = true` and `QorNavGraph` routes it to the real screen instead of the Milestone-2 disabled stub. Split into a `feat(mobile-shared)` commit (DI wiring for `FavoriteRepository`/`ToggleFavorite`/`ListFavorites`, already-existing classes from T9/T10) and this `feat(mobile-android)` commit per `ARCHITECTURE.md` §8.10. Quick gate (`./gradlew test`) green in isolation.

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
- [x] Pins render for geocoded events
- [x] Tapping a pin navigates to Event Detail

**Tests**: unit/Robolectric render test
**Gate**: quick

**T32 status**: ✅ Complete. `MapScreen`/`MapViewModel` extend `EventMapState.kt`'s single-pin pattern to a multi-pin `maps-compose` `GoogleMap`, consuming T13's `GetMapEvents`; defaults to `City.Vitoria` (city mode) on load since there's no location-permission flow yet, with pan/zoom re-querying via `loadByBounds` (MAPUI-03). New nav-graph route added. Split into a `feat(mobile-shared)` commit (`GetMapEvents` DI wiring) and this `feat(mobile-android)` commit per `ARCHITECTURE.md` §8.10. Quick gate green in isolation.

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
- [x] Each city's Hub renders correctly
- [x] Empty state for a zero-event city
- [x] Reachable from Home

**Tests**: unit/Robolectric render test
**Gate**: full (end of Phase 7)

**T33 status**: ✅ Complete. `HubScreen`/`HubViewModel` reuse the existing `GET /events?city=` filter via `ListUpcomingEvents` (design.md's Tech Decision — no dedicated hub-aggregation endpoint), reusing `EventCard`/`EmptyState`. `HomeFeedScreen` gains a "Hubs da Grande Vitória" entry-point row of 4 per-city pills (reusing `CityFilterColors`), alongside the existing `CityFilterBar`→`/eventos?city=` link, not replacing it. New nav-graph route `hub/{city}` added, city sourced only from the route arg (spec's Edge Case: no stored preference fallback). No shared-module DI change needed (`ListUpcomingEvents` already bound). Full gate (`./gradlew test koverVerify :androidApp:koverVerifyDebug detekt`) green — 2 detekt findings (a magic-number camera constant in `MapScreen.kt`, two over-length KDoc/test lines) fixed during reconciliation.

**Phase 7 (T31–T33) status**: ✅ Complete. All three tasks committed as 5 atomic commits (2 `feat(mobile-shared)` DI-wiring commits + 3 `feat(mobile-android)` screen commits), split per `ARCHITECTURE.md` §8.10's platform-boundary rule. Full gate green at Phase end.

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
- [x] Rendered screen structurally matches the Stitch mobile screenshot
- [x] Uses only reconciled tokens
- [x] Any pure-logic helper touched keeps/gains XCTest coverage (views themselves build-verified only, per the documented iOS render-test-infra gap)

**Tests**: unit (pure logic only) / build-verified for views
**Gate**: quick (full at end of Phase 8)

**Commits**: `style(mobile-ios): refresh <View> per new Stitch design` (one per task)

**T34 status**: ✅ Complete. `LoginView.swift` reordered to match "Entrar (Login Dark)" (mirrors Android's T24): the (disabled-stub) Google CTA and a new "OU" divider (`auth_divider_or`, added to `Localizable.xcstrings`) now lead the form, ahead of the email/password fields, and the "Esqueci minha senha" link moved to sit directly under the password field, above the submit button. All values remain `QorColor`/`QorSpace`/`QualORockThemeTokens` — no new hardcoded colors/spacing. No animation existed on this screen pre-refresh (REFRESH-03 no-op). One new `ViewInspector`-based test asserts the "OU" divider renders (`LoginViewTests.swift`); existing assertions (all `find(viewWithId:)`/`find(text:)`, order-independent) needed no changes. Prerequisite fix (separate commit, before T34): `Event`'s MAPGEO latitude/longitude fields had no Swift default across the Kotlin/Obj-C bridge, leaving 4 pre-existing iOS test fixtures (`EventDetailViewTests`, `EventDetailViewModelTests`, `HomeFeedViewTests`, `HomeFeedViewModelTests`) uncompilable — fixed so the whole `iosAppTests` target could build. Quick gate (`xcodebuild test -only-testing:iosAppTests/LoginViewTests`): 7/7 pass.

**T35 status**: ✅ Complete. `SignupView.swift` reordered the same way as T34's Login refresh, matching "Criar Conta (Registro Dark)" (mirrors Android's T25): the (disabled-stub) Google CTA and the shared `auth_divider_or` ("OU") divider now lead the form, ahead of name/email/password/birthdate. Tokens/animations unchanged. One new test asserts the "OU" divider renders; existing accessibility-identifier-based assertions unaffected. Quick gate (`xcodebuild test -only-testing:iosAppTests/SignupViewTests`): 5/5 pass.

**T36 status**: ✅ Complete. `EmailVerificationView.swift`'s existing title/instructions/OTP-field/submit/resend order already matched "Verificação de E-mail OTP (Mobile)" (mirrors Android's T26) — the one structural gap was the mock's trust-footer line, added as a new `email_verification_security_footer` Text at the bottom, tokens only. One new test asserts the footer renders. Quick gate (`xcodebuild test -only-testing:iosAppTests/EmailVerificationViewTests`): 5/5 pass.

**T37 status**: ✅ Complete. `HomeFeedView.swift`'s Content state gains the "Eventos em Destaque" section heading from "Mobile App Homepage" (mirrors Android's T27), rendered above the card list — Loading/Empty/Error states unchanged. The mock's city-filter chips and Hubs/Mapa/Salvos bottom-nav tabs are out of scope, belonging to not-yet-built screens (T41–T43). One new test asserts the heading renders. Quick gate (`xcodebuild test -only-testing:iosAppTests/HomeFeedViewTests`): 6/6 pass.

**T38 status**: ✅ Complete. Audit against "Detalhes do Evento (Mobile)" (mirrors Android's T28) found `EventDetailView.swift` already structurally matched: section order (hero, title/badges, date/venue, embedded map, description, ticket CTA, promoter contacts, share) and the `.toolbar` back-chevron affordance were already in place — unlike Android's `EventDetailScreen`, which had no back control before its own T28 refresh. No functional change was needed; a doc comment records the audit. The mock's "Outros rocks rolando" related-events section has no backing `EventDetail` field and stays out of scope (REFRESH-04), same call as Android's T28. Quick gate (`xcodebuild test -only-testing:iosAppTests/EventDetailViewTests -only-testing:iosAppTests/EventDetailViewModelTests`): 11/11 pass.

**T39 status**: ✅ Complete. `ProfileView.swift` reorders the editable name field to sit directly under the avatar/"Alterar foto" block (above the read-only birthdate row), matching "Meu Perfil (Mobile)"'s "name right under the avatar" order (mirrors Android's T29). The mock's location badge, activity level, like/saved/hub counters, genre/venue preferences, and account-settings list have no backing data on `ProfileViewModel`/`User` and stay out of scope (REFRESH-04). One new `ViewInspector`-based test asserts the name field is encountered before the birthdate row in document-order traversal. Quick gate (`xcodebuild test -only-testing:iosAppTests/ProfileViewTests`): 4/4 pass.

---

### T40: iOS `PasswordRecoveryView` — rebuild to real 3 steps

**What**: Mirrors T30 for iOS.
**Where**: `mobile/iosApp/iosApp/UI/Screens/PasswordRecoveryView.swift`
**Depends on**: T1, T11
**Reuses**: `EmailVerificationView.swift`'s existing OTP-entry pattern
**Requirement**: PWDR-01, PWDR-02, PWDR-03, PWDR-04, REFRESH-01

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [x] Full 3-step path works; invalid code rejected without advancing
- [x] Old 2-step logic tests replaced with 3-step equivalents

**T40 status**: ✅ Complete — already satisfied by prior work, no functional code change needed (mirrors T11's SPEC_DEVIATION shape). Unlike Android's original A10 (which shipped a collapsed 2-step stopgap needing T30 to retrofit), iOS's I10 already built `PasswordRecoveryView`/`PasswordRecoveryViewModel` as a real 3-step wizard (email → verify-code → new-password) consuming `ResetPassword.verifyResetCode`/`confirmReset` (T11's shared API), with PWDR-04's Success step already gated behind an explicit `onResetSuccess` tap rather than an immediate auto-navigate — the exact design decision Android's T30 had to retrofit was already iOS's design from the start. No 2-step legacy code or tests ever existed to replace. A doc comment on `PasswordRecoveryView` records this audit and cites the three Stitch mock IDs. Quick gate (`xcodebuild test -only-testing:iosAppTests/PasswordRecoveryViewTests -only-testing:iosAppTests/PasswordRecoveryViewModelTests`): 20/20 pass (7 view + 13 view-model).

**Phase 8 (T34–T40) status**: ✅ Complete. All seven iOS screens refreshed/audited per Stitch, mirroring Android's T24–T30 exactly (same mocks; T38/T40 needed no functional change since iOS's prior implementation already matched the mock/design). 6 atomic `style(mobile-ios)`/`feat(mobile-ios)` code commits (T34/T35/T36/T37/T39 style + T38/T40 doc-only style commits), plus one prerequisite `fix(mobile-ios)` commit (pre-existing `Event` fixture compile break blocking every gate in this phase). Full gate (`xcodegen generate && swiftlint lint --strict && xcodebuild test`) run at phase end.

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

**Amended 2026-09-10 (Stitch Fidelity Audit addendum)**: originally scoped as a plain per-city list mirroring T33. Android's equivalent (T33) shipped that shape and was found to violate HUB-01's "curated, distinct from Explore" requirement, needing a follow-up fix (T57). Since T43 is still unstarted, it is amended now to build the curated layout directly — see design.md:313–319 — instead of building the known-wrong version first.

**What**: New curated Hub surface: a city-selector landing state (4 gradient city cards + counts) plus a rebuilt curated per-city view (featured/highlighted event treatment, header imagery), per design.md's Hub rebuild (HUB-05/06). Not a plain per-city list.
**Where**: `mobile/iosApp/iosApp/UI/Screens/HubView.swift`, `UI/AppNavigation.swift` (extend)
**Depends on**: T1, T37
**Reuses**: `EventCard`-equivalent, `EmptyState`-equivalent, website's `CityGrid`/`CityFilterBar` styling as the curated-layout reference (per design.md:313-319)
**Requirement**: HUB-01, HUB-02, HUB-03, HUB-04, HUB-05, HUB-06

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] City-selector landing state renders 4 gradient city cards with event counts
- [ ] Each city's curated Hub view renders correctly, structurally distinct from the Explore/`/eventos` equivalent (featured/highlighted treatment, not a plain list)
- [ ] Empty state for a zero-event city
- [ ] Reachable from Home

**Tests**: unit (pure logic) / build-verified
**Gate**: full (end of Phase 9)

**Commit**: `feat(mobile-ios): add curated Hub view(s)`

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

**What**: Same as T44, for every changed/new Android screen (Compose preview or emulator screenshots), now including every addendum surface (Phases 10–15).
**Where**: N/A
**Depends on**: T33, T66
**Requirement**: REFRESH-01, FAVUI, MAPUI, HUB (all, Android-side), BUGFIX-01,02,04,05,06,07,08,09,10,11,12, REFRESH-05,06,07,08, NAV-01,02, HUB-05,06, EVDET-01,02,03,04, PROF-01,02,03,04,05, GUEST-01,02,03,04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Every Android screen in scope passes side-by-side UAT or has a logged, user-accepted deviation

**Tests**: none
**Gate**: n/a

---

### T46: Interactive UAT — iOS

**What**: Same as T44, for every changed/new iOS screen (SwiftUI preview or simulator screenshots), now including every addendum surface (Phases 10–15).
**Where**: N/A
**Depends on**: T43, T68
**Requirement**: REFRESH-01, FAVUI, MAPUI, HUB (all, iOS-side), BUGFIX-01,02,03,04,05,06,07,08,09,10,11,12, REFRESH-05,06,07,08, NAV-03,04, HUB-05,06, EVDET-01,02,03,04, PROF-01,02,03,04,05, GUEST-01,02,03,04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Every iOS screen in scope passes side-by-side UAT or has a logged, user-accepted deviation

**Tests**: none
**Gate**: n/a

---

## Addendum Task Breakdown (Stitch Fidelity Audit, 2026-09-10)

### T47: Shared — safe session restore

**What**: Wrap `SessionStore.restore()` in a try/catch and add a success-check before decode in `UserRepositoryImpl.getProfile()`, so a stale/incompatible session object or a 401 on cold launch clears the token and falls back to the unauthenticated state instead of throwing uncaught through `QorNavGraph.kt`'s unguarded `LaunchedEffect`.
**Where**: `mobile/shared/src/commonMain/kotlin/data/SessionStore.kt`, `mobile/shared/src/commonMain/kotlin/data/UserRepositoryImpl.kt`
**Depends on**: None
**Reuses**: existing `SessionStore`/`UserRepositoryImpl` structure
**Requirement**: BUGFIX-07, BUGFIX-08, BUGFIX-09

*Granularity note*: the crash spans both the store's restore path and the repository call it invokes — one root cause (unguarded deserialization), fixed together so neither file can regress the other's guard independently.

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] `SessionStore.restore()` catches deserialization/network failure, clears the token, and returns an unauthenticated state instead of throwing
- [ ] `UserRepositoryImpl.getProfile()` checks response success before decoding
- [ ] A new unit test reproduces the stale-session cold-launch crash pre-fix and proves it no longer throws post-fix

**Tests**: unit (GIVEN a stale/incompatible stored session WHEN `restore()` runs THEN it clears the token and returns unauthenticated, no throw; GIVEN `getProfile()` receives a non-success response THEN it returns a failure result, never an uncaught decode exception)
**Gate**: quick

**Commit**: `fix(mobile-shared): guard session restore against stale/invalid deserialization`

---

### T48: Android — wire real map navigation

**What**: `QorNavGraph.kt` passes real `onMapClick` callbacks into the Home/Explore/Favorites/Hub composable call sites instead of the hardcoded `{}` no-op currently in `FavoritesScreen.kt`/`HubScreen.kt`, so tapping a map entry point actually navigates to `MapScreen` (T32).
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/nav/QorNavGraph.kt`, `ui/screen/FavoritesScreen.kt`, `ui/screen/HubScreen.kt`
**Depends on**: T31, T32, T33
**Reuses**: `MapScreen`'s existing nav-graph route (T32)
**Requirement**: BUGFIX-01, BUGFIX-02

*Granularity note*: the nav-graph wiring and the two call sites it fixes are one indivisible repair — fixing only the nav graph without removing the screens' own hardcoded `{}` defaults leaves the bug in place.

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] Tapping the map entry point from Home, Explore, Favorites, and Hub navigates to `MapScreen`
- [ ] No remaining hardcoded `onMapClick = {}` default masking a real callback

**Tests**: unit/Robolectric render test (GIVEN the map entry point is tapped from each screen THEN navigation to `MapScreen` fires)
**Gate**: quick

**Commit**: `fix(mobile-android): wire real map navigation callbacks`

---

### T49: Android — event cover images

**What**: Add the Coil dependency and wire `AsyncImage(event.coverImageUrl)` into `EventCard.kt`'s image slot, falling back to the existing `PlaceholderImage` when `coverImageUrl` is null or fails to load. `Event.coverImageUrl` already exists as a field but `EventCard` never read it.
**Where**: `mobile/androidApp/build.gradle.kts` (add Coil dependency), `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/components/EventCard.kt`
**Depends on**: None
**Reuses**: `PlaceholderImage.kt` (already wired into `EventDetailScreen.kt`/`ProfileScreen.kt`, not yet into `EventCard`)
**Requirement**: BUGFIX-04, BUGFIX-05, BUGFIX-06

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] `EventCard` renders the real cover image via Coil when `coverImageUrl` is present
- [ ] `EventCard` falls back to `PlaceholderImage` when `coverImageUrl` is null or the load fails
- [ ] Every screen using `EventCard` (Home, Explore, Favorites, Hub, related-events) shows real covers, not blank boxes

**Tests**: unit/Robolectric render test (GIVEN an event with a cover URL THEN the image loads; GIVEN a null/failed cover URL THEN `PlaceholderImage` renders)
**Gate**: quick

**Commit**: `fix(mobile-android): render event cover images via Coil`

---

### T50: Android — signup birthdate mask + validation

**What**: Replace `SignupScreen.kt`'s bare free-text birthdate field with a real `DD/MM/AAAA` input mask, and replace `SignupViewModel.validateBirthdate()`'s non-blank-only check with real format/range validation, converting to ISO 8601 before it reaches the unchanged shared `RegisterFan` DTO.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/SignupScreen.kt`, `ui/viewmodel/SignupViewModel.kt`
**Depends on**: T25
**Reuses**: existing `QorTextField` component
**Requirement**: BUGFIX-10, BUGFIX-11, BUGFIX-12

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] Birthdate field masks input as `DD/MM/AAAA` while typing
- [ ] A valid date (e.g. a real birthdate in range) is accepted and converted to ISO 8601 before submission
- [ ] An invalid/out-of-range/malformed date is rejected client-side with a pt-BR error message, matching what previously reached the server as a silent rejection

**Tests**: unit/Robolectric render test (GIVEN a valid `DD/MM/AAAA` date WHEN submitted THEN it converts to ISO 8601 and signup proceeds; GIVEN an invalid date THEN client-side validation rejects it with a pt-BR message)
**Gate**: quick

**Commit**: `fix(mobile-android): add real birthdate mask and validation to signup`

---

### T51: iOS — event cover images parity

**What**: Verify the iOS root cause independently (per spec.md's iOS-parity assumption — `shared` KMP drives both platforms, but the platform-specific rendering layer differs) and wire native `AsyncImage` into the iOS `EventCard` equivalent, with the same `PlaceholderImage`-equivalent fallback as T49.
**Where**: iOS `UI/Components/EventCard.swift` (or the equivalent file, confirmed during implementation)
**Depends on**: None
**Reuses**: iOS's existing placeholder-image pattern (equivalent of `PlaceholderImage.kt`)
**Requirement**: BUGFIX-04, BUGFIX-05, BUGFIX-06

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] iOS root cause confirmed (not assumed identical to Android's) before the fix is written
- [ ] iOS `EventCard` equivalent renders the real cover image via native `AsyncImage` when `coverImageUrl` is present
- [ ] Falls back to the placeholder when `coverImageUrl` is null or the load fails

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: quick

**Commit**: `fix(mobile-ios): render event cover images`

---

### T52: iOS — signup birthdate mask + validation

**What**: Mirror T50 for iOS — verify the iOS root cause independently, then add a real `DD/MM/AAAA` input mask and format/range validation to the iOS signup birthdate field.
**Where**: iOS `UI/Screens/SignupView.swift` and its view model
**Depends on**: T35
**Reuses**: existing iOS text-field component
**Requirement**: BUGFIX-10, BUGFIX-11, BUGFIX-12

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] iOS root cause confirmed independently (mirrors T50, not copy-pasted from Android's diagnosis)
- [ ] Birthdate field masks input as `DD/MM/AAAA`
- [ ] Valid dates convert to ISO 8601 and submit; invalid dates are rejected client-side with a pt-BR message

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: quick

**Commit**: `fix(mobile-ios): add real birthdate mask and validation to signup`

---

### T53: Android — Login/Signup Stitch component fidelity

**What**: Bring `LoginScreen.kt`/`SignupScreen.kt` to real component-level Stitch match: a logo badge (net-new), the primary CTA restyled to the gradient `InstagramCta` treatment, `QorTextField` gains a `leadingIcon` slot (icon-prefixed fields), and the password field's visibility toggle becomes an eye/eye-slash icon.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/LoginScreen.kt`, `SignupScreen.kt`, shared `ui/components/QorTextField.kt`/`PasswordField.kt`
**Depends on**: T1, T24, T25
**Reuses**: `InstagramCta` gradient styling (per design.md:297-303)
**Requirement**: REFRESH-05, REFRESH-06, REFRESH-07, REFRESH-08

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Logo badge renders above the form on both Login and Signup
- [ ] Primary CTA uses the `InstagramCta` gradient treatment
- [ ] Email/password fields render with leading icons
- [ ] Password field toggle is an eye/eye-slash icon, not text

**Tests**: unit/Robolectric render test
**Gate**: quick

**Commit**: `style(mobile-android): match Login/Signup to Stitch component fidelity`

---

### T54: Android — bottom nav real 5-tab set

**What**: `BottomNavDestination` gains `Hubs` and `Mapa` cases (alongside the existing Início/Salvos/Perfil), routing to the already-built `HubScreen`/`MapScreen`, matching Stitch's Início/Hubs/Mapa/Salvos/Perfil tab set.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/components/BottomNav.kt`, `ui/nav/QorNavGraph.kt`
**Depends on**: T31, T32, T33
**Reuses**: existing `BottomNavDestination` enum shape, `BottomNav.kt`'s tab-rendering loop
**Requirement**: NAV-01, NAV-02

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Bottom nav shows exactly 5 tabs: Início, Hubs, Mapa, Salvos, Perfil
- [ ] Each new tab routes to its already-built screen (Hub, Map)

**Tests**: unit/Robolectric render test
**Gate**: full (end of Phase 10)

**Commit**: `feat(mobile-android): add real 5-tab bottom nav`

---

### T55: iOS — Login/Signup Stitch component fidelity

**What**: Mirrors T53 for iOS.
**Where**: iOS `UI/Screens/LoginView.swift`, `SignupView.swift`, shared text-field/password-field components
**Depends on**: T1, T34, T35
**Reuses**: iOS equivalent of `InstagramCta` gradient styling
**Requirement**: REFRESH-05, REFRESH-06, REFRESH-07, REFRESH-08

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Logo badge renders above the form on both Login and Signup
- [ ] Primary CTA uses the gradient treatment
- [ ] Email/password fields render with leading icons
- [ ] Password field toggle is an eye/eye-slash icon

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: quick

**Commit**: `style(mobile-ios): match Login/Signup to Stitch component fidelity`

---

### T56: iOS — bottom nav real 5-tab set

**What**: Mirrors T54 for iOS.
**Where**: iOS `UI/AppNavigation.swift`, `UI/Components/BottomNav.swift`
**Depends on**: T41, T42, T43
**Reuses**: existing iOS bottom-nav tab enum/rendering
**Requirement**: NAV-03, NAV-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Bottom nav shows exactly 5 tabs: Início, Hubs, Mapa, Salvos, Perfil
- [ ] Each new tab routes to its already-built view (Hub, Map)

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: full (end of Phase 11)

**Commit**: `feat(mobile-ios): add real 5-tab bottom nav`

---

### T57: Android — rebuild Hub curated layout

**What**: Rebuild `HubScreen.kt` to satisfy HUB-01/05/06: a city-selector landing state (4 gradient city cards + counts) plus a curated per-city view (featured/highlighted event treatment, header imagery), replacing the plain per-city list T33 shipped, which was structurally identical to `/eventos` and violated HUB-01's "curated, distinct from Explore" requirement.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/HubScreen.kt`
**Depends on**: T1, T33, T54
**Reuses**: `EventCard`, `EmptyState`, website's `CityGrid`/`CityFilterBar` styling as the curated-layout reference (per design.md:313-319)
**Requirement**: HUB-01, HUB-05, HUB-06

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] City-selector landing state renders 4 gradient city cards with event counts
- [ ] Each city's curated Hub view is structurally distinct from `/eventos`'s plain list (featured/highlighted treatment, header imagery)
- [ ] Zero-event city still shows `EmptyState`
- [ ] Existing `HubScreen` render tests updated to assert the curated structure, not the old plain-list structure

**Tests**: unit/Robolectric render test
**Gate**: full

**Commit**: `fix(mobile-android): rebuild Hub screen to curated layout per HUB-01`

---

### T58: Shared — EventDto fix + preferences/recommendations use cases

**What**: Fix `EventDto`'s promoter-mapping bug (deserializes a `promoters` key the API never sends — the API has always sent `tagged_promoters`; `ignoreUnknownKeys=true` silently masked the drop), correcting the mapping to `tagged_promoters[].contact_phone/contact_email` → `EventPromoterContact.phone/email`. Add `GetPreferences(): Result<UserPreferences>` / `UpdatePreferences(genreIds, radiusKm): Result<Unit>` use cases over the already-live `GET/PATCH /preferences`. Add a recommendations use case reusing `GET /events?city=&genre=` (same query, two call sites: EventDetail's related events and Profile's recommendations).
**Where**: `mobile/shared/src/commonMain/kotlin/data/EventDto.kt`, new `mobile/shared/src/commonMain/kotlin/domain/user/usecase/GetPreferences.kt`, `UpdatePreferences.kt`, new `mobile/shared/src/commonMain/kotlin/domain/event/usecase/GetRelatedEvents.kt` (or equivalently named)
**Depends on**: None
**Reuses**: existing `EventRepository`/`UserRepository` port+impl+use-case shape, `GET /events?city=&genre=` (`api/src/Http/Requests/Api/V1/ListEventsRequest.php:19-26`), `GET/PATCH /preferences` (`ProfileController::showPreferences/updatePreferences`)
**Requirement**: EVDET-01 (prerequisite), PROF-02, PROF-03

*Granularity note*: three shared-module additions bundled because both Android and iOS EventDetail/Profile tasks (T59–T62) need all three to compile against — this is the merge-forward resolution the skill's task-boundary rule calls for when downstream tasks can't be tested until the use cases they consume exist.

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] `EventDto` correctly deserializes `tagged_promoters` into `EventPromoterContact` (name/phone/email/instagram/tiktok)
- [ ] `GetPreferences`/`UpdatePreferences` call the existing `/preferences` endpoints and round-trip correctly
- [ ] The related-events/recommendations use case calls `GET /events?city=&genre=` and excludes the current event where applicable

**Tests**: unit (GIVEN an API response with `tagged_promoters` WHEN `EventDto` deserializes THEN `EventPromoterContact` fields populate correctly, reproducing the bug pre-fix and proving the fix post-fix; GIVEN preferences GET/PATCH calls THEN they round-trip; GIVEN a city/genre filter THEN related events exclude the current event)
**Gate**: quick

**Commit**: `fix(mobile-shared): correct EventDto promoter mapping, add preferences and related-events use cases`

---

### T59: Android — EventDetail organizer card, dual pill actions, related events

**What**: Add the organizer card (name, icon/initials — no logo field exists on the API response), a dual pill action row (`MapaCta` + `InstagramCta`, replacing the single "Abrir no mapa" button), and a horizontal related-events carousel (`LazyRow` using `EventCard`, the first horizontal-list pattern in the codebase) sourced from T58's related-events use case. Each section renders independently and is omitted, not shown broken, when its data is absent. Also closes T28's outstanding structural-fidelity gap for this screen (full layout/spacing/component-structure match against Stitch, not a reorder).
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/EventDetailScreen.kt`
**Depends on**: T1, T28, T58
**Reuses**: `EventCard` (for the carousel), `MapaCta`/`InstagramCta` pill components
**Requirement**: EVDET-01, EVDET-02, EVDET-03, EVDET-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Organizer card renders when organizer data is present, omitted (not broken) when absent
- [ ] Dual pill row (Maps + Instagram) replaces the single map button
- [ ] Horizontal related-events carousel renders other upcoming events in the same city/genre, excluding the current event
- [ ] Full structural fidelity against the "Detalhes do Evento (Mobile)" Stitch mock, not just a reorder

**Tests**: unit/Robolectric render test
**Gate**: quick

**Commit**: `feat(mobile-android): add EventDetail organizer card, dual actions, related events`

---

### T60: Android — Profile stats, preferences, favorite venues, recommendations, logout

**What**: On-device stat pills (favorited-events count, distinct cities), genre/venue preference chips backed by T58's `GetPreferences`/`UpdatePreferences`, an address-derived favorite-venues list (deduplicated venue addresses from favorited events — no linked `Venue` name field exists, so this reads as deduplicated addresses, per the already-granted Agent's Discretion in context.md), recommendations reusing T58's related-events use case, and a logout control calling `SessionStore`'s existing clear path then routing to guest-browsable Home. Also closes T29's outstanding structural-fidelity gap for this screen.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/ProfileScreen.kt`
**Depends on**: T1, T29, T58
**Reuses**: `EventCard` (recommendations), `SessionStore`'s existing clear path
**Requirement**: PROF-01, PROF-02, PROF-03, PROF-04, PROF-05

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Stat pills compute correctly from on-device favorited-events data
- [ ] Genre/venue preference chips read and update via `GetPreferences`/`UpdatePreferences`
- [ ] Favorite-venues list shows deduplicated addresses from favorited events
- [ ] Recommendations render other upcoming events in the fan's city/genres
- [ ] Logout clears the session and routes to guest-browsable Home
- [ ] Full structural fidelity against the "Meu Perfil (Mobile)" Stitch mock

**Tests**: unit/Robolectric render test
**Gate**: quick

**Commit**: `feat(mobile-android): add Profile stats, preferences, favorite venues, recommendations, logout`

---

### T61: iOS — EventDetail parity

**What**: Mirrors T59 for iOS.
**Where**: iOS `UI/Screens/EventDetailView.swift`
**Depends on**: T1, T38, T58
**Reuses**: iOS equivalent of `EventCard`, `MapaCta`/`InstagramCta` pill components
**Requirement**: EVDET-01, EVDET-02, EVDET-03, EVDET-04

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Organizer card renders when present, omitted when absent
- [ ] Dual pill row (Maps + Instagram) replaces the single map button
- [ ] Horizontal related-events carousel renders, excluding the current event
- [ ] Full structural fidelity against the Stitch mock

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: quick

**Commit**: `feat(mobile-ios): add EventDetail organizer card, dual actions, related events`

---

### T62: iOS — Profile parity

**What**: Mirrors T60 for iOS.
**Where**: iOS `UI/Screens/ProfileView.swift`
**Depends on**: T1, T39, T58
**Reuses**: iOS equivalent of `EventCard`, `SessionStore`'s existing clear path
**Requirement**: PROF-01, PROF-02, PROF-03, PROF-04, PROF-05

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Stat pills, preference chips, favorite venues, recommendations, and logout all match T60's Android behavior
- [ ] Full structural fidelity against the Stitch mock

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: quick

**Commit**: `feat(mobile-ios): add Profile stats, preferences, favorite venues, recommendations, logout`

---

### T63: Android — guest browsing

**What**: App starts at `Routes.Home` unauthenticated instead of forcing login-on-launch; Home/Explore/Event Detail/Hub/Map remain reachable without a session. Favoritos, Profile, the favorite-heart control on any card, and notifications hard-redirect to Login/Signup (no soft-gated empty state, mirroring website's existing `PUBLIC_PATHS` pattern). A "Continuar como convidado" button is added to the entry flow. Client-side only — no new Sanctum guard, since these are already-public `GET` endpoints.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/nav/QorNavGraph.kt`, entry-point composables
**Depends on**: T1, T31, T60
**Reuses**: website's existing `PUBLIC_PATHS`/`PUBLIC_PATH_PREFIXES` gating pattern as the reference shape
**Requirement**: GUEST-01, GUEST-02, GUEST-03, GUEST-04

*Granularity note*: the guest-mode entry state and the gating checks on Favoritos/Profile/heart/notifications are one behavior — gating without a working unauthenticated entry point (or vice versa) isn't a shippable guest-browsing feature.

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] App launches to Home unauthenticated, no forced login
- [ ] Home/Explore/Event Detail/Hub/Map render and function without a session
- [ ] Tapping Favoritos, Profile, a favorite-heart, or notifications while unauthenticated hard-redirects to Login/Signup
- [ ] "Continuar como convidado" button present on the entry flow

**Tests**: unit/Robolectric render test (GIVEN no stored session WHEN the app launches THEN Home renders unauthenticated; GIVEN an unauthenticated fan taps a gated action THEN Login/Signup opens)
**Gate**: full

**Commit**: `feat(mobile-android): add unauthenticated guest browsing`

---

### T64: iOS — guest browsing

**What**: Mirrors T63 for iOS. The `.unauthenticated` state renders `MainTabRootView` in guest mode instead of forcing Login — a larger nav-graph change than Android's per design.md's own risk note, since iOS's root view state machine differs structurally from Android's nav graph. Same gating rules on Favoritos/Profile/heart/notifications.
**Where**: iOS `UI/AppNavigation.swift`, root view state
**Depends on**: T1, T41, T62
**Reuses**: website's `PUBLIC_PATHS` pattern as the reference shape (same as T63)
**Requirement**: GUEST-01, GUEST-02, GUEST-03, GUEST-04

**Tools**: MCP: NONE | Skill: NONE

**Done when**:
- [ ] `.unauthenticated` state renders `MainTabRootView` in guest mode instead of forcing Login
- [ ] Home/Explore/Event Detail/Hub/Map render and function without a session
- [ ] Tapping a gated action hard-redirects to Login/Signup
- [ ] "Continuar como convidado" button present

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: full

**Commit**: `feat(mobile-ios): add unauthenticated guest browsing`

---

### T65: Android — Home structural fidelity rebuild

**What**: Rebuild `HomeFeedScreen.kt`'s layout/spacing/component structure to genuinely match "Mobile App Homepage" (Stitch), closing the gap the audit found: T27 only added a section heading, it did not rework structure/spacing to match the mock, which is what REFRESH-01's AC literally requires.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/HomeFeedScreen.kt`
**Depends on**: T1, T27, T63
**Reuses**: existing `ui/components/*` composables
**Requirement**: REFRESH-01

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Rendered screen structurally matches the Stitch mobile screenshot (layout, spacing, component structure — not a reorder)
- [ ] Uses only reconciled tokens
- [ ] Existing `HomeFeedScreen` render tests updated, passing

**Tests**: unit/Robolectric render test
**Gate**: quick

**Commit**: `style(mobile-android): rebuild Home structural fidelity per Stitch`

---

### T66: Android — Email Verification structural fidelity rebuild

**What**: Rebuild `EmailVerificationScreen.kt`'s layout/spacing/component structure to genuinely match "Verificação de E-mail OTP (Mobile)" (Stitch), closing the same reorder-vs-match gap T26 left.
**Where**: `mobile/androidApp/src/main/kotlin/br/com/qualorock/androidApp/ui/screen/EmailVerificationScreen.kt`
**Depends on**: T1, T26, T65
**Reuses**: existing `ui/components/*` composables
**Requirement**: REFRESH-01

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Rendered screen structurally matches the Stitch mobile screenshot
- [ ] Uses only reconciled tokens
- [ ] Existing `EmailVerificationScreen` render tests updated, passing

**Tests**: unit/Robolectric render test
**Gate**: full (end of Phase 15, Android side)

**Commit**: `style(mobile-android): rebuild Email Verification structural fidelity per Stitch`

---

### T67: iOS — Home structural fidelity rebuild

**What**: Mirrors T65 for iOS.
**Where**: iOS `UI/Screens/HomeFeedView.swift`
**Depends on**: T1, T37, T64
**Reuses**: existing `UI/Components/*` SwiftUI views
**Requirement**: REFRESH-01

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Rendered screen structurally matches the Stitch mobile screenshot
- [ ] Uses only reconciled tokens
- [ ] Any pure-logic helper touched keeps/gains XCTest coverage

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: quick

**Commit**: `style(mobile-ios): rebuild Home structural fidelity per Stitch`

---

### T68: iOS — Email Verification structural fidelity rebuild

**What**: Mirrors T66 for iOS.
**Where**: iOS `UI/Screens/EmailVerificationView.swift`
**Depends on**: T1, T36, T67
**Reuses**: existing `UI/Components/*` SwiftUI views
**Requirement**: REFRESH-01

**Tools**: MCP: `stitch` | Skill: NONE

**Done when**:
- [ ] Rendered screen structurally matches the Stitch mobile screenshot
- [ ] Uses only reconciled tokens
- [ ] Any pure-logic helper touched keeps/gains XCTest coverage

**Tests**: unit (pure logic) / build-verified for the view
**Gate**: full (end of Phase 15, iOS side)

**Commit**: `style(mobile-ios): rebuild Email Verification structural fidelity per Stitch`

---

## Phase Execution Notes

Within Phase 4, 6, 8 (the per-screen refresh phases) and Phase 5/7/9 (new-screen phases) and Phase 16 (UAT), tasks have no dependency on each other — each depends only on T1 (and, where noted, one other earlier task) — so a single worker executes them in any convenient order within the phase; the numeric order (T14, T15, T16...) is simply the presentation order. The authoritative dependency edges are the Full Dependency Graph above, not task-number adjacency. Phase 10 (regression fixes, T47–T52) is similarly a set of independent tasks with no cross-dependency. Phases run in order; batches (sub-agent workers) pack consecutive whole phases — see Sub-Agent Offer below.

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
| T47 | 1 root cause, 2 files (store + repo call it invokes, see note) | ✅ Granular (cohesive) |
| T48 | 1 nav-graph wiring + 2 dependent call sites (see note) | ✅ Granular (cohesive) |
| T49, T51 | 1 dependency + 1 component wiring each | ✅ Granular |
| T50, T52 | 1 field mask + 1 validation function each | ✅ Granular |
| T53, T55 | 1 screen pair's component fidelity each (Login+Signup, same commit per platform) | ✅ Granular (cohesive) |
| T54, T56 | 1 nav-tab-set change each | ✅ Granular |
| T57 | 1 screen rebuild | ✅ Granular |
| T58 | 1 DTO fix + 2 sibling use cases (see note) | ✅ Granular (cohesive) |
| T59–T62 | 1 screen's content parity each | ✅ Granular |
| T63, T64 | 1 guest-mode entry state + its gating checks each (see note) | ✅ Granular (cohesive) |
| T65–T68 | 1 screen's structural fidelity rebuild each | ✅ Granular |

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
| T45 | T33, T66 | T33→T45, T66→T45 | ✅ Match |
| T46 | T43, T68 | T43→T46, T68→T46 | ✅ Match |
| T47 | None | — | ✅ Match |
| T48 | T31, T32, T33 | T31→T48, T32→T48, T33→T48 | ✅ Match |
| T49 | None | — | ✅ Match |
| T50 | T25 | T25→T50 | ✅ Match |
| T51 | None | — | ✅ Match |
| T52 | T35 | T35→T52 | ✅ Match |
| T53 | T1, T24, T25 | T1→T53, T24→T53, T25→T53 | ✅ Match |
| T54 | T31, T32, T33 | T31→T54, T32→T54, T33→T54 | ✅ Match |
| T55 | T1, T34, T35 | T1→T55, T34→T55, T35→T55 | ✅ Match |
| T56 | T41, T42, T43 | T41→T56, T42→T56, T43→T56 | ✅ Match |
| T57 | T1, T33, T54 | T1→T57, T33→T57, T54→T57 | ✅ Match |
| T58 | None | — | ✅ Match |
| T59 | T1, T28, T58 | T1→T59, T28→T59, T58→T59 | ✅ Match |
| T60 | T1, T29, T58 | T1→T60, T29→T60, T58→T60 | ✅ Match |
| T61 | T1, T38, T58 | T1→T61, T38→T61, T58→T61 | ✅ Match |
| T62 | T1, T39, T58 | T1→T62, T39→T62, T58→T62 | ✅ Match |
| T63 | T1, T31, T60 | T1→T63, T31→T63, T60→T63 | ✅ Match |
| T64 | T1, T41, T62 | T1→T64, T41→T64, T62→T64 | ✅ Match |
| T65 | T1, T27, T63 | T1→T65, T27→T65, T63→T65 | ✅ Match |
| T66 | T1, T26, T65 | T1→T66, T26→T66, T65→T66 | ✅ Match |
| T67 | T1, T37, T64 | T1→T67, T37→T67, T64→T67 | ✅ Match |
| T68 | T1, T36, T67 | T1→T68, T36→T68, T67→T68 | ✅ Match |

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
| T47, T58 | mobile/shared domain | unit | unit | ✅ OK |
| T48–T50, T53, T54, T57, T59, T60, T63, T65, T66 | Android screens (fix/refresh/new) | unit/Robolectric | unit/Robolectric | ✅ OK |
| T51, T52, T55, T56, T61, T62, T64, T67, T68 | iOS views (fix/refresh/new) | unit (pure logic) | unit | ✅ OK |

No violations.

---

## Sub-Agent Offer

68 tasks across 16 phases exceeds the ~8-task inline threshold. Phase 1–9 sizing/rationale is unchanged from the original plan (see prior note, retained below for reference). The addendum's own phases are similarly uneven (Phase 10: 6, 11: 4, 12: 1, 13: 5, 14: 2, 15: 4, 16: 3) and don't pack evenly into ~7-task batches without splitting a phase either. Consistent with the original recommendation, **one batch per phase (16 batches)** is proposed — guarantees phase integrity (including the T58 merge-forward checkpoint feeding T59–T62), keeps every cross-file dependency (e.g. T48 on T31/T32/T33, T54/T57 on the Phase 7 screens) an unambiguous batch boundary, and matches the feature's real shape. Original note, retained:

> 46 tasks across the original 10 phases exceeds the ~8-task inline threshold. Given real phase-size variance (1, 7, 5, 7, 3, 7, 3, 7, 3, 3 tasks) and the hard cross-repo gate at T12/T13 (Phase 2→3 boundary), a 5-batch packing was possible but put 3 of 5 batches over budget by splitting-avoidance; one-batch-per-phase (10 batches) was recommended instead.

Ask the user to confirm 16 batches (or propose an alternative packing) before dispatching Phase 1.

---

## Tools/MCP confirmation needed before Execute

Primary tool per task group: `stitch` MCP for Stitch HTML/screenshot re-fetching during every screen-refresh, new-screen, and structural-fidelity task (including the addendum's T53, T55, T57, T59–T62, T65–T68, and the T43 amendment), plus each repo's own toolchain (`docker compose`, `gradlew`, `xcodebuild`) for implementation/testing. `postman` MCP is optional for T8. `claude-in-chrome` is used for the website UAT pass (T44). The addendum's bug-fix and content-parity tasks (T47–T52, T58–T64) need no MCP beyond each platform's own toolchain. No other skill or MCP is needed. Confirming this, and the batching question above, with the user before dispatching Phase 1 (or Phase 10, if Phases 1–9 are already complete, as they are per STATE.md AD-025).
