# Roadmap

**Current Milestone:** Monetization
**Status:** P1 DONE (`qor-api` + `qor-admin` + `qor-website`) — MVP Core, Social & Notifications, and Monetization P1 all DONE in `qor-api`. `qor-admin` is fully merged through `.specs/tasks/admin.md`'s Milestone 3 (PRs #3, #4, #5): MVP Core (AT1–AT23 — login, both approval queues, both self-registration pages, organizer event CRUD/submission, dashboard, role-aware layout, E2E smoke test) and Monetization UI (AT24–AT34 — Super Admin Plan CRUD, organizer plan/usage view, publish-quota at-limit gate, E2E smoke test), all working end-to-end in a real browser. `qor-website`'s MVP Core (`.specs/tasks/website.md`) is now also fully merged (PR #1: W1–W10 foundation; PR #2: W11–W24 hooks/pages/layout/E2E) — home/explore/event-detail/login/signup/email-verification/password-recovery/profile all working end-to-end in a real browser, E2E-verified (browse → filter → event detail → signup → OTP verify → login → profile). Building it required adding real OTP (one-time-code) auth to `qor-api` (PRs #19–#21) and fixing the fan guard's SPA session-cookie auth (PR #22, same bug class already fixed for the admin guard). P2 (upgrade/downgrade/cancel, MON-19–23) is deferred — no `qor-api` route exists for it yet. `qor-mobile`'s MVP Core Android track is now fully merged: Shared KMP module (S1–S11, PR #1), Android foundation (A1–A6, PR #2), and every remaining Android screen + nav-graph wiring (A7–A14, plus shared prerequisite S12b, PR #5) — login/signup/email-verification/password-recovery/home-feed/explore/event-detail/basic-profile all working end-to-end against real `shared`-module use cases, `review-kmp-android`-verified (AD-018, AD-021). `qor-mobile`'s iOS foundation (I1–I6 — app/DI wiring, the SwiftUI NIGHTLIFE-GV component library, BottomNav/EmptyState/PlaceholderImage/ConsentCapture/FormFields, PR #6) is merged; only I7–I14 (the iOS screens + nav-graph wiring, mirrors Android's A7–A14) remains for `qor-mobile`'s MVP Core scope. Next: `qor-mobile` I7+, `qor-landingpage` (no feature work yet), or Monetization P2.

---

## MVP Core

**Goal:** A fan can discover and favorite events without login; a Venue or Promoter can self-register, get approved, and publish an event through Super Admin review.
**Target:** v1 launch scope per PRD.md

### Features

**Event Discovery** - DONE (`qor-website`)

- Public event list (soonest-first, paginated, live-updating)
- Event card (image, date/time, description, location, free/paid, favorite)
- Event details page (full description, map, ticket link, tagged promoters, share)
- `qor-website` (Next.js UI): fully merged (W1–W10 foundation, PR #1; W11–W24 hooks/pages/layout/E2E, PR #2) — home feed, explore page, event detail (Google Maps JS API embed, ticket button, share via Web Share API/clipboard) all working end-to-end. Favorite-toggle itself is still API-only (no UI button wired yet — Milestone 2 scope). Known gap: `/` and `/eventos/[id]` are client-rendered with no SSR/`generateMetadata`, so shared links unfurl with generic branding instead of the event's own title/flyer (STATE.md Todo).

**Auth & Fan Profile** - DONE (`qor-website`, basic fields)

- Email/password + Google signup/login, password recovery
- Profile fields (username, contact, address, favorite genres, radius, notification prefs)
- `qor-website`: fully merged (W1–W10, PR #1; W11–W24, PR #2) — signup, login, email verification (OTP), password-recovery wizard (OTP), and a profile page covering basic fields (name/phone/email/picture) plus data-rights actions (export/delete/revoke). Address/favorite-genres/radius/notification-prefs fields are Milestone 2 scope (W35), not yet built. Google login is a disabled placeholder (no OAuth client ID provided yet).

**Venue/Promoter Admin + Approval Workflow** - DONE (`qor-api`)

- Venue self-registration (single-venue) and Promoter self-registration, both `Pending Approval`
- Event creation and `Draft → Pending Review → Published|Rejected → Cancelled|Ended` lifecycle
- Super Admin account-approval queue and event-publish queue
- Venue/Promoter dashboards (views, favorites, ticket-link clicks)
- Admin login (ADMIN-28-30) and Phase 4 event lifecycle (Edit/Duplicate/Cancel) also merged
- `qor-admin` (Next.js UI): fully merged through Milestone 3 — MVP Core (foundation + Corona design-system component library, AT1–AT10, PR #3; hooks/pages/layout wiring/E2E, AT11–AT23, PR #4) and Monetization UI (Plan CRUD, quota usage, at-limit gate, AT24–AT34, PR #5). Every flow works in a real browser, E2E-verified: venue/promoter self-registration → Super Admin account approval → event creation/submission → Super Admin event approval → publicly visible; free-plan auto-subscription → quota increments → at-limit block → Super Admin plan CRUD. P2 (upgrade/downgrade/cancel) deferred.

---

## Social & Notifications

**Goal:** Add the social layer and keep fans engaged after discovery ships.

### Features

**Favorites & Social** - DONE (`qor-api`)

- Mutual friends (request/accept/remove), friends-interested-in-event
- Share (native + in-app to friend)
- Social feed (should-have, ranking unspecified)
- `qor-mobile`/`qor-website` UI not started — this milestone is API-only so far; `spec.md`'s
  requirement-traceability table still reads "In Design" and needs a reconciliation pass

**Notifications** - DONE (`qor-api`)

- Push + email, per-channel opt-out, global silence
- Triggers: nearby favorited event soon, friend interest, new regional events, reminders, event changed/cancelled
- `spec.md`'s requirement-traceability table still reads "In Design" and needs a reconciliation pass

---

## Monetization

**Goal:** QOR generates revenue from Venue/Promoter subscriptions.

### Features

**Publishing Plans & Landing Page** - DONE (`qor-api` P1, MON-01–18; `qor-admin` UI)

- Plan/Subscription domain model, quota enforcement on event submission, default-free-plan grant on account approval, monthly quota reset, Super Admin plan CRUD, organizer usage view
- P2 (MON-19–26: plan upgrade/downgrade, cancellation, annual billing enforcement) deferred — no `qor-api` route exists for it yet
- `qor-admin` (Next.js UI): Plan CRUD pages, quota-usage widget, at-limit gate on event submission, organizer plan/usage view — all merged and E2E-verified (AT24–AT34, PR #5)
- `qor-landingpage` (plan comparison page) not started — that submodule has no feature work yet

- Public landing page (plan comparison, self-registration CTA)
- Free plan (5 publishes/month) + Super-Admin-configurable paid tiers
- Plan enforcement at submission time (quota block + upgrade prompt)
- Super Admin plan CRUD; organizer plan/usage view + upgrade/downgrade/cancel
- Payment gateway integration (gateway TBD — see PRD Open Questions)

---

## Future Considerations

- Search/filter by city or genre in Event Discovery (flagged gap in PRD — may pull forward into MVP Core, see Open Questions)
- Friend suggestions (source mechanism unspecified)
- Distinct non-venue "staff admin" role beneath Super Admin, if multiple Super Admins are needed
