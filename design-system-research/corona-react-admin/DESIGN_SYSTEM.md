# Corona React (BootstrapDash) Admin Dashboard — UI Pattern Reference
### Reverse-engineered from https://demo.bootstrapdash.com/corona-react/modern-vertical/dashboard (captured 2026-08-24)

> **⚠️ Superseded (2026-08-27)**: this audit's scope note below ("layout patterns only, do not adopt Corona's colors/typeface") reflected an earlier decision that has since been **reversed** — the admin panel (`qor-admin`) now fully adopts Corona's own design system. The canonical, current source is **`design-system-admin.md`** at the project root (a fuller re-navigation covering colors, typography, motion durations/easings, and the full component catalog). This document is kept as historical record only; `.specs/tasks/admin.md` does not reference it.

**Method:** Live inspection of the rendered dashboard demo via headless browser (desktop viewport 1512×797) — one full-page screenshot pass plus scroll, and `getComputedStyle`/DOM extraction via injected JavaScript for body/sidebar/card background, radius, shadow, font-family, and a global `transition`-property scan.

**Scope and purpose — read this before the rest of the document.** Unlike the other audits in this folder, this is **not** a full competing visual-identity audit. QOR already has an intentional, product-specific design system — **NIGHTLIFE-GV** (`design-system-porpose/design-system.md`) — and this reference was supplied specifically as inspiration for the **Admin Panel's layout and interaction patterns**, not its color or type system. This document therefore extracts and catalogs *structure and behavior* (sidebar navigation shape, widget types, table/status conventions, motion) and deliberately does **not** propose adopting Corona's own color palette or typeface (`rgb(25,28,36)` surfaces, near-black `#000` body, Rubik) — those stay NIGHTLIFE-GV's (navy-charcoal base, Space Grotesk/Inter, the existing 4-accent palette with orange as the Admin-Panel-specific accent per PRD §8). Where a color is recorded below, it is recorded as **evidence of the reference's own system**, not a recommendation to reuse the value.

---

## 1. Executive Summary

Corona React (BootstrapDash "Modern Vertical" demo) is a dark, data-dense admin dashboard: a collapsible icon+label vertical sidebar on the left, a scrollable content area on the right built from a grid of self-contained "widget" cards — KPI/stat cards with a trend indicator, a donut chart, list-style widgets (recent activity, messages, a to-do list, a slide/carousel), and a data table using avatar thumbnails and colored outline status-pills. Surfaces are flat (no drop shadow, small border radius) rather than skeuomorphic/elevated, and the page makes heavy use of CSS transitions — hover states, sidebar collapse, and menu/tab interactions all animate rather than snap. This overall shape (persistent nav rail + widget-grid dashboard + status-pill data tables) maps directly onto QOR's own Admin Panel needs: a venue-admin's event list (draft/published/canceled/ended — the same four-state shape as Corona's Approved/Pending/Rejected pills) and the Super Admin's moderation queue (Pending/Active/Suspended/Rejected) are both naturally expressed as this same status-pill-table pattern.

## 2. Layout Structure

- **OBSERVED** — A persistent left sidebar (~244px wide at default/expanded state) contains, top to bottom: a user identity block (avatar + name + "Gold Member"-style subtitle + an overflow-menu affordance), a "Navigation" section label, then a single-column list of icon+label nav items (Dashboard, RTL, Apps, Widgets, Basic UI Elements, Advanced UI, Form Elements, Tables, Editors, Charts, Maps, Notifications, Icons, ...). Several items carry a trailing chevron, implying an expandable sub-menu (not expanded during this capture).
- **OBSERVED** — The main content area is NOT full-bleed to the viewport edge — cards sit on a slightly-different-shade page background with consistent gutter spacing between the sidebar, the top promo banner, and each widget card.
- **OBSERVED** — A slim top announcement/utility bar spans the full width above the sidebar+content split (a "Buy Now" upsell + home/close icon-buttons in this demo — QOR has no equivalent need for this specific bar, but the *slot* — a slim, dismissible, full-width strip above the main layout — is a reusable pattern for e.g. a "trial/limit" banner).
- **OBSERVED** — Below the utility bar, a full-width gradient promo/announcement **banner card** (illustration + headline + one-line description + a single pill CTA button) sits above the KPI row — a good structural match for a "you're on the free plan — N of 3 events used" or "upgrade coming soon" banner in QOR's Admin dashboard.
- **OBSERVED** — A **KPI/stat-card row** follows: 4 equal-width cards, each containing a large numeric value, a small colored percentage-change chip (`+3.5%` in green, `-2.4%` in red), a short label beneath, and a small icon button in the top-right corner with a directional arrow (↗ or ↘) matching the trend's sign.
- **OBSERVED** — Below the KPI row, a **two-column widget zone**: a donut/doughnut chart card with a centered total value and a stacked list of labeled transaction rows beneath it, next to a taller list-style card (e.g. "Open Projects") with an icon-per-row, title/subtitle, a relative timestamp, and a trailing metadata line ("30 tasks, 15 issues").
- **OBSERVED** — Further down, a **full-width data table** ("Order Status") with a header row (checkbox-select-all, sortable-looking column headers), and body rows each combining a small circular avatar + name, several plain-text columns, and a **status-pill** in the final column (green "Approved", yellow/amber "Pending", red-outline "Rejected").
- **OBSERVED** — Below the table, a further widget row (Messages list with a "View all" link, a Portfolio image carousel with prev/next arrow controls, a To-Do list) — confirming the dashboard's general pattern of small, self-contained, independently-scrollable "widget cards" tiling a grid, rather than one monolithic page layout.

## 3. Component Patterns (the reusable catalog)

| Pattern | Description | Direct QOR Admin Panel mapping |
|---|---|---|
| Collapsible icon+label sidebar nav | Vertical list, one icon + one label per item, chevron for items with sub-items, active/hover state | Admin Panel's primary nav: Dashboard, Meus Eventos, Casa de Shows, Promoters, (Super Admin: Moderação) |
| Stat card with trend chip | Big number + colored `±N%` chip + label + directional icon button | Dashboard's "N de 3 publicações usadas este mês" and other `ADMIN-06` KPI tiles |
| Gradient promo/announcement banner | Full-width illustrated card, one headline, one CTA, dismissible | Free-plan-limit or "plano pago em breve" banner (ties to `ADMIN-03`, `LAND-03`) |
| Donut/doughnut metric widget | Centered total + segmented ring + itemized list below | Could represent event-status breakdown (draft/published/canceled/ended) on the dashboard |
| List-style activity widget | Icon + title/subtitle + relative time + trailing metadata, "View all" link | Recent activity / recently published events widget |
| Status-pill data table | Avatar + name + plain columns + colored outline pill for state | **Direct match** for both the venue admin's own event list (draft/published/canceled/ended) and the Super Admin's moderation queue (Pending/Active/Suspended/Rejected, `ADMIN-08`) |
| Carousel/slide widget | Prev/next arrow-button pair over an image strip | Not currently needed by any locked QOR requirement — noted for completeness, not adopted |

## 4. Motion & Interaction

- **MEASURED** — A page-wide scan of computed `transition` values found **1000+ elements** with an active (non-`none`, non-`all 0s`) transition property — i.e. hover/interaction animation is applied pervasively (nav items, cards, buttons), not as a handful of one-off effects. Exact per-element easing/duration values were not individually isolated in this pass.
- **OBSERVED** — Sidebar items show a visible hover/active background-color and icon-color change; the "trend" icon buttons on KPI cards appear as small circular chips independent of the rest of the card, implying they are separately hoverable/clickable targets.
- **INFERRED** — The general motion personality is "responsive and alive" (transitions on nearly everything interactive) rather than static — consistent with, and reinforcing rather than conflicting with, NIGHTLIFE-GV's own documented motion language (hover states with scale/gradient, slight "overshoot" entrances per `design-system-porpose/design-system.md`). The Admin Panel can inherit NIGHTLIFE-GV's actual easing/duration tokens while adopting Corona's *breadth* of what gets a transition (nav items, card hover, chip buttons — not just primary CTAs).

## 5. Surface Treatment (recorded as evidence of the reference's own system — values not adopted)

| Token (reference's own) | Value | Evidence |
|---|---|---|
| Body background | `rgb(0, 0, 0)` | MEASURED |
| Sidebar / card surface background | `rgb(25, 28, 36)` | MEASURED |
| Card border radius | `6px` | MEASURED |
| Card box-shadow | `none` (flat, no elevation) | MEASURED |
| Base font family | `Rubik, sans-serif` | MEASURED |
| Heading font-weight | `500` | MEASURED |
| Status-pill colors | Green (Approved), amber/yellow (Pending), red (Rejected) — outlined/tinted pill style, not solid fill | OBSERVED |
| Trend-chip colors | Green for positive `%`, red for negative `%` | OBSERVED |

**Reminder**: per the Scope note above, QOR's Admin Panel uses NIGHTLIFE-GV's own navy-charcoal surfaces, Space Grotesk/Inter type, and 4-accent palette (with orange as the admin-specific accent) — this table exists only so the *layout/component* recommendations in §3 can be implemented against the reference's actual proportions and states (e.g. "6px-radius flat card," "outlined status pill") without needing to re-inspect the source again, not to justify copying its palette.

## 6. Recommendation Summary

Adopt from this reference: the collapsible icon+label sidebar shape, the stat-card-with-trend-chip pattern, the gradient promo/announcement banner slot, the donut-metric widget, the list-style activity widget, and — most directly reusable — the **status-pill data table**, which maps almost one-to-one onto both `ADMIN-02`'s event-status list and `ADMIN-08`'s Super Admin moderation queue. Do not adopt: Corona's own color palette, typeface, or the carousel widget (no current QOR requirement). Reuse NIGHTLIFE-GV's tokens (`design-system-porpose/design-system.md`) for every color/type/motion-timing value while building these layout patterns in the `qor-admin` repo's shadcn/ui component set.
