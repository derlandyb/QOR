---
name: QOR-ADMIN (Corona)
source: https://demo.bootstrapdash.com/corona-tailwind/themes/modern-vertical/index.html
captured: 2026-09-01 (full re-navigation — Dashboard, Widgets, Buttons, Badges, Modals, Progress Bar, Tables, Login — supersedes the 2026-08-27 Corona React capture below)
superseded-source: https://demo.bootstrapdash.com/corona-react/modern-vertical/dashboard (captured 2026-08-27 — kept only as historical context, see AD-010 in STATE.md)
method: live browser inspection — `getComputedStyle` extraction per component + full-page screenshots
---

# QOR-ADMIN Design System

**Scope**: this is the **admin panel's own, fully-adopted** design system — colors, typography, spacing, radii, motion, and every component below are taken directly from the BootstrapDash **"Corona Tailwind — Modern Vertical"** demo, not from NIGHTLIFE-GV. NIGHTLIFE-GV (`design-system.md`) stays the system for mobile, website, and landing page only. The admin panel (`qor-admin`) is a deliberately distinct visual identity — a dark, data-dense dashboard aesthetic suited to Super Admin/Venue Admin/Promoter workflows (queues, tables, forms, stat cards) rather than a fan-facing nightlife brand.

**Why this file changed (2026-09-01)**: the user changed their mind mid-project and asked for the admin design system to be rebuilt from a different member of the same Corona template family — "Corona Tailwind" instead of "Corona React." Both demos share the same underlying Bootstrapdash color palette (verified below — the semantic accent hexes are numerically identical), but typography, radii, button sizing, and motion all diverge because Tailwind's utility classes replace the React demo's Bootstrap/SCSS component styles. `qor-admin` has no application code yet, so this is a pure re-specification, not a migration. See `STATE.md` AD-010 for the decision record.

---

## 1. Colors

### 1.1 Surfaces (dark theme, MEASURED)

| Token | Value | Usage |
|---|---|---|
| `--admin-bg-body` | `#000000` | Page background (`body.bg-black`) |
| `--admin-bg-surface` | `#191C24` | Card / sidebar / dropdown / input background |
| `--admin-text-primary` | `#FFFFFF` | Headings, body text, table cell text |
| `--admin-text-secondary` | table header text, muted row text — same slate-gray family as the Corona React capture; carry forward `#6C7293` pending a fresh measurement if a specific component needs exact precision |
| `--admin-text-muted` | secondary/faded label text — carry forward `#9C9FA6` from the Corona React capture, same caveat as above |

### 1.2 Semantic accent palette (MEASURED on Buttons + Badges + Tables pages — RECONFIRMED identical to the Corona React capture)

| Token | Value | Usage |
|---|---|---|
| `--admin-primary` | `#0090E7` | Primary buttons, active nav, links, focus states, "Login" CTA |
| `--admin-secondary` | `#E4EAEC` | Secondary buttons (light, dark text) |
| `--admin-success` | `#00D25B` (`rgb(0,210,91)`) | Success buttons, "Completed" status |
| `--admin-danger` | `#FC424A` (`rgb(252,66,74)`) | Danger buttons, "Pending" status — see note below |
| `--admin-warning` | `#FFAB00` | Warning buttons, "In progress" status |
| `--admin-info` | `#8F5FE8` | Info buttons, "Fixed" status (a purple, not cyan — Corona's own convention, still holds in the Tailwind build) |
| `--admin-light` | `#FFFFFF` | Light buttons |
| `--admin-dark` | `#0D0D0D` | Dark buttons |

These values were re-measured directly (not assumed) on the Tailwind template's Buttons page (`bg-modern-{color}` utility classes) and reconfirmed against its Tables page status pills — every hex matches the earlier Corona React capture exactly. **The QOR status→color mapping table below is unchanged and still the source of truth:**

| QOR status | Recommended color | Rationale |
|---|---|---|
| `Draft` / `Pending Approval` | `--admin-warning` (amber) | Neutral/in-progress, not yet a verdict |
| `Pending Review` | `--admin-warning` (amber) | Same — awaiting decision |
| `Published` / `Approved` | `--admin-success` (green) | Positive outcome |
| `Rejected` / `Suspended` / `Cancelled` | `--admin-danger` (red) | Negative outcome |
| `Encerrado` (ended, neutral) | `--admin-info` (purple) or `--admin-secondary` (light gray) | Neither positive nor negative — informational only |

### 1.3 Chart/data-viz palette (OBSERVED from progress bars / donut widgets)
Same five-color rotation as before: `--admin-success`, `--admin-primary`, `--admin-info`, `--admin-warning`, `--admin-danger` — reused for data series, no separate chart palette exists in this template either.

---

## 2. Typography

**Base font family (CHANGED from the Corona React capture)**: **no custom Google Font.** The Tailwind build's `<head>` has zero font `<link>` tags — `body` renders Tailwind's default stack: `ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"`. **Confirmed with the user: `qor-admin` adopts this system font stack as-is** — no Rubik, no font loading, matches the live template exactly.

| Token | Element | Size | Weight | Notes |
|---|---|---|---|---|
| `--admin-text-h5-name` | `h5` (e.g. sidebar user name) | 15px | 400 | line-height 15px (tight) |
| `--admin-text-h6-widget` | `h6` (widget titles, e.g. "Projects") | 14px | 700 (bold, not 500) | line-height 20px |
| `--admin-text-stat-value` | KPI stat-card value (e.g. "$12.34") | 24px | 700 (bold) | color `#FFFFFF` |
| `--admin-text-base` | `body` default | 16px | 400 | — |

**Change from the Corona React capture**: headings in this Tailwind build lean on `font-bold` (700) rather than the old doc's uniform 500-weight scale — verify each heading level's actual weight per-component as pages are built rather than assuming a single h1–h6 scale, since Tailwind builds set weight per-element via utility classes (no single cascading rule like the old SCSS-driven demo had).

---

## 3. Spacing & Radii (MEASURED — CHANGED from the Corona React capture)

| Token | Value | Usage |
|---|---|---|
| `--admin-radius-default` | `6px` (`rounded-md`) | **Uniform** across cards, buttons, badges, form inputs (text) — the Tailwind build collapsed the old doc's per-component 2–4px mix into one shared radius token |
| `--admin-radius-select` | `2px` observed on a plain text input in this build — verify per input type as components are built; do not assume uniform 6px for every form control | |
| `--admin-radius-button-rounded` | `9999px` (`rounded-full`) | `.rounded` pill button variant — same visual effect as the old doc's `50px`, still recommended as QOR-admin's default button shape (Corona's most distinctive treatment) |
| `--admin-sidebar-width` | `244px` | Sidebar (expanded state) — unchanged |
| `--admin-button-min-width` | `128px` (`min-w-32`) | Buttons in this build carry an explicit minimum width utility not present in the old doc |

No explicit spacing scale beyond Tailwind's default was isolated — component tasks should default to Tailwind's spacing utilities (`p-*`, `m-*`, 0.25rem-based scale), consistent with the whole template being Tailwind-based (replacing the old doc's Bootstrap-grid guidance).

---

## 4. Motion & Transitions (MEASURED — CHANGED from the Corona React capture)

| Interaction | Properties | Duration | Easing |
|---|---|---|---|
| Sidebar expand/collapse | `all` (`transition-all`) | `300ms` | `ease-in-out` |
| Sidebar menu-title fade (icon-only ↔ expanded label) | `opacity, transform` | driven by a JS-toggled duration class on collapse (base state measures `0s`) — treat as `300ms ease-in-out` to match the sidebar's own transition, verify against the toggle interaction when building | `ease-in-out` (assumed, matches sidebar) |
| Button hover (all semantic/style variants) | none — **no `transition` utility class present** on button elements; hover background swap (`hover:bg-{color}/85`) is an **instant snap**, not an animated fade | `0s` | — |
| Form input focus | none — same as buttons, no `transition` class observed on the measured text input | `0s` | — |

**Interpretation for component tasks**: this is a meaningfully flatter motion language than the Corona React capture (which measured 150ms ease-in-out fades on every button/input). The Tailwind build only animates structural layout changes (the sidebar's width/label collapse) — discrete color/style state changes (button hover, input focus, badge appearance) snap instantly. **Do not add hover/focus transitions that aren't in this table** just because the old doc had them — that would be inventing motion the actual template doesn't have. If `qor-admin` wants a hover fade for accessibility/polish reasons, treat it as a deliberate QOR-specific addition and say so explicitly in the component's implementation, not as "matching Corona."

Loader/spinner keyframe animations (`spin`, `bounce`, `flip`, etc.) exist in the stylesheet for the Advanced UI → Loaders showcase page — these are opt-in decorative components, not default motion for buttons/cards/inputs; only pull one in if a specific `qor-admin` screen calls for a loading spinner.

---

## 5. Components

### 5.1 Sidebar navigation
Fixed-width (244px) dark (`--admin-bg-surface`) vertical rail — unchanged in structure from the Corona React capture. Top: avatar + name + role-subtitle ("Gold Member" in the demo → QOR role label) + overflow-menu affordance. "Navigation" section label. Icon+label items. Collapse/expand driven by `transition-all duration-300 ease-in-out` on the `<nav>` element itself (§4).
**QOR mapping**: Dashboard, Aprovação de Contas, Aprovação de Eventos, Meus Eventos (role-scoped visibility per `admin.md` AT6).

### 5.2 Topbar
Full-width strip above content: hamburger/collapse toggle, search input (pill/bordered, dark fill, `Search products` placeholder in the demo), primary CTA text-link (`+ Create New Project` pattern → QOR's `+ Novo Evento`), icon buttons (apps grid, mail-with-dot, notifications-with-badge-dot), profile block (avatar + name, no visible dropdown chevron in this build — verify on click).

### 5.3 Stat card (KPI tile)
Card (`rounded-md`, `--admin-bg-surface`, no border/shadow — flat) containing: large numeric value (24px/700/white), small colored trend chip (`+3.5%` green / `-2.4%` red, using `--admin-success`/`--admin-danger`) inside a small square icon button with a directional arrow matching the trend sign, short label beneath.
**QOR mapping**: dashboard KPI row (`admin.md` AT20) — e.g. "Contas pendentes," "Eventos publicados este mês," "Publicações usadas / quota."

### 5.4 Donut/doughnut metric widget
Centered total value inside a segmented ring (segment colors drawn from the 5-color semantic rotation, §1.3), itemized list of contributing rows beneath (label + value, e.g. "Transfer to Paypal — $236").
**QOR mapping**: event-status breakdown (Draft/Pending Review/Published/Cancelled/Encerrado proportions) on the dashboard.

### 5.5 List-style activity widget ("Open Projects")
Icon-per-row (colored square icon tile) + title/subtitle + relative timestamp + trailing metadata line ("30 tasks, 5 issues").
**QOR mapping**: recent approval decisions / recently published events feed.

### 5.6 Data table with status pill
Header row (column headers, muted secondary text color, medium weight), body rows (plain columns + a status badge in the final column, some tables add a trend-percentage column with an up/down arrow colored green/red). Solid-fill badge style: bg=accent color, text=white, `border-radius: 6px` (matches the uniform radius token, not a separate 4px badge radius like the old doc), small padding, small bold-ish label.
**QOR mapping — direct match**: both approval queues (`admin.md` AT15/AT16) and the organizer's own event list (AT19).

### 5.7 Buttons
Six-plus semantic colors (§1.2) in three style families observed: **Default** (solid fill), **Inverse** (dark-tinted bg + colored text — new family not in the old doc's catalog, worth adopting since it reads well on the dark surface), **Rounded** (`rounded-full` pill, otherwise identical to Default), and **Outline** (transparent bg, colored border+text, fills solid on hover). Padding `6px 12px`, base font-size `16px`, `min-width: 128px` enforced. **No hover transition** (§4 — instant snap, not a fade). **Recommendation unchanged**: use the rounded/pill variant as QOR-admin's default — still Corona's most visually distinctive button treatment.

### 5.8 Form inputs
Dark fill (`--admin-bg-surface`), thin border, radius varies by input type (verify per control, §3 — the one measured text input showed `2px`, not the uniform `6px` card/button radius). **No focus transition observed** (§4 — instant border-color snap, not a 150ms fade like the old doc claimed). Checkboxes/labels: no transition, matches the a11y-clarity convention carried over from the old doc.

### 5.9 Modal
Structure (Default Modal, Authentication Modal, sized variants: Small/Large/Extra-large) confirmed present on the Modals page, but the toggle-open interaction couldn't be triggered during this capture pass (likely requires the page's own JS init timing) — **do not assume the old doc's 150ms backdrop fade / 400ms dialog slide values carry over**; re-measure the open/close transition live when `qor-admin`'s decision-modal component (`admin.md` AT9's `DecisionModal`) is actually built, since this template's default-instant-transition pattern (§4) makes it plausible modals also snap open/closed rather than animate.
**QOR mapping**: the approve/reject decision modal (`admin.md` AT9's `DecisionModal`).

### 5.10 Progress bars
Track: dark gray, thin bar. Fill: one of the 5 semantic accent colors. Three variants observed: **Colored** (plain fill), **With inner label** (percentage text inside the filled portion, white/dark depending on contrast), **With outer label** (label + percentage as separate text above/beside the bar), plus a **Circular ProgressBar** variant (rendered as a ring, values not yet filled in per-instance in the demo markup — SVG or canvas-based, verify implementation when adopted).
**QOR mapping**: publish-quota usage bar ("3 de 5 publicações usadas este mês" — ties to the Monetization milestone). The circular variant is a strong alternative presentation worth considering for the same quota widget instead of/alongside the linear bar.

### 5.11 Auth card (login/register) — CHANGED from the Corona React capture
Full-bleed photo background (sunset bridge/skyline image in the demo — QOR-admin should use its own background image or a solid dark fallback, not reproduce the literal photo) instead of the old doc's pure-black body. Centered floating card (`max-width` ~380px, rounded corners, `--admin-bg-surface`-family dark fill), **no wordmark on the card itself** (the "CORONA" wordmark only appears in the topbar on other pages — the auth card's own heading is a plain "Sign in"), stacked full-width inputs (Username/Email, Password), "Remember me" checkbox + "Lost Password?" link row, full-width primary "Login" button, **two** full-width social-login buttons (Facebook-blue **and** Google-red in this build, vs. only Facebook in the old doc — QOR-admin still has no social login per ARCHITECTURE §2, so **omit both**, don't reproduce either as dead UI), "Sign Up" footer link.
**QOR mapping**: `admin.md` AT14's login page.

---

## 6. What NOT to carry over

- Corona's social-login buttons — this build shows **both** Facebook and Google (the earlier capture only had Facebook) — QOR-admin has no social login per ARCHITECTURE §2, omit both, don't reproduce as dead UI
- The literal login-page background photo (bridge/skyline sunset) — structural pattern (full-bleed image + floating card) is fine to reuse, the specific stock photo is not
- The generic template nav categories not relevant to QOR (Widgets showcase, Advanced Elements/Editors/Charts/Maps showcase pages, Notifications/Popups showcase, most of "General Pages," Apps: Calendar/Todo/Email/Gallery, Ecommerce: Invoice/Pricing/Orders, Docs) — these are template filler pages, not features
- The dashboard's specific sample content (Henry Klein, fake revenue figures, "Open Projects" sample rows) — structural pattern only, not literal copy
- Any assumption of hover/focus transitions on buttons, inputs, or badges — this build measured `0s` (instant) on all of them (§4); don't reintroduce the old Corona React doc's 150ms fades as if they still apply
