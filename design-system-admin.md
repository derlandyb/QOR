---
name: QOR-ADMIN (Corona)
source: https://demo.bootstrapdash.com/corona-react/modern-vertical/dashboard
captured: 2026-08-27 (full re-navigation — Dashboard, Buttons, Typography, Form Elements, Tables, Badges, Modals, Progress, Login, plus the sidebar's full route inventory)
method: live browser inspection — `getComputedStyle` extraction per component + full-page screenshots
---

# QOR-ADMIN Design System

**Scope**: this is the **admin panel's own, fully-adopted** design system — colors, typography, spacing, radii, motion, and every component below are taken directly from the BootstrapDash "Corona React — Modern Vertical" demo, not from NIGHTLIFE-GV. NIGHTLIFE-GV (`design-system.md`) stays the system for mobile, website, and landing page only. The admin panel (`qor-admin`) is a deliberately distinct visual identity — a dark, data-dense dashboard aesthetic suited to Super Admin/Venue Admin/Promoter workflows (queues, tables, forms, stat cards) rather than a fan-facing nightlife brand.

*(Supersedes the "layout-patterns-only, do-not-adopt-colors" framing in `design-system-research/corona-react-admin/DESIGN_SYSTEM.md` — that earlier pass was scoped before this decision. This file is now the canonical source for `qor-admin`.)*

---

## 1. Colors

### 1.1 Surfaces (dark theme, MEASURED)

| Token | Value | Usage |
|---|---|---|
| `--admin-bg-body` | `#000000` | Page background |
| `--admin-bg-surface` | `#191C24` | Card / sidebar / modal-dialog background |
| `--admin-bg-surface-alt` | `#000000` | Modal content background (measured slightly darker than card) |
| `--admin-border-subtle` | `#2C2E33` (`rgb(44,46,51)`) | Card borders, input borders, table cell borders |
| `--admin-border-hairline` | `rgba(0,0,0,0.176)` | Card outer border (as rendered over surface) |
| `--admin-text-primary` | `#FFFFFF` | Headings, body text, table cell text |
| `--admin-text-secondary` | `#6C7293` (`rgb(108,114,147)`) | Table header text, muted row text |
| `--admin-text-muted` | `#9C9FA6` (`rgb(156,159,166)`) | Captions, secondary heading text |

### 1.2 Semantic accent palette (MEASURED, from the "Single Color Buttons" swatch — the canonical per-name mapping)

| Token | Value | Bootstrap name | Usage |
|---|---|---|---|
| `--admin-primary` | `#0090E7` | Primary | Primary buttons, active nav, links, focus states, "Sign In" CTA |
| `--admin-secondary` | `#E4EAEC` | Secondary | Secondary buttons (light, dark text) |
| `--admin-success` | `#00D25B` | Success | Success buttons, "Approved"/"Completed"/"Published" status |
| `--admin-danger` | `#FC424A` | Danger | Danger buttons, "Rejected"/"Pending"(!) status — see note below |
| `--admin-warning` | `#FFAB00` | Warning | Warning buttons, "In progress"/"Pending Review" status |
| `--admin-info` | `#8F5FE8` | Info | Info buttons, "Fixed"/tertiary status (a purple, not cyan — Corona's own convention) |
| `--admin-light` | `#FFFFFF` | Light | Light buttons |
| `--admin-dark` | `#0D0D0D` | Dark | Dark buttons |

**Naming collision to resolve during implementation**: Corona's own demo tables use "Pending" with the **danger** (red) badge color in one table (`tables/basic-table`) but an **amber/warning** outline pill in another (dashboard's "Order Status" table). QOR's actual status vocabulary should map deliberately, not copy either literally:

| QOR status | Recommended color | Rationale |
|---|---|---|
| `Draft` / `Pending Approval` | `--admin-warning` (amber) | Neutral/in-progress, not yet a verdict |
| `Pending Review` | `--admin-warning` (amber) | Same — awaiting decision |
| `Published` / `Approved` | `--admin-success` (green) | Positive outcome |
| `Rejected` / `Suspended` / `Cancelled` | `--admin-danger` (red) | Negative outcome |
| `Encerrado` (ended, neutral) | `--admin-info` (purple) or `--admin-secondary` (light gray) | Neither positive nor negative — informational only |

### 1.3 Chart/data-viz palette (OBSERVED from progress bars / donut widgets)
Five-color rotation used across progress bars and the dashboard's donut chart: `--admin-success`, `--admin-primary`, `--admin-info`, `--admin-warning`, `--admin-danger` (same 5 semantic accents, reused for data series — no separate chart palette exists).

---

## 2. Typography

**Base font family**: `Rubik, sans-serif` (Google Font — confirm CDN availability / self-host fallback for the admin repo, same consideration as NIGHTLIFE-GV's fonts in `mobile.md` S3).

| Token | Element | Size | Weight | Line-height |
|---|---|---|---|---|
| `--admin-text-h1` | `h1` | 35.04px | 500 | 42.05px |
| `--admin-text-h2` | `h2` | 30px | 500 | 36px |
| `--admin-text-h3` | `h3` | 18px | 500 | 21.6px |
| `--admin-text-h4` | `h4` | 18px | 500 | 21.6px |
| `--admin-text-h5` | `h5` | 16px | 400 | 19.2px |
| `--admin-text-h6` | `h6` | 15px | 500 | 18px |
| `--admin-text-body` | `p`, base | 14px | 400 | 14px (tight — verify against real content, may need 1.4–1.5× in practice) |
| `--admin-text-base` | `body` default | 16px | 400 | — |
| `--admin-text-small` | secondary/faded heading text | ~30.66px in the demo's specific "secondary text" heading pairing, but functionally a **muted color variant**, not a distinct size scale — treat as `color: var(--admin-text-muted)` applied inline to headings, not a separate type-scale rung |

All headings render white (`--admin-text-primary`) at weight 500 (h1–h4) or the body's default 400 (h5). No italic/letter-spacing variation observed except the login page's wordmark (`CORONA`, uppercase + wide letter-spacing — treat as a one-off logo treatment, not a reusable text token).

---

## 3. Spacing & Radii (MEASURED)

| Token | Value | Usage |
|---|---|---|
| `--admin-radius-card` | `4px` | Cards |
| `--admin-radius-input` | `2px` | Text inputs |
| `--admin-radius-select` | `6px` | Select dropdowns |
| `--admin-radius-badge` | `4px` | Status badges/pills (solid-fill variant) |
| `--admin-radius-button` | `3px` | Default buttons |
| `--admin-radius-button-rounded` | `50px` | `.btn-rounded` pill variant (used for the theme-color swatch row, and recommended as QOR-admin's default button shape since it's the more distinctive Corona signature) |
| `--admin-radius-modal` | `8px` | Modal content |
| `--admin-checkbox-radius` | `3.5px` | Checkbox inputs |
| `--admin-sidebar-width` | `244px` | Sidebar (expanded state) |

No explicit spacing scale beyond Bootstrap's default grid gutter was isolated in this pass — component tasks should default to Bootstrap 5's spacing utilities (`p-*`, `m-*`, 0.25rem-based scale) rather than inventing a parallel scale, since the whole template is Bootstrap-based.

---

## 4. Motion & Transitions (MEASURED — real durations/easings, not just "many elements transition")

| Interaction | Properties | Duration | Easing |
|---|---|---|---|
| Button hover/focus (all variants) | `color, background-color, border-color, box-shadow` | `0.15s` | `ease-in-out` |
| Form input focus | `border-color, box-shadow` | `0.15s` | `ease-in-out` |
| Sidebar nav item hover/active | `color` | `0.45s` | `ease-in-out` |
| Modal backdrop show/hide | `opacity` | `0.15s` | `linear` |
| Modal wrapper show/hide | `opacity` | `0.15s` | `linear` |
| Modal dialog show/hide | `transform` (translateY slide-in) | `0.4s` | `ease` |
| Checkbox / label | none | `0s` | — (instant, matches focus-clarity convention also used by NIGHTLIFE-GV) |
| Cards (idle, no hover-lift observed) | none | `0s` | — Corona's cards are flat/static; **any** hover-lift QOR-admin wants on cards would be a QOR-specific addition, not something to fabricate as "already there" |

**Interpretation for component tasks**: motion here is subtle and utilitarian (color/opacity/transform fades on interactive controls), not the "overshoot"/gradient-shift/stagger language of NIGHTLIFE-GV. Every component task below should implement exactly these measured values — 150ms ease-in-out for control state changes, 450ms ease-in-out for nav-link color transitions, 400ms ease modal slide, 150ms linear fades — rather than importing NIGHTLIFE-GV's `--ease-beat`/`--duration-*` tokens, which belong to a different product surface.

---

## 5. Components

### 5.1 Sidebar navigation
Fixed-width (244px) dark (`--admin-bg-surface`) vertical rail. Top: avatar + name + role-subtitle + overflow-menu affordance. "Navigation" section label. Single-column icon+label items, right-side-only pill rounding on the active/hover background (`border-radius: 0 100px 100px 0`), color transition 0.45s ease-in-out (muted `--admin-text-secondary` → `--admin-text-primary`/accent on hover-active). Chevron affordance on items with sub-menus.
**QOR mapping**: Dashboard, Aprovação de Contas, Aprovação de Eventos, Meus Eventos (role-scoped visibility per `admin.md` AT6).

### 5.2 Topbar
Full-width strip above content: hamburger/collapse toggle, search input (pill/bordered, dark fill), primary CTA button (`+ Create New Project` pattern → QOR's `+ Novo Evento`), icon buttons (apps grid, mail, notifications-with-badge-dot), profile dropdown (avatar + name + chevron).

### 5.3 Stat card (KPI tile)
Card (`--admin-radius-card`, `--admin-bg-surface`, no shadow) containing: large numeric value, small colored trend chip (`+3.5%` green / `-2.4%` red, using `--admin-success`/`--admin-danger`), short label, small circular icon button top-right with a directional arrow matching the trend sign.
**QOR mapping**: dashboard KPI row (`admin.md` AT20) — e.g. "Contas pendentes," "Eventos publicados este mês," "Publicações usadas / quota."

### 5.4 Donut/doughnut metric widget
Centered total value inside a segmented ring (segment colors drawn from the 5-color semantic rotation, §1.3), itemized list of contributing rows beneath (label + value, e.g. "Transfer to Paypal — $236").
**QOR mapping**: event-status breakdown (Draft/Pending Review/Published/Cancelled/Encerrado proportions) on the dashboard.

### 5.5 List-style activity widget
Icon-per-row + title/subtitle + relative timestamp + trailing metadata line, "View all" link at the widget header.
**QOR mapping**: recent approval decisions / recently published events feed.

### 5.6 Data table with status pill
Header row (checkbox-select-all + column headers, `--admin-text-secondary`, weight 500), body rows (avatar + name + plain columns + a status badge in the final column). Two observed badge styles — **use the solid-fill variant** (§1.2's badge colors: bg=accent color, text=white, `border-radius: 4px`, `padding: 4px 6px`, `font-size: 12px`, `font-weight: 500`) as the default, since it reads more clearly than the outline variant at small sizes.
**QOR mapping — direct match**: both approval queues (`admin.md` AT15/AT16) and the organizer's own event list (AT19).

### 5.7 Buttons
Six semantic colors (§1.2) × three styles: solid single-color, outlined (transparent bg, colored border+text), rounded/pill (`border-radius: 50px`, otherwise identical to solid). Padding `6px 12px`, `font-size: 15px`, `font-weight: 400`. Transition per §4 (150ms ease-in-out on color/background/border/shadow). **Recommendation**: use the rounded/pill variant as QOR-admin's default — it's Corona's most visually distinctive button treatment and reads cleanly against the dark surface.

### 5.8 Form inputs
Dark fill (`--admin-bg-surface`), 1px `--admin-border-subtle` border, `border-radius: 2px` (text) / `6px` (select), `padding: 13px 20px 11px`, `font-size: 14px`, focus transition 150ms ease-in-out on `border-color, box-shadow`. Checkboxes: white fill, dark border, `border-radius: 3.5px`, no transition (instant, matches the a11y-clarity convention).

### 5.9 Modal
Backdrop: black, 50% opacity, 150ms linear fade. Dialog: `transform` slide, 400ms ease. Content: `border-radius: 8px`, background near-black (`--admin-bg-surface-alt`, `#000000` — measurably darker than the `#191C24` card default). Footer-right button pair (primary "Submit" + light/outline "Cancel").
**QOR mapping**: the approve/reject decision modal (`admin.md` AT9's `DecisionModal`).

### 5.10 Progress bars
Track: dark gray, thin (~6–8px). Fill: one of the 5 semantic accent colors, optional diagonal stripe pattern (`.striped`), optional CSS animation sweeping the stripe (`.animated`) — this is the one clear looping/animated component in the catalog beyond state-transitions, worth extracting the actual `@keyframes` (`progress-bar-stripes`, Bootstrap's stock animation, ~1s linear infinite background-position sweep) if adopted literally rather than re-implemented.
**QOR mapping**: publish-quota usage bar ("3 de 5 publicações usadas este mês" — ties to the Monetization milestone, not MVP Core, but the component itself is worth building now since it's cheap and generic).

### 5.11 Auth card (login/register)
Centered card (max-width ~420px) on pure-black body, wordmark top (uppercase, wide letter-spacing — one-off treatment), heading + subheading, stacked full-width inputs, full-width primary "SIGN IN" button (uppercase label, bold), "remember me" checkbox + "forgot password" link row, secondary full-width social-login button (Facebook-blue in the demo — QOR-admin has no equivalent social login; omit rather than reproduce, since ARCHITECTURE §2 defines only email/password for the admin guard), "create account" footer link.
**QOR mapping**: `admin.md` AT14's login page.

---

## 6. What NOT to carry over

- Corona's Facebook-login button (QOR-admin has no social login per ARCHITECTURE §2 — omit, don't reproduce as dead UI)
- The generic template nav categories not relevant to QOR (RTL, Apps/Kanban/Chat/Email/Calendar, Editors, Maps, Icons showcase, E-commerce, most of "General Pages") — these are template filler pages, not features
- The dashboard's specific sample content (Henry Klein, fake revenue figures, portfolio carousel) — structural pattern only, not literal copy
