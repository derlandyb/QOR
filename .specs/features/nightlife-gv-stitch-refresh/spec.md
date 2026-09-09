# Nightlife GV Stitch Refresh Specification

## Problem Statement

`qor-mobile` (Android+iOS) and `qor-website` implement 8 screens on the NIGHTLIFE-GV design system, but a new Stitch project (`projects/6008587636717635180`, "Qual o Rock? Local Discovery") now exists as the current source-of-truth mock set. Bringing the two client repos to max fidelity with it also surfaces three product gaps the Stitch screens assume are already built — Favoritos, Mapa Interativo, and Hubs da Grande Vitória — plus one long-standing mobile/website parity gap (password recovery step count) that the new mocks make newly obvious.

## Goals

- [ ] Every existing screen in `qor-mobile` (Android+iOS) and `qor-website` visually matches its corresponding Stitch screenshot (structure, spacing, imagery treatment) while reconciling any real token deltas against the "Nightlife Discovery" Stitch design system.
- [ ] Favoritos (favorite/unfavorite + list) ships end-to-end on both mobile platforms and website, replacing the existing disabled nav-tab stub.
- [ ] Mapa Interativo ships end-to-end: `qor-api` gains real per-event coordinates and a geo query endpoint, and all three clients render a multi-event pin map.
- [ ] Hubs da Grande Vitória ships as a new curated per-city landing surface on both mobile platforms and website, distinct from the existing Explore screen.
- [ ] `qor-mobile`'s password-recovery flow reaches real 3-step parity with `qor-website` (email → verify-code → new-password), closing STATE.md's AD-021 gap.

## Out of Scope

| Feature | Reason |
| --- | --- |
| `qor-admin`, `qor-landingpage` | User confirmed scope is `qor-mobile` + `qor-website` only |
| Replacing NIGHTLIFE-GV tokens with the "Vix Rock Discovery" (light) theme | User confirmed "Nightlife Discovery" (dark) is the correct Stitch design system; the light theme was `get_project`'s default, not the intended one |
| A dedicated city-hub aggregation/trending backend endpoint (per-city counts, "trending in city X") | User confirmed: build Hubs against the existing `GET /events?city=` filter; a dedicated endpoint is deferred, documented as a Todo in STATE.md |
| Retiring/restructuring the existing `/eventos` Explore screen | User confirmed Hubs is a distinct new surface; Explore is untouched by this feature |
| GA4 event implementation for any new screen | Per `ARCHITECTURE.md` §11, GA4 events require a reviewed/approved tracking spreadsheet first — not started unprompted; this feature only reaches the point of listing candidate events, not implementing them |
| Push/email notifications for new favorites or map features | No trigger for this exists in `notifications/design.md`'s scope; not requested |

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

## Edge Cases

- IF a fan favorites an event, then unfavorites it before the optimistic UI reconciles with the server response THEN the system SHALL resolve to the server's actual final state, not the UI's last optimistic guess.
- IF the geocoding call to the Map Provider times out or errors (rate limit, network) THEN the system SHALL treat it identically to "address not resolvable" (AC2 of the backend geo story) — event saves, coordinates stay null, failure logged.
- IF a fan opens the Map screen with no network connectivity THEN the system SHALL show the existing empty/error-state pattern already used elsewhere (e.g. `EmptyState`) rather than a blank map.
- WHEN the mobile password-recovery flow's verify-code step is abandoned mid-flow (app backgrounded/closed) THEN the system SHALL require starting over from the email step on return — no persisted partial-recovery state (matches `qor-website`'s existing behavior, no new session concept introduced).
- IF a fan's device/browser has no City selected yet and lands on a Hub deep-link directly THEN the system SHALL still render that specific Hub (the Hub route's city comes from the URL/route param, not from any stored preference).

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

**Coverage:** 29 total, 0 mapped to tasks, 29 unmapped ⚠️ (expected pre-Design)

---

## Success Criteria

- [ ] All 8 existing screens across Android/iOS/website pass interactive UAT against their Stitch screenshots.
- [ ] Favoritos, Mapa Interativo, and Hubs da Grande Vitória are usable end-to-end on all in-scope clients.
- [ ] `qor-mobile`'s password recovery reaches real 3-step parity with `qor-website`.
- [ ] Zero unexplained token deltas remain between the four token files and "Nightlife Discovery"'s `designMd`.
- [ ] Every submodule PR (`qor-api`, `qor-mobile`, `qor-website`) passes its matching reviewer subagent and `gh pr checks` green before merge, per `ARCHITECTURE.md` §8.11.
