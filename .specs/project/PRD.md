# PRD — QOR: Music Events Platform

**Status:** Draft v1 — based on Miro board `uXjVHCBsiOM=` + stakeholder clarifications, 2026-08-27.

---

## 1. Summary

QOR is a music-event discovery platform for the Greater Vitória region (Vitória, Vila Velha, Serra, Cariacica). It connects fans with venues and promoters across three surfaces — a mobile app, a public website, and an admin panel — backed by a shared API. QOR is **discovery-first, not a ticketing platform**: there's no in-app *ticket* purchase for fans. Paid events link out to whichever external ticketing platform the organizer already uses; free events are supported natively.

QOR's own revenue comes from the organizer side: Venues and Promoters publish events under a **subscription plan** (a free tier with a 5-events/month publish limit, plus paid tiers), sold from a dedicated landing page and managed by the Super Admin.

Target stack (already established in this workspace): mobile app in Kotlin Multiplatform + Compose (Android) / SwiftUI (iOS), website and admin panel in Next.js, API in Laravel. Visual design follows the existing NIGHTLIFE-GV design system (`design-system.md`): dark, high-contrast, four vibrant accent colors.

## 2. Problem & Goals

Fans currently have no single place to discover music events across Greater Vitória's venues and promoters — event info is scattered across each organizer's own Instagram, WhatsApp groups, and word of mouth. Organizers (venues and independent promoters) have no shared tool to publish events, and no visibility into who's interested.

**Goals for v1:**
1. Give fans one app/site to browse upcoming events (soonest first), see full details, favorite events, and see which friends are also going.
2. Let venues and promoters self-register and publish their own events without engineering involvement, subject to moderation.
3. Give a Super Admin full control over the platform: who gets an account, what gets published, and what plans/pricing organizers can buy into.
4. Monetize the organizer side with a free-tier-plus-paid-plans model gating how many events an account can publish per month.
5. Ship deliberately narrow: email/password + Google login only, no ticket payments, single region.

**Non-goals for v1:** in-app *ticket* purchase/payments (fan-facing), Facebook/Instagram login, multi-venue-per-admin-account. (Organizer subscription billing, by contrast, is now in scope — see §5.8.)

## 3. Users & Roles

| Role | Surface | Description |
|---|---|---|
| **Fan** | Mobile app, Website | Browses/searches events, favorites, has friends, gets notified, manages a profile. No approval needed to sign up. |
| **Venue Admin** | Admin panel | Owns exactly **one** venue. Registers the venue, publishes events at it, sees a dashboard. Self-registers, requires Super Admin approval before publishing anything. |
| **Promoter** | Admin panel | Not tied to one venue — can work across many venues/events. Self-registers (name, phone, email, Instagram, TikTok), and — once approved — can independently create and publish events, same as a Venue Admin. Can also be tagged onto a Venue Admin's event as a listed promoter. |
| **Super Admin** | Admin panel | Platform operator. Approves/rejects new Venue and Promoter account registrations. Approves/rejects every event before it goes public. Manages other admin-level accounts. |

## 4. Scope

### In scope (v1)
- Mobile app + website (website mirrors the mobile app's discovery features — listing, details, favorites — as a secondary consumer surface for users without the app) + admin panel.
- Email/password login + Google social login.
- Venue and Promoter self-registration via public signup form, gated by Super Admin approval before the account can publish.
- Event publish workflow with a **pre-publish Super Admin approval gate** (nothing goes live without sign-off).
- Favorites, mutual (add/accept) friends, "friends interested in this event."
- Push + email notifications per the triggers below.
- External link to the organizer's own ticket platform (no in-app checkout for fans).
- A public landing page marketing publishing plans to Venues and Promoters, a free plan (5 publishes/month), one or more paid plans, and Super-Admin-managed plan/pricing configuration.

### Out of scope (deferred)
- Facebook / Instagram login.
- In-app ticket purchase / payments for **fans** (event tickets stay external).
- One admin account managing multiple venues (Venue Admin is single-venue by design; Promoters are the multi-venue role instead).

## 5. Requirements

### 5.1 Event Discovery (mobile + website, no login required)

- Event list sorted with the **soonest upcoming event first**, then further out; only `Published` events appear; past events drop off the default view.
- List supports pagination or infinite scroll, and should reflect new/changed events without a manual app restart.
- **Event card**: featured image, date/time, brief description, location, free/paid indicator, favorite action, tap-through to details.
- **Event details page**: full description, date, time, address, image, genre/category, free/paid indicator, external ticket-link button (paid events only), embedded venue map, list of tagged promoters (name, phone, email, Instagram, TikTok, with direct-contact links), share button. Accessibility info and event rules/notes are supported fields but lower priority.
- *Open gap:* the source material has no search/filter by city or genre, despite the app spanning four cities — likely needed for real usability; recommend confirming before this is dropped from v1.

### 5.2 Favorites & Social (login required)

- Favorite/unfavorite an event; profile page lists favorited events.
- Friends are **mutual**: request → accept, not a one-way follow. Users can add, accept, remove friends, and see a friends list; friend suggestions are a nice-to-have (source mechanism unspecified).
- On an event's card/details page, a fan sees which friends are also interested.
- Users can share an event (native share, or directly to a friend in-app).
- A social feed (friends who favorited, friends interested, popular-among-friends) is a should-have, not fully specified.

### 5.3 Fan Profile & Auth

- Signup/login via email+password or Google only (v1). Password recovery, email verification, standard session handling.
- Profile fields: username, email, phone, profile picture, an address used for nearby-event search (manual entry or device location permission), favorite genres, search radius, notification preferences.

### 5.4 Venue Admin Panel

- **Self-registration**: public signup form (venue name, description, address, contact, image, login credentials). Account starts `Pending Approval` — no event creation or publishing until a Super Admin approves it.
- **Event creation**: featured image, date/time, description, location, external ticket link, free/paid flag, genre, capacity, age rating, additional notes.
- **Event lifecycle**: `Draft → Pending Review → Published | Rejected`, then `Published → Cancelled | Ended`. Submitting for review hands the event to the Super Admin's queue.
- Edit/delete/duplicate own events; view per-event statistics.
- Manage venue profile (name, description, address, contact, image); view event schedule and history.
- Dashboard: interested-user count, views, favorites, ticket-link clicks, per-event performance.

### 5.5 Promoter Panel

- **Self-registration**: same pattern as Venue Admin (name, contact phone, email, Instagram, TikTok, login credentials), same `Pending Approval` gate.
- Unlike the original board's framing (promoters as passive contact info a venue attaches to an event), a Promoter is a **first-class publisher**: once approved, creates and submits their own events through the same lifecycle as a Venue Admin — including entering the venue/location themselves, since they aren't tied to one registered venue.
- Can also be tagged by a Venue Admin onto that venue's own event, without gaining edit rights to it.
- Maintains a public promoter profile shown on event details pages.

### 5.6 Super Admin Panel

- **Account approval queue**: reviews pending Venue and Promoter registrations, approves/rejects (rejection can carry a reason), can suspend an approved account later.
- **Event publish queue**: reviews events in `Pending Review`, approves (→ `Published`) or rejects (→ `Rejected`, with optional feedback back to the organizer).
- Can also intervene on already-published events (e.g., force-cancel) for policy reasons, not just at the initial gate.
- Manages other admin-level platform accounts.

### 5.7 Notifications

- Triggers: favorited event happening soon nearby; a friend marks interest in an event; new events published in the fan's region; reminder as a favorited event's date approaches; an event the fan favorited is changed or cancelled (including Super Admin-forced cancellations).
- Channels: push and email, each independently mutable from the profile; a global "silence alerts" option. Per-trigger granularity is a nice-to-have, not confirmed as required.

### 5.8 Publishing Plans & Landing Page (Venue/Promoter monetization)

Venues and Promoters are QOR's paying customers, not fans. A dedicated public landing page (separate from the fan-facing marketing on the website) sells them on the platform and funnels them into self-registration (§5.4/§5.5), then into a plan.

- **Landing page**: a public, unauthenticated page (part of qor-website) pitching QOR to venues/promoters — value proposition, plan comparison table, "Start free" / "Register your venue" CTA leading into the existing self-registration flow.
- **Free plan**: every self-registered Venue or Promoter account defaults to a free plan capped at **5 event publishes per calendar month**. "Publish" here means the count of events the organizer *submits* into `Pending Review` (i.e., the action they control), not the count of events the Super Admin ends up approving — an organizer shouldn't lose quota to a Super Admin rejection. (Flagged as an assumption — see Open Questions.)
- **Paid plans**: one or more tiers above free, each defined by a higher (or unlimited) monthly publish quota. No plan feature beyond publish quota is specified yet — price/quota per tier is entirely Super-Admin-configured, not hardcoded.
- **Plan enforcement**: when an organizer attempts to submit an event for review and their current-period publish count has reached their plan's quota, submission MUST be blocked with an upgrade prompt back to the landing page/plan picker.
- **Plan management (Super Admin)**: the Super Admin panel MUST expose CRUD for plans — name, monthly price, publish quota, active/inactive toggle — so pricing and quotas can change without a deploy.
- **Subscription lifecycle**: an organizer can view their current plan and usage (X of Y publishes used this period) from the admin panel, and upgrade/downgrade/cancel. Payment collection itself (gateway, invoicing, dunning) is not detailed here — see Open Questions.

## 6. Legal & Compliance — LGPD

The entire platform (mobile app, website, admin panel, API) MUST comply with Brazil's *Lei Geral de Proteção de Dados* (LGPD, Law 13.709/2018). This is a cross-cutting requirement, not a feature module — it constrains how every other section above is built. Personal data appears on every surface: fan profile (§5.3), Venue/Promoter registration (§5.4/§5.5), friends graph (§5.2), and now billing/payment details (§5.8).

- **Legal basis & consent**: every collection point (signup forms, Google login, device-location permission, notification opt-ins) MUST record a lawful basis (typically consent, per LGPD Art. 7) and MUST NOT pre-check optional consent boxes. Location access (used for nearby-event search, §5.3) requires explicit, revocable consent — not bundled into a blanket "accept terms."
- **Privacy policy & terms**: a Portuguese-language privacy policy and terms of service MUST be presented and accepted at signup on every surface (fan, Venue Admin, Promoter), describing what's collected, why, retention period, and third parties data is shared with (Google auth, push notification provider, payment processor for §5.8, map provider for §5.1 venue maps).
- **Data subject rights**: users (fans, Venue Admins, Promoters) MUST be able to exercise LGPD Art. 18 rights from their profile/account settings — access their data, correct it, request deletion ("right to be forgotten"), request portability (export), and revoke consent. Account deletion must cascade correctly (e.g., a deleted fan's favorites/friendships, a deleted Venue's events) rather than leaving orphaned PII.
- **Data minimization**: only collect what each feature actually needs — e.g., §5.3's address is for nearby-event search, not stored/used elsewhere without new consent.
- **Sensitive/minors data**: nightlife events likely carry age ratings (§5.4 `age_rating` field). If under-18 access is possible for some events, age-gating and any data collected from minors needs LGPD Art. 14's stricter handling (parental consent) — flagged for legal review, not resolved here.
- **Data controller responsibilities**: QOR (as controller) needs an identified point of contact for privacy requests (DPO or equivalent, Art. 41), a documented retention/deletion schedule for each entity in §6's data model below, and a breach-notification process (Art. 48) for the Super Admin/ops team.
- **Third-party processors**: Google (login), the push/email notification provider (§5.7), the map provider (§5.1), and the future payment gateway (§5.8) are all LGPD data processors acting on QOR's behalf — each needs a data-processing agreement and to be named in the privacy policy.
- **Data residency**: hosting/storage location for the API and databases should be confirmed against LGPD's cross-border transfer rules (Art. 33) if any infrastructure sits outside Brazil.

## 7. Data Model (high level)

`User` (fan) · `UserAddress` · `UserPreferences` · `Venue` (1:1 with a Venue Admin) · `Promoter` · `Event` (status machine, `created_by_type`: venue_admin\|promoter) · `EventPromoter` (join) · `Favorite` · `Friendship` (status: pending/accepted) · `NotificationPreference` · `ApprovalDecision` (audit trail for account/event approvals) · `Plan` (id, name, price, publish_quota, is_active — Super-Admin-managed) · `Subscription` (venue_id\|promoter_id, plan_id, status, current_period_start/end, publishes_used_this_period).

**PII inventory** (subject to §6): `User` (email, phone, profile picture), `UserAddress` (physical address / geolocation), `Venue`/`Promoter` (contact phone, email, social handles), `Friendship` (social graph), payment details tied to `Subscription` (§5.8, likely tokenized via the payment gateway, not stored raw).

## 8. Open Questions

1. No search/filter across the four cities — is this really out of scope for v1, given the multi-city footprint?
2. Friend-suggestion source (contacts? mutual friends? mutual event interest?) — unspecified.
3. Social feed ranking — unspecified, defaulting to reverse-chronological if not addressed.
4. Whether more than one Super Admin will exist, and if so whether a distinct non-venue "staff admin" role is needed beneath it.
5. Whether a `Rejected` event returns to `Draft` automatically or needs explicit organizer action to resubmit.
6. Payment gateway/processor for organizer subscriptions is unspecified — needs a decision (e.g., Stripe) before billing can be built, and that choice needs its own LGPD data-processing agreement per §6.
7. What exactly counts against the monthly publish quota — submission-to-review (assumed above) vs. Super-Admin-approved/published — needs stakeholder confirmation.
8. Does the free-plan quota reset on the calendar month, or on a rolling 30-day window from signup?
9. What happens to an organizer's already-published events if their paid plan lapses or they downgrade mid-period — do existing events stay live?
10. Are there discounts/annual billing, or is every plan month-to-month at a flat price?
11. Who is QOR's designated DPO/privacy contact (LGPD Art. 41), and where will the API/database infrastructure be hosted (data residency)?
12. Can any event on the platform be relevant to under-18 fans (age-rating field, §5.4), triggering LGPD Art. 14's minors provisions?
13. Retention period per entity (e.g., how long is a deleted user's data kept for legal/audit purposes before hard deletion) is not yet defined.

## 9. Source Material

- Miro board `uXjVHCBsiOM=`: three mind maps ("Mobile App Eventos," "Detalhes e login," "Admin Panel"). All three frames on the board were empty — no wireframes/prototypes yet, requirements only.
- `design-system.md` (NIGHTLIFE-GV) at the workspace root — visual system to design against once UI work starts.
- Stakeholder clarifications captured during this session (single-venue admin scope, promoter self-registration and publish rights, pre-publish Super Admin approval gate, mutual friends model, email/Google-only login for v1, website mirrors mobile app, organizer subscription plans, LGPD compliance).

---

*A more granular, requirement-ID-tagged breakdown of each area above (for task planning / implementation) lives in `.specs/features/*/spec.md` in this same workspace, generated alongside this PRD.*
