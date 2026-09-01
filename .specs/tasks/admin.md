# Admin Panel Tasks — `admin` (Next.js)

**Submodule**: `qor-admin` (git remote name) — checked out locally as `admin/`
**Design refs**: `.specs/features/venue-promoter-admin/design.md`
**Architecture ref**: `.specs/project/ARCHITECTURE.md`; design system: **`design-system-admin.md`** (QOR-ADMIN / "Corona" — the admin panel's own, fully-adopted design system, canonical as of this Tasks-phase revision)
**Status**: Draft
**Milestone**: MVP Core only (Venue/Promoter Admin P1 = ADMIN-01–20; P2 ADMIN-21–27 included as stretch, same as `api.md` Phase 4, since spec marks them "In Design" not "Pending")

**✅ Resolved (confirmed with user, reversing an earlier draft of this file)**: the admin panel **fully adopts** the BootstrapDash "Corona Tailwind — Modern Vertical" demo's own design system — colors, typography, spacing, radii, and motion — not NIGHTLIFE-GV. NIGHTLIFE-GV (`design-system.md`) stays scoped to mobile/website/landing page only, per `mobile.md`/`website.md`/`landingpage.md`. Every color/type/spacing/radius/motion value below traces to **`design-system-admin.md`**, extracted via a full live re-navigation of the demo (`https://demo.bootstrapdash.com/corona-tailwind/themes/modern-vertical/`) covering Dashboard, Widgets, Buttons, Badges, Modals, Progress Bar, Tables, and the Login page — `getComputedStyle`-measured colors, transition durations/easings, radii, and font metrics, not just structural observation. This 2026-09-01 revision supersedes an earlier pass that used the sibling "Corona React" demo — see `STATE.md` AD-010. See `design-system-admin.md` for the full token/component/motion catalog before starting any task below.

**Test coverage**: no `TESTING.md` yet (greenfield). Same test-type-per-layer convention as `website.md`: components → unit, pages/data-fetching → integration, scaffolding → none.

**Tools (all tasks, unless overridden, confirmed with user)**: MCP `context7` (Next.js/React API lookups), `github` (PR creation) / Skill `NONE`. No Stitch screens apply here — the admin panel's structural and visual reference is `design-system-admin.md` (BootstrapDash Corona, live-browsed), not the Stitch project (which only covers fan-facing mobile/web screens).

---

## `design-system-admin.md` quick index (see that file for full detail)

- **§1 Colors**: `--admin-bg-body` `#000000`, `--admin-bg-surface` `#191C24`, 8-color semantic palette (`--admin-primary` `#0090E7`, `--admin-success` `#00D25B`, `--admin-danger` `#FC424A`, `--admin-warning` `#FFAB00`, `--admin-info` `#8F5FE8`, plus secondary/light/dark) — §1.2 has the QOR-status→color mapping table to use verbatim.
- **§2 Typography**: no custom font — Tailwind's system font stack (`ui-sans-serif, system-ui, sans-serif, ...`), confirmed with user; stat values 24px/700, widget titles 14px/700, body 16px/400.
- **§3 Spacing & Radii**: uniform `6px` (`rounded-md`) across cards/buttons/badges/most inputs (verify per input type — one measured input was `2px`), `9999px` (`rounded-full`) pill button variant (recommended default), sidebar 244px, buttons carry an explicit `min-width: 128px`.
- **§4 Motion (MEASURED, not estimated — flatter than the old Corona React capture)**: sidebar expand/collapse `all` 300ms ease-in-out; buttons/inputs have **no transition class at all** — hover/focus states snap instantly (`0s`), do not add fades that aren't there; modal open/close transition unmeasured (couldn't trigger during capture) — re-measure live when the `DecisionModal` is built, don't assume the old doc's values.
- **§5 Components**: Sidebar (5.1), Topbar (5.2), Stat card (5.3), Donut widget (5.4), List-activity widget (5.5), Status-pill data table (5.6), Buttons (5.7, adds an "Inverse" style family), Form inputs (5.8), Modal (5.9, unmeasured transition), Progress bar (5.10, adds circular variant), Auth card (5.11, photo background + two social buttons, both omitted).
- **§6**: what NOT to carry over (Facebook + Google login buttons, the literal login background photo, template filler nav categories, sample content, invented hover/focus transitions).

---

## Execution Plan

```
Phase 1 (Foundation, sequential): AT1 → AT2 → AT3 → AT4 → AT5

Phase 2 (Corona design-system component library, parallel after AT4):
  AT4 ──┬→ AT6  ─┐
        ├→ AT7  ─┤
        ├→ AT8  ─┤
        ├→ AT9  ─┤
        └→ AT10 ─┘

Phase 3 (API client + hooks, parallel after AT4):
  AT4 → AT11 [P] → AT13
  AT4 → AT12 [P] → AT14

Phase 4 (Pages, parallel after matching deps):
  AT6,AT10,AT14         → AT15 [P] (admin login)
  AT7,AT10,AT13         → AT16 [P] (account approval queue)
  AT7,AT10,AT13         → AT17 [P] (event approval queue)
  AT9,AT10,AT14          → AT18 [P] (venue self-registration)
  AT9,AT10,AT14          → AT19 [P] (promoter self-registration)
  AT7,AT8,AT9,AT10,AT13,AT14 → AT20 [P] (organizer event CRUD + submit)
  AT6,AT7,AT8,AT13        → AT21 [P] (dashboard overview, P2)

Phase 5 (Integration, sequential):
  AT15,AT16,AT17,AT18,AT19,AT20,AT21 → AT22 (layout/sidebar wiring) → AT23 (E2E smoke)
```

---

## Task Breakdown

#### AT1: Scaffold `admin` Next.js repo
**What**: Next.js (App Router) + TypeScript + Tailwind CSS scaffold, admin-specific (separate from `website`).
**Where**: `admin/`
**Depends on**: None
**Reuses**: n/a
**Requirement**: ARCHITECTURE §1
**Tests**: none
**Gate**: build

#### AT2: Docker Compose service + root Makefile wiring
**Where**: `docker-compose.yml` (root), `Makefile` (root)
**Depends on**: AT1
**Requirement**: ARCHITECTURE §8.1
**Tests**: none
**Gate**: build

#### AT3: CI workflow (lint/test/build gate)
**Where**: `.github/workflows/admin-ci.yml` (in `qor-admin` repo)
**Depends on**: AT1, AT2
**Requirement**: ARCHITECTURE §8.2, §8.4
**Tests**: none
**Gate**: build

#### AT4: API client (typed fetch wrapper for `/api/admin/v1`)
**What**: Typed HTTP client hitting `api.md`'s `/api/admin/v1` endpoints, cookie-based SPA auth (httpOnly, admin guard — distinct cookie/session from `website`'s fan-guard cookie) per ARCHITECTURE §2.
**Where**: `admin/lib/api/client.ts`
**Depends on**: AT1
**Reuses**: `api.md`'s T40–T43 endpoint contracts
**Requirement**: ARCHITECTURE §2, §3
**Done when**: unit tests — request builders for registration/approval/event-CRUD endpoints correct; 401 triggers admin-login redirect
**Tests**: unit
**Gate**: quick

#### AT5: Enum mirrors (`ApprovalStatus`, `ApprovalOutcome`, `EventStatus`, `City`)
**What**: TS union/const mirrors of `api`'s backed enums.
**Where**: `admin/lib/enums/`
**Depends on**: AT1
**Reuses**: `api.md` T4's exact enum values
**Requirement**: ARCHITECTURE §14.1
**Tests**: unit
**Gate**: quick

### Corona design-system component library (fully sourced from `design-system-admin.md`)

#### AT6: Corona token layer (Tailwind theme) + Sidebar + Topbar shell
**What**: First task to touch styling, so it also owns porting the **full** `design-system-admin.md` §1–4 token set into this repo's Tailwind theme — colors (8-color semantic palette + surfaces/text), typography (system font stack — no custom Google Font, confirmed with user), spacing/radii (uniform 6px card/button/badge radius, 2px on the one measured input type — verify others, 9999px pill button, sidebar 244px, 128px button min-width), and the exact measured motion values (sidebar expand/collapse `all` 300ms ease-in-out; **no transition class on buttons/inputs** — hover/focus states snap instantly, do not add fades that aren't in the source; modal transition unmeasured, re-check live before implementing AT9). Then: sidebar per §5.1 (244px, icon+label nav — Dashboard, Aprovação de Contas, Aprovação de Eventos, Meus Eventos, role-scoped visibility, 300ms ease-in-out collapse transition) and topbar per §5.2 (search input, `+ Novo Evento` primary CTA, icon buttons, profile block).
**Where**: `admin/styles/corona-theme.css` (or Tailwind theme extension, token layer), `admin/components/layout/Sidebar.tsx`, `Topbar.tsx`
**Depends on**: AT4
**Reuses**: `design-system-admin.md` §1–4 (full token set) and §5.1–5.2 (component blueprints)
**Requirement**: user request — admin panel fully adopts the Corona design system, including all documented animations/transitions
**Done when**:
- [ ] Every token category from `design-system-admin.md` §1–4 present in the theme file — colors, type, spacing, radii, motion — none inlined ad hoc in later component tasks
- [ ] Sidebar renders role-appropriate nav items (Super Admin sees both approval queues; Venue Admin/Promoter see only their own event management); the sidebar's own expand/collapse uses the measured `all` 300ms ease-in-out transition — nav-item active/hover state itself has no measured transition (instant), don't invent one
- [ ] No NIGHTLIFE-GV token (Space Grotesk/Inter, the pink/orange/purple/blue accent set, `--ease-beat`/`--duration-*`) present anywhere in this repo's rendered output
**Tests**: unit
**Gate**: quick

#### AT7: Stat card + donut widget + status-pill + data-table components
**What**: Per `design-system-admin.md` §5.3 (stat card: value + colored trend chip + label + directional icon button), §5.4 (donut metric widget: centered total + segmented ring using the 5-color semantic rotation + itemized row list), §5.6 (status-pill data table: header row + avatar/name/plain columns + solid-fill status badge, `border-radius: 4px`, `padding: 4px 6px`, `font-size: 12px`/`font-weight: 500`). `StatusPill` maps `ApprovalStatus`/`EventStatus` enum values through the QOR-status→color table in `design-system-admin.md` §1.2 (never a raw string driving color). `DataTable` is the one reusable table+decision-action component parameterized for both approval queues, per `venue-promoter-admin/design.md`.
**Where**: `admin/components/design-system/{StatCard,DonutWidget,StatusPill,DataTable}.tsx`
**Depends on**: AT4, AT5, AT6
**Reuses**: `ApprovalStatus`/`EventStatus` enums (AT5), Corona tokens (AT6), `design-system-admin.md` §1.2/§5.3/§5.4/§5.6
**Requirement**: `venue-promoter-admin/design.md`'s admin-panel queue UI components note
**Done when**: unit tests — `StatusPill` renders correct color/label for every enum case per the §1.2 mapping table; `DataTable` renders rows + fires row-action callbacks; `StatCard` trend chip colors correctly by sign
**Tests**: unit
**Gate**: quick

#### AT8: Button, badge, and progress-bar components (with their measured animations)
**What**: Per `design-system-admin.md` §5.7 (semantic colors × Default/Inverse/Outline/Rounded-pill styles, `padding: 6px 12px`, `font-size: 16px`, `min-width: 128px` — pill variant is the recommended default per §5.7's note — **no hover/focus transition**, hover background swap is an instant snap, don't add a fade) and §5.10 (progress bar: thin track, semantic-color fill; three variants — plain colored, inner-label percentage text, outer-label percentage text — plus a circular ring variant worth adopting for the quota widget).
**Where**: `admin/components/design-system/{Button,Badge,ProgressBar}.tsx`
**Depends on**: AT6
**Reuses**: Corona tokens (AT6), `design-system-admin.md` §5.7/§5.10
**Requirement**: user request — admin design-system components including all animations/transitions
**Done when**:
- [ ] Every button variant renders with the correct semantic color and radius; hover state snaps instantly (no transition), matching the measured source
- [ ] Progress bar supports inner-label, outer-label, and (if adopted) circular variants; width/ring reflects the `value` prop correctly
- [ ] Unit tests: button variant/style matrix renders correct classes; progress bar value reflects the `value` prop correctly
**Tests**: unit
**Gate**: quick

#### AT9: Registration + event form components
**What**: Per `design-system-admin.md` §5.8 (dark-fill inputs, thin border, radius verified per input type — `2px` on the one measured text input, don't assume the uniform `6px` card radius applies to every control; **no focus transition observed**, border-color change is an instant snap, not a fade; checkboxes instant/no-transition too, consistent with the a11y-clarity note). Multi-field form components for Venue/Promoter self-registration (name/description/address/contact/image or name/phone/email/Instagram/TikTok) and event creation/edit (image upload, date/time picker, description, location, ticket-link URL with conditional required-when-paid validation, free/paid toggle, genre select, capacity, age rating, notes) — client-side validation mirroring `venue-promoter-admin/design.md`'s Error Handling Strategy, all copy pt-BR.
**Where**: `admin/components/design-system/{RegistrationForm,EventForm}.tsx`
**Depends on**: AT5, AT6
**Reuses**: Corona form-input tokens (AT6), `design-system-admin.md` §5.8
**Requirement**: ADMIN-01, ADMIN-04, ADMIN-05, ADMIN-11, ADMIN-12, ADMIN-15
**Done when**: unit tests — required-field validation blocks submit with field-specific pt-BR errors; ticket-link required only when `is_free` is false; input focus state matches the measured instant (no-transition) border-color change
**Tests**: unit
**Gate**: quick

#### AT10: Consent-capture component + approval-decision modal
**What**: Consent-capture contract shared with `mobile.md`/`website.md` (independent admin-repo implementation, Corona-styled) plus the approve/reject decision modal per `design-system-admin.md` §5.9 — structure confirmed (Default/Authentication/sized variants) but the open/close transition was **not measurable live** during capture; re-measure it against the actual demo before finalizing this component rather than assuming the superseded doc's 150ms/400ms values, since this template's other components snap instantly rather than fade. Content radius should match the uniform `6px` token unless the modal's own dialog measures differently. Optional reason/feedback field (ADMIN-09/ADMIN-18's "optional, not required" rule), footer-right primary/light button pair.
**Where**: `admin/components/design-system/{ConsentCapture,DecisionModal}.tsx`
**Depends on**: AT6, AT8
**Reuses**: same consent contract as `mobile.md` A5; `Button` (AT8); `design-system-admin.md` §5.9
**Requirement**: ADMIN-02, ADMIN-06, ADMIN-09, ADMIN-10, ADMIN-18, ADMIN-19
**Done when**: unit test confirms the modal's fade/transform durations match §5.9's measured values, not an arbitrary guess
**Tests**: unit
**Gate**: quick

### API hooks

#### AT11: Approval-queue hooks (accounts + events) [P]
**What**: `useAccountApprovalQueue()`, `useEventApprovalQueue()` wrapping AT4's client — list + decide actions.
**Where**: `admin/hooks/useApprovalQueues.ts`
**Depends on**: AT4
**Reuses**: AT4
**Requirement**: ADMIN-07–ADMIN-10, ADMIN-16–ADMIN-19
**Tests**: unit
**Gate**: quick

#### AT12: Registration + event CRUD hooks [P]
**What**: `useVenueRegistration()`, `usePromoterRegistration()`, `useEvents()` (CRUD + submit) wrapping AT4's client.
**Where**: `admin/hooks/useRegistration.ts`, `useOrganizerEvents.ts`
**Depends on**: AT4
**Reuses**: AT4
**Requirement**: ADMIN-01–ADMIN-06, ADMIN-11–ADMIN-15, ADMIN-20–ADMIN-22
**Tests**: unit
**Gate**: quick

#### AT13: Approval-queue hooks integration test [P]
**Where**: `admin/hooks/__tests__/useApprovalQueues.integration.test.tsx`
**Depends on**: AT11
**Reuses**: AT11
**Tests**: integration
**Gate**: full

#### AT14: Registration/event hooks integration test [P]
**Where**: `admin/hooks/__tests__/useRegistration.integration.test.tsx`
**Depends on**: AT12
**Reuses**: AT12
**Tests**: integration
**Gate**: full

### Pages

#### AT15: Admin login page [P]
**What**: Per `design-system-admin.md` §5.11 — centered auth card (max-width ~420px) on pure-black body, wordmark, heading/subheading, stacked full-width inputs, full-width uppercase primary "ENTRAR" button, "manter conectado" checkbox + "esqueci minha senha" link row. **No social-login button** — Corona's Facebook-connect button is explicitly not reproduced (§6: QOR-admin has no social login per ARCHITECTURE §2, email/password only for the admin guard).
**Where**: `admin/app/entrar/page.tsx`
**Depends on**: AT6, AT10, AT14
**Requirement**: ARCHITECTURE §2 (admin guard); `design-system-admin.md` §5.11, §6
**Tests**: integration
**Gate**: full

#### AT16: Account-approval queue page [P]
**What**: Per ADMIN-07–ADMIN-10 — list every `Pending Approval` Venue/Promoter with submitted details, approve/reject with optional reason, auditable.
**Where**: `admin/app/aprovacoes/contas/page.tsx`
**Depends on**: AT7, AT10, AT13
**Reuses**: `DataTable`/`StatusPill` (AT7), `DecisionModal` (AT10), `useAccountApprovalQueue` (AT11/AT13)
**Requirement**: ADMIN-07–ADMIN-10
**Done when**: integration test covers approve + reject-with-reason + reject-without-reason
**Tests**: integration
**Gate**: full

#### AT17: Event-approval (publish) queue page [P]
**What**: Per ADMIN-16–ADMIN-19 — list every `Pending Review` event, approve (→`Published`)/reject (→`Draft` + feedback), auditable, including the past-date→`Ended` edge case display.
**Where**: `admin/app/aprovacoes/eventos/page.tsx`
**Depends on**: AT7, AT10, AT13
**Reuses**: same components as AT16
**Requirement**: ADMIN-16–ADMIN-19
**Tests**: integration
**Gate**: full

#### AT18: Venue self-registration page [P]
**What**: Per ADMIN-01–ADMIN-04.
**Where**: `admin/app/cadastro/local/page.tsx`
**Depends on**: AT9, AT10, AT14
**Reuses**: `RegistrationForm` (AT9), `ConsentCapture` (AT10), `useVenueRegistration` (AT12/AT14)
**Requirement**: ADMIN-01–ADMIN-04
**Tests**: integration
**Gate**: full

#### AT19: Promoter self-registration page [P]
**What**: Per ADMIN-05–ADMIN-06.
**Where**: `admin/app/cadastro/promotor/page.tsx`
**Depends on**: AT9, AT10, AT14
**Reuses**: same components as AT18
**Requirement**: ADMIN-05–ADMIN-06
**Tests**: integration
**Gate**: full

#### AT20: Organizer event CRUD + submission pages [P]
**What**: Per ADMIN-11–ADMIN-15, ADMIN-20–ADMIN-22 — event list (own events, `DataTable`+`StatusPill`), create/edit form (`EventForm`), submit-for-review action (`Button`), pending-approval-blocked state clearly shown (ADMIN-03).
**Where**: `admin/app/eventos/page.tsx`, `admin/app/eventos/novo/page.tsx`, `admin/app/eventos/[id]/editar/page.tsx`
**Depends on**: AT7, AT8, AT9, AT10, AT13, AT14
**Reuses**: `EventForm` (AT9), `DataTable`/`StatusPill` (AT7), `Button` (AT8), `useOrganizerEvents` (AT12/AT14)
**Requirement**: ADMIN-11–ADMIN-15, ADMIN-20–ADMIN-22
**Done when**: integration test covers Venue-default-address vs. Promoter-manual-location branching, unapproved-account blocked state, edit/duplicate/cancel actions
**Tests**: integration
**Gate**: full

#### AT21: Dashboard overview page (P2) [P]
**What**: Per ADMIN-26 — stat cards (per-event view/favorite/ticket-click/interested counts, **0/null with a documented-gap note** since those counts depend on later milestones, same caveat as `api.md` T48) + event schedule/history table + donut-widget event-status breakdown + quota-usage progress bar (per `design-system-admin.md` §5.10's QOR mapping — cheap to build now even though Monetization itself is out of scope).
**Where**: `admin/app/dashboard/page.tsx`
**Depends on**: AT6, AT7, AT8, AT13
**Reuses**: `StatCard`/`DonutWidget` (AT7), `ProgressBar` (AT8)
**Requirement**: ADMIN-26
**Tests**: integration
**Gate**: full

#### AT22: Layout/sidebar wiring (sequential)
**What**: Root layout wiring `Sidebar`/`Topbar` (AT6) around all pages above, role-aware nav visibility (Super Admin vs. Venue Admin vs. Promoter).
**Where**: `admin/app/layout.tsx`
**Depends on**: AT15, AT16, AT17, AT18, AT19, AT20, AT21
**Reuses**: AT6
**Requirement**: cross-cutting
**Tests**: integration
**Gate**: full
**Commit**: `feat(admin): wire layout and role-aware navigation for MVP Core pages`

#### AT23: E2E smoke test (sequential)
**What**: One Playwright E2E flow: register a venue → (as Super Admin, separate session) approve the account → (as venue) create + submit an event → (as Super Admin) approve the event → confirm it's visible via `api.md`'s public endpoint.
**Where**: `admin/e2e/mvp-core-smoke.spec.ts`
**Depends on**: AT22
**Requirement**: cross-cutting verification of this file's scope, and of the Venue/Promoter Admin ↔ Event Discovery integration point
**Tests**: integration
**Gate**: full

---

## Parallel Execution Map

```
Phase 1 (Sequential): AT1 → AT2 → AT3 → AT4,AT5 [P, both after AT1]

Phase 2 (Parallel after AT4): AT6 [P] → AT7,AT8 [P] → AT9 [P] → AT10 [P]
  (AT7 depends on AT5,AT6; AT8 depends on AT6; AT9 depends on AT5,AT6; AT10 depends on AT6,AT8)

Phase 3 (Parallel after AT4): AT11 [P] → AT13 ; AT12 [P] → AT14

Phase 4 (Parallel after matching deps): AT15,AT16,AT17,AT18,AT19,AT20,AT21 [P]

Phase 5 (Sequential): AT22 → AT23
```

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| AT1–AT3 | 1 concern each | ✅ Granular |
| AT4, AT5 | 1 client / 1 enum set | ✅ Granular |
| AT6 | Token layer + 2 layout components (cohesive, one theme foundation task) | ✅ Granular |
| AT7 | 4 cohesive components, one shared pattern (stat/metric widgets + table) | ✅ Granular |
| AT8 | 3 cohesive components, one shared pattern (interactive controls + their transitions) | ✅ Granular |
| AT9, AT10 | 1–2 cohesive components each | ✅ Granular |
| AT11–AT14 | 1 hook group + its integration test each | ✅ Granular |
| AT15–AT21 | 1 page (or tightly-scoped page trio for AT20) each | ✅ Granular |
| AT22, AT23 | 1 concern each | ✅ Granular |

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| AT1–AT5 | AT1 chain, AT4/AT5 after AT1 | Phase 1 | ✅ Match |
| AT6 | AT4 | Phase 2 | ✅ Match |
| AT7 | AT4, AT5, AT6 | Phase 2 | ✅ Match |
| AT8 | AT6 | Phase 2 | ✅ Match |
| AT9 | AT5, AT6 | Phase 2 | ✅ Match |
| AT10 | AT6, AT8 | Phase 2 | ✅ Match |
| AT11, AT12 | AT4 | Phase 3 | ✅ Match |
| AT13 | AT11 | Phase 3 | ✅ Match |
| AT14 | AT12 | Phase 3 | ✅ Match |
| AT15 | AT6, AT10, AT14 | Phase 4 | ✅ Match |
| AT16, AT17 | AT7, AT10, AT13 | Phase 4 | ✅ Match |
| AT18, AT19 | AT9, AT10, AT14 | Phase 4 | ✅ Match |
| AT20 | AT7, AT8, AT9, AT10, AT13, AT14 | Phase 4 | ✅ Match |
| AT21 | AT6, AT7, AT8, AT13 | Phase 4 | ✅ Match |
| AT22 | AT15–AT21 | Phase 5 | ✅ Match |
| AT23 | AT22 | Phase 5 | ✅ Match |

All rows ✅.

---

## Test Co-location Validation

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| AT1–AT3 | Scaffolding/CI | none | none | ✅ OK |
| AT4, AT5 | Client/enums | unit | unit | ✅ OK |
| AT6–AT10 | Components | unit | unit | ✅ OK |
| AT11, AT12 | Hooks | unit | unit | ✅ OK |
| AT13, AT14 | Hook integration | integration | integration | ✅ OK |
| AT15–AT21 | Pages | integration | integration | ✅ OK |
| AT22 | Layout | integration | integration | ✅ OK |
| AT23 | E2E | integration | integration | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (MVP Core scope above)

- This file was revised after the user reversed the earlier NIGHTLIFE-GV-for-admin decision — every MVP Core task above sources exclusively from `design-system-admin.md`, and AT6/AT8/AT10 explicitly call out the **measured** (not estimated) animation/transition values so implementation doesn't drift into inventing motion that was never observed on the reference.
- GA4 calls remain excluded from every task in this file, across every milestone.
- AT21 (dashboard) ships with documented zero/null counts for metrics that depend on the Favorites & Social / Notifications milestone — not a silently fabricated number. Milestone 2 below adds no admin UI (see its scope note), so those counts stay 0/null until whichever milestone actually surfaces per-event view/favorite counts on the admin side, which no current feature spec requests.
- `design-system-research/corona-react-admin/DESIGN_SYSTEM.md` (the earlier, narrower "layout-patterns-only" audit) is superseded by `design-system-admin.md` for `qor-admin` purposes — kept in place as historical record, not deleted, but no task above or below should reference it as the source of truth.

---

# Milestone 3: Monetization

**Feature**: `monetization` (MON-01–26).
**Design ref**: `.specs/features/monetization/design.md`
**API contracts**: `.specs/tasks/api.md` Milestone 3 (T90–T106)
**Sequencing note**: cannot start until Milestone 2's PRs merge across all 5 submodules (ROADMAP.md's sequential rule — Milestone 2 itself has no admin-panel tasks, but the rule is still project-wide, not per-repo). Payment gateway integration is out of scope (PRD §8 Q6, unresolved).
**Not in scope here**: Favorites & Social / Notifications have zero admin UI per those design docs — no task below should add friends/favorites/notification-preference UI. That milestone's only touchpoint with `qor-api` (domain events on event change/cancel) is backend-only, already covered in `api.md`.

## Execution Plan — Milestone 3

```
Phase 6 (API client + hooks, parallel after AT4 existing):
  AT4(existing) → AT24 [P] (plan/subscription client extension)
  AT24 → AT25 (hooks) ; AT25 → AT26 (integration test)

Phase 7 (Components, parallel after AT6/AT7/AT8/AT9 existing):
  AT6(existing) → AT27 (Plan CRUD form component)
  AT7(existing) → AT28 (plan comparison table, reuses DataTable)
  AT8(existing) → AT29 (quota-usage widget, reuses ProgressBar per its §5.10 flag)

Phase 8 (Pages, parallel after matching deps):
  AT27,AT10(existing) → AT30 [P] (Plan CRUD pages, Super Admin)
  AT29,AT20(existing, EventForm) → AT31 [P] (at-limit banner + upgrade prompt, modifies event submission)
  AT29 → AT32 [P] (organizer plan/usage view)

Phase 9 (Integration, sequential):
  AT30,AT31,AT32 → AT33 (layout/nav update, modifies AT22) → AT34 (E2E)
```

## Task Breakdown — Milestone 3

#### AT24: API client extension — plan/subscription [P]
**What**: Extend the typed client (AT4) with `api.md` T103/T104's endpoints (admin Plan CRUD, organizer subscription/usage, change-plan/cancel).
**Where**: `admin/lib/api/client.ts` (modify)
**Depends on**: AT4 (existing)
**Reuses**: AT4
**Requirement**: MON-13–MON-23
**Tests**: unit
**Gate**: quick

#### AT25: Plan/subscription hooks
**What**: `usePlans()` (Super Admin CRUD), `useOrganizerSubscription()` (usage, change-plan, cancel [P2]).
**Where**: `admin/hooks/useBilling.ts`
**Depends on**: AT24
**Reuses**: AT24
**Requirement**: MON-13–MON-23
**Tests**: unit
**Gate**: quick

#### AT26: Plan/subscription hooks integration test
**Where**: `admin/hooks/__tests__/useBilling.integration.test.tsx`
**Depends on**: AT25
**Reuses**: AT25
**Tests**: integration
**Gate**: full

#### AT27: Plan CRUD form component
**What**: Name/monthly price/annual price (optional)/publish quota (nullable = unlimited) fields, required-field validation per `design-system-admin.md` §5.8's input styling, Corona-styled per this file's fully-adopted design system (not NIGHTLIFE-GV — same rule as every other admin component).
**Where**: `admin/components/design-system/PlanForm.tsx`
**Depends on**: AT6 (existing)
**Reuses**: AT6's Corona token layer
**Requirement**: MON-13, MON-16
**Done when**: unit test — required-field validation blocks submit with field-specific pt-BR errors
**Tests**: unit
**Gate**: quick

#### AT28: Plan comparison table (reuses `DataTable`, AT7)
**What**: Read-only table of all plans (active + inactive, Super Admin view) using the existing status-pill/table pattern (active=success green, inactive=secondary gray per `design-system-admin.md` §1.2's status-color convention).
**Where**: `admin/components/design-system/PlanTable.tsx`
**Depends on**: AT7 (existing)
**Reuses**: `DataTable` (AT7)
**Requirement**: MON-01, MON-15
**Tests**: unit
**Gate**: quick

#### AT29: Quota-usage widget (reuses `ProgressBar`, AT8)
**What**: "X of Y publicações usadas este mês" progress bar + at-limit visual flag — this is exactly the task `design-system-admin.md` §5.10 flagged as "cheap to build now" when `ProgressBar` was first built in MVP Core.
**Where**: `admin/components/design-system/QuotaUsageWidget.tsx`
**Depends on**: AT8 (existing)
**Reuses**: `ProgressBar` (AT8)
**Requirement**: MON-17–MON-18
**Tests**: unit
**Gate**: quick

#### AT30: Plan CRUD pages (Super Admin only) [P]
**What**: List (`PlanTable`), create/edit (`PlanForm`), deactivate action — gated by the new `PlanPolicy` from `api.md` T103.
**Where**: `admin/app/planos/page.tsx`, `admin/app/planos/novo/page.tsx`, `admin/app/planos/[id]/editar/page.tsx`
**Depends on**: AT27, AT28, AT10 (existing `DecisionModal` pattern reused for the deactivate-confirm step)
**Reuses**: AT27, AT28, AT10
**Requirement**: MON-13–MON-16
**Tests**: integration
**Gate**: full

#### AT31: At-limit banner + upgrade prompt (modifies event submission, AT20) [P]
**What**: Extend the existing organizer event-submission page (AT20) to surface `QuotaUsageWidget`'s at-limit state as a blocking banner with an upgrade-prompt link (to `qor-landingpage`'s plan page — cross-repo external link, not an in-app route) when `api.md` T96's `CheckAndIncrementQuota` rejects a submission.
**Where**: `admin/app/eventos/novo/page.tsx` (modify), `admin/app/eventos/[id]/editar/page.tsx` (modify)
**Depends on**: AT29, AT20 (existing)
**Reuses**: AT20, `QuotaUsageWidget` (AT29)
**Requirement**: MON-08, MON-18
**Done when**: existing AT20 tests still pass, plus a new test for the quota-block response rendering the banner instead of a generic error
**Tests**: integration
**Gate**: full

#### AT32: Organizer plan/usage view [P]
**What**: Per MON-17–MON-18 — current plan name/price/quota, `QuotaUsageWidget`, change-plan picker [P2], cancel action [P2].
**Where**: `admin/app/assinatura/page.tsx`
**Depends on**: AT29
**Reuses**: `QuotaUsageWidget` (AT29), `useOrganizerSubscription` (AT25/AT26)
**Requirement**: MON-17–MON-23
**Tests**: integration
**Gate**: full

#### AT33: Layout/nav update (sequential, modifies AT22)
**What**: Add "Planos" (Super Admin) and "Assinatura" (Venue Admin/Promoter) nav items to the existing `Sidebar` (AT6/AT22).
**Where**: `admin/app/layout.tsx` (modify)
**Depends on**: AT30, AT31, AT32, AT22 (existing)
**Reuses**: AT22
**Requirement**: cross-cutting
**Tests**: integration
**Gate**: full
**Commit**: `feat(admin): wire Monetization pages into role-aware navigation`

#### AT34: E2E smoke test extension (sequential)
**What**: Extend AT23's flow: approve a new venue (confirms free-plan `Subscription` auto-created per `api.md` T100), submit 5 events (confirms count increments), submit a 6th (confirms block + banner), as Super Admin create/edit a plan and confirm it reflects on the landing page (cross-repo check against `landingpage.md`'s Milestone 3 page).
**Where**: `admin/e2e/mvp-core-smoke.spec.ts` (extend, or new `monetization-smoke.spec.ts`)
**Depends on**: AT33
**Reuses**: AT23 (existing)
**Requirement**: cross-cutting verification, MON-04–MON-10
**Tests**: integration
**Gate**: full

## Task Granularity Check — Milestone 3

| Task | Scope | Status |
|---|---|---|
| AT24–AT26 | 1 client extension / hook group / integration test each | ✅ Granular |
| AT27–AT29 | 1 cohesive component each | ✅ Granular |
| AT30–AT32 | 1 page (or tightly-scoped page trio, AT30) each | ✅ Granular |
| AT33, AT34 | 1 concern each | ✅ Granular |

## Diagram-Definition Cross-Check — Milestone 3

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| AT24 | AT4 | Phase 6 | ✅ Match |
| AT25 | AT24 | Phase 6 | ✅ Match |
| AT26 | AT25 | Phase 6 | ✅ Match |
| AT27 | AT6 | Phase 7 | ✅ Match |
| AT28 | AT7 | Phase 7 | ✅ Match |
| AT29 | AT8 | Phase 7 | ✅ Match |
| AT30 | AT27, AT28, AT10 | Phase 8 | ✅ Match |
| AT31 | AT29, AT20 | Phase 8 | ✅ Match |
| AT32 | AT29 | Phase 8 | ✅ Match |
| AT33 | AT30–AT32, AT22 | Phase 9 | ✅ Match |
| AT34 | AT33 | Phase 9 | ✅ Match |

All rows ✅.

## Test Co-location Validation — Milestone 3

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| AT24 | Client | unit | unit | ✅ OK |
| AT25 | Hooks | unit | unit | ✅ OK |
| AT26 | Hook integration | integration | integration | ✅ OK |
| AT27–AT29 | Components | unit | unit | ✅ OK |
| AT30–AT32 | Pages | integration | integration | ✅ OK |
| AT33 | Layout | integration | integration | ✅ OK |
| AT34 | E2E | integration | integration | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (all milestones)

- No Favorites & Social / Notifications UI exists anywhere in this file — those features have no admin-panel surface per their own design docs.
- AT31, AT33 modify existing MVP Core files — confirm original test suites still pass before adding new assertions.
- Every task in this file, across every milestone, sources its visual system from `design-system-admin.md` (Corona), never NIGHTLIFE-GV — this was the explicit, confirmed reversal from earlier in the session and applies uniformly.
- GA4 calls remain excluded from every task in this file, across every milestone.
