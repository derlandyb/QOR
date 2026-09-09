# Nightlife GV Stitch Refresh Context

**Gathered:** 2026-09-09
**Spec:** `.specs/features/nightlife-gv-stitch-refresh/spec.md`
**Status:** Ready for design

---

## Feature Boundary

Bring `qor-mobile` (Android+iOS) and `qor-website` to visual fidelity with the new Stitch project (`projects/6008587636717635180`), reconciling design tokens against the "Nightlife Discovery" Stitch design system, and shipping three new features the mocks assume exist (Favoritos, Mapa Interativo, Hubs da Grande Vitória) plus fixing mobile's password-recovery step-count gap. `qor-admin`/`qor-landingpage` are out of scope.

---

## Implementation Decisions

### Design system source

- Two design systems are registered on the Stitch project. "Nightlife Discovery" (dark, `#FF2E7E`/`#2EC5FF`/`#FF8A1E`/`#B14EFF`, Space Grotesk+Inter) is the correct one — confirmed by the user after `get_project`'s default response returned the wrong one ("Vix Rock Discovery," a light teal theme).
- Since Nightlife Discovery's hex values already match what's live in `nightlife-gv.css`/`QualORockThemeTokens.kt` almost exactly, this is a **reconciliation pass**, not a token replacement — verify line-by-line, apply only real deltas.

### Hubs vs. Explore

- Hubs da Grande Vitória is a **distinct new surface**, not a replacement for the existing `/eventos` Explore screen. Explore stays untouched by this feature. Reachable as an additional entry point from Home's city selection, alongside the existing `CityGrid`→`/eventos?city=` link.

### Password recovery

- Fix mobile to **real 3-step parity** with the website (email → verify-code → new-password), not just a re-skin of the existing 2-step collapse. This requires a new shared-module use case consuming `qor-api`'s already-existing `/auth/password/verify-code` endpoint (AD-016) — no new backend endpoint needed, only new shared/mobile client-side logic.

### Map backend

- `Event` has no lat/lng today (only free-text `address`). Add real backend geo work in this pass: migration + geocoding + geo query endpoint in `qor-api`, sequenced to merge before any client Map UI task starts (milestone-sequencing rule, `ARCHITECTURE.md` §8.11).

### Hub backend

- No dedicated aggregation/trending endpoint. Build Hubs against the existing `GET /events?city=` filter. A dedicated hub endpoint is explicitly deferred — record as a Todo in `STATE.md`, not built here.

### Agent's Discretion

- Exact typography role-name mapping between Stitch's new role names (`display-hero`, `headline-sm`, `title-card`, `label-venue`, `label-btn`, `label-caps`, `badge-tag`) and the current token objects' role names — map by nearest size+weight during Design; add a genuinely new role only if a screen's structural diff requires it.
- The `sm` radius delta (Stitch 4px vs. current 6px) — kept at current 6px per the reconciliation-not-replacement principle; revisit only if UAT visibly disagrees on a specific screen.
- Exact shape of the new geo query endpoint (bounding-box vs. per-city radius params) — decided in Design once the Google Maps geocoding/query API specifics are checked.

### Declined / Undiscussed Gray Areas → Assumptions

None declined — both gray areas raised (Hubs-vs-Explore, password-recovery step count) were discussed and resolved above. The typography-mapping and radius-delta questions were resolved by the agent as implementation details discoverable from the two token sets directly, not product decisions requiring the user; both are logged in spec.md's Assumptions & Open Questions table.

---

## Specific References

- Stitch screenshots/HTML per screen (`list_screens` on `projects/6008587636717635180`, already retrieved this session) are the visual reference for every existing-screen refresh task — never copy Stitch's Tailwind HTML directly, rewrite idiomatically per client.
- "Nightlife Discovery" design system's full `styleGuidelines`/`designMd` (already retrieved via `list_design_systems`) is the token reference.
- Prior precedent for "preserve animations, don't simplify away" during a visual restyle: AD-017 ("Cena GV" pass).

---

## Deferred Ideas

- A dedicated city-hub aggregation/trending endpoint (per-city counts, "trending in city X") — confirmed out of scope, to be recorded as a Todo in `STATE.md` after implementation.
- Backfilling coordinates for existing events synchronously as part of this pass — the geo backend story only geocodes on create/update going forward; a bulk backfill of existing seed/production events is a separate, smaller follow-up if needed.
