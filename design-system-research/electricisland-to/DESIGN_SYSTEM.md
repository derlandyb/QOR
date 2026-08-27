# Electric Island — Design System Specification
### Reverse-engineered from https://www.electricisland.to/ (Season 14 site, captured 2026-08-22)

**Method:** Live inspection of the rendered site via headless browser (desktop viewport 1512×797), computed-style extraction (`getComputedStyle`), and static analysis of the site's production stylesheet (`electric-island-season-14.webflow.shared.7ab204c4f.min.css`, fetched directly, 169,050 characters, including its `:root` custom-property block). The site is built on **Webflow** (confirmed by `w-` utility classes, `.webflow.shared` CSS filename, and Webflow's default breakpoint grid).

Every claim below is tagged **OBSERVED**, **MEASURED**, **INFERRED**, or **UNKNOWN** per the requested methodology. Mobile/tablet viewports could not be physically rendered in this session (the automation sandbox's browser window would not resize below 1512×797), so responsive claims below 991px are derived from the stylesheet's `@media` rules and the site's fluid `vw`-based type tokens rather than pixel screenshots — these are explicitly marked INFERRED.

---

## 1. Executive Summary

Electric Island is a Toronto electronic-music festival site with a **stark, high-contrast, editorial-poster visual language**: pure black canvas, oversized condensed display type, a single coral accent color, and duotone-treated photography. The system leans on **three typefaces doing three distinct jobs** — a condensed grotesk (Anton) for shouting headlines, a neutral grotesk (Suisse Int'l) for reading text, and a monospace (TT Interphases Pro Mono) for all "system" text (labels, dates, timers, button captions) — which gives the site a "festival flyer meets terminal/HUD" personality. Layout is built on Webflow's standard container/grid primitives but pushed to extremes: full-bleed duotone photography, a scroll-pinned "stacking cards" lineup sequence, live scramble/decode text animations, and a real-time countdown. Radii are small and controlled (buttons/pills go fully round; content panels use an 8px system radius); shadows and elevation are entirely absent — depth comes from contrast and opacity, not blur.

## 2. Visual Identity

- **OBSERVED** — Base canvas is pure black (`#000`) with pure white (`#fff`) type; the only chromatic brand color is a single coral-orange (`#fd5f40`), used sparingly and consistently for every actionable/temporal element (CTA fills, countdown numbers, date badges, map pin).
- **OBSERVED** — The wordmark and hero headline ("ELECTRIC ISLAND") are set in an all-caps, extremely condensed slab/grotesk (Anton) at a scale that fills the full viewport width — an oversized-typography, poster-first composition rather than a photo-first one.
- **OBSERVED** — Photography (skyline, crowd, stage shots) is uniformly treated with a **duotone orange/violet-blue filter**, never shown in natural color. This is a deliberate, repeated brand filter, not incidental.
- **OBSERVED** — Secondary/supporting artist names in the lineup use full white text dropped to **50% opacity** rather than a separate grey token — hierarchy is built with opacity, not a second color.
- **OBSERVED** — All "system" copy (dates, countdown labels, small eyebrow tags, button captions, section indices like `S14-W4-D1`) is set in monospace, uppercase, small size, and frequently animates in via a character-scramble/decode effect (class name `scramble`) — a HUD/data-terminal motif layered on top of the poster aesthetic.
- **OBSERVED** — Negative space is used aggressively: the hero, intro, and countdown sections are dominated by black with type and image as the only incident; there is no decorative chrome, no drop shadows, no card borders in the hero flow.
- **INFERRED** — The overall tone reads as "electronic-music rave meets brutalist/Swiss editorial poster": maximum typographic contrast and confidence, minimal ornament, a single hot accent color, and a recurring circuit/lightning-bolt motif (logomark, thin outline illustrations) reinforcing the "Electric" theme.
- **OBSERVED** — Motion is a first-class part of the identity: a live countdown timer, scramble-text reveals, and a scroll-pinned card-stacking lineup sequence are all present on a single page load — this is not a static brochure site.

## 3. Color System

| Token | Value | Usage | Evidence |
|---|---|---|---|
| `color.brand.primary` | `#fd5f40` (coral/orange) | Primary CTA fill (hover/active), countdown digits, date accents, section pill badges, map pin, weekend-4 accent | MEASURED (computed style + CSS var `--swatch--w4`) |
| `color.brand.secondary` | `#00f5d4` (teal) | CSS var `--swatch--w1`, aliased as `--swatch--brand`; appears to be an alternate weekend/edition accent (weekend 1) not seen rendered in this pass | INFERRED (present in `:root`, not visually confirmed on Weekend 4 page) |
| `color.brand.accent-2` | `red` (named CSS color, `#ff0000`) | `--swatch--w2`, likely Weekend 2 accent | INFERRED (CSS var only) |
| `color.brand.accent-3` | `#e7f80d` (yellow-green) | `--swatch--w3`, likely Weekend 3 accent | INFERRED (CSS var only) |
| `color.background.primary` | `#000000` | Page background, section background (nearly every section) | OBSERVED |
| `color.background.secondary` | `#131313` (`rgb(19,19,19)`) | Lineup "stacking card" panel background — the one deliberate near-black-but-not-black surface in the system | MEASURED |
| `color.background.overlay` | `rgba(13,27,30,0.6)` (`#0d1b1e99`) | Dark overlay tint (from CSS var `--swatch--dark-fade`), used on image overlays | MEASURED (CSS var) |
| `color.text.primary` | `#ffffff` | Headlines, body copy, primary lineup names, nav links | OBSERVED |
| `color.text.secondary` | `rgba(255,255,255,0.5)` | Secondary/support-act names in lineup lists | MEASURED (opacity, not a separate hex) |
| `color.text.muted` | `rgba(253,253,253,0.7)` (`#fdfdfdb3`) | CSS var `--swatch--light-fade`; general muted/faded light text | INFERRED (CSS var) |
| `color.text.inverse` | `#000000` | Text on the white/coral filled buttons | MEASURED |
| `color.border.default` | `#000000` (1px) / `rgba(255,255,255,0.5px)` on buttons | Stacking-card list wrapper border (`1px solid #000`); button outline (`0.5px solid #fff`) | MEASURED |
| `color.ui.hover` | `#fd5f40` (brand coral) | Button background swaps to brand color on hover/press per `--button--background-hover` var | INFERRED (CSS var `--button--background-hover: var(--swatch--brand)`; note the *var* points to `--swatch--w1` teal, but the rendered coral pill button on this page is `#fd5f40` — indicates the "brand" swatch is edition-specific and this Weekend-4 page overrides it locally) |
| `color.ui.disabled` / `focus` | — | Not observed | NOT OBSERVED |

**Note on color architecture:** the stylesheet defines a **generic 4-swatch rotation** (`--swatch--w1` teal, `w2` red, `w3` yellow-green, `w4` coral) that appears designed to give each of the festival's four weekends its own accent color, with the currently-rendered "Weekend 4 / Labour Day" page using coral (`w4`) throughout. Any rebuild should treat the accent color as **swappable per section/weekend**, not fixed.

## 4. Typography System

**Font families (OBSERVED, loaded via `document.fonts` + confirmed in CSS):**

| Role | Family | CSS var | Fallback stack |
|---|---|---|---|
| Display / Headings (H1–H3) | **Anton** | `--font--third-family` | `Anton, Impact, sans-serif` |
| Body / UI text, buttons, H4–H6 | **Suisse Int'l** (`Suisseintl`) | `--font--primary-family` | `Suisseintl, Arial, sans-serif` |
| Monospace / labels, dates, eyebrows, countdown, button captions | **TT Interphases Pro Mono Var Roman** | `--font--secondary-family` | `"Tt Interphases Pro Mono Var Roman", sans-serif` |
| Unused/reserved | **Druk Wide** | — | listed in `document.fonts` but `status:"unloaded"` — reserved for logo artwork (outlined to SVG paths in the wordmark), not applied to live text | INFERRED |

All heading and display tokens compute to `font-weight: 400` in the browser (the theme's weight variables like `--font-weight--500` literally resolve to `0px`, a Webflow variable-mode quirk) — Anton is visually bold by design (it has no regular/bold distinction as loaded), so **there is effectively one weight of the display face in use.**

| Token | Font | Size (desktop, MEASURED) | Fluid source (`:root`, MEASURED) | Line Height | Letter Spacing | Transform | Usage |
|---|---|---:|---|---:|---:|---|---|
| `typography.display` | Anton | ~176px at this viewport | `5.833vw` | `1em` | `-0.03em` | UPPERCASE | Hero "ELECTRIC ISLAND" wordmark-scale headline |
| `typography.heading.xl` (h1) | Anton | `120.96px` (MEASURED on rendered `<h1>`) | `5vw` | `1em` (`108.86px` computed) | `0em` | UPPERCASE | "THE LEGENDARY MUSIC SERIES", "LABOUR DAY LONG WEEKEND" |
| `typography.heading.lg` (h2) | Anton | ~3.333vw computed | `3.333vw` | `1em` | `0em` | UPPERCASE | Day headers ("SATURDAY SEPTEMBER 05") |
| `typography.heading.md` (h3) | Anton | ~2.5vw computed | `2.5vw` | `1.1em` | `0em` | UPPERCASE | Section subheads |
| `typography.heading.sm` (h4) | Suisseintl | `2vw` | `2vw` | `1.3em` | `0em` | UPPERCASE, weight 600 (demibold) | Card/module titles |
| `typography.body.lg` (text-large) | TT Interphases Mono | `1vw` (~15px at capture width) | `1vw` | `1.3em` | `0em` | UPPERCASE | Eyebrow labels, date pairs under hero, index tags (`S14-W4-D1`) |
| `typography.body.md` (text) | Suisseintl | `1.2vw` (`18.14px` MEASURED) | `1.2vw` | `1.5em` | `0em` | none | Paragraph copy ("Dive into the electric energy...") |
| `typography.body.sm` (text-small) | TT Interphases Mono | `0.5vw` | `0.5vw` | `1.5em` | `0em` | UPPERCASE | Fine print, footer micro-labels |
| `typography.label` / button caption | TT Interphases Mono | `15.12px` MEASURED | — | `18.14px` | normal | UPPERCASE | Button text ("GET TICKETS →", "2026 EDITION") |
| `typography.artist.headliner` | Anton | matches h1/h2 scale in lineup stack | — | `1em` | — | UPPERCASE, 100% white | Headliner name in lineup list |
| `typography.artist.support` | Anton | same scale, `opacity:0.5` | — | `1em` | — | UPPERCASE, 50%-opacity white | Support-act name in lineup list |

**Key system property:** almost every type token is defined in **`vw` units** (`--h1--font-size:5vw`, `--text--font-size:1.2vw`, etc.), meaning the entire type scale is **fluid/viewport-relative by default**, not a fixed step scale with breakpoint overrides. This is the mechanism behind the site's "always-oversized" headline feel at any screen size and is a core, reusable rule for rebuilding it (see §8).

## 5. Spacing System

**MEASURED** directly from the stylesheet's `:root` size tokens (rem-based, `1rem = 16px` at default root):

| Token | rem | px (at 16px root) |
|---|---|---|
| `space.0` | 0rem | 0px |
| `space.1` (`--size--0-25rem`) | .25rem | 4px |
| `space.2` (`--size--0-5rem`) | .5rem | 8px |
| `space.3` (`--space--extra-small` / `--size--0-75rem`) | .75rem | 12px |
| `space.4` (`--size--1rem`) | 1rem | 16px |
| `space.5` (`--size--1-25rem`) | 1.25rem | 20px |
| `space.6` (`--size--1-5rem`) | 1.5rem | 24px |
| `space.7` (`--size--2rem`) | 2rem | 32px |
| `space.8` (`--size--2-5rem`) | 2.5rem | 40px |
| `space.9` (`--space--medium` / `--size--3rem`) | 3rem | 48px |
| `space.10` (`--size--3-5rem`) | 3.5rem | 56px |
| `space.11` (`--space--large` / `--size--4rem`) | 4rem | 64px |
| `space.12` (`--size--4-5rem`) | 4.5rem | 72px |
| `space.13` (`--size--5rem`) | 5rem | 80px |
| `space.14`–`space.20` | 5.5rem → 16rem | 88px → 256px |

**Section rhythm (MEASURED, CSS var):**

- `padding-vertical.none` = `0rem`
- `padding-vertical.small` = `5rem` (80px) — compact sections
- `padding-vertical.main` (default) = `7rem` (112px) — standard section padding
- `padding-vertical.large` = `10rem` (160px) — hero/major sections
- `padding-horizontal.main` = `3rem` (48px) — desktop side gutters
- `grid-gap.main` = `1rem` (16px)

This is a **rem-based 4px-rooted scale** (all values are multiples of 4px/0.25rem) layered with three named vertical-rhythm presets (small/main/large) rather than one flat spacing scale applied everywhere — a reusable rule: pick `small`/`main`/`large` per section, don't invent new paddings.

## 6. Layout System

- **MEASURED** — `--max-width--main: 150rem` (2400px) — an unusually generous outer content cap, effectively "almost unconstrained" on typical monitors; in practice full-bleed sections (hero image, countdown, merch, map) run edge-to-edge regardless.
- **MEASURED** — Desktop horizontal padding: `3rem` (48px) via `--padding-horizontal--main`.
- **OBSERVED** — The nav bar, hero headline, and date row all share the same left edge (`38px`/`~2.4vw` from viewport edge at capture width) — confirms a single shared container/gutter system across the header and hero.
- **INFERRED** — Webflow's default 12-column grid (`.w-col-*`) is present in the framework CSS but the visually distinctive sections (hero, lineup stack, merch, venue) read as single-column, full-width, centered-text compositions rather than multi-column grids — the grid is used structurally (nav left/right groups, footer's 3-column layout) more than compositionally.
- **OBSERVED** — Footer uses a clear 3-column layout: nav links / policy links / newsletter signup, each column left-aligned under a mono-label header, with a full-width giant wordmark and copyright bar beneath.
- **OBSERVED** — Section backgrounds are **full-bleed black-to-image-to-black transitions**; images (skyline, crowd shots) run full viewport width with no side margin, while text content within those same sections is horizontally centered and width-constrained.
- **CSS technology (INFERRED from class names):** standard Webflow flex/block layout (`w-container`, `w-row`, `w-col`) for structure; a dedicated **"stacking-cards"** component (`.stacking-cards__collection/list/item`) for the lineup sequence, which uses `position` + scroll-linked transforms (JS-driven, likely a Webflow/GSAP scroll interaction) rather than CSS Grid/aspect-ratio containers.

## 7. Grid & Alignment

```
Page
└── Global Container (max-width: 150rem, side padding: 3rem desktop)
    ├── Navbar (fixed/sticky, left: logo, right: CTA + menu toggle) — shares container edge
    ├── Hero (headline + date row share container edge; image below is full-bleed)
    ├── Intro / Brand Statement (centered text column, image background full-bleed)
    ├── Countdown (full-bleed duotone image bg, centered text + 2 buttons)
    ├── Lineup — Stacking Cards (each weekend/day = one pinned card, full-bleed, index bar top: S14 / WEEKEND N / DAY; centered artist stack)
    ├── Merchandise (full-bleed image bg, centered product shot + heading + CTA)
    ├── Venue / Map (full-bleed custom dark map, coral pin)
    └── Footer (3-column: Menu / Policy / Newsletter, full-width giant wordmark, copyright bar)
```

- **OBSERVED** — Nav, hero text block, and footer nav columns all align to the **same left inset**, confirming one consistent container gutter reused everywhere text (not imagery) appears.
- **OBSERVED** — All major headlines and CTAs are **center-aligned** within their section, while the nav and footer are **edge-aligned** (left/right groups) — the system deliberately alternates between a centered-poster mode (hero, countdown, lineup, merch) and a functional edge-aligned mode (nav, footer) for utility chrome.

## 8. Responsive System

| Breakpoint token | Value | Status |
|---|---|---|
| `breakpoint.mobile` | ≤479px | MEASURED (from CSS `@media screen and (max-width:479px)`) |
| `breakpoint.tablet` | ≤767px | MEASURED (CSS `@media screen and (max-width:767px)`) |
| `breakpoint.desktop-sm` | ≤991px | MEASURED (CSS `@media screen and (max-width:991px)`) |
| `breakpoint.wide` | >991px (no explicit upper cap besides `--max-width--main`) | INFERRED |

These are Webflow's four standard default breakpoints; there is no evidence of custom-added breakpoints in the CSS.

- **INFERRED** — Because nearly all typography and spacing is expressed in `vw` units rather than fixed `px`, most of the visual scaling across viewport widths happens **continuously/fluidly** rather than in discrete jumps at the three breakpoints — the breakpoints exist mainly to change *layout structure* (grid column stacking, nav collapse to hamburger, hidden/shown elements via `w-hidden-*` utility classes), not to re-key the type scale.
- **OBSERVED** — A hamburger icon (three lines) is present in the nav at the captured desktop width and is fully functional: clicking it swaps to an "×" and reveals a full-screen black overlay menu (two-column link list + policy list + footer/social row) — this is very likely the **same mobile menu pattern reused at all widths** below the point where inline nav links would appear (no inline nav links were observed at 1512px either, meaning the hamburger may be the *only* nav pattern the site uses, not a mobile-only fallback). **INFERRED** for widths <991/767px specifically; **OBSERVED** at 1512px.
- **UNKNOWN** — Exact grid-column stacking, image aspect-ratio changes, and touch-target sizing at ≤767px/≤479px could not be visually verified in this session (viewport resize was unavailable); §26 Recommendations includes a note to re-verify these with real device/DevTools testing before shipping a rebuild.
- **NOT OBSERVED** — horizontal scrolling anywhere on the page.

## 9. Radius System

**MEASURED** from `:root` and rendered elements:

| Token | Value | Usage |
|---|---|---|
| `radius.none` | `0` | Default for most elements (images, section wrappers) |
| `radius.small` | `.25rem` (4px) | Compact UI elements (form inputs per CSS) |
| `radius.main` | `.5rem` (8px) | Default content-panel radius |
| `radius.lg` | `18.144px` (computed, ~1.13rem at this viewport — appears to derive from a `vw`-scaled value) | Lineup stacking-card top corners (`18.14px 18.14px 0 0`) — rounded top only, square bottom, because cards stack/overlap |
| `radius.round` / `radius.full` | `100vw` (functionally `9999px`) | Pill buttons, CTA badges, countdown/date pills |

The system deliberately mixes **two radius philosophies**: near-sharp (0–8px) for structural panels, and fully-round pills for every clickable/tag element — there is no "large card" radius family in between except the special stacking-card top corners.

## 10. Border System

- **MEASURED** — `--border-width--main: 1.5px` — the system's one named border weight, used on outline buttons ("RESERVE TABLE →" white-outline button) and SVG stroke illustrations (`--svg-stroke-width--main: 1.5px`).
- **MEASURED** — Primary/filled button border: `0.5px solid #fff` (an artifact of the 1.5px var scaled down at this render, effectively a hairline).
- **MEASURED** — Stacking-card list wrapper: `1px solid #000` (invisible against the black page background — functions as a technical separator, not a visible line).
- **OBSERVED** — No visible dividers/hairlines are used between most sections; separation is achieved by background-color changes (black → image → black) or by whitespace, not by drawn borders. The one exception is the footer's `1px` horizontal rule above the copyright row.
- All borders observed are **solid**; no dashed/decorative borders were found.

## 11. Shadows and Elevation

**Explicitly confirmed absent.** No `box-shadow`, `filter: drop-shadow`, `backdrop-filter: blur`, or glow effects were found in the extracted CSS custom properties, and no rendered element in this session showed a soft shadow or blur. Depth/hierarchy in this system is communicated entirely through **flat contrast** (black vs. white vs. 50%-opacity white) and **layering of full-bleed image panels**, not simulated elevation. Any rebuild should not introduce shadows — it would contradict the flat, poster-like identity.

- Gradients: **OBSERVED** — a dark radial/linear fade (`--swatch--dark-fade: #0d1b1e99`) is used as an image overlay tint to keep text legible over photography; this is a flat-opacity overlay, not a soft gradient blur.

## 12. Iconography

- **OBSERVED** — Custom lightning-bolt-in-circle logomark (the "electric" motif), rendered as a geometric, faceted vector — flat-fill, no stroke, matching the display type's angular character.
- **OBSERVED** — Arrow glyphs (`→`) appear inline in every button/link label ("GET TICKETS →", "RESERVE TABLE →", "BACK TO TOP ↑") — a consistent micro-icon convention rather than a separate icon component.
- **OBSERVED** — Hamburger menu icon: two horizontal lines, morphing to an "×" (two crossed lines) on open — simple line-based, no fill.
- **OBSERVED** — Footer social icons: Instagram and Facebook (line/outline style, single color, small square touch targets, evenly spaced, right-aligned in the footer's meta row).
- **OBSERVED** — Footer menu-link rows use a right-pointing diagonal arrow (`↗`-style) that appears on the link — consistent with the button arrow convention.
- **MEASURED** — SVG stroke width for decorative outline illustrations (the circuit/lightning line-art behind the hero) is `1.5px`, matching `--svg-stroke-width--main`.
- **UNKNOWN** — Specific icon library/source cannot be identified from the DOM (icons appear to be hand-built inline SVGs, not a named icon font/library like Feather or Font Awesome).

## 13. Image System

- **OBSERVED** — All photographic imagery (skyline, crowd, stage) uses a uniform **orange/violet duotone treatment** — this is the single most identity-defining visual rule of the system and must be preserved exactly in any rebuild (do not use natural-color photography).
- **OBSERVED** — Images are used **full-bleed / full-viewport-width**, edge to edge, with no rounded corners and no border, functioning as section backgrounds rather than contained "photos."
- **OBSERVED** — Text is overlaid directly on these images (white type, sometimes with a dark overlay tint underneath for legibility) rather than images being placed beside text in a split layout.
- **OBSERVED** — The merch section is the one exception: a product photo (white T-shirt mockup) is shown as a **contained, drop-shadow-free cutout** over the duotone background — object-fit/contain behavior, not full-bleed.
- **OBSERVED** — The venue section uses a custom dark, monochrome-grey **map illustration** (not a real photo, likely a styled Mapbox/Google Maps instance) with a single coral pulsing pin marker — treated with the same "flat, high-contrast, one-accent-color" rule as the rest of the system.
- **UNKNOWN** — Exact source image aspect ratios/crop points (server-side responsive image variants weren't inspected in this pass).

## 14. Motion System

| Animation | Trigger | Element | Duration/Delay/Easing | Transform/Opacity | Repeat | Evidence |
|---|---|---|---|---|---|---|
| Character-scramble text reveal | On load / on scroll into view | Any element with class `scramble` (dates, eyebrow labels, index tags) | Not measured precisely; visually resolves over roughly 0.5–1s per string | Cycles through random mono characters before settling on final text (e.g. `K4R 6H` → `MAY 17`) | Once per element per view | OBSERVED (two screenshots of the same element mid-decode) |
| Live countdown | Continuous (real time) | Countdown digits ("13 DAYS 21 HOURS...") | Updates every second | Digit text content changes; no visible transform | Infinite (ticks every second) | OBSERVED (values decremented between screenshots taken ~90s apart) |
| Scroll-pinned lineup stacking | Scroll | `.stacking-cards__item` (one per weekend/day) | Scroll-linked (not time-based) | Each card is pinned full-viewport while the next slides over it, rounded top corners revealing a "deck of cards" effect | Once per scroll pass | INFERRED from class naming (`stacking-cards`) + observed rounded-top/flat-bottom card geometry consistent with a stacking pattern; exact easing/duration is scroll-position-driven, not time-based, so cannot be measured as seconds |
| Button hover/press state swap | Hover/press | Primary button (`.btn_panel.is-bg`) | Not measured (CSS transition duration not captured) | Background/text color swap: default white-bg/black-text ↔ hover coral-bg/black-text per `--button--background-hover` | On hover only | INFERRED from CSS custom properties (`--button--background-hover`, `--button--text-hover`); direct hover-state screenshot not captured this session |
| Full-screen menu open/close | Click hamburger | Nav overlay panel | Not measured | Hamburger icon morphs to "×"; overlay appears (no slide direction confirmed) | Toggle | OBSERVED (before/after screenshots) |
| Hero image reveal / scroll parallax | Scroll | Hero background image | Not measured | Not conclusively observed — no strong parallax detected in the captures taken | — | NOT OBSERVED (present as a plausible pattern for this template style, but not confirmed) |

- **INFERRED** — Given the `scramble` and `stacking-cards` component names and general Webflow-ecosystem conventions, this site almost certainly uses a scroll-animation library (GSAP + ScrollTrigger is the most common pairing for this exact pattern on Webflow) — but the library itself was not directly confirmed in this pass and should be verified via network/script inspection if implementation fidelity matters.
- **NOT OBSERVED** — marquee/ticker text, explicit page-load fade-ins beyond the scramble effect, or infinite-loop background animation.

## 15. Component Inventory

Present and strongly supported by direct observation:

- Header / Navbar (logo, ticket CTA, hamburger menu)
- Full-screen Nav Overlay Menu
- Hero (headline, event meta/date row, background image)
- Section Eyebrow / Index Label (mono, uppercase, scramble-animated)
- Intro / Brand Statement block (headline + paragraph over image)
- Countdown (live timer + dual CTA)
- Button — Primary (filled, pill)
- Button — Secondary (outline, pill)
- Lineup Stacking Card (per weekend/day: index bar + headliner/support artist stack)
- Artist List Item (headliner vs. support states via opacity)
- Merch Promo Block (product image + heading + CTA)
- Venue / Map Block (custom map + pin)
- Footer (3-column nav, newsletter signup, social icons, giant wordmark, copyright bar)
- Newsletter Signup Form (footer)
- Social Icon Row

Not present / not found: standard card grids with borders, testimonial/review components, image carousels/sliders (beyond the stacking cards), pricing tables, tabs, accordions.

## 16. Component Anatomy

### Header / Navbar
```
Anatomy:
- Logo mark (lightning-in-circle) + wordmark, left
- Primary CTA pill button "GET TICKETS →", right
- Hamburger toggle icon, far right
Typography: mono for button label (15px), uppercase
Colors: black bg (nav sits on transparent/black hero), white logo, white/coral button
Spacing: ~38px side inset, ~24px vertical padding (nav height ≈104px MEASURED)
Radius: button fully round
Interaction: hamburger click → full-screen overlay menu; icon morphs to ×
```

### Button — Primary
```
Anatomy: single pill container, label + trailing arrow glyph
Variants: light (white bg/black text, seen in nav) — dark/coral (seen as "2026 EDITION", "GET TICKETS" in hero, "LAUNCH STORE") 
States: default; hover/press swaps to brand coral bg per CSS var (INFERRED, not screenshotted)
Typography: TT Interphases Mono, 15px, uppercase, no letter-spacing override
Colors: bg #fff or #fd5f40; text #000
Spacing: padding ≈14px/36px (vertical/horizontal), MEASURED
Radius: 100vw (fully round)
Border: 0.5px solid white (light variant)
Dimensions: height ≈46px MEASURED
```

### Button — Secondary (outline)
```
Anatomy: pill container, label only ("RESERVE TABLE →")
Colors: transparent/white bg, white border, black or white text depending on fill
Radius: fully round, matching primary
Usage: paired with primary button as a secondary action (e.g., "RESERVE TABLE" next to "GET TICKETS")
```

### Lineup Stacking Card
```
Anatomy:
- Top index bar: three-column row — season/day code (e.g. "S14"), weekend label ("WEEKEND 4"), day code ("D1") — mono, coral, small
- Full-bleed day headline (Anton, huge, e.g. "SATURDAY SEPTEMBER 05")
- Second index bar: date code, stage label, full date — mono, small
- Artist stack: centered list, headliners in solid white Anton, support acts in 50%-opacity white Anton, largest/boldest at top
Colors: panel bg #131313 (near-black), text white/coral
Radius: 18px top corners, square bottom (cards overlap when stacked)
Spacing: ~91px vertical internal padding (MEASURED "stacking-cards__item")
Interaction: scroll-pinned stacking transition between cards (INFERRED)
Responsive: NOT VERIFIED at narrow widths this session
```

### Countdown
```
Anatomy: eyebrow label → big headline ("LABOUR DAY LONG WEEKEND") → 4-part timer (days/hours/min/sec, mono, coral) → button pair (secondary + primary)
Background: full-bleed duotone crowd photo
Colors: white headline, coral timer digits and labels
Layout: fully centered, single column
```

### Footer
```
Anatomy:
- 3 columns: "MENU" (Home/Events/Artists/Directions/Merch/Contact), "POLICY" (FAQ/Code of Conduct/Cannabis Policy/Privacy Policy), Newsletter signup ("Get notified" + email field + submit)
- Meta row: "EVERYTHING'S ELECTRIC" tagline (left) + social icons (right)
- Full-width giant repeated wordmark
- Copyright bar: "© 2026 ELECTRIC ISLAND" (left) + "BACK TO TOP ↑" (right)
Typography: mono for column headers/index codes, Suisseintl for link labels
Colors: black bg, white/grey text, links show a trailing arrow on the row
```

## 17. Component Variants

Only variants with direct evidence are listed (per the "do not invent variants" rule):

- **Button:** primary-filled (white or brand-coral background, both observed), secondary-outline (white border/transparent). No size variants (small/large) were found — all observed buttons render at the same scale.
- **Section accent color:** system supports 4 accent swatches (teal/red/yellow/coral) tied to weekend number — only coral (Weekend 4) was rendered and directly confirmed in this session.
- **Lineup item weight:** headliner (100% opacity) vs. support (50% opacity) — no third "featured" or "closing set" variant was found.
- **Nav:** single variant observed (`navbar is--dark`) — a light/inverted navbar variant was not found on this page but the class name (`is--dark`) implies a counterpart `is--light` state may exist elsewhere in the site (e.g. inner pages). **INFERRED, not confirmed.**

## 18. Interaction States

| Component | Default | Hover | Focus | Active | Disabled |
|---|---|---|---|---|---|
| Primary button | OBSERVED (white or coral fill) | INFERRED (CSS var swaps bg to `--swatch--brand`/coral, text to black) | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED |
| Nav link / footer link | OBSERVED (plain white text) | INFERRED (arrow glyph present at rest already; a color or underline shift on hover is plausible given the `→` per row but not screenshotted) | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED |
| Hamburger icon | OBSERVED (☰) | NOT OBSERVED | NOT OBSERVED | OBSERVED (morphs to ×) | — |
| Newsletter input | OBSERVED (placeholder "Your email") | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED |
| Lineup item | OBSERVED (static, 100%/50% opacity split) | NOT OBSERVED (no evidence artist names are links/hoverable) | — | — | — |

Selected / Expanded / Collapsed / Loading states: **NOT OBSERVED** anywhere on the page.

## 19. Navigation Architecture

**Information architecture (OBSERVED, from footer + overlay menu):**
- Home, Events, Artists, Directions, VIP Table Service (overlay menu) / Merch, Contact
- Policy: FAQ, Code of Conduct, Cannabis Policy, Privacy Policy
- Footer repeats a slightly different set (Home/Events/Artists/Directions/Merch/Contact) — near-identical to the overlay menu's "Menu" column, minor list differences (VIP Table Service appears only in the overlay).

**Visual/behavioral (OBSERVED at 1512px):**
- Header height: **≈104px** (MEASURED, `navbar` bounding box).
- No inline nav links are shown at desktop width — navigation is hamburger-only at every width tested.
- Sticky/fixed behavior: **UNKNOWN** (not explicitly tested by scrolling with the nav pinned; nav remained at top in all captures but page never scrolled far enough past the fold to conclusively confirm sticky vs. static positioning — treat as INFERRED sticky given the site's genre conventions).
- Menu overlay: full-screen black panel, two-column link layout (Menu / Policy), each row with a trailing arrow, footer utility row (copyright + social icons) duplicated inside the overlay.
- Active-state indication: **NOT OBSERVED** (single-page-style site; no clear "current page" highlighting found).
- Mobile menu: **INFERRED** to be the same full-screen overlay pattern (Webflow's `w-nav` component reliably reuses one overlay across breakpoints), not confirmed at true mobile width this session.

## 20. Page Templates

```
Festival Homepage (the only template directly observed)
Header (fixed, logo + CTA + hamburger)
↓
Hero (oversized wordmark + date grid)
↓
Intro / Brand Statement (headline + body copy over full-bleed image)
↓
Countdown (live timer + dual CTA over full-bleed image)
↓
Lineup — Stacking Cards (repeated per weekend × per day: index bar → day headline → index bar → artist stack)
↓
Merchandise (product shot + heading + CTA over full-bleed image)
↓
Venue / Location (custom map + pin)
↓
Footer (3-column nav/policy/newsletter + wordmark + copyright)
```

Other referenced-but-not-visited templates (from nav): Events (listing), Artists (listing/detail), Directions, Merch (external store), Contact, FAQ, Code of Conduct, Cannabis Policy, Privacy Policy — **UNKNOWN** structure, not inspected in this session.

## 21. Design Tokens (Consolidated)

See §22 (CSS variables) and §27 (JSON) for the full machine-readable set. Categories present with real extracted values: Colors, Typography, Spacing, Radius, Borders, Breakpoints, Containers, Motion (qualitative). Categories with **no evidence of use** in this system: Shadows (confirmed absent, §11), formal Z-index scale (not exposed in the extracted `:root`, treat as UNKNOWN), formal Sizing/icon-size scale beyond spacing tokens (UNKNOWN).

## 22. CSS Variables

Only values with direct MEASURED or `:root`-sourced evidence are included. See the accompanying `variables.css` file for the full implementation-ready layer (also reproduced below).

```css
:root {
  /* Color */
  --color-background-primary: #000000;
  --color-background-secondary: #131313;
  --color-background-overlay: #0d1b1e99;
  --color-text-primary: #ffffff;
  --color-text-secondary: rgba(255, 255, 255, 0.5);
  --color-text-muted: #fdfdfdb3;
  --color-text-inverse: #000000;
  --color-brand-primary: #fd5f40;   /* Weekend 4 / active accent on this page */
  --color-brand-w1: #00f5d4;        /* Weekend 1 accent (inferred, not rendered) */
  --color-brand-w2: #ff0000;        /* Weekend 2 accent (inferred, not rendered) */
  --color-brand-w3: #e7f80d;        /* Weekend 3 accent (inferred, not rendered) */
  --color-border-default: #000000;
  --color-border-button: #ffffff;

  /* Typography */
  --font-display: Anton, Impact, sans-serif;
  --font-body: Suisseintl, Arial, sans-serif;
  --font-mono: "Tt Interphases Pro Mono Var Roman", sans-serif;

  --text-display-size: 5.833vw;
  --text-h1-size: 5vw;
  --text-h2-size: 3.333vw;
  --text-h3-size: 2.5vw;
  --text-h4-size: 2vw;
  --text-h5-size: 1.5vw;
  --text-body-size: 1.2vw;
  --text-large-size: 1vw;
  --text-small-size: .5vw;
  --text-letter-spacing-display: -0.03em;

  /* Spacing (4px-rooted rem scale) */
  --space-0: 0rem;
  --space-1: .25rem;
  --space-2: .5rem;
  --space-3: .75rem;
  --space-4: 1rem;
  --space-5: 1.25rem;
  --space-6: 1.5rem;
  --space-7: 2rem;
  --space-8: 2.5rem;
  --space-9: 3rem;
  --space-10: 3.5rem;
  --space-11: 4rem;
  --space-13: 5rem;

  --padding-vertical-none: 0rem;
  --padding-vertical-small: 5rem;
  --padding-vertical-main: 7rem;
  --padding-vertical-large: 10rem;
  --padding-horizontal-main: 3rem;
  --grid-gap-main: 1rem;

  /* Radius */
  --radius-none: 0;
  --radius-small: .25rem;
  --radius-main: .5rem;
  --radius-card-top: 18.144px;
  --radius-round: 100vw;

  /* Borders */
  --border-width-main: 1.5px;
  --svg-stroke-width-main: 1.5px;

  /* Containers */
  --container-max: 150rem;

  /* Breakpoints */
  --breakpoint-mobile: 479px;
  --breakpoint-tablet: 767px;
  --breakpoint-desktop-sm: 991px;
}
```

## 23. Component APIs

Proposed for implementation, constrained to observed variants only:

```text
<Button
  variant="primary" | "secondary"   // primary = filled (white or brand-coral), secondary = outline
  href="..."
  icon="arrow"                       // trailing → glyph, observed on every button
>
  GET TICKETS
</Button>

<EyebrowLabel
  scramble={true}                    // toggles the character-decode reveal animation
>
  SEASON 14
</EyebrowLabel>

<LineupCard
  seasonCode="S14"
  weekendLabel="WEEKEND 4"
  dayCode="D1"
  date="SAT AUG 05"
  stage="STAGE 02"
  dayHeadline="SATURDAY SEPTEMBER 05"
  artists={[
    { name: "GREEN VELVET", tier: "headliner" },
    { name: "LAYTON GIORDANI", tier: "support" },
    ...
  ]}
/>

<Countdown
  targetDate="2026-09-05T00:00:00-04:00"
  labels={["DAYS","HOURS","MINUTES","SECONDS"]}
/>

<VenueMap
  pinColor="var(--color-brand-primary)"
  style="dark-monochrome"
/>

<SiteFooter
  menuLinks={[...]}
  policyLinks={[...]}
  newsletterAction="..."
  socials={["instagram","facebook"]}
/>
```

Required vs. optional props, exact validation, and full responsive slot behavior are **UNKNOWN** beyond what's inferable from the rendered markup — treat this API sketch as a starting contract, not a final spec.

## 24. Tailwind Mapping

```text
color.background.primary   → bg-black
color.background.secondary → bg-[#131313]
color.text.primary         → text-white
color.text.secondary       → text-white/50
color.brand.primary        → bg-[#fd5f40] / text-[#fd5f40]
space.9 (3rem)              → p-12   (Tailwind's default 3rem step)
padding-vertical.main (7rem)→ py-28  (7rem = 112px; nearest default is py-28)
padding-vertical.large(10rem)→ py-40 (10rem = 160px = Tailwind's py-40)
radius.main (.5rem)         → rounded-lg
radius.small (.25rem)       → rounded
radius.round (100vw)        → rounded-full
container (150rem)          → max-w-[150rem]   (custom value; far beyond Tailwind's default max-w-7xl)
breakpoint.tablet (767px)   → custom screen "md: 767px" (Tailwind default md=768px is close but not exact — keep custom to preserve fidelity)
breakpoint.mobile (479px)   → custom screen "xs: 479px" (not a Tailwind default)
font-display                → font-['Anton'] (custom font-family, not in default Tailwind stack)
```

Tailwind's default spacing/breakpoint scale is close-but-not-identical to this system in a few places (479 vs no default, 767 vs Tailwind's 768 `md`) — **use custom values rather than forcing the nearest default**, per the visual-fidelity rules.

## 25. Accessibility

**Observed:**
- Contrast: white-on-black and coral-on-black both read as very high contrast (OBSERVED visually); the 50%-opacity secondary artist names reduce contrast substantially and would need a contrast-ratio check against WCAG AA for body-text-sized use (UNKNOWN exact ratio — not computed in this pass).
- Motion: the scramble-text effect and live countdown are continuous/attention-grabbing motion with **no visible reduced-motion accommodation found** in the extracted CSS (`prefers-reduced-motion` media query was not found in the stylesheet's media-query list).
- Touch targets: primary button height ≈46px (MEASURED) meets the common 44px minimum guideline; hamburger icon and footer social icons were not measured for target size.
- Semantic hierarchy: `<h1>` was found and used correctly for the top-level headline; deeper heading-level usage across sections was not fully audited.

**Recommended (not applied to the extracted system, offered as guidance only):**
- Add a `prefers-reduced-motion` variant that disables/shortens the scramble animation and pauses non-essential motion.
- Verify the 50%-opacity secondary text against WCAG AA at its rendered size; consider a slightly higher minimum opacity (e.g. 60–65%) if used for anything beyond decorative list hierarchy.
- Ensure the hamburger-only navigation (no visible inline links at any tested width) still exposes a keyboard-accessible, properly labelled toggle (`aria-expanded`, `aria-controls`) — **not verified in this session** (ARIA attributes were not inspected).

## 26. Implementation Architecture

```text
design-system/
├── tokens/
│   ├── colors.ts        (§4 — brand + 4-weekend swatch rotation)
│   ├── typography.ts     (§4 — 3-family system, vw-fluid scale)
│   ├── spacing.ts         (§5 — 4px-rooted rem scale + 3 vertical presets)
│   ├── radius.ts           (§9 — sharp panels + full-round pills)
│   ├── borders.ts           (§10 — 1.5px hairline system)
│   └── breakpoints.ts        (§8 — 479 / 767 / 991)
│
├── components/
│   ├── Navbar/             (logo, CTA, hamburger, overlay menu)
│   ├── Button/              (primary filled, secondary outline)
│   ├── EyebrowLabel/          (mono, scramble-capable)
│   ├── Hero/
│   ├── Countdown/
│   ├── LineupStackingCard/
│   ├── ArtistListItem/         (headliner / support opacity variant)
│   ├── MerchPromo/
│   ├── VenueMap/
│   └── Footer/
│
├── patterns/
│   ├── LineupSection/    (composes LineupStackingCard × N with scroll-pin)
│   ├── CountdownSection/
│   ├── MerchSection/
│   └── VenueSection/
│
└── templates/
    └── FestivalHomepage/  (§20 page template order)
```

**Note:** given the confirmed absence of shadows/elevation (§11) and the flat, opacity-driven hierarchy (§2, §16), a rebuild should resist adding conventional "card" shadow/border treatments even where a component library's defaults would suggest them — this would break visual fidelity to the source (§28, rule 3–4).

## 27. Machine-Readable JSON

See the accompanying `tokens.json` file (full contents below).

```json
{
  "brand": {
    "name": "Electric Island",
    "edition": "Season 14",
    "platform": "Webflow"
  },
  "colors": {
    "background": {
      "primary": "#000000",
      "secondary": "#131313",
      "overlay": "#0d1b1e99"
    },
    "text": {
      "primary": "#ffffff",
      "secondary": "rgba(255,255,255,0.5)",
      "muted": "#fdfdfdb3",
      "inverse": "#000000"
    },
    "brand": {
      "primary": "#fd5f40",
      "weekend1": "#00f5d4",
      "weekend2": "#ff0000",
      "weekend3": "#e7f80d",
      "weekend4": "#fd5f40"
    },
    "border": {
      "default": "#000000",
      "button": "#ffffff"
    }
  },
  "typography": {
    "families": {
      "display": "Anton, Impact, sans-serif",
      "body": "Suisseintl, Arial, sans-serif",
      "mono": "\"Tt Interphases Pro Mono Var Roman\", sans-serif"
    },
    "scale": {
      "display": { "size": "5.833vw", "lineHeight": "1em", "letterSpacing": "-0.03em", "transform": "uppercase" },
      "h1": { "size": "5vw", "measuredPx": 120.96, "lineHeight": "1em", "transform": "uppercase" },
      "h2": { "size": "3.333vw", "lineHeight": "1em", "transform": "uppercase" },
      "h3": { "size": "2.5vw", "lineHeight": "1.1em", "transform": "uppercase" },
      "h4": { "size": "2vw", "lineHeight": "1.3em", "transform": "uppercase", "weight": "demibold" },
      "h5": { "size": "1.5vw", "lineHeight": "1.3em" },
      "body": { "size": "1.2vw", "measuredPx": 18.144, "lineHeight": "1.5em" },
      "textLarge": { "size": "1vw", "lineHeight": "1.3em", "transform": "uppercase" },
      "textSmall": { "size": "0.5vw", "lineHeight": "1.5em", "transform": "uppercase" },
      "buttonLabel": { "measuredPx": 15.12, "lineHeight": "18.144px", "transform": "uppercase" }
    }
  },
  "spacing": {
    "scale": {"0":"0rem","1":".25rem","2":".5rem","3":".75rem","4":"1rem","5":"1.25rem","6":"1.5rem","7":"2rem","8":"2.5rem","9":"3rem","10":"3.5rem","11":"4rem","13":"5rem"},
    "sectionVertical": { "none": "0rem", "small": "5rem", "main": "7rem", "large": "10rem" },
    "sectionHorizontal": "3rem",
    "gridGap": "1rem"
  },
  "sizing": {
    "navHeight": "104px",
    "buttonHeight": "46px",
    "containerMax": "150rem"
  },
  "radius": {
    "none": "0",
    "small": ".25rem",
    "main": ".5rem",
    "cardTop": "18.144px",
    "round": "100vw"
  },
  "borders": {
    "widthMain": "1.5px",
    "svgStrokeWidth": "1.5px"
  },
  "shadows": {
    "status": "not used in this system"
  },
  "breakpoints": {
    "mobile": "479px",
    "tablet": "767px",
    "desktopSmall": "991px"
  },
  "containers": {
    "max": "150rem",
    "paddingHorizontal": "3rem"
  },
  "grid": {
    "gap": "1rem",
    "framework": "Webflow default 12-column (.w-col-*), used structurally not compositionally"
  },
  "motion": {
    "scrambleText": { "trigger": "on view/load", "elements": "class .scramble", "durationEstimateSec": "0.5-1 (INFERRED)" },
    "countdown": { "trigger": "continuous", "interval": "1s" },
    "stackingCards": { "trigger": "scroll", "component": ".stacking-cards__*", "durationBasis": "scroll-position-linked" },
    "buttonHover": { "trigger": "hover", "change": "background swaps to brand color (INFERRED from CSS var, not screenshotted)" }
  },
  "components": {
    "navbar": { "height": "104px", "variant": "is--dark", "nav": "hamburger-only at all tested widths" },
    "button": { "variants": ["primary-filled", "secondary-outline"], "radius": "100vw", "height": "46px", "borderWidth": "0.5px" },
    "lineupStackingCard": { "background": "#131313", "radiusTop": "18.144px", "verticalPadding": "90.72px" },
    "artistListItem": { "headlinerOpacity": 1, "supportOpacity": 0.5 },
    "footer": { "columns": ["Menu","Policy","Newsletter"], "socials": ["instagram","facebook"] }
  },
  "patterns": {
    "pageTemplate": ["Header","Hero","IntroStatement","Countdown","LineupStackingCards","Merch","VenueMap","Footer"]
  }
}
```

## 28. Observed vs Measured vs Inferred vs Unknown — Summary

| Category | Status breakdown |
|---|---|
| Core palette (black/white/coral) | OBSERVED + MEASURED |
| Weekend 1–3 accent colors (teal/red/yellow) | INFERRED (present in CSS, not rendered) |
| Font families | OBSERVED (`document.fonts`) + MEASURED (computed styles) |
| Fluid `vw` type scale | MEASURED (`:root` tokens) |
| Spacing scale | MEASURED (`:root` tokens) |
| Section vertical rhythm (small/main/large) | MEASURED |
| Radius values | MEASURED |
| Border widths | MEASURED |
| Shadows/elevation | Confirmed **absent** (verified negative, not merely unobserved) |
| Breakpoints (479/767/991) | MEASURED (from `@media` rules) |
| Mobile/tablet rendered layout | **UNKNOWN** — could not physically resize the viewport this session; only CSS-rule-level evidence available |
| Motion durations/easing curves | INFERRED / estimated — exact timing values were not extractable without reading JS/animation library config |
| Hover/focus/active visual states | Mostly INFERRED from CSS custom properties; only the hamburger→× state was directly screenshotted |
| ARIA/accessibility implementation | **UNKNOWN** — not audited this session |
| Icon library source | **UNKNOWN** — appears to be custom inline SVG |

## 29. Recommendations for Recreating the Visual System

1. **Preserve the three-typeface division of labor exactly**: Anton for anything shouted (headlines, artist names), Suisse Int'l for anything read (paragraphs, form fields), and the mono face for anything "systemic" (labels, timers, button captions, index codes). Do not consolidate to one or two fonts — the mono/display contrast is a primary identity signal.
2. **Keep type fluid (`vw`-based), not stepped**, for the display/heading tokens — this is what gives the site its "always oversized" feel across viewport widths; converting to fixed `px` breakpoint jumps will visibly flatten the brand's confidence.
3. **Treat photography as a single-step pipeline**: any new image must go through the same orange/violet duotone filter before use. Do not introduce natural-color photography anywhere in the system.
4. **Do not add shadows, blurs, or glassmorphism** anywhere — this system's entire depth language is flat opacity and full-bleed image contrast; introducing elevation effects (a common "modernization" instinct) would break fidelity.
5. **Reuse the pill-radius-for-actionable / sharp-radius-for-structural split** consistently: buttons, tags, and countdown pills are always fully round; content panels (lineup cards) use the small 8px system radius, never the pill radius.
6. **Build the accent color as a swappable token**, not a hardcoded value — the underlying CSS already anticipates 4 weekend-specific accents (teal/red/yellow/coral); a faithful rebuild of the broader site (not just the Weekend-4 page captured here) should expose this as a themeable variable per section.
7. **Re-verify mobile/tablet behavior with a real device or DevTools viewport override before finalizing a rebuild** — this report's responsive section is CSS-rule-derived, not visually confirmed, and is the single biggest fidelity risk in this specification.
8. **Preserve the scramble-text and scroll-pinned-stacking-card interactions** as the system's signature motion patterns — a static rebuild without these would be visually accurate at rest but would misrepresent the product's actual feel; note their existence and intent even if exact timing curves need to be re-authored.
