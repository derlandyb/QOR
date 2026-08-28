# Event Discovery Specification

## Problem Statement

Fans in Greater Vitória have no single place to find out what's happening across the region's venues and promoters — event info is scattered across each organizer's own Instagram, WhatsApp groups, and word of mouth. Event Discovery is QOR's core value proposition: a fast, no-login browse-and-detail experience that surfaces upcoming events across four cities in one place.

## Goals

- [ ] Fan can see every published upcoming event, soonest first, without creating an account
- [ ] Fan can go from list to full event detail (including how to get tickets) in one tap
- [ ] List reflects newly published/changed events without a manual app restart

## Out of Scope

| Feature | Reason |
|---|---|
| In-app ticket purchase | PRD non-goal — QOR is discovery-first; paid events link to the organizer's own ticket platform |
| Favoriting, "friends interested" | Requires login — covered by the Favorites & Social feature |
| Event creation/editing | Covered by the Venue/Promoter Admin feature |
| Push/email notifications about events | Covered by the Notifications feature |

---

## User Stories

### P1: Browse upcoming events ⭐ MVP

**User Story**: As a fan (logged in or not), I want to see a list of upcoming events soonest-first, so that I can quickly find something happening near me.

**Why P1**: This is the app's core loop — without it there's no discovery product.

**Acceptance Criteria**:

1. WHEN the fan opens the event list THEN system SHALL show only `Published` events, ordered by start date/time ascending (soonest first).
2. WHEN an event's date/time has passed THEN system SHALL exclude it from the default list view.
3. WHEN the list has more events than fit on screen THEN system SHALL support pagination or infinite scroll to load more.
4. WHEN a new event is published or an existing one changes while the fan has the list open THEN system SHALL reflect the change without requiring a manual app restart.
5. WHEN the fan views an event card in the list THEN system SHALL display: featured image, date/time, brief description, location, a free/paid indicator, and a favorite action (favorite action itself gated by login — see Favorites & Social).
6. WHEN the fan taps an event card THEN system SHALL navigate to that event's details page.

**Independent Test**: Load the app with no account, see a soonest-first list of published events, scroll to load more, tap one to reach its details page.

---

### P1: View event details ⭐ MVP

**User Story**: As a fan, I want to see everything about an event on one screen, so that I can decide whether to go and know how to get there or get tickets.

**Why P1**: The list alone doesn't answer "should I go" — details close the loop.

**Acceptance Criteria**:

1. WHEN the fan opens an event's details page THEN system SHALL display full description, date, time, address, image, genre/category, and a free/paid indicator.
2. WHEN the event is paid THEN system SHALL show an external ticket-link button that opens the organizer's own ticket platform.
3. WHEN the event is free THEN system SHALL NOT show a ticket-link button (no external link needed).
4. WHEN the fan opens an event's details page THEN system SHALL display an embedded map for the venue's address.
5. WHEN the event has one or more tagged promoters THEN system SHALL list each promoter's name, phone, email, Instagram, and TikTok, with direct-contact links (e.g., `tel:`, `mailto:`, deep links to Instagram/TikTok).
6. WHEN the fan taps share on the details page THEN system SHALL invoke native share for that event.
7. WHEN accessibility info or event rules/notes exist for the event THEN system SHALL display them (lower priority than the fields above — may render as an optional/collapsed section).

**Independent Test**: From the list, open any event and verify every field above renders correctly for both a free and a paid event.

---

### P1: Search/filter by city or genre ⭐ MVP

**User Story**: As a fan, I want to filter the event list by city or genre, so that I only see events relevant to me across the four cities QOR covers.

**Why P1**: Originally flagged as a likely-needed gap since the Miro source material never specified it despite the app spanning four cities from day one. **Resolved during Design (2026-08-27): pulled into P1** — the list/API is built with filter support from the start rather than retrofitted later.

**Acceptance Criteria**:

1. WHEN the fan applies a city filter THEN system SHALL show only events in that city, among the four Greater Vitória cities (Vitória, Vila Velha, Serra, Cariacica).
2. WHEN the fan applies a genre filter THEN system SHALL show only events in that genre/category.
3. WHEN the fan applies both a city and a genre filter THEN system SHALL show only events matching both (AND, not OR).
4. WHEN the fan clears all filters THEN system SHALL return to the default soonest-first, unfiltered list.
5. WHEN a filter is applied THEN system SHALL preserve soonest-first ordering and pagination/live-update behavior within the filtered set.

---

## Edge Cases

- WHEN no events are published in the fan's view (empty state) THEN system SHALL show a clear empty-state message rather than a blank screen.
- WHEN an event has no featured image THEN system SHALL render a design-system-consistent placeholder image.
- WHEN an event is cancelled (`Cancelled`) after being published THEN system SHALL remove it from the default list and show a cancelled state if reached directly via a deep link or share.
- WHEN an event's status changes to `Ended` THEN system SHALL treat it the same as a past event and exclude it from the default list.
- WHEN the ticket-link URL is malformed or unreachable THEN system SHALL fail gracefully (e.g., show an error toast) rather than crash.
- WHEN a tagged promoter is missing one or more contact fields (phone/email/Instagram/TikTok) THEN system SHALL omit only the missing contact links, not the whole promoter entry.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
|---|---|---|---|
| DISC-01 | P1: Browse upcoming events — soonest-first ordering | Design | In Design |
| DISC-02 | P1: Browse upcoming events — exclude past events | Design | In Design |
| DISC-03 | P1: Browse upcoming events — pagination/infinite scroll | Design | In Design |
| DISC-04 | P1: Browse upcoming events — live-updating list | Design | In Design |
| DISC-05 | P1: Browse upcoming events — event card fields | Design | In Design |
| DISC-06 | P1: Browse upcoming events — card tap → details | Design | In Design |
| DISC-07 | P1: View event details — full detail fields | Design | In Design |
| DISC-08 | P1: View event details — paid ticket-link button | Design | In Design |
| DISC-09 | P1: View event details — free event hides ticket link | Design | In Design |
| DISC-10 | P1: View event details — embedded venue map | Design | In Design |
| DISC-11 | P1: View event details — tagged promoter contacts | Design | In Design |
| DISC-12 | P1: View event details — share | Design | In Design |
| DISC-13 | P1: View event details — accessibility/rules fields | Design | In Design |
| DISC-14 | P1: City filter | Design | In Design |
| DISC-15 | P1: Genre filter | Design | In Design |
| DISC-16 | P1: Combined city+genre filter (AND) | Design | In Design |
| DISC-17 | P1: Clear filters returns to default list | Design | In Design |
| DISC-18 | P1: Filters preserve ordering/pagination/live-update | Design | In Design |

**ID format:** `DISC-[NUMBER]`

**Status values:** Pending → In Design → In Tasks → Implementing → Verified

**Coverage:** 18 total, 0 mapped to tasks, 18 unmapped, 18 In Design ⚠️

---

## Success Criteria

- [ ] A fan with no account can view the full, live, soonest-first event list on first app open
- [ ] A fan can reach any published event's full detail view, including a working ticket link for paid events, in one tap from the list
- [ ] A fan can filter the list by city, by genre, or both, and clear filters back to the default view
- [ ] Zero errors when an event has missing optional fields (image, promoter contact, accessibility notes)
