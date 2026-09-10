# Nightlife GV Stitch Refresh Specification

## Problem Statement

`qor-mobile` (Android+iOS) and `qor-website` implement 8 screens on the NIGHTLIFE-GV design system, but a new Stitch project (`projects/6008587636717635180`, "Qual o Rock? Local Discovery") now exists as the current source-of-truth mock set. Bringing the two client repos to max fidelity with it also surfaces three product gaps the Stitch screens assume are already built — Favoritos, Mapa Interativo, and Hubs da Grande Vitória — plus one long-standing mobile/website parity gap (password recovery step count) that the new mocks make newly obvious.

**Addendum (2026-09-10, Stitch Fidelity Audit):** T1–T40 were marked complete with a fresh Verifier PASS (AD-025), but a side-by-side screenshot audit against the actual built Android app (and the one iOS screen it could reach) found the render/unit-test gate never caught two things: (1) T24–T29's implementations explicitly narrowed "match the mock" down to reordering existing elements, leaving REFRESH-01's literal "layout, spacing, and component structure matching" AC unmet, and Android's Hub screen (T33) violates its own HUB-01 AC by rendering a plain per-city list structurally identical to `/eventos`, not the "curated layout... distinct" the AC requires; (2) four concrete regressions unrelated to visual fidelity — dead map navigation, blank event cover images app-wide, a cold-launch crash from stale-session deserialization, and a signup birthdate field that rejects valid input. Per user decisions made while reviewing the audit, this addendum also expands scope to build content previously deferred as "no backing data" (Profile stats/genre chips/favorite venues/recommendations, EventDetail organizer card/related events) and to add real guest browsing. See `context.md` for the full decision record.

## Goals

- [ ] Every existing screen in `qor-mobile` (Android+iOS) and `qor-website` visually matches its corresponding Stitch screenshot (structure, spacing, imagery treatment) while reconciling any real token deltas against the "Nightlife Discovery" Stitch design system.
- [ ] Favoritos (favorite/unfavorite + list) ships end-to-end on both mobile platforms and website, replacing the existing disabled nav-tab stub.
- [ ] Mapa Interativo ships end-to-end: `qor-api` gains real per-event coordinates and a geo query endpoint, and all three clients render a multi-event pin map.
- [ ] Hubs da Grande Vitória ships as a new curated per-city landing surface on both mobile platforms and website, distinct from the existing Explore screen.
- [ ] `qor-mobile`'s password-recovery flow reaches real 3-step parity with `qor-website` (email → verify-code → new-password), closing STATE.md's AD-021 gap.
- [ ] (Addendum) The 4 audit-confirmed `qor-mobile` bugs (dead map navigation, blank cover images, cold-launch crash, birthdate validation) are fixed on both Android and iOS.
- [ ] (Addendum) Login/Signup reach real component-level Stitch match (logo badge, gradient CTA, icon-prefixed fields, eye-icon toggle) and the bottom nav reaches Stitch's real 5-tab set (Início/Hubs/Mapa/Salvos/Perfil) on both Android and iOS.
- [ ] (Addendum) Hub's Android+iOS layout is rebuilt to satisfy HUB-01's "curated, distinct from Explore" requirement instead of a plain per-city list.
- [ ] (Addendum) Profile and EventDetail reach full content parity with their Stitch mocks (stats, genre/venue preferences, recommendations, logout; organizer card, related events, dual pill actions) on both Android and iOS.
- [ ] (Addendum) An unauthenticated fan can browse Home/Explore/Event Detail/Hub/Map on mobile without logging in, per the guest-access scope in `context.md`.

## Out of Scope

| Feature | Reason |
| --- | --- |
| `qor-admin`, `qor-landingpage` | User confirmed scope is `qor-mobile` + `qor-website` only |
| Replacing NIGHTLIFE-GV tokens with the "Vix Rock Discovery" (light) theme | User confirmed "Nightlife Discovery" (dark) is the correct Stitch design system; the light theme was `get_project`'s default, not the intended one |
| A dedicated city-hub aggregation/trending backend endpoint (per-city counts, "trending in city X") | User confirmed: build Hubs against the existing `GET /events?city=` filter; a dedicated endpoint is deferred, documented as a Todo in STATE.md |
| Retiring/restructuring the existing `/eventos` Explore screen | User confirmed Hubs is a distinct new surface; Explore is untouched by this feature |
| GA4 event implementation for any new screen | Per `ARCHITECTURE.md` §11, GA4 events require a reviewed/approved tracking spreadsheet first — not started unprompted; this feature only reaches the point of listing candidate events, not implementing them |
| Push/email notifications for new favorites or map features | No trigger for this exists in `notifications/design.md`'s scope; not requested |
| (Addendum) `qor-website` audit/fix pass | The Stitch Fidelity Audit only covered `qor-mobile` (Android + iOS); website may have the same or different gaps but hasn't been audited — a separate pass, not assumed clean or assumed broken here |
| (Addendum) A new backend "favorite venue" entity | Profile's favorite-venues list is scoped as a derived view (venues of favorited events) per this spec's Assumptions — a real favoritable-venue entity is `favorites-social` scope, not this feature's |
| (Addendum) A recommendation ranking/ML system | Recommendations are scoped conservatively as "other upcoming events in the fan's city/genres" reusing existing list endpoints, per this spec's Assumptions — not a new algorithm |
| (Addendum) A new Sanctum guest auth guard | Guest browsing is client-side only (skip forced login, use already-public endpoints) per `context.md` — `ARCHITECTURE.md`'s fan/venue-promoter-admin two-guard model is unchanged |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Design-token source of truth | "Nightlife Discovery" Stitch design system (`assets/6811aff1ad13406583f0ad36140a0e7b`), reconciled into existing `design-system.md`/`nightlife-gv.css`/`QualORockThemeTokens.kt`/`ColorTokens.swift` rather than replacing them | Near-identical hex values already live in both repos; this is a verification+small-delta pass | y |
| Hubs vs. Explore | Hubs is a new, distinct surface; `/eventos` Explore stays as-is | User confirmed | y |
| Password-recovery step count | Mobile gets real 3-step parity (adds an intermediate verify-code use case to `shared`'s `ResetPassword` flow) | User confirmed | y |
| Map geo backend | Add real `latitude`/`longitude` to `Event` + geocoding + a geo query endpoint in `qor-api`, sequenced before any client Map UI task per `ARCHITECTURE.md` §8.11 | User confirmed | y |
| Typography role-name mapping (Stitch's `display-hero`/`headline-sm`/`title-card`/`label-venue`/`label-btn`/`label-caps`/`badge-tag` vs. current `TextEventTitle`/`TextBadge`/etc.) | Map by nearest existing size+weight during Design; add any genuinely new role (e.g. a 48px hero display size not currently used anywhere) as a new token only if a screen's structural diff actually needs it — never speculatively | Discoverable from the two token sets directly; no new visual values are introduced beyond what Stitch specifies | n — logged as assumption, not a user decision; revisit only if Design finds a real mismatch |
| Radius `sm` delta (Stitch: 4px vs. current: 6px) | Keep current 6px; Stitch's `sm` (4px) is used for its badge/chip radius, and current `RadiusSmDp`/`--radius-nightlife-sm` already serves that same role at 6px — a 2px delta is not perceptible enough to justify a token-wide rename+re-verify across every consumer, given "Nightlife Discovery" is being treated as reconciliation not replacement | This is a judgment call inside the reconciliation-not-replacement decision already confirmed by the user | n — logged as assumption; flip only if a specific screen's UAT visibly disagrees |
| Geocoding provider for the new `qor-api` geo backend | Reuse whatever Map Provider `ARCHITECTURE.md` §1 already names as the project's map integration (Google Maps, matching `GoogleMap.tsx`/the mobile `EventMapState` Google-Maps-based inline map already in place) for both the geocoding call and the client-side pin rendering, rather than introducing a second map/geocoding vendor | Consistency with what's already integrated on all three clients; avoids a second vendor integration and its own API-key/quota management | n — logged as assumption; confirm in Design once the specific Google geocoding API and its cost/quota profile are checked |
| (Addendum) Favorite venues concept | A derived view (venues of the fan's favorited events, deduplicated), not a new favoritable venue entity | `favorites-social/spec.md`'s FAV-01–26 only covers favoriting events — no favorite-venue entity exists anywhere in the spec tree; a derived view needs no new backend model | y — confirmed via context.md's Deferred Ideas (flip to a real entity only if this proves insufficient) |
| (Addendum) Recommendations scope | "Other upcoming events in the fan's same city and/or favorite genres," reusing existing list endpoints — not a new ranking/ML system | No recommendation concept exists anywhere in `.specs`; scoping conservatively avoids inventing an algorithm the user never asked for | n — logged as assumption; revisit if Design finds the existing endpoints can't cheaply support this filter |
| (Addendum) Guest access mechanism | Client-side only: mobile stops forcing login-on-launch and lets already-public event-browsing `GET` endpoints render without a bearer token; Favoritos/Profile/notifications/favorite-heart hard-redirect to Login/Signup (mirrors website's existing `PUBLIC_PATHS` pattern, FAVUI-03) | User confirmed scope (Home/Explore/Event Detail/Hub/Map reachable, rest hard-gated); no new Sanctum guard needed since these endpoints are already public per `qor-website`'s existing unauthenticated browsing | y |
| (Addendum) Organizer-card data source | Reuse `venue-promoter-admin`'s existing Promoter/Venue fields (name, phone, email, Instagram, TikTok) already returned for event listings — no new backend model | Confirmed present in `venue-promoter-admin/spec.md`; EventDetail just needs to render fields it may already receive (verify exact DTO shape in Design) | n — logged as assumption; confirm the mobile DTO actually carries these fields in Design, add them server-side if it doesn't |
| (Addendum) iOS root-cause parity with Android's 4 bugs | Assumed structurally similar (shared KMP `shared` module drives both), but each iOS root cause is verified independently in Design/Execute, not copy-pasted from Android's diagnosis | iOS wasn't audited beyond Login; `SessionStore`/image-loading/date-validation code may differ from Android's platform-specific layer even where `shared` is common | n — logged as assumption per context.md's Agent's Discretion |

**Open questions:** none — all resolved or logged above.

---

## User Stories

### P1: Design token reconciliation ⭐ MVP

**User Story**: As a fan using either the mobile app or the website, I want the visual language (colors, type, corner rounding) to be exactly what the new Stitch mocks specify, so the product feels intentionally designed rather than stale.

**Why P1**: Every other story in this feature depends on the token layer being settled first — screens can't be verified against Stitch screenshots if the underlying tokens are still in flux.

**Acceptance Criteria**:

1. WHEN `design-system.md`, `website/styles/nightlife-gv.css`, `mobile/shared/.../QualORockThemeTokens.kt`, and `mobile/iosApp/.../ColorTokens.swift` are diffed against the "Nightlife Discovery" Stitch design system's `designMd` THEN the system SHALL record every value delta (color hex, font, radius, named typography role) in `design.md` before any token file is edited.
2. WHEN a real delta is confirmed (not already matching) THEN the system SHALL update all four token surfaces (`design-system.md`, website CSS, Android/iOS Kotlin/Swift token objects) in the same reconciliation pass, so no client drifts from another.
3. The system SHALL NOT introduce the "Vix Rock Discovery" (light) theme's values anywhere in any token file.
4. IF a Stitch typography role has no current equivalent AND no screen's structural diff requires it THEN the system SHALL leave it undefined rather than adding a speculative, unused token.

**Independent Test**: Diff each of the four token files against the Nightlife Discovery `designMd` and confirm zero unexplained deltas remain; each remaining delta traces to a `design.md` entry with a stated resolution.

---

### P1: Existing-screen visual refresh (8 screens × 3 clients) ⭐ MVP

**User Story**: As a fan, I want the Login, Signup, Email Verification, Password Recovery, Home, Event Detail, and Profile screens to look and feel exactly like the new Stitch designs, on whichever client I use.

**Why P1**: This is the core ask — the reason the feature exists.

**Acceptance Criteria**:

1. WHEN a fan opens any of the 8 existing screens (Login, Signup, Email Verification OTP, Password Recovery wizard, Home, Event Detail, Profile) on Android, iOS, or the website THEN the system SHALL render layout, spacing, and component structure matching the corresponding Stitch screenshot for that device type (mobile screenshot for Android/iOS, desktop screenshot for website).
2. The system SHALL reuse the reconciled tokens from the Design token reconciliation story for every visual property (color, type, radius) on these 8 screens — no screen introduces a one-off hardcoded value not present in the token files.
3. WHILE a screen's existing animation/transition behavior is not addressed by a specific Stitch screen difference THEN the system SHALL preserve that behavior unchanged (per the prior "Cena GV" restyle precedent, AD-017 — animations are preserved, not simplified away, unless the new mock specifies otherwise).
4. IF a Stitch screen's HTML/CSS structure conflicts with a client's existing idiomatic component pattern (e.g. a Compose `LazyColumn` vs. a raw HTML scroll container) THEN the system SHALL rewrite the structure idiomatically for that platform rather than copy-pasting Stitch's Tailwind HTML verbatim.

**Independent Test**: For each of the 8 screens × 3 clients (24 render targets), a side-by-side screenshot comparison against the matching Stitch export passes interactive UAT.

---

### P1: Password recovery 3-step parity ⭐ MVP

**User Story**: As a fan on mobile who forgot my password, I want the same email → verification-code → new-password flow the website already has, so recovering my account works identically regardless of which client I'm on.

**Why P1**: Directly required to match the new Stitch mocks (3 distinct screens), and closes a documented gap (AD-021) rather than leaving mobile permanently behind website.

**Acceptance Criteria**:

1. WHEN a fan submits their email on mobile's password-recovery screen THEN the system SHALL call a new shared-module verify-code-capable flow that mirrors `qor-website`'s `verifyPasswordResetCode` step, not the current single-step `ResetPassword` call.
2. WHEN the fan enters the code sent to their email THEN the system SHALL verify it against `qor-api`'s existing `/auth/password/verify-code` endpoint (already implemented per AD-016 — no new backend endpoint needed here, only a new shared-module use case consuming it) before allowing the new-password step.
3. IF the entered code is invalid or expired THEN the system SHALL show a pt-BR error and allow re-entry or a resend, without advancing to the new-password step.
4. WHEN the new password is submitted and accepted THEN the system SHALL show a success confirmation screen matching Stitch's "Sucesso Envio de Link" design, then route to Login.

**Independent Test**: On both Android and iOS, complete email → code → new password → success → login, and confirm an invalid code is rejected without advancing.

---

### P1: Favoritos ⭐ MVP

**User Story**: As a fan, I want to favorite events and see my favorited events in one place, on any client, so I can track what I'm interested in.

**Why P1**: Fully backend-ready today (`POST /events/{id}/favorite`, `GET /favorites` already routed) and both mobile platforms already carry a disabled nav-tab stub waiting for this — the lowest-risk, highest-readiness new feature in this pass.

**Acceptance Criteria**:

1. WHEN an authenticated fan taps/clicks the favorite control on an event card or detail screen THEN the system SHALL call `POST /events/{id}/favorite` and reflect the toggled state immediately in the UI (optimistic update, reconciled on response).
2. WHEN an authenticated fan opens the Favoritos screen/page THEN the system SHALL call `GET /favorites` and render the result using the same `EventCard`/event-card component already used elsewhere, matching Stitch's "Meus Favoritos" layout.
3. IF an unauthenticated visitor reaches the Favoritos route on website THEN the system SHALL redirect to `/entrar`, consistent with `lib/api/http.ts`'s existing `PUBLIC_PATHS` auth-gating pattern (the TODO already flagging `/favoritos` for this).
4. WHEN the fan un-favorites an event from the Favoritos list itself THEN the system SHALL remove it from the list without a full page/screen reload.
5. The system SHALL enable the existing disabled `Favoritos` bottom-nav tab on both Android and iOS, routing it to the new screen instead of `EmptyView()`/a stub.

**Independent Test**: Favorite two events from different surfaces (card + detail), confirm both appear on the Favoritos screen, un-favorite one, confirm it disappears — on each of the 3 clients independently.

---

### P2: Mapa Interativo backend geo data

**User Story**: As a fan, I want to see events plotted on a real map, so I can find something happening near me without reading through a list.

**Why P2**: Blocks the Map UI story below; must ship first per the milestone-sequencing rule, but is not itself user-facing.

**Acceptance Criteria**:

1. WHEN an `Event` is created or its `address`/`city` changes THEN the system SHALL geocode the address (via the project's existing Google Maps integration, per the Assumptions table) and persist `latitude`/`longitude` on the event.
2. IF geocoding fails (address not resolvable) THEN the system SHALL persist the event without coordinates and log the failure, rather than blocking event creation/update.
3. WHEN a client requests `GET /events/map` (or equivalent geo query endpoint, exact shape decided in Design) with a bounding box or a city parameter THEN the system SHALL return only events that have resolved coordinates within that area, each with `latitude`/`longitude` plus the existing public event summary fields.
4. The system SHALL add `latitude`/`longitude` as nullable columns on `events` via a new migration — existing rows without geocoded data remain valid (nullable, not backfilled synchronously in this pass).

**Independent Test**: Create an event with a real Greater-Vitória address, confirm coordinates populate; create one with a nonsense address, confirm it still saves (coordinates null, failure logged); query the new endpoint and confirm only geocoded events return with correct lat/lng.

---

### P2: Mapa Interativo — client UI

**User Story**: As a fan, I want an interactive map screen showing event pins across Greater Vitória, so I can browse spatially instead of by list.

**Why P2**: The user-facing half of the Map feature; depends on the backend story above being merged first.

**Acceptance Criteria**:

1. WHEN a fan opens the new Map screen/page on any client THEN the system SHALL render a map (Google Maps, matching the existing single-event embed pattern) with one pin per geocoded event returned by the new geo endpoint, styled per Stitch's "Mapa Interativo" mock (custom pin markers, category/cluster treatment).
2. WHEN a fan taps/clicks a pin THEN the system SHALL show that event's summary (title, date, venue) with a link/navigation to its full Event Detail screen.
3. WHILE the map viewport changes (pan/zoom, or a city filter is applied) THE system SHALL re-query the geo endpoint for the new bounds/city rather than filtering a single unbounded initial fetch.
4. IF an event has no resolved coordinates THEN the system SHALL exclude it from the map (per the backend story's AC3) without erroring the screen.

**Independent Test**: Open the Map screen, confirm pins render for known-geocoded seed events, tap a pin, confirm it opens the right event's detail screen.

---

### P2: Hubs da Grande Vitória

**User Story**: As a fan, I want a curated landing page per city (Vitória, Vila Velha, Serra, Cariacica) so I can quickly see what's happening in the area I care about, styled distinctly from the generic filtered list.

**Why P2**: New surface confirmed in scope, but lower priority than Favoritos/Map since it has no backend gap — purely additive UI over an existing endpoint.

**Acceptance Criteria**:

1. WHEN a fan navigates to a Hub for one of the 4 `City` enum values THEN the system SHALL call the existing `GET /events?city=<city>` endpoint and render the result in the curated layout Stitch's "Hubs da Grande Vitória" mock specifies (distinct from `/eventos`'s plain filtered list).
2. WHEN a fan is on Home and selects a city from `CityGrid` (website) or its mobile equivalent THEN the system SHALL offer navigation to that city's Hub as an additional entry point, alongside the existing `/eventos?city=` deep-link (per the confirmed "distinct new surface" decision — Hubs does not replace the existing CityGrid→Explore link).
3. IF a city has zero published events at the time of viewing THEN the system SHALL show the existing `EmptyState` component/pattern rather than a blank Hub page.
4. The system SHALL NOT call a dedicated hub-aggregation endpoint (none exists) — all Hub data comes from the existing city-filtered event list.

**Independent Test**: Visit each of the 4 city Hubs, confirm each shows only that city's published events in the curated layout; visit a Hub with no events (if any exist locally) and confirm the empty state renders.

---

### P1: Bugfix — map navigation reaches the Map screen ⭐ MVP

**User Story**: As a fan, I want tapping "Ver no Mapa" on any event card to actually open the map, so I can find the event's location without the app silently doing nothing.

**Why P1**: Confirmed regression — `Routes.Map` already exists as a nav destination but nothing calls it; blocks the entire Map feature from being reachable via its primary entry point.

**Acceptance Criteria**:

1. WHEN a fan taps "Ver no Mapa" on an event card on HomeFeed, Explore, or Hub (Android or iOS) THEN the system SHALL navigate to the Map screen (`Routes.Map` on Android, its iOS equivalent), not remain on the current screen.
2. WHEN a fan taps EventDetail's map action THEN the system SHALL navigate to the same in-app Map screen used elsewhere (or, if EventDetail's inline embedded map is kept as an additional preview per Design, both SHALL be reachable — the standalone Map screen SHALL NOT be the one dropped).
3. The system SHALL NOT silently no-op a map-navigation tap — every "Ver no Mapa"-labeled control SHALL be wired to a real callback, not a default no-op lambda.

**Independent Test**: From HomeFeed, Explore, Hub, and EventDetail on both Android and iOS, tap "Ver no Mapa" and confirm the Map screen opens each time.

---

### P1: Bugfix — event cover images render ⭐ MVP

**User Story**: As a fan, I want to see each event's actual cover photo on cards and detail pages, so I can recognize and be drawn to events instead of seeing blank boxes.

**Why P1**: Confirmed regression across every screen with an event card (HomeFeed, EventDetail, Hub, Explore) — image loading was never implemented on Android; iOS status TBD in Design.

**Acceptance Criteria**:

1. WHEN an event card or EventDetail hero renders and `Event.coverImageUrl` is non-null THEN the system SHALL load and display that image (Android: via a network-image loader such as Coil; iOS: via `AsyncImage` or equivalent — exact library choice is a Design decision).
2. IF `Event.coverImageUrl` is null THEN the system SHALL render the existing `PlaceholderImage` pattern, not a blank rectangle.
3. IF the image fails to load (network error, 404) THEN the system SHALL fall back to the same placeholder pattern rather than an indefinite blank/loading state.

**Independent Test**: On HomeFeed, EventDetail, Hub, and Explore (Android + iOS), confirm seeded events with a cover URL show a real image, and an event with no cover URL shows the placeholder, not a blank box.

---

### P1: Bugfix — cold-launch session restore no longer crashes ⭐ MVP

**User Story**: As a returning fan with a stale cached session, I want the app to open normally (even if that means logging me out), so a leftover token never force-closes the app before I see anything.

**Why P1**: Confirmed crash — `MissingFieldException` on `UserResponseDto.data` during unconditional profile-fetch deserialization in session restore.

**Acceptance Criteria**:

1. WHEN the app launches with a stored session token AND the profile fetch it triggers returns a non-success HTTP status or an unexpected body shape THEN the system SHALL treat the session as invalid (clear it, proceed as unauthenticated) rather than letting deserialization throw uncaught.
2. The system SHALL check response success/status before deserializing a typed success DTO on every session-restore path, matching the existing pattern already used by `register`/`login` (which branch before choosing `UserResponseDto` vs. an error DTO).
3. IF session restore fails for any reason THEN the system SHALL land the fan on the normal unauthenticated entry point (Login, or the guest-browsable Home per the Guest access story) — never a crash or a blank screen.

**Independent Test**: Seed a stored session token that yields a non-`data`-wrapped or error response from the profile endpoint, cold-launch the app (Android + iOS), and confirm it opens to an unauthenticated state instead of crashing.

---

### P1: Bugfix — signup birthdate accepts valid dates ⭐ MVP

**User Story**: As a new fan signing up, I want a valid birthdate like 01/01/1990 to be accepted, so I can actually complete signup instead of getting stuck on a false validation error.

**Why P1**: Confirmed regression — blocks signup completion entirely, making EmailVerification unreachable for new users who hit this field.

**Acceptance Criteria**:

1. WHEN a fan enters a birthdate in the field's documented/masked format (format decided in Design — e.g. DD/MM/AAAA) THEN the system SHALL parse it, convert it to whatever format the API's `RegisterFan`/`RegisterRequestDto` actually expects (e.g. ISO 8601), and accept it without a false "Data de nascimento inválida" error.
2. IF the entered birthdate is genuinely invalid (impossible date, under a minimum age if one exists per `auth-fan-profile/spec.md`, or malformed) THEN the system SHALL show a specific pt-BR error identifying what's wrong, not a generic rejection of well-formed input.
3. The system SHALL apply the same fix on both Android's `SignupScreen`/`SignupViewModel` and iOS's `SignupView` equivalent.

**Independent Test**: On both Android and iOS, enter `01/01/1990` (or the field's documented valid format) into Signup's birthdate field and confirm the flow advances to EmailVerification without a validation error.

---

### P1: Login/Signup component-level Stitch fidelity ⭐ MVP

**User Story**: As a fan, I want Login and Signup to actually look like the Stitch "Entrar (Login Dark)"/"Criar Conta (Registro Dark)" mocks — not just have their existing elements reordered — so the screens match what REFRESH-01 already requires.

**Why P1**: Reopens REFRESH-01 for these two screens specifically — T24/T25's prior implementation only reordered existing elements and left the component-level mismatches (missing logo badge, flat CTA vs. gradient pill, boxed floating-label fields vs. icon-prefixed rounded fields, text-link vs. eye-icon password toggle) unaddressed, which the audit confirmed on both Android and iOS Login.

**Acceptance Criteria**:

1. WHEN a fan opens Login or Signup THEN the system SHALL render a circular "Qual o Rock?" logo badge + wordmark header matching the Stitch mock, above the form.
2. WHEN a fan views the primary submit CTA ("Entrar"/"Cadastrar") THEN the system SHALL render it as a gradient pill (pink→purple, matching the token-reconciled gradient already established by `InstagramCta`'s brush pattern on Android) with a trailing arrow and the mock's full CTA copy, not a flat solid-color rectangle.
3. WHEN a fan views the email/password input fields THEN the system SHALL render them as rounded fields with a leading icon (mail/lock) per the mock, not boxed fields with a floating label straddling the border.
4. WHEN a fan taps the password-visibility control THEN the system SHALL render and operate it as an eye icon inside the field, not a separate "Mostrar senha" text link.
5. The system SHALL apply AC1–4 on both Android and iOS.

**Independent Test**: Side-by-side screenshot comparison of Login and Signup against their Stitch mocks on both Android and iOS, confirming logo badge, gradient CTA, icon-prefixed fields, and eye-icon toggle all match.

---

### P1: Bottom navigation reaches Stitch's 5-tab set ⭐ MVP

**User Story**: As a fan, I want Hubs and Mapa as real bottom-nav tabs like the Stitch mock shows, so I can reach them as first-class destinations instead of only through buried entry points.

**Why P1**: `HubScreen`/`MapScreen` (Android) already exist as nav-graph routes from T31–T33 but were never added to the bottom-nav tab set, which is still the pre-Favoritos/Hub/Map 4-tab layout; the Stitch mock's tab set is Início/Hubs/Mapa/Salvos/Perfil (5 tabs).

**Acceptance Criteria**:

1. WHEN a fan views the bottom navigation on Android or iOS THEN the system SHALL render 5 tabs — Início, Hubs, Mapa, Salvos (Favoritos), Perfil — matching the Stitch mock's tab set and icons.
2. WHEN a fan taps the Hubs tab THEN the system SHALL navigate to a Hub entry surface (city selector or the fan's default/last city, per Design), not require going through Home's city chips first.
3. WHEN a fan taps the Mapa tab THEN the system SHALL navigate to the standalone Map screen this addendum's map-navigation bugfix story wires up.
4. The system SHALL preserve existing Explore/`/eventos` reachability (per the Hubs vs. Explore assumption already in this spec) even though Explore itself is not one of the 5 bottom tabs — Design decides its new entry point (e.g. from Home or Hub).

**Independent Test**: On both Android and iOS, confirm the bottom nav shows exactly the 5 Stitch tabs and each navigates to its correct destination.

---

### P1: Hub rebuilt to a real curated layout ⭐ MVP

**User Story**: As a fan, I want a city's Hub to actually look like the Stitch "Hubs da Grande Vitória" curated page, not just a plain event list, so it feels like a distinct destination worth visiting.

**Why P1**: Reopens HUB-01 — T33's Android implementation renders "just the city name as a header, then a vertical list," which the audit confirmed is structurally identical to `/eventos`'s plain filtered list, directly violating HUB-01's "distinct from `/eventos`'s plain filtered list" requirement.

**Acceptance Criteria**:

1. WHEN a fan opens a city's Hub THEN the system SHALL render the curated layout the Stitch "Hubs da Grande Vitória" mock specifies for the per-city detail state (not merely the city-selector landing state) — distinguishing visual treatment from `/eventos`'s plain filtered list (e.g. featured/highlighted event treatment, city-specific header imagery/badge, per the mock).
2. WHEN a fan navigates to Hubs from the bottom nav (not from a specific city deep-link) THEN the system SHALL show the mock's city-selection landing screen (4 gradient city cards with event counts) as the entry point, before drilling into a specific city's curated list.
3. The system SHALL reuse the existing `GET /events?city=` data source (per this feature's existing HUB-04 constraint) — this story changes presentation only, not the data contract.
4. The system SHALL apply AC1–2 on both Android and iOS (iOS gains its first Hub implementation here, coordinated with Phase 9/T43 rather than duplicating it).

**Independent Test**: Visit a city Hub via the bottom-nav entry point, confirm the city-selector landing renders first, drill into one city, and confirm its layout is visually distinct from `/eventos` for the same city — on both Android and iOS.

---

### P2: EventDetail content parity

**User Story**: As a fan viewing an event, I want to see the organizer, related events, and the two dedicated map/Instagram actions the Stitch mock shows, so I get the full picture instead of a bare event summary.

**Why P2**: Previously deferred as "no backing data" (REFRESH-04); the organizer data already exists via `venue-promoter-admin` and the map/Instagram actions reuse logic that already exists elsewhere in the app — the user confirmed building this now rather than leaving it deferred.

**Acceptance Criteria**:

1. WHEN a fan opens EventDetail for an event with a tagged Promoter/Venue THEN the system SHALL render an organizer card (name, logo if available, Instagram/TikTok links) sourced from the existing `venue-promoter-admin` fields, positioned per the mock (directly under the title block).
2. WHEN a fan opens EventDetail THEN the system SHALL render two side-by-side pill actions, "Ver no Mapa" (this addendum's map-navigation bugfix target) and "Ver Instagram" (deep-links to the organizer's Instagram if present), replacing the single "Abrir no mapa" button.
3. WHEN a fan scrolls to the bottom of EventDetail THEN the system SHALL render an "Outros rolês rolando" horizontal carousel of other upcoming events (same city and/or genre, per this spec's Recommendations assumption), reusing the existing event-card component.
4. IF an event has no tagged organizer, no Instagram link, or no related events to show THEN the system SHALL omit that section entirely rather than rendering an empty/broken placeholder for it.
5. The system SHALL apply AC1–4 on both Android and iOS.

**Independent Test**: Open an event with a tagged organizer and Instagram link, confirm the organizer card, dual pill actions, and related-events carousel all render correctly-populated; open one without an organizer/related events and confirm those sections are cleanly omitted — on both Android and iOS.

---

### P2: Profile content parity

**User Story**: As a fan, I want my Profile to show my stats, genre/venue preferences, recommendations, and a clear way to log out — like the Stitch "Meu Perfil" mock — instead of a bare edit form.

**Why P2**: Previously deferred as "no backing data" (REFRESH-04); genre-preference/radius fields already exist as `AUTH-20..24` (Pending, unbuilt on mobile), and the user confirmed building the rest now rather than leaving it deferred.

**Acceptance Criteria**:

1. WHEN a fan opens Profile THEN the system SHALL render stat pills (events attended / cities visited / activity level, or whatever subset the available data actually supports — Design confirms exact fields) per the Stitch mock's layout.
2. WHEN a fan opens Profile's preferences THEN the system SHALL let them view/edit favorite genres and search radius using `auth-fan-profile`'s existing `AUTH-20..24` fields, rendered as the mock's editable genre-preference chips.
3. WHEN a fan opens Profile THEN the system SHALL render a favorite-venues list derived from the venues of their favorited events (deduplicated, per this spec's Assumptions), and a recommendations section (per the EventDetail story's same recommendation definition).
4. WHEN a fan taps a visible "Sair da Minha Conta" (logout) control THEN the system SHALL end the session and return to the unauthenticated/guest entry point — this control SHALL be present and reachable, not absent as it is today.
5. IF a fan has zero favorited events (and therefore zero derived favorite venues) THEN the system SHALL show the existing `EmptyState` pattern for that section rather than omitting it silently or erroring.
6. The system SHALL apply AC1–5 on both Android and iOS.

**Independent Test**: On a fan account with favorited events and genre preferences set, open Profile on both Android and iOS and confirm stat pills, genre chips, favorite venues, recommendations, and a working logout control all render and function; confirm the empty-favorites case shows the empty state instead of breaking.

---

### P1: Guest browsing access ⭐ MVP

**User Story**: As a visitor without an account, I want to browse events, hubs, and the map without being forced to log in first, so I can decide QOR is worth signing up for before committing.

**Why P1**: New capability confirmed in scope; Login's Stitch mock explicitly offers "Continuar como convidado," and the app currently has no path to browse without authenticating first.

**Acceptance Criteria**:

1. WHEN an unauthenticated visitor opens the app THEN the system SHALL let them reach Home, Explore, Event Detail, Hub, and Map without requiring login, per `context.md`'s confirmed guest-access scope.
2. WHEN an unauthenticated visitor taps Favoritos, Profile, the favorite-heart control on any card, or a notifications entry point THEN the system SHALL redirect to Login/Signup, mirroring `qor-website`'s existing `PUBLIC_PATHS` redirect pattern (already an AC under this spec's Favoritos story) rather than a new gating mechanism.
3. WHEN a guest taps "Continuar como convidado" on Login THEN the system SHALL route them straight to the guest-browsable Home, not through any intermediate auth step.
4. The system SHALL NOT call any endpoint that requires a bearer token while in guest mode — guest browsing SHALL rely only on the already-public event-listing/detail endpoints.

**Independent Test**: Launch the app with no stored session (Android + iOS), confirm Home/Explore/Event Detail/Hub/Map are reachable without a login prompt, then confirm tapping Favoritos or Profile redirects to Login.

---

## Edge Cases

- IF a fan favorites an event, then unfavorites it before the optimistic UI reconciles with the server response THEN the system SHALL resolve to the server's actual final state, not the UI's last optimistic guess.
- IF the geocoding call to the Map Provider times out or errors (rate limit, network) THEN the system SHALL treat it identically to "address not resolvable" (AC2 of the backend geo story) — event saves, coordinates stay null, failure logged.
- IF a fan opens the Map screen with no network connectivity THEN the system SHALL show the existing empty/error-state pattern already used elsewhere (e.g. `EmptyState`) rather than a blank map.
- WHEN the mobile password-recovery flow's verify-code step is abandoned mid-flow (app backgrounded/closed) THEN the system SHALL require starting over from the email step on return — no persisted partial-recovery state (matches `qor-website`'s existing behavior, no new session concept introduced).
- IF a fan's device/browser has no City selected yet and lands on a Hub deep-link directly THEN the system SHALL still render that specific Hub (the Hub route's city comes from the URL/route param, not from any stored preference).
- IF a guest (unauthenticated) taps a favorite-heart control on an event card THEN the system SHALL redirect to Login/Signup rather than silently failing the API call or showing a generic error.
- IF the cover-image loader for an event errors after the guest/fan has already scrolled past it THEN the system SHALL swap to the placeholder in place, not shift layout or cause a visible jump.
- IF an event's tagged organizer has no Instagram/TikTok link on file THEN the system SHALL omit the corresponding action from EventDetail's dual pill actions rather than rendering a dead "Ver Instagram" button.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| TOKEN-01 | P1: Design token reconciliation | Design | Pending |
| TOKEN-02 | P1: Design token reconciliation | Design | Pending |
| TOKEN-03 | P1: Design token reconciliation | Design | Pending |
| TOKEN-04 | P1: Design token reconciliation | Design | Pending |
| REFRESH-01 | P1: Existing-screen visual refresh | Design | Pending |
| REFRESH-02 | P1: Existing-screen visual refresh | Design | Pending |
| REFRESH-03 | P1: Existing-screen visual refresh | Design | Pending |
| REFRESH-04 | P1: Existing-screen visual refresh | Design | Pending |
| PWDR-01 | P1: Password recovery 3-step parity | Design | Pending |
| PWDR-02 | P1: Password recovery 3-step parity | Design | Pending |
| PWDR-03 | P1: Password recovery 3-step parity | Design | Pending |
| PWDR-04 | P1: Password recovery 3-step parity | Design | Pending |
| FAVUI-01 | P1: Favoritos | Design | Pending |
| FAVUI-02 | P1: Favoritos | Design | Pending |
| FAVUI-03 | P1: Favoritos | Design | Pending |
| FAVUI-04 | P1: Favoritos | Design | Pending |
| FAVUI-05 | P1: Favoritos | Design | Pending |
| MAPGEO-01 | P2: Mapa Interativo backend geo data | Design | Pending |
| MAPGEO-02 | P2: Mapa Interativo backend geo data | Design | Pending |
| MAPGEO-03 | P2: Mapa Interativo backend geo data | Design | Pending |
| MAPGEO-04 | P2: Mapa Interativo backend geo data | Design | Pending |
| MAPUI-01 | P2: Mapa Interativo — client UI | Design | Pending |
| MAPUI-02 | P2: Mapa Interativo — client UI | Design | Pending |
| MAPUI-03 | P2: Mapa Interativo — client UI | Design | Pending |
| MAPUI-04 | P2: Mapa Interativo — client UI | Design | Pending |
| HUB-01 | P2: Hubs da Grande Vitória | Design | Pending |
| HUB-02 | P2: Hubs da Grande Vitória | Design | Pending |
| HUB-03 | P2: Hubs da Grande Vitória | Design | Pending |
| HUB-04 | P2: Hubs da Grande Vitória | Design | Pending |
| BUGFIX-01 | P1: Bugfix — map navigation reaches the Map screen | Design | Pending |
| BUGFIX-02 | P1: Bugfix — map navigation reaches the Map screen | Design | Pending |
| BUGFIX-03 | P1: Bugfix — map navigation reaches the Map screen | Design | Pending |
| BUGFIX-04 | P1: Bugfix — event cover images render | Design | Pending |
| BUGFIX-05 | P1: Bugfix — event cover images render | Design | Pending |
| BUGFIX-06 | P1: Bugfix — event cover images render | Design | Pending |
| BUGFIX-07 | P1: Bugfix — cold-launch session restore no longer crashes | Design | Pending |
| BUGFIX-08 | P1: Bugfix — cold-launch session restore no longer crashes | Design | Pending |
| BUGFIX-09 | P1: Bugfix — cold-launch session restore no longer crashes | Design | Pending |
| BUGFIX-10 | P1: Bugfix — signup birthdate accepts valid dates | Design | Pending |
| BUGFIX-11 | P1: Bugfix — signup birthdate accepts valid dates | Design | Pending |
| BUGFIX-12 | P1: Bugfix — signup birthdate accepts valid dates | Design | Pending |
| REFRESH-05 | P1: Login/Signup component-level Stitch fidelity | Design | Pending |
| REFRESH-06 | P1: Login/Signup component-level Stitch fidelity | Design | Pending |
| REFRESH-07 | P1: Login/Signup component-level Stitch fidelity | Design | Pending |
| REFRESH-08 | P1: Login/Signup component-level Stitch fidelity | Design | Pending |
| NAV-01 | P1: Bottom navigation reaches Stitch's 5-tab set | Design | Pending |
| NAV-02 | P1: Bottom navigation reaches Stitch's 5-tab set | Design | Pending |
| NAV-03 | P1: Bottom navigation reaches Stitch's 5-tab set | Design | Pending |
| NAV-04 | P1: Bottom navigation reaches Stitch's 5-tab set | Design | Pending |
| HUB-05 | P1: Hub rebuilt to a real curated layout | Design | Pending |
| HUB-06 | P1: Hub rebuilt to a real curated layout | Design | Pending |
| EVDET-01 | P2: EventDetail content parity | Design | Pending |
| EVDET-02 | P2: EventDetail content parity | Design | Pending |
| EVDET-03 | P2: EventDetail content parity | Design | Pending |
| EVDET-04 | P2: EventDetail content parity | Design | Pending |
| PROF-01 | P2: Profile content parity | Design | Pending |
| PROF-02 | P2: Profile content parity | Design | Pending |
| PROF-03 | P2: Profile content parity | Design | Pending |
| PROF-04 | P2: Profile content parity | Design | Pending |
| PROF-05 | P2: Profile content parity | Design | Pending |
| GUEST-01 | P1: Guest browsing access | Design | Pending |
| GUEST-02 | P1: Guest browsing access | Design | Pending |
| GUEST-03 | P1: Guest browsing access | Design | Pending |
| GUEST-04 | P1: Guest browsing access | Design | Pending |

**Coverage:** 63 total, 0 mapped to tasks, 63 unmapped ⚠️ (expected pre-Design; 29 of these — `TOKEN`/`REFRESH-01..04`/`PWDR`/`FAVUI`/`MAPGEO`/`MAPUI`/`HUB-01..04` — already have T1–T40 implementation history per `tasks.md`, but this addendum reopens `REFRESH-01..04` and `HUB-01..04` pending re-verification against the new stories above, so they stay Pending rather than being marked Verified from prior task completions)

---

## Success Criteria

- [ ] All 8 existing screens across Android/iOS/website pass interactive UAT against their Stitch screenshots.
- [ ] Favoritos, Mapa Interativo, and Hubs da Grande Vitória are usable end-to-end on all in-scope clients.
- [ ] `qor-mobile`'s password recovery reaches real 3-step parity with `qor-website`.
- [ ] Zero unexplained token deltas remain between the four token files and "Nightlife Discovery"'s `designMd`.
- [ ] Every submodule PR (`qor-api`, `qor-mobile`, `qor-website`) passes its matching reviewer subagent and `gh pr checks` green before merge, per `ARCHITECTURE.md` §8.11.
- [ ] (Addendum) All 4 audit-confirmed bugs (dead map nav, blank cover images, cold-launch crash, birthdate validation) are fixed and verified on both Android and iOS.
- [ ] (Addendum) Login, Signup, and Hub pass interactive UAT against their Stitch mocks on both Android and iOS — not just render-tested, screenshot-compared.
- [ ] (Addendum) The bottom nav shows the real 5-tab Stitch set on both Android and iOS.
- [ ] (Addendum) Profile and EventDetail reach full Stitch content parity (stats/preferences/recommendations/logout; organizer/related-events/dual actions) on both Android and iOS.
- [ ] (Addendum) An unauthenticated visitor can browse Home/Explore/Event Detail/Hub/Map on both Android and iOS without logging in, and is correctly redirected to Login/Signup when reaching a gated action.
