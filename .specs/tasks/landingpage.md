# Landing Page Tasks — `landingpage` (Next.js)

**Submodule**: `qor-landingpage` (git remote name) — checked out locally as `landingpage/`
**Design refs**: none yet — the Monetization feature (`.specs/features/monetization/`) owns this repo's actual content (publishing-plans pricing page) but is **out of scope this milestone** per ROADMAP.md's sequential-milestone rule
**Architecture ref**: `.specs/project/ARCHITECTURE.md`; design system: `design-system.md` (NIGHTLIFE-GV)
**Status**: Draft
**Milestone**: MVP Core — **narrow scope**. This file only covers repo scaffolding and the shared NIGHTLIFE-GV design-system component package, explicitly requested by the user for the landing page even though its actual pricing/plan pages don't exist until the Monetization milestone starts. **Do not add plan/pricing pages under this file** — that's `monetization/design.md`'s job once that milestone opens.

**Test coverage**: no `TESTING.md` yet (greenfield). Same test-type-per-layer convention as `website.md`.

**Tools (all tasks, unless overridden, confirmed with user)**: MCP `context7` (Next.js/React API lookups), `github` (PR creation) / Skill `NONE`.

---

## Execution Plan

```
Phase 1 (Foundation, sequential): L1 → L2 → L3

Phase 2 (Design-system component library, parallel after L3):
  L3 ──┬→ L4 ─┐
       ├→ L5 ─┤
       └→ L6 ─┘

Phase 3 (Placeholder landing page, sequential):
  L4,L5,L6 → L7
```

---

## Task Breakdown

#### L1: Scaffold `landingpage` Next.js repo
**What**: Next.js (App Router) + TypeScript + Tailwind CSS scaffold — separate repo from `website` per ARCHITECTURE §1 ("distinct from `qor-website`").
**Where**: `landingpage/`
**Depends on**: None
**Reuses**: n/a
**Requirement**: ARCHITECTURE §1
**Done when**: `npm run dev` serves a default page; `npm run build` succeeds
**Tests**: none
**Gate**: build

#### L2: Docker Compose service + root Makefile wiring
**Where**: `docker-compose.yml` (root), `Makefile` (root)
**Depends on**: L1
**Requirement**: ARCHITECTURE §8.1
**Tests**: none
**Gate**: build

#### L3: CI workflow (lint/test/build gate)
**Where**: `.github/workflows/landingpage-ci.yml` (in `qor-landingpage` repo)
**Depends on**: L1, L2
**Requirement**: ARCHITECTURE §8.2, §8.4
**Tests**: none
**Gate**: build

### Design-system component library (same source as `website.md`, independent repo — no shared package infra exists in ARCHITECTURE.md, so this is a parallel implementation, not an import)

#### L4: Token layer + `EventCard`/CTA button port [P]
**What**: Same Tailwind theme tokens as `website.md` W5/W6/W8, plus the CTA button variants — the landing page is public marketing surface, so its component needs overlap with website's (buttons, cards for feature/plan highlights) more than with mobile/admin-specific pieces.
**Where**: `landingpage/lib/enums/`, `landingpage/components/design-system/{EventCard,CtaButton}.tsx`, `landingpage/styles/nightlife-gv.css`
**Depends on**: L3
**Reuses**: `design-system.md` §2–4, same source `website.md` W5/W6/W8 pull from (independent port, no shared npm package exists to import from — ARCHITECTURE.md doesn't define monorepo/package-sharing infra, so this is intentionally duplicated, not a bug)
**Requirement**: user request — design-system components for the landing page
**Tests**: unit
**Gate**: quick

#### L5: `NavBar`/footer components [P]
**What**: Marketing-site nav bar and footer per `design-system.md`'s showcase pattern (logo mark + wordmark, nav links) adapted for a single-page marketing site.
**Where**: `landingpage/components/design-system/{NavBar,Footer}.tsx`
**Depends on**: L3
**Reuses**: `design-system.md` showcase nav pattern
**Requirement**: user request — design-system components for the landing page
**Tests**: unit
**Gate**: quick

#### L6: Form input + consent-capture components [P]
**What**: Same contract as `website.md` W8/W10, independent implementation — needed for a future contact/lead-capture form even before Monetization's real plan-signup forms exist.
**Where**: `landingpage/components/design-system/{FormField,ConsentCapture}.tsx`
**Depends on**: L3
**Reuses**: same contract as `website.md` W8/W10
**Requirement**: user request — design-system components for the landing page
**Tests**: unit
**Gate**: quick

#### L7: Placeholder landing page (sequential)
**What**: A single `/` page assembling L4–L6's components into a minimal "QOR para organizadores — em breve" (coming soon) holding page — proves the component library renders correctly together, without inventing Monetization-scope content (no pricing tiers, no plan comparison — that's explicitly out of scope per this file's header).
**Where**: `landingpage/app/page.tsx`
**Depends on**: L4, L5, L6
**Reuses**: L4, L5, L6
**Requirement**: cross-cutting verification of this file's narrow scope
**Done when**: page renders with `NavBar`/`Footer`, at least one `CtaButton`, no broken component references; integration test confirms it
**Tests**: integration
**Gate**: full
**Commit**: `feat(landingpage): scaffold repo and design-system component library`

---

## Parallel Execution Map

```
Phase 1 (Sequential): L1 → L2 → L3
Phase 2 (Parallel after L3): L4, L5, L6 [P]
Phase 3 (Sequential): L7 (after L4, L5, L6)
```

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| L1–L3 | 1 concern each | ✅ Granular |
| L4–L6 | 1–2 cohesive components each | ✅ Granular |
| L7 | 1 page | ✅ Granular |

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| L1–L3 | sequential chain | Phase 1 | ✅ Match |
| L4, L5, L6 | L3 | Phase 2 | ✅ Match |
| L7 | L4, L5, L6 | Phase 3 | ✅ Match |

All rows ✅.

---

## Test Co-location Validation

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| L1–L3 | Scaffolding/CI | none | none | ✅ OK |
| L4–L6 | Components | unit | unit | ✅ OK |
| L7 | Page | integration | integration | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (MVP Core scope above)

- MVP Core deliberately shipped only scaffolding + the design-system component library + a placeholder page — no pricing content. Milestone 3 below is exactly the promised follow-up.

---

# Milestone 3: Monetization

**Feature**: `monetization` (MON-01–03 — the landing page's actual scope; MON-04 onward are `api.md`/`admin.md` concerns).
**Design ref**: `.specs/features/monetization/design.md`
**API contract**: `.specs/tasks/api.md` T102 (`GET /api/v1/plans`, public)
**Sequencing note**: cannot start until Milestone 2's PRs merge across all 5 submodules (ROADMAP.md's sequential rule — this repo has no Milestone 2 tasks of its own, but the project-wide rule still applies).
**Not in scope here**: payment/checkout — this page pitches plans and routes into self-registration (`admin.md`'s AT18/AT19), it never collects payment (PRD §8 Q6 unresolved, explicitly deferred per `monetization/spec.md`).

## Execution Plan — Milestone 3

```
Phase 4 (sequential, replaces the placeholder page):
  L4(existing) → L8 (API client) → L9 (hook) → L10 (plan comparison table component) → L11 (page, replaces L7's placeholder)
```

## Task Breakdown — Milestone 3

#### L8: API client — public plans list
**What**: Typed fetch wrapper for `api.md` T102's `GET /api/v1/plans` (public, no auth).
**Where**: `landingpage/lib/api/client.ts`
**Depends on**: L4 (existing tokens/enums, for typing)
**Reuses**: `api.md` T102's contract
**Requirement**: MON-01
**Tests**: unit
**Gate**: quick

#### L9: `usePlans()` hook
**Where**: `landingpage/hooks/usePlans.ts`
**Depends on**: L8
**Reuses**: L8
**Requirement**: MON-01, MON-03
**Tests**: unit
**Gate**: quick

#### L10: Plan comparison table component
**What**: Renders each active plan's name, monthly price, publish quota, optional annual price (monthly-only display when unset, per MON-25) — built from L4's `EventCard`/`CtaButton` port and L6's `FormField` primitives, not new visual primitives.
**Where**: `landingpage/components/design-system/PlanComparisonTable.tsx`
**Depends on**: L4, L6 (existing)
**Reuses**: L4, L6
**Requirement**: MON-01, MON-24–MON-25
**Done when**: unit test — a plan with no annual price renders monthly-only; a plan with both renders a cycle toggle
**Tests**: unit
**Gate**: quick

#### L11: Landing page (replaces L7's placeholder)
**What**: Real content replacing the "em breve" holding page — hero pitch copy, `PlanComparisonTable` (L10), CTA ("Cadastre seu local" / "Cadastre-se como promoter") routing to `admin.md`'s AT18/AT19 self-registration pages (external cross-repo link — no in-app registration flow lives here).
**Where**: `landingpage/app/page.tsx` (modify, replaces L7's placeholder content)
**Depends on**: L10, L7 (existing)
**Reuses**: L5's `NavBar`/`Footer` (existing), L10
**Requirement**: MON-01–MON-03
**Done when**: integration test — deactivated plan (mocked API response) does not render; CTA link target matches `admin.md`'s registration page URLs exactly, not a placeholder anchor
**Tests**: integration
**Gate**: full
**Commit**: `feat(landingpage): replace placeholder with real plans landing page`

## Task Granularity Check — Milestone 3

| Task | Scope | Status |
|---|---|---|
| L8, L9 | 1 client / 1 hook | ✅ Granular |
| L10 | 1 component | ✅ Granular |
| L11 | 1 page (modification) | ✅ Granular |

## Diagram-Definition Cross-Check — Milestone 3

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| L8 | L4 | Phase 4 | ✅ Match |
| L9 | L8 | Phase 4 | ✅ Match |
| L10 | L4, L6 | Phase 4 | ✅ Match |
| L11 | L10, L7 | Phase 4 | ✅ Match |

All rows ✅.

## Test Co-location Validation — Milestone 3

| Task | Code Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| L8 | Client | unit | unit | ✅ OK |
| L9 | Hook | unit | unit | ✅ OK |
| L10 | Component | unit | unit | ✅ OK |
| L11 | Page | integration | integration | ✅ OK |

No violations.

---

## Notes carried from the Tasks-phase plan (all milestones)

- L11 modifies L7's existing placeholder rather than adding a second competing page — confirm L7's original render-without-broken-references test still passes before layering in real content.
- This file has no Social & Notifications tasks — that milestone has no landing-page surface per its design docs.
- Payment/checkout remains out of scope — L11's CTAs route to self-registration, never to a payment form.
