# Notifications Specification

## Problem Statement

Once fans have favorites and friends, nothing brings them back to the app proactively — a favorited event's date can pass, get cancelled, or a friend can express interest, and the fan only finds out if they happen to check. Notifications close that loop using the channel/silence preferences already captured in Auth & Fan Profile (`AUTH-24`) and the address/radius fields (`AUTH-23`).

## Goals

- [ ] A fan is notified (push and/or email) for each of the PRD's five triggers, scoped to their profile's search radius/address
- [ ] A fan controls delivery via per-channel toggles, a global silence switch, and per-trigger opt-outs
- [ ] No duplicate/spammy notifications for the same underlying event

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---|---|
| SMS channel | PRD §5.7 specifies push + email only |
| Notification history/inbox UI | Not specified in PRD |
| Push/email provider selection (FCM/APNs/SendGrid, etc.) | Infra decision for Design, not Specify |
| In-app chat/messaging | Distinct from one-shot notifications |
| Friend-request flow itself (badges, accept/reject UI) | Covered by Favorites & Social — this feature covers the delivery trigger only |

---

## User Stories

### P1: Favorited event happening soon nearby ⭐ MVP

**User Story**: As a fan, I want to be notified when a favorited event is happening soon nearby, so that I don't miss something I already said I care about.

**Why P1**: PRD §5.7's first listed trigger — core reminder loop the feature exists for.

**Acceptance Criteria**:

1. WHEN a favorited event's date is approaching AND the event falls within the fan's profile search radius/address (`AUTH-23`) THEN system SHALL send a reminder notification via the fan's enabled channels.
2. WHEN a fan has global silence enabled THEN system SHALL suppress this trigger entirely.
3. WHEN a fan has no address/radius set on their profile THEN system SHALL skip this trigger for them rather than notifying about all favorited events indiscriminately.
4. WHEN a fan has already been sent a reminder for a given event THEN system SHALL NOT send a duplicate reminder for the same event/trigger combination.

**Independent Test**: Favorite an event within the profile's radius with a near-term date, confirm a reminder notification is sent once via an enabled channel.

---

### P1: Event changed or cancelled ⭐ MVP

**User Story**: As a fan, I want to be notified when a favorited event's details change or it's cancelled, so that I don't show up to the wrong place or a cancelled event.

**Why P1**: PRD §5.7 explicitly includes Super-Admin-forced cancellations — this is the trigger with the highest cost if missed.

**Acceptance Criteria**:

1. WHEN a favorited event's date, time, or location changes materially THEN system SHALL notify every fan who favorited it via their enabled channels.
2. WHEN a favorited event is cancelled — by its organizer or by a Super Admin force-cancellation — THEN system SHALL notify every fan who favorited it, regardless of who initiated the cancellation.
3. WHEN a fan has disabled the "new events" or "friend interest" triggers but not global silence THEN system SHALL still deliver this trigger, since it concerns an event the fan already committed to.
4. WHEN a fan has global silence enabled THEN system SHALL suppress this trigger like every other.

**Independent Test**: Favorite an event, force-cancel it as Super Admin, and confirm the favoriting fan receives a cancellation notification.

---

### P1: Channel preferences + global silence enforcement ⭐ MVP

**User Story**: As a fan, I want my channel and silence preferences to be respected by every notification, so that I only receive alerts the way I want them.

**Why P1**: Without enforcement, every other trigger story is unusable — a fan who disables push must never receive push.

**Acceptance Criteria**:

1. WHEN any notification is about to be sent THEN system SHALL read the fan's current `AUTH-24` channel preferences (push/email) at send time, not at the time the preference was last changed.
2. WHEN a fan has disabled a channel THEN system SHALL NOT deliver any notification through that channel, regardless of trigger.
3. WHEN a fan has global silence enabled THEN system SHALL suppress all notifications on all channels and all triggers until silence is turned off.
4. WHEN a fan changes a channel or silence preference THEN system SHALL apply it to the next notification attempt, without requiring an app restart.

**Independent Test**: Disable the push channel, trigger a notification-worthy event, and confirm only email (if enabled) is sent, not push.

---

### P2: Friend marks interest in an event

**User Story**: As a fan, I want to be notified when a friend marks interest in an event, so that I can consider going together.

**Why P2**: Adds social engagement value on top of the baseline reminder/cancellation triggers, depends on Favorites & Social's friend graph.

**Acceptance Criteria**:

1. WHEN a mutual friend favorites an event THEN system SHALL notify the fan via their enabled channels, subject to their preferences.
2. WHEN the fan and the friend are no longer mutual friends (removed) THEN system SHALL NOT trigger this notification for future favorites.
3. WHEN a fan has disabled this specific trigger (per-trigger opt-out) but not global silence THEN system SHALL suppress only this trigger, leaving others active.

**Independent Test**: Have a mutual friend favorite an event and confirm the other fan receives a "friend interested" notification.

---

### P2: New events published in the fan's region

**User Story**: As a fan, I want to be notified about new events published near me, so that I discover things I haven't searched for yet.

**Why P2**: Discovery-boosting trigger, not tied to an existing favorite/friend relationship, so it's lower priority than the P1 triggers.

**Acceptance Criteria**:

1. WHEN a new event is `Published` within a fan's profile search radius/address THEN system SHALL notify the fan via their enabled channels.
2. WHEN several qualifying events publish within a short window THEN system SHALL batch them into a consolidated notification rather than sending one per event — **flagged as an assumption**, not confirmed by PRD, needs stakeholder sign-off.
3. WHEN a fan has no address/radius set THEN system SHALL skip this trigger for them.
4. WHEN a fan has disabled this specific trigger (per-trigger opt-out) but not global silence THEN system SHALL suppress only this trigger.

**Independent Test**: Publish a new event within a fan's radius and confirm they receive a notification about it.

---

### P2: Per-trigger opt-out

**User Story**: As a fan, I want to disable individual notification triggers, so that I keep the alerts I value (like cancellations) and mute the ones I don't (like new regional events).

**Why P2**: Extends beyond the PRD's stated baseline (channel + global silence) per this session's decision, giving finer control without adding a new channel.

**Acceptance Criteria**:

1. WHEN a fan opens notification settings THEN system SHALL let them independently toggle each trigger (nearby reminder, event changed/cancelled, friend interest, new regional events) on or off.
2. WHEN a fan disables a specific trigger THEN system SHALL suppress only that trigger, leaving other enabled triggers and channels unaffected.
3. WHEN global silence is enabled THEN system SHALL suppress all triggers regardless of individual per-trigger settings, taking precedence over them.
4. WHEN a fan has set no per-trigger preferences THEN system SHALL default every trigger to enabled (opt-out model, not opt-in).

**Independent Test**: Disable the "new regional events" trigger only, publish a qualifying new event and confirm no notification is sent, then trigger a cancellation and confirm it is still delivered.

---

## Edge Cases

- WHEN a fan has global silence on THEN system SHALL suppress every trigger even if individual channels/triggers are enabled.
- WHEN the same event qualifies for two triggers at once (e.g., nearby reminder AND a friend is interested) THEN system SHALL send one consolidated notification, not two — **flagged as an assumption**, not specified in PRD, needs confirmation before Design.
- WHEN a fan has no address/radius set THEN system SHALL skip geofenced triggers (nearby, regional) rather than notifying about everything or erroring.
- WHEN an event is cancelled by Super Admin override THEN system SHALL still fire the "event changed/cancelled" trigger to fans who favorited it, independent of who cancelled it.
- WHEN a fan disables all per-trigger toggles individually THEN system SHALL behave the same as global silence for that fan (no notifications sent), even though the settings are stored distinctly.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
|---|---|---|---|
| NOTIF-01 | P1: Nearby favorited event soon — reminder sent within radius | Design | In Design |
| NOTIF-02 | P1: Nearby favorited event soon — global silence suppresses | Design | In Design |
| NOTIF-03 | P1: Nearby favorited event soon — skipped with no address/radius | Design | In Design |
| NOTIF-04 | P1: Nearby favorited event soon — no duplicate reminders | Design | In Design |
| NOTIF-05 | P1: Event changed/cancelled — material change notifies favoriters | Design | In Design |
| NOTIF-06 | P1: Event changed/cancelled — cancellation notifies regardless of initiator | Design | In Design |
| NOTIF-07 | P1: Event changed/cancelled — always fires despite other trigger opt-outs | Design | In Design |
| NOTIF-08 | P1: Event changed/cancelled — global silence suppresses | Design | In Design |
| NOTIF-09 | P1: Channel/silence enforcement — reads prefs at send time | Design | In Design |
| NOTIF-10 | P1: Channel/silence enforcement — disabled channel never used | Design | In Design |
| NOTIF-11 | P1: Channel/silence enforcement — global silence suppresses all | Design | In Design |
| NOTIF-12 | P1: Channel/silence enforcement — preference changes apply immediately | Design | In Design |
| NOTIF-13 | P2: Friend interest — notifies on mutual friend favorite | Design | In Design |
| NOTIF-14 | P2: Friend interest — stops after friendship removed | Design | In Design |
| NOTIF-15 | P2: Friend interest — per-trigger opt-out respected | Design | In Design |
| NOTIF-16 | P2: New regional events — notifies within radius | Design | In Design |
| NOTIF-17 | P2: New regional events — batches concurrent publishes | Design | In Design |
| NOTIF-18 | P2: New regional events — skipped with no address/radius | Design | In Design |
| NOTIF-19 | P2: New regional events — per-trigger opt-out respected | Design | In Design |
| NOTIF-20 | P2: Per-trigger opt-out — independent toggle per trigger | Design | In Design |
| NOTIF-21 | P2: Per-trigger opt-out — disabling one leaves others unaffected | Design | In Design |
| NOTIF-22 | P2: Per-trigger opt-out — global silence takes precedence | Design | In Design |
| NOTIF-23 | P2: Per-trigger opt-out — defaults to enabled (opt-out model) | Design | In Design |

**ID format:** `NOTIF-[NUMBER]`

**Status values:** Pending → In Design → In Tasks → Implementing → Verified

**Coverage:** 23 total, 0 mapped to tasks, 23 unmapped, 23 In Design ⚠️

---

## Success Criteria

- [ ] Each of the 5 PRD-listed triggers (§5.7) fires correctly in isolation
- [ ] Global silence suppresses 100% of notifications regardless of other settings
- [ ] No fan without an address/radius receives a geofenced notification

**✅ Resolved during Design (2026-08-27)**: (a) When one event qualifies for two triggers at once for the same fan, system SHALL send **one consolidated notification**, not two — implemented via `NotificationDispatcher`'s `NotificationLog` dedup check (see `notifications/design.md`, ARCHITECTURE.md §6.1). (b) "New regional events" SHALL **batch** concurrent publishes into one digest notification per fan per scan window, not one notification per event — implemented by `DetectRegionalPublishes` (`notifications/design.md`).
