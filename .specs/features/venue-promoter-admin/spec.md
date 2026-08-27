# Venue/Promoter Admin + Approval Workflow Specification

## Problem Statement

Venues and independent Promoters have no shared tool to publish events or see who's interested, and today rely on their own Instagram/WhatsApp. QOR's Super Admin needs to gate every new organizer account and every event before it's fan-visible, so nothing goes live without review. This feature is QOR's supply side — without it, Event Discovery has nothing published to show.

## Goals

- [ ] A Venue or Promoter can self-register and, once Super Admin-approved, create and publish events without engineering involvement
- [ ] No event reaches `Published` (fan-visible) without passing through a Super Admin approval gate
- [ ] Super Admin can moderate accounts and events (approve, reject, suspend, force-cancel) entirely from the admin panel

## Out of Scope

| Feature | Reason |
|---|---|
| Fan-facing discovery/favorites of published events | Covered by the Event Discovery and Favorites & Social features |
| Publishing-plan quotas, pricing, and billing | Covered by the Monetization milestone — this feature triggers a quota check on submission but doesn't define plans themselves |
| One admin account managing multiple venues | Explicit PRD non-goal — Venue Admin is single-venue by design |
| Notification delivery for approval/rejection/publish events | Covered by the Notifications feature — this feature only produces the state changes that would trigger them |
| Fan-facing login/profile | Covered by the Auth & Fan Profile feature — Venue/Promoter/Super Admin accounts are a separate credential space |

---

## User Stories

### P1: Venue self-registration ⭐ MVP

**User Story**: As a venue operator, I want to register my venue with QOR, so that I can eventually publish events there.

**Why P1**: Entry point for the entire organizer side — no venue account, no events.

**Acceptance Criteria**:

1. WHEN a venue operator submits the registration form (venue name, description, address, contact, image, login credentials) THEN system SHALL create a `Pending Approval` Venue Admin account.
2. WHEN the registration form is submitted THEN system SHALL present the Portuguese-language privacy policy/terms and require explicit, non-pre-checked consent acceptance before account creation (LGPD Art. 7).
3. WHEN a `Pending Approval` Venue Admin logs in THEN system SHALL allow access to the panel but block event creation/submission and show the pending-approval state clearly.
4. WHEN a venue operator submits a registration with a required field missing THEN system SHALL reject the submission with field-specific errors.

**Independent Test**: Submit venue registration with all required fields, confirm the account is created in `Pending Approval` state and cannot create events.

---

### P1: Promoter self-registration ⭐ MVP

**User Story**: As an independent promoter, I want to register with QOR, so that I can create and publish my own events across venues once approved.

**Why P1**: Promoters are a first-class publisher role, not just contact info — this is their entry point.

**Acceptance Criteria**:

1. WHEN a promoter submits the registration form (name, phone, email, Instagram, TikTok, login credentials) THEN system SHALL create a `Pending Approval` Promoter account.
2. WHEN the registration form is submitted THEN system SHALL present the same Portuguese-language privacy policy/terms and non-pre-checked consent acceptance as Venue registration.
3. WHEN a `Pending Approval` Promoter logs in THEN system SHALL allow access to the panel but block event creation/submission and show the pending-approval state clearly.

**Independent Test**: Submit promoter registration with all required fields, confirm the account is created in `Pending Approval` state and cannot create events.

---

### P1: Super Admin account-approval queue ⭐ MVP

**User Story**: As a Super Admin, I want to review pending Venue and Promoter registrations, so that only legitimate organizers can publish on QOR.

**Why P1**: The gate that makes self-registration safe to allow at all.

**Acceptance Criteria**:

1. WHEN a Super Admin opens the account-approval queue THEN system SHALL list every `Pending Approval` Venue and Promoter account with their submitted registration details.
2. WHEN a Super Admin approves a pending account THEN system SHALL change its status to `Approved` and unblock event creation/submission for it.
3. WHEN a Super Admin rejects a pending account THEN system SHALL change its status to `Rejected` and SHALL allow attaching an optional reason.
4. WHEN an approval or rejection decision is made THEN system SHALL record it as an auditable decision (who, when, outcome, reason if any).

**Independent Test**: From the queue, approve one pending account and reject another with a reason; confirm the approved account can now create events and the rejected one still cannot.

---

### P1: Event creation ⭐ MVP

**User Story**: As an approved Venue Admin or Promoter, I want to create an event, so that I can eventually publish it to fans.

**Why P1**: The core content-creation action of this feature.

**Acceptance Criteria**:

1. WHEN an approved Venue Admin or Promoter creates an event with the required fields (featured image, date/time, description, location, external ticket link if paid, free/paid flag, genre, capacity, age rating, additional notes) THEN system SHALL save it as `Draft`.
2. WHEN a Promoter creates an event THEN system SHALL require them to enter the venue/location themselves, since they aren't tied to one registered venue.
3. WHEN a Venue Admin creates an event THEN system SHALL default the location to their registered venue's address.
4. WHEN an unapproved (`Pending Approval` or `Rejected`) account attempts to create an event THEN system SHALL block the action.

**Independent Test**: As an approved Venue Admin, create an event with all fields and confirm it saves as `Draft`; confirm a `Pending Approval` account cannot do the same.

---

### P1: Submit event for review ⭐ MVP

**User Story**: As an approved Venue Admin or Promoter, I want to submit my draft event for review, so that it can go live once approved.

**Why P1**: The transition that hands content into the moderation gate — without it, `Draft` events never reach fans.

**Acceptance Criteria**:

1. WHEN the organizer submits a `Draft` event with all required fields complete THEN system SHALL transition it to `Pending Review` and place it in the Super Admin's event-publish queue.
2. WHEN the organizer attempts to submit a `Draft` event with a required field missing THEN system SHALL block submission with field-specific errors.
3. WHEN an unapproved account attempts to submit an event THEN system SHALL block the action.

**Independent Test**: Complete a draft event and submit it; confirm it appears in the Super Admin's event-publish queue as `Pending Review`.

---

### P1: Super Admin event-publish queue ⭐ MVP

**User Story**: As a Super Admin, I want to review events submitted for publication, so that nothing goes live without my sign-off.

**Why P1**: The pre-publish approval gate is a hard platform requirement (PRD §5.6) — nothing is fan-visible without it.

**Acceptance Criteria**:

1. WHEN a Super Admin opens the event-publish queue THEN system SHALL list every `Pending Review` event with its full submitted details.
2. WHEN a Super Admin approves a `Pending Review` event THEN system SHALL transition it to `Published`, making it visible to fans (per Event Discovery).
3. WHEN a Super Admin rejects a `Pending Review` event THEN system SHALL transition it back to `Draft` (auto-return — no separate `Rejected` state) and SHALL allow attaching optional feedback that stays visible to the organizer on the event until they resubmit.
4. WHEN an approval or rejection decision is made on an event THEN system SHALL record it as an auditable decision (who, when, outcome, feedback if any).

**Independent Test**: From the queue, approve one pending event and reject another with feedback; confirm the approved event is `Published` and the rejected one is not, with feedback visible to its organizer.

---

### P1: Blocked actions before approval ⭐ MVP

**User Story**: As the platform, I want unapproved organizer accounts fully blocked from publishing, so that moderation can't be bypassed.

**Why P1**: This is the enforcement half of the approval gate — a requirement that cuts across the stories above, so it's stated as its own testable story.

**Acceptance Criteria**:

1. WHEN a `Pending Approval` or `Rejected` Venue/Promoter account attempts to create, edit, or submit an event THEN system SHALL block the action and explain why.
2. WHEN an account's approval status changes from `Approved` to `Rejected` or suspended (see dashboard/suspension story) THEN system SHALL immediately block further event creation/submission for that account, without affecting already-`Published` events unless explicitly force-cancelled by a Super Admin.

**Independent Test**: Attempt event creation/submission as a `Pending Approval` account and confirm every attempt is blocked with a clear message.

---

### P2: Edit/delete/duplicate own events

**User Story**: As a Venue Admin or Promoter, I want to edit, delete, or duplicate my own events, so that I can fix mistakes or reuse a template for a recurring event.

**Why P2**: Quality-of-life for organizers, not required for the first publish loop to work.

**Acceptance Criteria**:

1. WHEN an organizer edits their own `Draft` event (including one that just auto-returned from a Super Admin rejection) THEN system SHALL save the changes.
2. WHEN an organizer edits a `Published` event's non-critical fields (e.g., description, image) THEN system SHALL apply the change without requiring re-review.
3. WHEN an organizer deletes their own event THEN system SHALL remove it, but SHALL NOT allow deleting an event they don't own.
4. WHEN an organizer duplicates one of their own events THEN system SHALL create a new `Draft` copy with the same field values, minus date/time.

**Independent Test**: Edit, duplicate, and delete an owned draft event; confirm a second organizer cannot edit or delete the first organizer's event.

---

### P2: Event cancellation

**User Story**: As an organizer, I want to cancel my own published event, and as a Super Admin, I want to force-cancel any event, so that fans see accurate status when an event doesn't happen.

**Why P2**: Necessary for data accuracy but not part of the initial publish loop.

**Acceptance Criteria**:

1. WHEN an organizer cancels their own `Published` event THEN system SHALL transition it to `Cancelled`.
2. WHEN a Super Admin force-cancels any `Published` event for policy reasons THEN system SHALL transition it to `Cancelled`, independent of the organizer's action.
3. WHEN an event is `Cancelled` THEN system SHALL remove it from the fan-facing default list (per Event Discovery) while remaining reachable via direct link with a cancelled state shown.

**Independent Test**: Cancel a published event as its organizer, and separately force-cancel another as Super Admin; confirm both reach `Cancelled`.

---

### P2: Natural event end

**User Story**: As the platform, I want a published event to automatically reflect that its date has passed, so that stale events don't linger as if upcoming.

**Why P2**: Data-hygiene requirement, not part of the core create-and-publish loop.

**Acceptance Criteria**:

1. WHEN a `Published` event's date/time passes THEN system SHALL transition it to `Encerrado`.
2. WHEN an event is `Encerrado` THEN system SHALL treat it the same as a past event for fan-facing purposes (excluded from default list, per Event Discovery).

**Independent Test**: Confirm a published event with a past date/time is `Encerrado`, not still `Published`.

---

### P2: Promoter tagging

**User Story**: As a Venue Admin, I want to tag a Promoter onto my own event, so that fans see the promoter's contact info without giving them edit rights.

**Why P2**: Enriches event details but isn't required for either role's core publish loop.

**Acceptance Criteria**:

1. WHEN a Venue Admin tags one or more approved Promoters onto their own event THEN system SHALL list those promoters on the event (name, phone, email, Instagram, TikTok) without granting them edit rights to the event.
2. WHEN a tagged Promoter attempts to edit an event they were tagged on but don't own THEN system SHALL block the action.
3. WHEN a Promoter creates their own event THEN system SHALL NOT require tagging, since they publish independently.

**Independent Test**: Tag a promoter onto a venue's event, confirm the promoter's contact info displays, and confirm the tagged promoter cannot edit that event.

---

### P2: Venue/Promoter profile management

**User Story**: As a Venue Admin or Promoter, I want to edit my own venue/promoter profile after registration, so that my public-facing info stays current.

**Why P2**: Account upkeep, not required for the first publish loop.

**Acceptance Criteria**:

1. WHEN a Venue Admin edits their venue profile (name, description, address, contact, image) THEN system SHALL save the changes.
2. WHEN a Promoter edits their profile (name, contact phone, email, Instagram, TikTok) THEN system SHALL save the changes, and the updated profile SHALL reflect on any event details page where they're tagged or listed as organizer.

**Independent Test**: Edit venue/promoter profile fields and confirm they persist and reflect on a related event's details page.

---

### P2: Venue/Promoter dashboard

**User Story**: As a Venue Admin or Promoter, I want a dashboard showing my events' performance, so that I know how fans are engaging.

**Why P2**: Valuable feedback loop for organizers but not required for the create-and-publish loop itself.

**Acceptance Criteria**:

1. WHEN an organizer opens their dashboard THEN system SHALL show, per event: view count, favorite count, ticket-link click count, and interested-user count.
2. WHEN an organizer opens their dashboard THEN system SHALL also show their event schedule/history (all events regardless of status).

**Independent Test**: Confirm a published event with known views/favorites/clicks shows the correct counts on the organizer's dashboard.

---

### P2: Super Admin account suspension

**User Story**: As a Super Admin, I want to suspend an already-approved Venue or Promoter account, so that I can intervene on policy violations after the fact, not just at initial approval.

**Why P2**: An ongoing moderation lever distinct from the initial approval gate.

**Acceptance Criteria**:

1. WHEN a Super Admin suspends an approved Venue/Promoter account THEN system SHALL block that account from creating or submitting further events.
2. WHEN a Super Admin suspends an account THEN system SHALL record the action as an auditable decision.
3. WHEN a Super Admin lifts a suspension THEN system SHALL restore the account's ability to create and submit events.

**Independent Test**: Suspend an approved account, confirm it can no longer create/submit events, then lift the suspension and confirm access is restored.

---

## Edge Cases

- WHEN a venue operator or promoter attempts to register a second time with the same email THEN system SHALL reject the duplicate registration.
- WHEN an event is submitted with a missing required field (e.g., no ticket link on a paid event) THEN system SHALL block submission with a field-specific error rather than accepting it silently.
- WHEN a Super Admin rejects an event or account with no reason/feedback entered THEN system SHALL still allow the rejection (feedback is optional, not required).
- WHEN a Promoter tagged on a Venue Admin's event attempts to edit or delete it THEN system SHALL block the action — tagging never grants edit rights.
- WHEN an event's date/time passes while it's still `Pending Review` (never approved in time) THEN system SHALL NOT auto-publish it — it remains in the queue for an explicit Super Admin decision, and if later approved after its date has passed, system SHALL immediately mark it `Encerrado` rather than showing it as upcoming.
- WHEN an organizer account is suspended THEN system SHALL leave that account's already-`Published` events live and fan-visible unless a Super Admin separately force-cancels them.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
|---|---|---|---|
| ADMIN-01 | P1: Venue self-registration — account creation as Pending Approval | Design | In Design |
| ADMIN-02 | P1: Venue self-registration — terms/consent acceptance | Design | In Design |
| ADMIN-03 | P1: Venue self-registration — pending account blocked from publishing | Design | In Design |
| ADMIN-04 | P1: Venue self-registration — required-field validation | Design | In Design |
| ADMIN-05 | P1: Promoter self-registration — account creation as Pending Approval | Design | In Design |
| ADMIN-06 | P1: Promoter self-registration — terms/consent acceptance | Design | In Design |
| ADMIN-07 | P1: Super Admin account-approval queue — list pending accounts | Design | In Design |
| ADMIN-08 | P1: Super Admin account-approval queue — approve account | Design | In Design |
| ADMIN-09 | P1: Super Admin account-approval queue — reject account with reason | Design | In Design |
| ADMIN-10 | P1: Super Admin account-approval queue — auditable decisions | Design | In Design |
| ADMIN-11 | P1: Event creation — save as Draft with required fields | Design | In Design |
| ADMIN-12 | P1: Event creation — Promoter enters own location | Design | In Design |
| ADMIN-13 | P1: Event creation — unapproved account blocked | Design | In Design |
| ADMIN-14 | P1: Submit event for review — Draft to Pending Review | Design | In Design |
| ADMIN-15 | P1: Submit event for review — required-field validation | Design | In Design |
| ADMIN-16 | P1: Super Admin event-publish queue — list pending events | Design | In Design |
| ADMIN-17 | P1: Super Admin event-publish queue — approve to Published | Design | In Design |
| ADMIN-18 | P1: Super Admin event-publish queue — reject with feedback | Design | In Design |
| ADMIN-19 | P1: Super Admin event-publish queue — auditable decisions | Design | In Design |
| ADMIN-20 | P1: Blocked actions before approval — enforcement across create/edit/submit | Design | In Design |
| ADMIN-21 | P2: Edit/delete/duplicate own events | Design | In Design |
| ADMIN-22 | P2: Event cancellation — organizer and Super Admin force-cancel | Design | In Design |
| ADMIN-23 | P2: Natural event end — Published to Encerrado | Design | In Design |
| ADMIN-24 | P2: Promoter tagging — listed without edit rights | Design | In Design |
| ADMIN-25 | P2: Venue/Promoter profile management | Design | In Design |
| ADMIN-26 | P2: Venue/Promoter dashboard — per-event stats | Design | In Design |
| ADMIN-27 | P2: Super Admin account suspension | Design | In Design |

**ID format:** `ADMIN-[NUMBER]`

**Status values:** Pending → In Design → In Tasks → Implementing → Verified

**Coverage:** 27 total, 0 mapped to tasks, 27 unmapped, 27 In Design ⚠️

---

## Success Criteria

- [ ] A Venue and a Promoter can each self-register, get Super Admin-approved, create an event, and get it published, entirely without engineering involvement
- [ ] No event reaches `Published` without passing through the Super Admin event-publish queue
- [ ] An unapproved or suspended organizer account is blocked from creating or submitting events at every attempt
- [ ] Organizer dashboards show accurate per-event counts matching fan-side activity

**✅ Resolved during Design (2026-08-27)**: A rejected event **auto-returns to `Draft`** — there is no separate `Rejected` event state. The Super Admin's optional feedback stays attached to and visible on the event until the organizer edits and resubmits it. (Event lifecycle is therefore `Draft → Pending Review → Published | Draft (rejected) → Cancelled | Encerrado`, simpler than the PRD's original `Draft → Pending Review → Published | Rejected` sketch.)
