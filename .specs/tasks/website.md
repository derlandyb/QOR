# Website Tasks — `website` (Next.js)

**Submodule**: `qor-website` (git remote name) — checked out locally as `website/`
**Design refs**: `.specs/features/event-discovery/design.md`, `.specs/features/auth-fan-profile/design.md`
**Architecture ref**: `.specs/project/ARCHITECTURE.md`; design system: `design-system.md` (NIGHTLIFE-GV)
**Status**: Draft
**Milestone**: MVP Core only (Event Discovery P1 + Auth & Fan Profile P1/AUTH-25). Website mirrors mobile's discovery features per PROJECT.md — same scope boundary as `mobile.md` (no map view, no social profile parts, no notification-prefs UI).

**Test coverage**: no `TESTING.md` yet (greenfield). Test-type-per-layer: components → **unit** (Jest + React Testing Library), pages/data-fetching → **integration** (RTL + mocked API or Playwright component test), infra scaffolding → **none**, gated by CI build.

**Tools (all tasks, unless overridden, confirmed with user)**: MCP `context7` (Next.js/React API lookups), `stitch` (`mcp__stitch__get_screen` for every UI task referencing a Stitch screen ID, same table as `mobile.md`), `github` (PR creation) / Skill `NONE`.

---

## Stitch screen reference

Same table as `.specs/tasks/mobile.md` — reused here rather than duplicated in full; see that file's "Stitch screen reference" section for the 10 MVP Core screen IDs. NIGHTLIFE-GV tokens override Stitch's own theme, same rule as mobile.

---

## Execution Plan

```
Phase 1 (Foundation, sequential):
  W1 → W2 → W3 → W4 → W5

Phase 2 (Design-system component library, parallel after W5):
  W5 ──┬→ W6  ─┐
       ├→ W7  ─┤
       ├→ W8  ─┤
       ├→ W9  ─┤
       └→ W10 ─┘

Phase 3 (API client + data hooks, parallel after W4):
  W4 → W11 [P] → W13
  W4 → W12 [P] → W14

Phase 4 (Pages, parallel after matching components + hooks):
  W6,W9,W13 → W15 [P]  (home feed)
  W6,W9,W13 → W16 [P]  (explore)
  W6,W13    → W17 [P]  (event detail)
  W8,W10,W14 → W18 [P] (login)
  W8,W10,W14 → W19 [P] (signup)
  W8,W14     → W20 [P] (email verification)
  W8,W14     → W21 [P] (password recovery)
  W8,W14     → W22 [P] (profile — basic fields only)

Phase 5 (Integration, sequential):
  W15,W16,W17,W18,W19,W20,W21,W22 → W23 (layout/nav wiring) → W24 (E2E smoke)
```

---

## Task Breakdown

#### W1: Scaffold `website` Next.js repo
**What**: Next.js (App Router) + TypeScript + Tailwind CSS scaffold.
**Where**: `website/` (root config files, `app/` directory)
**Depends on**: None
**Reuses**: n/a
**Requirement**: ARCHITECTURE §1
**Done when**:
- [ ] `npm run dev` serves a default page; `npm run build` succeeds
**Tests**: none
**Gate**: build

#### W2: Docker Compose service + root Makefile wiring
**What**: Add `website` service to the root Docker Compose file, wire into `make up`/`make test`.
**Where**: `docker-compose.yml` (root), `Makefile` (root)
**Depends on**: W1
**Reuses**: n/a
**Requirement**: ARCHITECTURE §8.1
**Tests**: none
**Gate**: build

#### W3: CI workflow (lint/test/build gate)
**What**: GitHub Actions workflow — ESLint (with unused-export rule per §8.4), Jest+RTL, `npm run build`.
**Where**: `.github/workflows/website-ci.yml` (in `qor-website` repo)
**Depends on**: W1, W2
**Reuses**: n/a
**Requirement**: ARCHITECTURE §8.2, §8.4
**Tests**: none
**Gate**: build

#### W4: API client (typed fetch wrapper for `/api/v1`)
**What**: Typed HTTP client hitting `api.md`'s `/api/v1` endpoints, cookie-based SPA auth (httpOnly, `credentials: 'include'`) per ARCHITECTURE §2 — no token ever touches `localStorage`/`sessionStorage`.
**Where**: `website/lib/api/client.ts`
**Depends on**: W1
**Reuses**: `api.md`'s T25/T31/T32 endpoint contracts
**Requirement**: ARCHITECTURE §2, §3
**Done when**:
- [ ] Unit tests: request builder produces correct URLs/params for event list filters and each auth/profile endpoint; 401 response triggers the shared auth-redirect handler, not a silent failure
**Tests**: unit
**Gate**: quick

#### W5: TS enum mirrors (`EventStatus`, `City`, `ConsentType`)
**What**: TS union/const mirrors of `api`'s backed enums — same cross-file-contract rule as `mobile.md` S5.
**Where**: `website/lib/enums/`
**Depends on**: W1
**Reuses**: `api.md` T4's exact enum values
**Requirement**: ARCHITECTURE §14.1
**Done when**: unit test — every enum value round-trips correctly against a fixture API response
**Tests**: unit
**Gate**: quick

### Design-system component library (Tailwind, lifted from `design-system.md` §2/§4 — already web-shaped)

#### W6: `EventCard` component
**What**: Port `design-system.md` §4.1 near-verbatim (it's already Tailwind/HTML) — 4:5 image holder with 500ms hover zoom to scale-105, floating date badge, floating genre tag, content block, CTA row — plus §3's `card-enter` keyframe with per-index stagger (`animation-delay: calc(var(--duration-stagger) * var(--card-index))`), hover scale(1.03)+translateY(-4px)+pink-glow shadow.
**Where**: `website/components/design-system/EventCard.tsx`, `website/styles/nightlife-gv.css` (or Tailwind theme extension) for the token/keyframe definitions
**Depends on**: W5
**Reuses**: `design-system.md` §2 (Tailwind theme tokens), §3 (`card-enter` keyframe, hover spec), §4.1 (HTML/Tailwind blueprint) — lifted near-verbatim per prior research (this section of the design system is already web-shaped)
**Requirement**: user request — web design-system components + animations; DISC-05
**Done when**:
- [ ] Component matches §4.1's structure exactly; every documented animation present (hover scale/rise/glow, entrance stagger via `--card-index`)
- [ ] Unit tests: renders all required fields; missing image falls back to placeholder; live event shows pulse badge instead of date badge
**Tests**: unit
**Gate**: quick

#### W7: `CityFilterBar` + `GenreTagSet` components
**What**: Port §4.2 (city pill nav, `aria-pressed` state, inactive 15%-tint vs. active solid+scale(1.05), 250ms ease-smooth) and §4.3 (5-genre color table) near-verbatim.
**Where**: `website/components/design-system/CityFilterBar.tsx`, `GenreTagSet.tsx`
**Depends on**: W5
**Reuses**: `design-system.md` §4.2, §4.3
**Requirement**: user request — web design-system components; DISC-14–DISC-16
**Tests**: unit
**Gate**: quick

#### W8: CTA button components (`Ver no Mapa`, `Ver Instagram`) + form inputs
**What**: Port §4.4's two CTA button variants (blue-outline→solid, and pink→purple gradient with animated `background-position` shift) plus generic form input/error-state components for auth forms.
**Where**: `website/components/design-system/CtaButton.tsx`, `FormField.tsx`
**Depends on**: W5
**Reuses**: `design-system.md` §4.4
**Requirement**: user request — web design-system components; DISC-08, auth forms
**Tests**: unit
**Gate**: quick

#### W9: `EmptyState`, `PlaceholderImage`, live-pulse badge components
**What**: Empty-state message component, design-system placeholder image, and the standalone live-pulse badge (§3's one continuous-loop animation, 1.8s ease-in-out infinite, pink accent).
**Where**: `website/components/design-system/{EmptyState,PlaceholderImage,LivePulseBadge}.tsx`
**Depends on**: W5
**Reuses**: `design-system.md` §3 (live-pulse spec)
**Requirement**: event-discovery edge cases
**Tests**: unit
**Gate**: quick

#### W10: Consent-capture component
**What**: pt-BR terms/privacy display with required, non-pre-checked checkbox — same content contract as `mobile.md`'s A5/I5, independent web implementation.
**Where**: `website/components/design-system/ConsentCapture.tsx`
**Depends on**: W5
**Reuses**: `design-system.md` tokens; same contract as `mobile.md` A5
**Requirement**: AUTH-02, AUTH-03
**Tests**: unit
**Gate**: quick

### Data hooks

#### W11: Event data hooks (list + detail, with polling)
**What**: `useEventList(filters)` / `useEventDetail(id)` React hooks wrapping W4's client, polling per `qor.polling.event_list_interval_seconds` (mirrored client-side, same Tech Decision as mobile) plus manual refresh.
**Where**: `website/hooks/useEvents.ts`
**Depends on**: W4
**Reuses**: W4's API client
**Requirement**: DISC-01–DISC-06, DISC-14–DISC-18
**Done when**: unit tests (mocked client): polling interval respected; filter changes trigger refetch with correct params; loading/error/empty states exposed correctly
**Tests**: unit
**Gate**: quick

#### W12: Auth/profile data hooks
**What**: `useAuth()` (login/signup/logout/session), `useProfile()` (get/update/data-rights) hooks wrapping W4's client.
**Where**: `website/hooks/useAuth.ts`, `useProfile.ts`
**Depends on**: W4
**Reuses**: W4's API client
**Requirement**: AUTH-01–AUTH-19, AUTH-25
**Tests**: unit
**Gate**: quick

#### W13: Event data hooks integration test [P]
**What**: Integration test hitting a mocked API layer end-to-end through W11's hooks into a minimal test harness component, confirming the full request→render cycle (not just the hook in isolation).
**Where**: `website/hooks/__tests__/useEvents.integration.test.tsx`
**Depends on**: W11
**Reuses**: W11
**Requirement**: same as W11
**Tests**: integration
**Gate**: full

#### W14: Auth/profile hooks integration test [P]
**What**: Same shape as W13, for W12.
**Where**: `website/hooks/__tests__/useAuth.integration.test.tsx`
**Depends on**: W12
**Reuses**: W12
**Requirement**: same as W12
**Tests**: integration
**Gate**: full

### Pages

#### W15: `/` home feed page [P]
**What**: Per Stitch `32c8c87d76994eaf9f42cd320c2759e5` — soonest-first list, `CityFilterBar`, entrance-stagger grid.
**Where**: `website/app/page.tsx`
**Depends on**: W6, W9, W13
**Reuses**: `EventCard` (W6), `EmptyState` (W9), `useEventList` (W11/W13)
**Requirement**: DISC-01–DISC-06; Stitch screen `32c8c87d76994eaf9f42cd320c2759e5`
**Tests**: integration
**Gate**: full

#### W16: `/eventos` explore/discovery page [P]
**What**: Per Stitch `642def01ae144e1f8a1896018febf379` — full city+genre filter UI, per `event-discovery/design.md`'s note that the website mirrors mobile discovery.
**Where**: `website/app/eventos/page.tsx`
**Depends on**: W6, W9, W13
**Reuses**: same as W15
**Requirement**: DISC-14–DISC-18; Stitch screen `642def01ae144e1f8a1896018febf379`
**Tests**: integration
**Gate**: full

#### W17: `/eventos/[id]` event detail page [P]
**What**: Per Stitch `391ebe25bee544b89dc309283b2b9008` — full detail fields, ticket-link button (paid only), embedded map iframe/component keyed off venue address, promoter contact list, native Web Share API (with clipboard-copy fallback) for share.
**Where**: `website/app/eventos/[id]/page.tsx`
**Depends on**: W6, W13
**Reuses**: `EventCard`'s sub-components where applicable, `useEventDetail` (W11/W13)
**Requirement**: DISC-07–DISC-13; Stitch screen `391ebe25bee544b89dc309283b2b9008`
**Done when**: integration test covers cancelled/ended banner rendering, missing-promoter-contact-field omission, paid-vs-free ticket-button visibility
**Tests**: integration
**Gate**: full

#### W18: `/entrar` login page [P]
**What**: Per Stitch `cfa5690fed3d487897d65de249ad7f1d`.
**Where**: `website/app/entrar/page.tsx`
**Depends on**: W8, W10, W14
**Reuses**: `CtaButton`/`FormField` (W8), `useAuth` (W12/W14)
**Requirement**: AUTH-06–AUTH-12; Stitch screen `cfa5690fed3d487897d65de249ad7f1d`
**Tests**: integration
**Gate**: full

#### W19: `/cadastro` signup page [P]
**What**: Per Stitch `d4965c8bc3a740158366d6a9a45ed459`.
**Where**: `website/app/cadastro/page.tsx`
**Depends on**: W8, W10, W14
**Reuses**: `ConsentCapture` (W10), `useAuth` (W12/W14)
**Requirement**: AUTH-01–AUTH-05; Stitch screen `d4965c8bc3a740158366d6a9a45ed459`
**Tests**: integration
**Gate**: full

#### W20: Email verification page [P]
**What**: Per Stitch `31a89c6e38cd4136998d650e9d778f73`.
**Where**: `website/app/verificar-email/page.tsx`
**Depends on**: W8, W14
**Requirement**: AUTH-10; Stitch screen `31a89c6e38cd4136998d650e9d778f73`
**Tests**: integration
**Gate**: full

#### W21: Password recovery pages (request + success) [P]
**What**: Per Stitch `32a562fe876e4d0cb2eb87c2140de64e` and `bfdd2ec9b4c944c0a3f7c26793fb02c3`.
**Where**: `website/app/recuperar-senha/page.tsx`, `website/app/recuperar-senha/sucesso/page.tsx`
**Depends on**: W8, W14
**Requirement**: AUTH-13–AUTH-16; Stitch screens `32a562fe876e4d0cb2eb87c2140de64e`, `bfdd2ec9b4c944c0a3f7c26793fb02c3`
**Tests**: integration
**Gate**: full

#### W22: `/perfil` profile page (basic fields only) [P]
**What**: Per Stitch `ee5dea95cc384522b7705c2eb44ac552`, scoped to basic-info fields (no social widgets) — same scope cut as `mobile.md` A13/I13.
**Where**: `website/app/perfil/page.tsx`
**Depends on**: W8, W14
**Requirement**: AUTH-17–AUTH-19, AUTH-25; Stitch screen `ee5dea95cc384522b7705c2eb44ac552`
**Tests**: integration
**Gate**: full

#### W23: Layout/nav wiring (sequential)
**What**: Root layout, top nav (per `design-system.md`'s showcase — logo mark, "Agenda / Casas / Sobre" link pattern adapted to actual site nav), auth-aware header state (login/signup links vs. profile menu).
**Where**: `website/app/layout.tsx`, `website/components/design-system/NavBar.tsx`
**Depends on**: W15, W16, W17, W18, W19, W20, W21, W22
**Reuses**: `useAuth` (W12)
**Requirement**: DISC-06 (navigation between list/detail)
**Tests**: integration
**Gate**: full
**Commit**: `feat(website): wire layout and navigation for MVP Core pages`

#### W24: E2E smoke test (sequential)
**What**: One Playwright E2E flow: browse home → filter → open detail → sign up → verify (mocked) → log in → view profile.
**Where**: `website/e2e/mvp-core-smoke.spec.ts`
**Depends on**: W23
**Reuses**: n/a
**Requirement**: cross-cutting verification of this file's scope
**Done when**: E2E suite runs in CI (W3) and passes against a seeded local stack (`api.md` T22's seed data)
**Tests**: integration (E2E classified as integration for this coverage matrix)
**Gate**: full

---

## Parallel Execution Map

```
Phase 1 (Sequential): W1 → W2 → W3 → W4,W5 [P after W1/W2/W3? — W4,W5 both only depend on W1]

Phase 2 (Parallel after W5): W6,W7,W8,W9,W10 [P]

Phase 3 (Parallel after W4): W11 [P] → W13 ; W12 [P] → W14

Phase 4 (Parallel after matching deps): W15,W16,W17,W18,W19,W20,W21,W22 [P]

Phase 5 (Sequential): W23 → W24
```

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| W1–W3 | 1 concern each | ✅ Granular |
| W4, W5 | 1 client / 1 enum set | ✅ Granular |
| W6–W10 | 1–2 related components each (cohesive) | ✅ Granular |
| W11–W14 | 1 hook group + its integration test each | ✅ Granular |
| W15–W22 | 1 page each | ✅ Granular |
| W23, W24 | 1 concern each | ✅ Granular |

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| W1–W5 | W1 (W2,W3 sequential; W4,W5 after W1) | Phase 1 | ✅ Match |
| W6–W10 | W5 | Phase 2 | ✅ Match |
| W11, W12 | W4 | Phase 3 | ✅ Match |
| W13 | W11 | Phase 3 | ✅ Match |
| W14 | W12 | Phase 3 | ✅ Match |
| W15, W16 | W6, W9, W13 | Phase 4 | ✅ Match |
| W17 | W6, W13 | Phase 4 | ✅ Match |
| W18, W19 | W8, W10, W14 | Phase 4 | ✅ Match |
| W20, W21, W22 | W8, W14 | Phase 4 | ✅ Match |
| W23 | W15–W22 | Phase 5 | ✅ Match |
| W24 | W23 | Phase 5 | ✅ Match |

All rows ✅.

---

## Test Co-location Validation

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| W1–W3 | Scaffolding/CI | none | none | ✅ OK |
| W4, W5 | Client/enums | unit | unit | ✅ OK |
| W6–W10 | Components | unit | unit | ✅ OK |
| W11, W12 | Hooks | unit | unit | ✅ OK |
| W13, W14 | Hook integration | integration | integration | ✅ OK |
| W15–W22 | Pages (data-fetching) | integration | integration | ✅ OK |
| W23 | Layout/nav | integration | integration | ✅ OK |
| W24 | E2E | integration | integration | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (MVP Core scope above)

- No map view, no favorites, no notification-prefs UI, no GA4 calls were in MVP Core — same exclusions as `mobile.md` for the same reasons (out of designed scope / gated on spreadsheet approval). Favorites/notifications are what Milestone 2 below adds.
- `EventCard`/`CityFilterBar`/CTA buttons were lifted **near-verbatim** from `design-system.md` §4 rather than re-derived, since that section is already Tailwind/HTML — unlike `mobile.md`'s Compose/SwiftUI tasks, which must re-derive the same spec into a different UI paradigm.

---

# Milestone 2: Social & Notifications

**Features**: `favorites-social` (FAV-01–26) + `notifications` (NOTIF-01–23), plus `auth-fan-profile`'s previously-`Pending` P2 stories (AUTH-20–24).
**Design refs**: `.specs/features/favorites-social/design.md`, `.specs/features/notifications/design.md`
**API contracts**: `.specs/tasks/api.md` Milestone 2 (T53–T89)
**Sequencing note**: cannot start until MVP Core's PRs merge across all 5 submodules, and depends on `api.md`'s Milestone 2 endpoints.
**Not in scope here**: Monetization has zero website UI per `monetization/design.md` — no task below should add plan/pricing/quota UI.

## Stitch screen reuse for Milestone 2

Same as `mobile.md`'s Milestone 2 table: `d9b7f87492424f9b952270971837bd22` ("Meus Favoritos") for the favorites page, and the social sections of `ee5dea95cc384522b7705c2eb44ac552` ("Meu Perfil - Foco Social") for the `/perfil` additions. No dedicated screens for friend-requests/share/feed — built from the existing web design-system component library (W6–W10).

## Execution Plan — Milestone 2

```
Phase 6 (API client + hooks, parallel after W4 existing):
  W4(existing) → W25 [P] (favorites/friends client extension)
  W4(existing) → W26 [P] (notification-prefs/address client extension)
  W25 → W27 (hooks) ; W26 → W28 (hooks)

Phase 7 (Components, parallel after W6/W8 existing):
  W6(existing) → W29 (favorite button, modifies EventCard)
  W8(existing) → W30 (friend-request/decision UI components)

Phase 8 (Pages, parallel after matching deps):
  W29,W27 → W31 [P] (/favoritos)
  W30,W27 → W32 [P] (/amigos)
  W29,W27 → W33 [P] (share picker, modifies event detail page W17)
  W27 → W34 [P3] (/feed)
  W28 → W35 [P] (notification-prefs + address/radius additions, modifies /perfil W22)

Phase 9 (Integration, sequential):
  W31,W32,W33,W34,W35 → W36 (nav update, modifies W23) → W37 (E2E)
```

## Task Breakdown — Milestone 2

#### W25: API client extension — favorites/friends [P]
**What**: Extend the typed client (W4) with `api.md` T80–T82's endpoints (favorite toggle, friend requests, friends list, friends-interested, share).
**Where**: `website/lib/api/client.ts` (modify)
**Depends on**: W4 (existing)
**Reuses**: W4
**Requirement**: FAV-01–FAV-23
**Tests**: unit
**Gate**: quick

#### W26: API client extension — notification-prefs/address [P]
**What**: Extend W4 with `api.md` T83/T84's endpoints.
**Where**: `website/lib/api/client.ts` (modify)
**Depends on**: W4 (existing)
**Reuses**: W4
**Requirement**: AUTH-20–AUTH-24
**Tests**: unit
**Gate**: quick

#### W27: Favorites/friends/share/feed hooks
**What**: `useFavorite(eventId)`, `useFriends()`, `useFriendRequests()`, `useFriendsInterested(eventId)`, `useShareEvent()`, `useSocialFeed()` [P3].
**Where**: `website/hooks/useSocial.ts`
**Depends on**: W25
**Reuses**: W25
**Requirement**: FAV-01–FAV-26
**Tests**: unit
**Gate**: quick

#### W28: Notification-prefs/address hooks
**What**: `useNotificationPreferences()`, `useAddressAndRadius()`.
**Where**: `website/hooks/useNotificationSettings.ts`
**Depends on**: W26
**Reuses**: W26
**Requirement**: AUTH-20–AUTH-24
**Tests**: unit
**Gate**: quick

#### W29: Favorite button on `EventCard` (modifies W6)
**What**: Wire the favorite-icon placeholder already present in MVP Core's `EventCard` to W27's `useFavorite`, optimistic toggle with the `--ease-beat` overshoot per `design-system.md` §3.
**Where**: `website/components/design-system/EventCard.tsx` (modify)
**Depends on**: W27, W6 (existing)
**Reuses**: W6, W27
**Requirement**: FAV-01–FAV-02
**Done when**: existing W6 unit tests still pass, plus a new toggle-interaction test
**Tests**: unit
**Gate**: quick

#### W30: Friend-request/decision UI components
**What**: Request-row component (accept/reject actions), friend-list row, built from W8's `CtaButton`/`FormField` primitives.
**Where**: `website/components/design-system/{FriendRequestRow,FriendListRow}.tsx`
**Depends on**: W8 (existing)
**Reuses**: W8
**Requirement**: FAV-09–FAV-11
**Tests**: unit
**Gate**: quick

#### W31: `/favoritos` page [P]
**What**: Per Stitch `d9b7f87492424f9b952270971837bd22`.
**Where**: `website/app/favoritos/page.tsx`
**Depends on**: W29, W27
**Reuses**: `EventCard` (W6/W29), `useFavorite`/favorites list from W27
**Requirement**: FAV-03; Stitch screen `d9b7f87492424f9b952270971837bd22`
**Tests**: integration
**Gate**: full

#### W32: `/amigos` page (friends list + requests) [P]
**Where**: `website/app/amigos/page.tsx`
**Depends on**: W30, W27
**Reuses**: `FriendRequestRow`/`FriendListRow` (W30), W27
**Requirement**: FAV-05–FAV-17
**Tests**: integration
**Gate**: full

#### W33: Share picker (modifies `/eventos/[id]`, W17) [P]
**What**: Native Web Share API (already present per MVP Core's W17) plus an in-app "share to friend" picker over the friends list.
**Where**: `website/app/eventos/[id]/page.tsx` (modify), `website/components/design-system/SharePicker.tsx`
**Depends on**: W29, W27, W17 (existing)
**Reuses**: W17, W27
**Requirement**: FAV-21–FAV-23
**Done when**: existing W17 tests still pass, plus new share-to-friend tests
**Tests**: integration
**Gate**: full

#### W34: `/feed` page [P3]
**Where**: `website/app/feed/page.tsx`
**Depends on**: W27
**Reuses**: `EventCard` entrance-stagger pattern (W6)
**Requirement**: FAV-24–FAV-26
**Tests**: integration
**Gate**: full

#### W35: Notification-prefs + address/radius additions (modifies `/perfil`, W22) [P]
**What**: Same field set as `mobile.md`'s A19 — per-channel toggles, global silence, per-trigger toggles (event-changed/cancelled non-togglable), manual address + distinct revocable location-consent, favorite genres, search radius. Also renders the social sections of `ee5dea95cc384522b7705c2eb44ac552` now in scope.
**Where**: `website/app/perfil/page.tsx` (modify)
**Depends on**: W28, W22 (existing)
**Reuses**: W22, W28
**Requirement**: AUTH-20–AUTH-24; Stitch screen `ee5dea95cc384522b7705c2eb44ac552`
**Done when**: existing W22 tests still pass, plus new tests per added field
**Tests**: integration
**Gate**: full

#### W36: Nav update (sequential, modifies W23)
**What**: Add `/amigos`, `/favoritos`, `/feed` (P3) links to the existing `NavBar` (W23).
**Where**: `website/components/design-system/NavBar.tsx` (modify)
**Depends on**: W31, W32, W33, W34, W35, W23 (existing)
**Reuses**: W23
**Requirement**: cross-cutting
**Tests**: integration
**Gate**: full
**Commit**: `feat(website): wire Social & Notifications pages into navigation`

#### W37: E2E smoke test extension (sequential)
**What**: Extend W24's Playwright flow: favorite an event, send/accept a friend request between two seeded accounts, confirm friends-interested shows on a shared favorite.
**Where**: `website/e2e/mvp-core-smoke.spec.ts` (extend, or new `social-smoke.spec.ts`)
**Depends on**: W36
**Reuses**: W24 (existing)
**Requirement**: cross-cutting verification
**Tests**: integration
**Gate**: full

## Task Granularity Check — Milestone 2

| Task | Scope | Status |
|---|---|---|
| W25–W28 | 1 client extension / hook group each | ✅ Granular |
| W29, W30 | 1–2 cohesive components each | ✅ Granular |
| W31–W35 | 1 page each | ✅ Granular |
| W36, W37 | 1 concern each | ✅ Granular |

## Diagram-Definition Cross-Check — Milestone 2

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| W25, W26 | W4 | Phase 6 | ✅ Match |
| W27 | W25 | Phase 6 | ✅ Match |
| W28 | W26 | Phase 6 | ✅ Match |
| W29 | W6, W27 | Phase 7 | ✅ Match |
| W30 | W8 | Phase 7 | ✅ Match |
| W31 | W29, W27 | Phase 8 | ✅ Match |
| W32 | W30, W27 | Phase 8 | ✅ Match |
| W33 | W29, W27, W17 | Phase 8 | ✅ Match |
| W34 | W27 | Phase 8 | ✅ Match |
| W35 | W28, W22 | Phase 8 | ✅ Match |
| W36 | W31–W35, W23 | Phase 9 | ✅ Match |
| W37 | W36 | Phase 9 | ✅ Match |

All rows ✅.

## Test Co-location Validation — Milestone 2

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| W25, W26 | Client | unit | unit | ✅ OK |
| W27, W28 | Hooks | unit | unit | ✅ OK |
| W29, W30 | Components | unit | unit | ✅ OK |
| W31–W35 | Pages | integration | integration | ✅ OK |
| W36 | Nav | integration | integration | ✅ OK |
| W37 | E2E | integration | integration | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (all milestones)

- No monetization UI exists anywhere in this file — `monetization/design.md` names only `qor-landingpage`/`qor-admin`.
- W29, W33, W35, W36 all modify existing MVP Core files — confirm original test suites still pass before adding new assertions.
- GA4 calls remain excluded from every task in this file, across every milestone.
