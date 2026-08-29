# Roadmap

**Current Milestone:** Monetization
**Status:** In Progress (`qor-api` P1) — MVP Core and Social & Notifications both DONE in `qor-api`

---

## MVP Core

**Goal:** A fan can discover and favorite events without login; a Venue or Promoter can self-register, get approved, and publish an event through Super Admin review.
**Target:** v1 launch scope per PRD.md

### Features

**Event Discovery** - IN PROGRESS

- Public event list (soonest-first, paginated, live-updating)
- Event card (image, date/time, description, location, free/paid, favorite)
- Event details page (full description, map, ticket link, tagged promoters, share)

**Auth & Fan Profile** - IN PROGRESS

- Email/password + Google signup/login, password recovery
- Profile fields (username, contact, address, favorite genres, radius, notification prefs)

**Venue/Promoter Admin + Approval Workflow** - DONE (`qor-api`)

- Venue self-registration (single-venue) and Promoter self-registration, both `Pending Approval`
- Event creation and `Draft → Pending Review → Published|Rejected → Cancelled|Ended` lifecycle
- Super Admin account-approval queue and event-publish queue
- Venue/Promoter dashboards (views, favorites, ticket-link clicks)
- Admin login (ADMIN-28-30) and Phase 4 event lifecycle (Edit/Duplicate/Cancel) also merged
- `qor-admin` (Next.js UI) not started — this milestone is API-only so far

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

**Publishing Plans & Landing Page** - IN PROGRESS (`qor-api` P1 underway; spec+design already complete)

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
