# Nightlife GV Stitch Refresh Context (Audit-fix addendum)

**Gathered:** 2026-09-10
**Spec:** `.specs/features/nightlife-gv-stitch-refresh/spec.md`
**Status:** Ready for design

---

## Feature Boundary

This addendum closes gaps found by a Stitch Fidelity Audit run against the built `qor-mobile` app (Android + iOS): 4 concrete bugs, unmet REFRESH-01..04/HUB-01 acceptance criteria despite T24–T40 being marked complete, and — per explicit user decisions — a scope expansion to build previously-deferred content (Profile enrichment, EventDetail enrichment) and add real guest login. Website is not in this addendum's scope (the audit only covered mobile); Design/Tasks should confirm whether the same gaps exist on `qor-website` as a follow-up, not assume they don't.

---

## Implementation Decisions

### Guest access scope

- Unauthenticated visitors can reach Home, Explore, Event Detail, Hub, and Map without logging in — these are already public browsing surfaces (`qor-website` already works unauthenticated for the equivalent pages).
- Tapping Favoritos, Profile, the favorite-heart control on any card, or notifications hard-redirects to Login/Signup — no soft-gated empty/locked state. This mirrors the website's existing `PUBLIC_PATHS` redirect pattern (already an AC under FAVUI-03) rather than inventing a second gating UX.
- No new backend auth guard is needed: this is a client-side change (mobile stops forcing login-on-launch and lets already-public `GET` event endpoints render without a bearer token) — not a new Sanctum guest guard, which `ARCHITECTURE.md`'s two-guard model doesn't have a slot for today.

### Deferred content — build now

- Confirmed via the approved plan: Profile stat pills, `AUTH-20..24`-based favorite-genre chips + search radius, a derived favorite-venues list, recommendations, and a visible logout action all ship this pass — not left as documented deviations.
- EventDetail's organizer card (reusing `venue-promoter-admin`'s existing name/phone/email/Instagram/TikTok fields), related-events carousel, and dual "Ver no Mapa"/"Ver Instagram" pill actions all ship this pass.

### Android + iOS parity

- Every bugfix, fidelity-completion, and scope-expansion story applies to both Android and iOS as one shared AC per story — not Android-only with iOS deferred. The audit only captured iOS Login (tooling-limited), but iOS's screen files (`LoginView`, `SignupView`, `HomeFeedView`, `EventDetailView`, `ProfileView`, `ExploreView`, `PasswordRecoveryView`, `EmailVerificationView`) started from the same pre-fidelity-pass state as Android's, so the same gaps are assumed present until Design/Execute prove otherwise per-screen.

### Agent's Discretion

- Exact recommendation logic (see spec Assumptions: same-city/same-genre upcoming events, no new ranking system) — Design can refine within that bound without a fresh product decision.
- "Favorite venues" as a derived view (venues of the fan's favorited events, deduplicated) rather than a new favoritable entity — Design implements against this definition; flip back to the user only if it proves infeasible against existing data.
- iOS-side root-cause investigation for BUGFIX-01/02/03 (does the same missing-image-loader / unconditional-decode pattern actually exist there, or is iOS's equivalent code already safe?) — resolved during Design/Execute per screen, not assumed identical to Android's exact defect.

### Declined / Undiscussed Gray Areas → Assumptions

- Recommendation algorithm depth, guest session persistence details beyond "no backend guard needed" (e.g. exact local-storage/session-marker mechanism) — not discussed live; logged as Assumptions in spec.md with chosen defaults and rationale, to be confirmed or overridden before/at Design.

---

## Specific References

None beyond the Stitch Fidelity Audit artifact itself and the existing "Nightlife Discovery" Stitch project (`projects/6008587636717635180`) already governing this feature.

---

## Deferred Ideas

- A dedicated backend "favorite venue" entity (vs. the derived-view interpretation used here) — if the derived view proves insufficient, that's new `favorites-social` scope, not this feature's.
- Website-side audit and fix pass — this addendum is mobile-only; website should get its own UAT/audit pass before assuming parity.
