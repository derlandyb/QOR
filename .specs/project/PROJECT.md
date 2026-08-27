# QOR

**Vision:** A music-event discovery platform for the Greater Vitória region (Vitória, Vila Velha, Serra, Cariacica) connecting fans with venues and promoters across mobile, web, and admin surfaces.
**For:** Music fans in Greater Vitória (discovery), and Venues/Promoters (publishing, monetized via subscription).
**Solves:** Event info today is scattered across each organizer's own Instagram, WhatsApp groups, and word of mouth — fans have no single place to browse, and organizers have no shared publishing tool or audience visibility.

## Goals

- Give fans one app/site to browse upcoming events (soonest first), see full details, favorite events, and see which friends are also going.
- Let venues and promoters self-register and publish their own events without engineering involvement, subject to Super Admin moderation.
- Give a Super Admin full control: account approvals, event publish approvals, plan/pricing configuration.
- Monetize the organizer side via a free-tier-plus-paid-plans model gating monthly event publishes.
- Ship deliberately narrow for v1: email/password + Google login only, no in-app fan ticket payments, single region.

## Tech Stack

**Core:**

- Mobile: Kotlin Multiplatform + Compose (Android) / SwiftUI (iOS)
- Website + Admin Panel: Next.js
- API: Laravel

**Key dependencies:** Google Sign-In (social login), external ticket platforms (link-out only, no in-app checkout), push + email notification provider, map provider (venue maps), NIGHTLIFE-GV design system (dark, high-contrast, four accent colors).

## Scope

**v1 includes:**

- Mobile app + website (website mirrors mobile's discovery features) + admin panel
- Email/password + Google login
- Venue and Promoter self-registration, gated by Super Admin approval before publishing
- Event publish workflow with a pre-publish Super Admin approval gate
- Favorites, mutual friends, "friends interested in this event"
- Push + email notifications
- External link to organizer's own ticket platform (free events supported natively, no in-app fan checkout)
- Publishing-plans landing page + free/paid tier quotas, Super-Admin-managed pricing

**Explicitly out of scope:**

- Facebook / Instagram login
- In-app ticket purchase/payments for fans
- One admin account managing multiple venues (Venue Admin is single-venue by design)

## Constraints

- Single region: Greater Vitória (four cities) only for v1
- LGPD (Brazil's data protection law) compliance is cross-cutting — consent, data subject rights, data minimization, minors handling, processor agreements, data residency — constrains every surface, not a separate feature
- Narrow v1 auth surface by design (email/password + Google only)
- Payment gateway for organizer subscriptions not yet chosen (see PRD Open Questions)
