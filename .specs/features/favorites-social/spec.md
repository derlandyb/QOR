# Favorites & Social Specification

## Problem Statement

Fans can already favorite individual events, but discovery is solitary — there's no way to build a friend graph, see who else is going, or pull a friend back into an event they're eyeing. Without this, "friends interested in this event" and any social reason to return to the app don't exist.

## Goals

- [ ] A fan can favorite/unfavorite any published event and see their favorites list
- [ ] A fan can build a mutual (request/accept) friends graph and see who's interested in a given event
- [ ] A fan can share an event natively or directly to a friend in-app

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---|---|
| Friend suggestions | Source mechanism unspecified (PRD Open Q2) — deferred to ROADMAP's Future Considerations |
| One-way following | PRD requires mutual friends only, not asymmetric follow |
| Feed ranking beyond reverse-chronological | No usage data yet to justify ranking logic |
| Notification delivery for friend-interest/share/etc. | Covered by the Notifications feature |
| In-app chat/persistent messaging | Share is a one-off notification, not a conversation thread |

---

## User Stories

### P1: Favorite/unfavorite an event ⭐ MVP

**User Story**: As a fan, I want to favorite or unfavorite an event, so that I can keep track of what I'm interested in and see it reflected in my profile.

**Why P1**: Baseline capability every other story in this spec depends on — friends-interested and social feed both read the favorites a fan has set.

**Acceptance Criteria**:

1. WHEN a fan taps favorite on a `Published` event's card or details page THEN system SHALL mark it favorited and reflect the change immediately on both surfaces.
2. WHEN a fan taps favorite on an event already favorited by them THEN system SHALL unfavorite it (idempotent toggle), not create a duplicate favorite record.
3. WHEN a fan opens their profile THEN system SHALL list every event they've currently favorited.
4. WHEN a favorited event is no longer `Published` (unpublished, rejected, or force-cancelled) THEN system SHALL remove it from the fan's favorites list.

**Independent Test**: Favorite an event from its card, confirm it appears in the profile's favorites list, unfavorite it, and confirm it disappears.

---

### P1: Send a friend request ⭐ MVP

**User Story**: As a fan, I want to send another fan a friend request, so that we can become mutual friends and see each other's interest in events.

**Why P1**: Entry point to the mutual friends graph that every other social story depends on.

**Acceptance Criteria**:

1. WHEN a fan sends a friend request to another fan with no existing relationship between them THEN system SHALL create a `Pending` request visible to the recipient.
2. WHEN a fan sends a request to someone they already have a `Pending` outgoing request to THEN system SHALL block the duplicate rather than creating a second request.
3. WHEN a fan sends a request to someone who already sent them one THEN system SHALL auto-accept and create a mutual friendship instead of two pending requests.
4. WHEN a fan sends a request to someone they're already friends with THEN system SHALL reject the action with a clear "already friends" response.

**Independent Test**: Send a request between two test accounts with no prior relationship, confirm it shows as `Pending` for the recipient only.

---

### P1: Accept/reject a friend request ⭐ MVP

**User Story**: As a fan, I want to accept or reject an incoming friend request, so that I control who I'm mutually connected to.

**Why P1**: Completes the mutual-friend model — a request with no resolution path is not usable.

**Acceptance Criteria**:

1. WHEN a fan accepts a pending incoming request THEN system SHALL create a mutual friendship visible to both fans and remove the `Pending` state.
2. WHEN a fan rejects a pending incoming request THEN system SHALL remove the request without notifying the sender repeatedly and without creating a friendship.
3. WHEN a fan views their pending requests THEN system SHALL show only requests sent to them, not ones they sent.

**Independent Test**: From the recipient account, accept a pending request and confirm both accounts now list each other as friends; repeat with reject and confirm no friendship is created.

---

### P1: Remove a friend ⭐ MVP

**User Story**: As a fan, I want to remove an existing friend, so that I can manage who sees my activity and interest.

**Why P1**: Required complement to add/accept for a usable friends graph.

**Acceptance Criteria**:

1. WHEN a fan removes a friend THEN system SHALL delete the mutual friendship for both sides, not just the initiating fan's view of it.
2. WHEN two fans are no longer friends THEN system SHALL require a fresh friend request (not a "restore") for them to reconnect.
3. WHEN a fan removes a friend THEN system SHALL drop that friend from any "friends interested in this event" display, without deleting the removed friend's own favorite record.

**Independent Test**: Remove a friend from one account, confirm the other account no longer lists them as a friend, and confirm re-adding requires a new request/accept cycle.

---

### P1: View friends list ⭐ MVP

**User Story**: As a fan, I want to see my list of friends, so that I know who I'm connected to on QOR.

**Why P1**: Baseline visibility needed alongside add/accept/remove for the friends graph to be usable.

**Acceptance Criteria**:

1. WHEN a fan opens their friends list THEN system SHALL show only accepted (mutual) friends, not pending or rejected requests.
2. WHEN a fan has no friends yet THEN system SHALL show an empty state, not an error.
3. WHEN a fan's friends list is long THEN system SHALL paginate rather than loading the entire list at once.

**Independent Test**: Load the friends list for an account with several accepted friends and confirm only accepted friends appear, correctly paginated.

---

### P2: Friends interested in an event

**User Story**: As a fan, I want to see which of my friends are interested in an event, so that I can decide whether to go with them.

**Why P2**: Adds the social payoff on top of the baseline favorites/friends mechanics, but the event browsing loop works without it.

**Acceptance Criteria**:

1. WHEN a fan views an event's card or details page THEN system SHALL show which of their mutual friends have also favorited that event.
2. WHEN none of a fan's friends have favorited the event THEN system SHALL show a valid empty state (e.g., no friends-interested section), not an error.
3. WHEN a fan has no friends at all THEN system SHALL omit or gracefully hide the friends-interested section rather than showing a broken empty list.

**Independent Test**: Have two mutual friends favorite the same event, view the event as a third mutual friend, and confirm both are listed as interested.

---

### P2: Share an event

**User Story**: As a fan, I want to share an event natively or directly to a friend in-app, so that I can invite others without leaving QOR.

**Why P2**: Extends reach beyond the friends graph (native share) and gives a direct in-app invite path, but isn't required for the core favorite/friend loop.

**Acceptance Criteria**:

1. WHEN a fan taps share on an event THEN system SHALL offer the device's native share sheet with a deep link to the event.
2. WHEN a fan chooses to share in-app to a specific friend THEN system SHALL send that friend a notification (per their channel/silence preferences) containing a deep link to the event, rather than posting to a shared feed or opening a chat thread.
3. WHEN a fan attempts to share in-app to someone who is no longer their friend (removed/blocked since) THEN system SHALL reject the share with a clear message rather than silently failing or crashing.

**Independent Test**: Share an event in-app to a mutual friend and confirm the friend receives a notification with a working deep link to the event.

---

### P3: Social feed

**User Story**: As a fan, I want a feed of my friends' event activity, so that I can discover events through people I trust without checking each friend individually.

**Why P3**: Nice-to-have on top of the core social mechanics; ranking is intentionally simple (reverse-chronological) for v1 pending real usage data.

**Acceptance Criteria**:

1. WHEN a fan opens their social feed THEN system SHALL show friend activity (favorited an event, marked interest) in reverse-chronological order.
2. WHEN a fan has no friends or no friend activity THEN system SHALL show an empty state, not an error.
3. WHEN a favorited event referenced in the feed is no longer `Published` THEN system SHALL exclude it from the feed rather than showing a dead event.

**Independent Test**: Have a friend favorite an event, open the feed, and confirm the activity appears at the top in chronological order.

---

## Edge Cases

- WHEN a fan sends a friend request to someone who already sent them one THEN system SHALL auto-accept (mutual intent) rather than create two pending requests.
- WHEN a fan removes a friend THEN system SHALL also drop that friend from any "friends interested" display without deleting the other fan's favorite itself.
- WHEN a fan shares an event to a friend who has since blocked/removed them THEN system SHALL fail the share with a clear message (no crash, no silent no-op).
- WHEN an event a fan favorited is later unpublished/rejected/force-cancelled by a Super Admin THEN system SHALL remove it from favorites lists and the social feed rather than showing a dead event.
- WHEN a fan has zero friends THEN system SHALL treat "friends interested" and the social feed as valid empty states, not errors.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
|---|---|---|---|
| FAV-01 | P1: Favorite/unfavorite — toggle favorite state | Design | In Design |
| FAV-02 | P1: Favorite/unfavorite — idempotent re-favorite | Design | In Design |
| FAV-03 | P1: Favorite/unfavorite — profile favorites list | Design | In Design |
| FAV-04 | P1: Favorite/unfavorite — removed when event no longer Published | Design | In Design |
| FAV-05 | P1: Send friend request — create Pending request | Design | In Design |
| FAV-06 | P1: Send friend request — block duplicate outgoing request | Design | In Design |
| FAV-07 | P1: Send friend request — auto-accept on mutual request | Design | In Design |
| FAV-08 | P1: Send friend request — reject if already friends | Design | In Design |
| FAV-09 | P1: Accept/reject request — accept creates mutual friendship | Design | In Design |
| FAV-10 | P1: Accept/reject request — reject removes request cleanly | Design | In Design |
| FAV-11 | P1: Accept/reject request — pending list shows incoming only | Design | In Design |
| FAV-12 | P1: Remove friend — deletes mutual friendship both sides | Design | In Design |
| FAV-13 | P1: Remove friend — reconnection requires fresh request | Design | In Design |
| FAV-14 | P1: Remove friend — dropped from friends-interested display | Design | In Design |
| FAV-15 | P1: View friends list — accepted friends only | Design | In Design |
| FAV-16 | P1: View friends list — empty state | Design | In Design |
| FAV-17 | P1: View friends list — pagination | Design | In Design |
| FAV-18 | P2: Friends interested — show mutual friends who favorited | Design | In Design |
| FAV-19 | P2: Friends interested — empty state, no friends interested | Design | In Design |
| FAV-20 | P2: Friends interested — hidden gracefully with zero friends | Design | In Design |
| FAV-21 | P2: Share event — native share sheet with deep link | Design | In Design |
| FAV-22 | P2: Share event — in-app share sends friend a notification | Design | In Design |
| FAV-23 | P2: Share event — reject share to non-friend | Design | In Design |
| FAV-24 | P3: Social feed — reverse-chronological friend activity | Design | In Design |
| FAV-25 | P3: Social feed — empty state | Design | In Design |
| FAV-26 | P3: Social feed — excludes unpublished events | Design | In Design |

**ID format:** `FAV-[NUMBER]`

**Status values:** Pending → In Design → In Tasks → Implementing → Verified

**Coverage:** 26 total, 0 mapped to tasks, 26 unmapped, 26 In Design ⚠️

---

## Success Criteria

- [ ] A fan can go from "no friends" to "friend accepted, see them on a shared favorited event" in one sitting
- [ ] Removing/re-adding a friend behaves correctly with no orphaned pending requests
- [ ] Zero events shown in a favorites list or feed that aren't currently `Published`

**Carried into Design as-is**: social feed ranking is reverse-chronological, per this spec's stated decision — `favorites-social/design.md`'s `GetSocialFeed` implements it on that basis. PRD §8 Open Question #3 still leaves it formally unconfirmed by stakeholders; this Design pass does not have authority to close that out, so it's inherited rather than newly resolved. Revisit if stakeholder feedback surfaces before Tasks/Execute.
