# Monetization (Publishing Plans & Landing Page) Specification

## Problem Statement

QOR's organizer side (Venues/Promoters) currently has no monetization mechanism — every self-registered account can publish unlimited events for free. QOR needs a plan system that gates monthly event publishes, a public landing page that sells organizers into it, and Super-Admin-configurable pricing/quotas, so the platform can generate revenue from its paying customers (venues and promoters, not fans).

## Goals

- [ ] A public landing page pitches QOR to venues/promoters and funnels them into self-registration and a plan
- [ ] Every organizer account is on exactly one plan at a time, with an enforced monthly publish quota
- [ ] Super Admin can create/edit/deactivate plans (name, monthly price, optional annual price, publish quota) without a deploy
- [ ] An organizer can see their current plan/usage and change plans, entirely within the admin panel (payment collection excluded)

## Out of Scope

| Feature | Reason |
|---|---|
| Payment gateway integration (checkout, invoicing, dunning, tokenized card storage) | Gateway not yet chosen (PRD §8 Q6) — deferred to its own spec once a gateway is decided |
| Fan-facing ticket payments | Explicit PRD non-goal — QOR is discovery-first, tickets stay external |
| Event creation/submission mechanics themselves | Covered by the Venue/Promoter Admin feature — this feature only adds the quota check at submission |
| Notification delivery for quota/plan events (upgrade prompts, renewal reminders) | Covered by the Notifications feature — this feature only produces the triggering state |
| Landing page visual design | Covered by NIGHTLIFE-GV design system application, not a requirement here |

---

## User Stories

### P1: Public plans landing page ⭐ MVP

**User Story**: As a prospective venue operator or promoter, I want to see QOR's plans and pricing on a public page, so that I can decide whether to sign up.

**Why P1**: The top of the organizer acquisition funnel — no landing page, no path into self-registration for someone who isn't already sold on QOR.

**Acceptance Criteria**:

1. WHEN an unauthenticated visitor opens the plans landing page THEN system SHALL display every currently active plan with its name, monthly price, publish quota, and (if set) annual price.
2. WHEN the visitor selects a "Start free" / "Register your venue" CTA THEN system SHALL route them into the existing Venue/Promoter self-registration flow.
3. WHEN a plan is deactivated by the Super Admin THEN system SHALL immediately stop showing it on the landing page, without affecting organizers already subscribed to it.

**Independent Test**: Load the landing page while at least two active plans exist, confirm both display with correct price/quota, and confirm following the CTA lands on the self-registration form.

---

### P1: Default free plan on registration ⭐ MVP

**User Story**: As a newly self-registered Venue or Promoter, I want to automatically start on a free plan, so that I can publish immediately without a purchase step.

**Why P1**: Without an automatic default, no organizer has a plan to be measured against, and quota enforcement has nothing to check.

**Acceptance Criteria**:

1. WHEN a Venue or Promoter account is approved by the Super Admin (per the Venue/Promoter Admin feature's approval workflow) THEN system SHALL create a `Subscription` for that account on the active free plan (5 publishes/month), starting the current calendar-month period.
2. WHEN no plan is flagged as the free/default plan THEN system SHALL block approval and surface a configuration error to the Super Admin rather than leaving the account without a subscription.
3. WHEN an organizer views their plan before ever changing it THEN system SHALL show the free plan and its quota.

**Independent Test**: Approve a newly registered Venue account and confirm a `Subscription` row exists for it on the free plan with a 0-of-5 usage count.

---

### P1: Quota enforcement at submission ⭐ MVP

**User Story**: As the platform, I want to block an organizer from submitting more events than their plan allows in the current period, so that free-tier usage stays bounded and paid tiers have a reason to exist.

**Why P1**: This is the actual monetization lever — without it, plans are cosmetic.

**Acceptance Criteria**:

1. WHEN an organizer submits an event for review (per the Venue/Promoter Admin feature's submit-for-review action) and their current-period publish count is below their plan's quota THEN system SHALL increment the count by 1 and allow the submission to proceed.
2. WHEN an organizer submits an event for review and their current-period publish count has already reached their plan's quota THEN system SHALL block the submission and show an upgrade prompt linking to the plans landing page, and SHALL NOT increment the count.
3. WHEN a submitted event is later rejected or approved by the Super Admin THEN system SHALL NOT adjust the publish count either way — the count reflects submissions, not outcomes (PRD §5.8).
4. WHEN a plan's quota is configured as unlimited THEN system SHALL never block submission for organizers on that plan.

**Independent Test**: On the free plan, submit 5 events successfully, then confirm a 6th submission attempt is blocked with an upgrade prompt and the count stays at 5; confirm a subsequent Super Admin rejection of one of the 5 does not free up quota.

---

### P1: Calendar-month quota reset ⭐ MVP

**User Story**: As an organizer, I want my publish count to reset every month, so that my quota isn't permanently exhausted after one busy month.

**Why P1**: Without a reset, quota enforcement becomes a one-time lifetime cap instead of the intended monthly allowance (PRD §5.8, resolved per user decision: calendar month, not per-organizer rolling window).

**Acceptance Criteria**:

1. WHEN a new calendar month begins THEN system SHALL reset every organizer's current-period publish count to 0, regardless of individual signup date.
2. WHEN an organizer views their usage mid-month THEN system SHALL show counts scoped to the current calendar month only, not cumulative across all time.

**Independent Test**: Set an organizer's count to their plan's quota, advance to the next calendar month, and confirm they can submit again from a count of 0.

---

### P1: Super Admin plan CRUD ⭐ MVP

**User Story**: As a Super Admin, I want to create, edit, and deactivate plans, so that pricing and quotas can change without engineering involvement.

**Why P1**: The mechanism that makes the whole plan system configurable rather than hardcoded (PRD §5.8).

**Acceptance Criteria**:

1. WHEN a Super Admin creates a plan with name, monthly price, publish quota, and optionally an annual price THEN system SHALL save it as active and make it visible on the landing page.
2. WHEN a Super Admin edits an existing plan's price or quota THEN system SHALL apply the change to that plan going forward, without altering the historical usage counts of organizers already subscribed to it.
3. WHEN a Super Admin deactivates a plan THEN system SHALL stop offering it to new signups (landing page and any plan picker) while leaving existing subscribers on it undisturbed.
4. WHEN a Super Admin attempts to save a plan with a missing required field (name, monthly price, or quota) THEN system SHALL reject the submission with a field-specific error.

**Independent Test**: Create a plan, confirm it appears on the landing page; edit its quota and confirm the new value applies to new subscriptions; deactivate it and confirm it disappears from the landing page while an already-subscribed organizer keeps their access.

---

### P1: Organizer plan/usage view ⭐ MVP

**User Story**: As a Venue Admin or Promoter, I want to see my current plan and how much of my quota I've used, so that I know when I'm at risk of being blocked.

**Why P1**: Without visibility, quota enforcement (a hard block) would surprise organizers with no warning.

**Acceptance Criteria**:

1. WHEN an organizer opens their plan/usage view THEN system SHALL show their current plan name, price, quota, and "X of Y publishes used this period."
2. WHEN an organizer is within the current period and has used all of their quota THEN system SHALL visibly flag that they are at their limit, alongside the same upgrade prompt shown at submission-block time.

**Independent Test**: As an organizer with 3 of 5 publishes used, confirm the view shows "3 of 5"; submit 2 more and confirm the view updates to "5 of 5" with the at-limit flag shown.

---

### P2: Plan upgrade/downgrade

**User Story**: As an organizer, I want to switch to a different plan, so that I can get a higher quota (or reduce cost) as my needs change.

**Why P2**: Valuable flexibility but not required for the first plan/quota loop to function.

**Acceptance Criteria**:

1. WHEN an organizer selects a different active plan THEN system SHALL apply the new plan's quota starting at the next calendar-month reset, not retroactively mid-period.
2. WHEN an organizer downgrades to a plan with a lower quota than their current period's publish count THEN system SHALL NOT retroactively block them for the remainder of the current period — the lower quota takes effect at the next reset.
3. WHEN an organizer's plan changes (upgrade or downgrade) THEN system SHALL leave all of that organizer's already-`Published` events live, independent of the plan change.

**Independent Test**: Downgrade an organizer already at their old quota mid-period, confirm they are not blocked until the next calendar-month reset, and confirm their published events remain visible to fans throughout.

---

### P2: Plan cancellation

**User Story**: As an organizer on a paid plan, I want to cancel it, so that I stop being charged and fall back to the free tier.

**Why P2**: Necessary for a complete subscription lifecycle but not required for the initial plan/quota enforcement loop.

**Acceptance Criteria**:

1. WHEN an organizer cancels their paid plan THEN system SHALL keep their current plan/quota active through the end of the current period, then move them to the free plan at the next calendar-month reset.
2. WHEN an organizer's plan reverts to free after cancellation THEN system SHALL leave their already-`Published` events live.

**Independent Test**: Cancel a paid plan mid-period, confirm the organizer keeps the paid quota until month-end, then confirm they're on the free plan the following month.

---

### P2: Annual billing option

**User Story**: As a Super Admin, I want to optionally set a discounted annual price on a plan, so that organizers can commit for a year at a lower effective rate.

**Why P2**: An additional pricing lever, not required for the core monthly plan/quota mechanics to work.

**Acceptance Criteria**:

1. WHEN a Super Admin sets an annual price on a plan THEN system SHALL offer both monthly and annual billing-cycle options for that plan wherever it's presented (landing page, plan picker).
2. WHEN a Super Admin leaves a plan's annual price unset THEN system SHALL only offer the monthly cycle for that plan.
3. WHEN an organizer is on an annual billing cycle THEN system SHALL still apply the calendar-month publish-quota reset the same as a monthly-cycle organizer — billing cycle and quota-reset cadence are independent.

**Independent Test**: Set an annual price on a plan, confirm both cycle options appear on the landing page; confirm an annual-cycle organizer's publish count still resets every calendar month.

---

## Edge Cases

- WHEN an organizer is at exactly their quota and attempts to submit THEN system SHALL block the submission and SHALL NOT increment the count.
- WHEN a Super Admin deactivates the plan an organizer is currently subscribed to THEN system SHALL leave that organizer's existing plan/quota untouched — deactivation only removes the plan from new-signup visibility.
- WHEN an organizer downgrades to a lower-quota plan while already over the new quota for the current period THEN system SHALL NOT retroactively block or unpublish anything — the new quota applies from the next reset only.
- WHEN a free-plan organizer reaches month-end with unused quota THEN system SHALL reset to the same 5/month allotment with no rollover/accumulation.
- WHEN a paid plan lapses (cancellation or, once billing exists, a failed payment) THEN system SHALL leave already-`Published` events live regardless (per user decision), and only gate future submissions under the reverted plan's quota.
- WHEN two Super Admins edit the same plan concurrently THEN system SHALL apply last-write-wins (flagged as an assumption — no optimistic-locking pattern is established elsewhere in the codebase yet).
- WHEN no plan is flagged as the default/free plan at the time of an account approval THEN system SHALL block the approval action with a configuration error rather than approving an account with no subscription.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
|---|---|---|---|
| MON-01 | P1: Public plans landing page — list active plans | Implementing | Done (T10, T20) |
| MON-02 | P1: Public plans landing page — CTA into self-registration | Implementing | Done, API side only (client-side CTA needs `qor-landingpage`, not yet scaffolded) |
| MON-03 | P1: Public plans landing page — deactivated plan hidden | Implementing | Done (T10, T20) |
| MON-04 | P1: Default free plan on registration — Subscription created on approval | Implementing | Done (T14, T18, T24) |
| MON-05 | P1: Default free plan on registration — missing default-plan config blocks approval | Implementing | Done (T14, T18) |
| MON-06 | P1: Default free plan on registration — visible before any change | Implementing | Done (T14, T24) |
| MON-07 | P1: Quota enforcement at submission — under-quota increments and proceeds | Implementing | Done (T15, T19) |
| MON-08 | P1: Quota enforcement at submission — at-quota blocked with upgrade prompt | Implementing | Done (T15, T19) |
| MON-09 | P1: Quota enforcement at submission — approval/rejection doesn't adjust count | Implementing | Done (T19 — `DecideEventApproval.php` verified untouched) |
| MON-10 | P1: Quota enforcement at submission — unlimited-quota plan never blocks | Implementing | Done (T15, T19) |
| MON-11 | P1: Calendar-month quota reset — reset to 0 for all organizers | Implementing | Done (T16, T23) |
| MON-12 | P1: Calendar-month quota reset — usage view scoped to current month | Implementing | Done (T17, T22) |
| MON-13 | P1: Super Admin plan CRUD — create plan | Implementing | Done (T11, T21) |
| MON-14 | P1: Super Admin plan CRUD — edit plan without altering historical usage | Implementing | Done (T12, T21) |
| MON-15 | P1: Super Admin plan CRUD — deactivate plan | Implementing | Done (T13, T21) |
| MON-16 | P1: Super Admin plan CRUD — required-field validation | Implementing | Done (T21) |
| MON-17 | P1: Organizer plan/usage view — show plan, price, quota, usage | Implementing | Done (T17, T22) |
| MON-18 | P1: Organizer plan/usage view — at-limit flag with upgrade prompt | Implementing | Done (T17, T22) |
| MON-19 | P2: Plan upgrade/downgrade — new quota effective next reset | Design | In Design |
| MON-20 | P2: Plan upgrade/downgrade — no retroactive block on downgrade | Design | In Design |
| MON-21 | P2: Plan upgrade/downgrade — published events stay live | Design | In Design |
| MON-22 | P2: Plan cancellation — revert to free at period end | Design | In Design |
| MON-23 | P2: Plan cancellation — published events stay live | Design | In Design |
| MON-24 | P2: Annual billing option — offer both cycles when annual price set | Design | In Design |
| MON-25 | P2: Annual billing option — monthly-only when annual price unset | Design | In Design |
| MON-26 | P2: Annual billing option — quota reset independent of billing cycle | Design | In Design |

**ID format:** `MON-[NUMBER]`

**Status values:** Pending → In Design → In Tasks → Implementing → Verified

**Coverage:** 26 total, 18 mapped and implemented (MON-01–18, P1 — 571 tests passing, PHPStan level 9 clean; pending `review-laravel-api` before merge), 8 unmapped (MON-19–26, P2, deferred)

---

## Success Criteria

- [ ] A new organizer signup lands on the free plan automatically with a visible 0-of-5 usage counter
- [ ] Submitting a 6th event in a calendar month on the free plan is blocked with an upgrade prompt; Super Admin approval/rejection never affects the count
- [ ] Super Admin can change a plan's price/quota and see it reflected on the landing page and in new subscriptions, without a code deploy
- [ ] An organizer whose paid plan lapses or downgrades keeps their already-published events live

**⚠️ Deferred to a future spec**: Payment gateway integration (PRD §8 Q6) — this spec's plan/subscription/quota model is gateway-agnostic by design so that billing can be layered in later without reshaping the `Plan`/`Subscription` entities defined in PRD §7.
