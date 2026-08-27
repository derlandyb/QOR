# Vibrant Brampton Summer Fest — Design System Specification
### Reverse-engineered from https://vibrantbrampton.ca/ (captured 2026-08-22)

**Method:** Live inspection of the rendered homepage via headless browser (desktop viewport 1512×741), computed-style extraction (`getComputedStyle`) on hero, navigation, buttons, badges, cards, and footer elements. The site is a **custom WordPress theme** (page title literally reads "VIBRANT BRAMPTON – Music, Band & Singer WordPress Theme"), most likely built with a page builder (Elementor-style block structure inferred from class patterns, though the exact builder was not directly confirmed). Unlike the companion electricisland.to audit, this session's direct stylesheet fetch was blocked by the browser tool's data-safety filter on this domain (repeated `[BLOCKED: Cookie/query string data]` errors when reading raw HTML/CSS text), so this report relies entirely on **rendered computed-style measurements and direct visual observation** rather than parsed source CSS. Where a value could not be measured this way, it is marked UNKNOWN or INFERRED rather than guessed. Mobile/tablet viewports could not be physically rendered in this session (viewport resize was unavailable), so responsive behavior below 1512px is **UNKNOWN** except where inferable from general WordPress/page-builder conventions.

---

## 1. Executive Summary

Vibrant Brampton Summer Fest is a South Asian cultural-music-festival site with a **warm, maximalist, celebratory visual language** — the near-opposite of a minimal poster system. It combines a rainbow-mosaic wordmark, a continuous cream-to-gold diagonal gradient with a low-poly triangle texture running behind nearly every section, full-color (non-filtered) event photography in organic blob/circle-masked crops, and a large-type editorial layout for both a "festival day" sequence and a numbered performer showcase. Typography splits cleanly into a confident geometric sans (Epilogue) for headlines/buttons/nav and a plain, highly-legible grotesk (Work Sans) for body copy, with a decorative brush-script accent used only in the logo lockup ("Summer Fest"). The site's defining structural device is the **repeating "eyebrow → mixed-case headline → paragraph → meta line → pill button" pattern**, reused for every festival day and reinforced by giant translucent numeral watermarks in the performer carousel. Depth comes from color and photography, not shadows — panels are flat or lightly translucent, and the one dramatic non-web element is a torn-paper edge transition into a dark footer.

## 2. Visual Identity

- **OBSERVED** — The nav/hero region sits on a continuous warm gradient (pale cream near the logo, deepening to gold toward the CTA), and this same gradient (deepened further into orange) with a **low-poly triangular mosaic texture** recurs as the background for nearly every section on the page (day cards, performer carousel, sponsors, "Get Involved") — this triangle-mosaic-on-gradient is the system's single most repeated visual motif, functioning the way the duotone photo filter does for Electric Island: as the connective tissue between otherwise very different sections.
- **OBSERVED** — Event photography is shown in **natural, saturated full color** (not stylized/filtered), a direct contrast to a monochrome or duotone treatment — the personality here is warmth and vibrancy, not edit/atmosphere.
- **OBSERVED** — Photography is consistently cropped into **organic, non-rectangular masks**: rounded "guitar pick"/blob shapes for the four festival-day cards, and full circles for supporting imagery — rectangular full-bleed photography (as used throughout Electric Island) is notably absent from the hero/day sections.
- **OBSERVED** — The performer showcase pairs each artist with a **unique multi-color low-poly polygon background** (a different palette per performer — teal/purple/brown for one, olive/orange for the next) layered with a giant, barely-visible **watermark numeral** ("01"–"07") — this "one accent world per artist" approach visually enacts the site's "One World. Many Sounds." tagline.
- **OBSERVED** — The wordmark itself carries a rainbow polygon-mosaic texture inside the "VIBRANT" letterforms, paired with a black "BRAMPTON" and a pink brush-script "Summer Fest" — three distinct visual treatments inside one logo lockup, signaling maximalism as a deliberate brand choice rather than restraint.
- **OBSERVED** — Headline typography is set in **mixed case** (not uppercase), a further contrast with Electric Island's all-caps convention — the tone reads as inviting/editorial rather than commanding/poster-like.
- **INFERRED** — Overall personality: a community-cultural-festival identity built on saturation, color pluralism (many distinct hues doing many distinct jobs, rarely repeating exactly), and organic/soft shapes — celebratory and inclusive rather than austere.
- **OBSERVED** — Negative space is used far less aggressively than on Electric Island; nearly every viewport is filled with gradient texture, photography, or copy — this is a busier, denser composition style.

## 3. Color System

| Token | Value | Usage | Evidence |
|---|---|---|---|
| `color.brand.primary` | `#FFD700` (gold/yellow) | Primary CTA button fill, active nav-pill text | MEASURED (`rgb(255,215,0)` computed on both the "View Event Highlights" button and the active "Home" nav pill's text) |
| `color.background.gradient.start` | ≈`#FFF6D0` (pale cream) | Nav bar / hero top-left gradient origin | INFERRED (visual sampling from screenshots; computed fallback returned flat `rgb(241,241,241)` on the `<header>`, indicating the visible gradient lives on a child/pseudo-element not directly queried) |
| `color.background.gradient.end` | ≈`#FF8A1E` (deep orange) | Section backgrounds (day cards, performer carousel, sponsors, Get Involved) | INFERRED (visual sampling; exact stops not measured) |
| `color.text.primary.dark` | `rgb(32,32,32)` (~`#202020`) | Button label text, most on-light headings | MEASURED |
| `color.text.primary.light` | `#ffffff` | Headlines/names set over photography (hero H1, performer names) | OBSERVED |
| `color.text.muted` | `rgb(177,167,167)` (~`#B1A7A7`, mauve-grey) | Eyebrow labels ("INVITATION ONLY", "FREE ENTRY \| FREE PARKING"), footer column headers ("CONTACT US") | MEASURED |
| `color.nav.active-pill.background` | `#111111` | Active/current nav item pill | MEASURED |
| `color.badge.border` | ≈`rgb(186,200,209)` (`#BAC8D1`) on one card; varies by performer accent | Outline pill badges (month/day) in the performer carousel | MEASURED on one instance; **INFERRED to vary per-performer** since each carousel card has a distinct accent palette |
| `color.link.accent` | ≈`#5B8DEF`-range blue (visually sampled on "FUZON" sub-label) | Sub-name/genre link accent in one performer card | INFERRED (visual only, not computed) |
| `color.footer.background` | Dark navy/near-black (visually ≈`#12141C`) | Footer section | INFERRED (the `<footer>` element itself computed as transparent — background lives on a parent wrapper not directly queried; visually a distinctly cooler dark tone than the page's warm palette) |
| `color.background.card-panel` | Semi-transparent white overlay (visual estimate ≈10–15% white) | Community/media sponsor logo tiles | INFERRED (translucent rounded-rect panels over the orange gradient; exact alpha not measured) |

**Note:** unlike Electric Island's single hard-coded accent, this system reads as **palette-per-context**: gold is the one true "brand" constant (CTA + active-state), while every performer card and every section background draws from its own multi-color gradient/mosaic rather than a shared token set. A faithful rebuild should treat "one warm base gradient + gold accent + unlimited per-card decorative palettes" as the rule, not try to force the decorative card colors into a fixed token list.

## 4. Typography System

**Font families (MEASURED via computed style):**

| Role | Family | Evidence |
|---|---|---|
| Display / Headings, buttons, active nav | **Epilogue** (sans-serif) | MEASURED (`<h1>`: `Epilogue, sans-serif`; primary button and active nav pill also compute to Epilogue) |
| Body copy, eyebrow labels, footer text | **Work Sans** | MEASURED (`document.body` computed `fontFamily`; also confirmed on "CONTACT US" and "INVITATION ONLY" elements) |
| Badge/pill numerals (month/day) | **Inter** | MEASURED (computed on the "July"/"18" pill badge) |
| Logo script accent ("Summer Fest") | Decorative brush-script — **UNKNOWN exact family** | OBSERVED visually; the text did not resolve to a queryable DOM node with its own font (likely embedded in a logo image/SVG asset), so family name could not be measured |

| Token | Font | Size (MEASURED) | Weight | Line Height | Letter Spacing | Transform | Usage |
|---|---|---:|---:|---:|---:|---|---|
| `typography.display` (h1) | Epilogue | `102.816px` | `500` | `102.816px` (1:1, very tight) | `-4.11264px` (≈`-0.04em`) | none (mixed case) | Hero headline "Vibrant Brampton Summer Fest 2026" |
| `typography.heading.day` (h2, day cards) | Epilogue (INFERRED — not separately measured, visually consistent with h1 family) | large, ~48–60px visual estimate | medium/bold visual estimate | tight | none observed | mixed case | "DAY 1 – Gala Evening" style headings |
| `typography.performer.name` | Epilogue (INFERRED) | large, bold, white | bold visual estimate | tight | none | UPPERCASE (source text is capitalized, not confirmed as CSS `text-transform`) | Performer name in carousel ("MANJ MUSIK") |
| `typography.button` | Epilogue | `16px` | `600` | normal | none | none | CTA button labels ("View Event Highlights") |
| `typography.nav.active` | Epilogue | `14px` | `700` | normal | none | none | Active nav pill label ("Home") |
| `typography.badge` | Inter | `19px` | `500` | normal | none | none | Month/day outline pill badges |
| `typography.body` | Work Sans | `16px` (body/eyebrow default) | `400` | normal | normal | none (source text typed in caps where relevant, not CSS-driven) | Paragraph copy, eyebrow labels, footer copy |

Compared to Electric Island's fully fluid (`vw`-based) type scale, this system's measured values are **fixed pixel sizes** at the captured viewport — whether they scale via `clamp()`/media queries at other widths is **UNKNOWN** (not testable this session).

## 5. Spacing System

Only a small number of spacing values could be directly measured this session (no source CSS access); the following are the confirmed data points, with the rest of a full scale marked UNKNOWN.

| Token | Value | Evidence |
|---|---|---|
| `space.badge-padding` | `3px 12px` | MEASURED (month/day pill badge) |
| `space.button-padding` | `18px 40px` | MEASURED ("View Event Highlights" button) |
| `space.nav-pill-padding` | `8px 16px` | MEASURED (active "Home" nav pill) |
| `space.section-rhythm` | Large, full-viewport-height sections (visually ~700–900px tall per day/performer card) | OBSERVED, not pixel-measured |

**UNKNOWN** — a systemic base spacing scale (4px/8px-rooted or otherwise) could not be derived without source CSS access; the three measured paddings above are not obviously multiples of a single shared unit (3px, 8px, 18px), suggesting this theme may not use as rigorously tokenized a spacing system as Electric Island's Webflow build — **INFERRED**, not confirmed.

## 6. Layout System

- **OBSERVED** — Content sections run full-viewport-width with the background gradient/texture; text and image content within is inset with generous side padding (visually ~30–48px at this viewport, not precisely measured).
- **OBSERVED** — The four festival-day cards **alternate image-left/text-right and image-right/text-left** across the sequence (Day 1: image left; Day 2: image right) — a classic zig-zag editorial layout.
- **OBSERVED** — The performer carousel is a **vertically stacked sequence of full-viewport-height panels** (not a horizontal slider), each with image on one side, text block with pagination ("04 / 07") on the other, and a giant faint background numeral — panels do not appear to alternate sides as consistently as the day cards (several consecutive cards showed image-left).
- **OBSERVED** — The sponsor/partner section uses a **3-column card grid**; the media gallery below it uses a **4-column image/video grid** — both are conventional CSS Grid/Flexbox patterns (INFERRED technology, not confirmed by source inspection).
- **OBSERVED** — Nav bar remains visually pinned to the top of the viewport across every scroll position captured in this session — behaves as a sticky/fixed header. Direct `position` computed-style query returned `absolute` on one queried header node and `static` on another query, suggesting either a JS-toggled sticky class (common in WordPress/Elementor themes, added after a scroll threshold) or that multiple header-like elements exist in the DOM (e.g., a duplicate for mobile) and the wrong one was queried on one pass — the **sticky behavior itself is OBSERVED; the CSS mechanism is INFERRED/uncertain**.
- **UNKNOWN** — Exact `max-width` container value and grid-column technology (CSS Grid vs. Flexbox vs. builder-specific absolute positioning) were not directly confirmed from source.

## 7. Grid & Alignment

```
Page
└── Full-bleed gradient/texture background (persists across most sections)
    ├── Navbar (logo left, nav pills center-right, social icons far right) — sits on cream gradient
    ├── Hero (headline + subhead + date line, centered/left, full-bleed photo background)
    ├── Recap Video (full-width embedded YouTube)
    ├── Day 1–4 Cards (alternating image/text halves, organic image masks, per-card same gradient bg)
    ├── "2026 Headliners" intro (eyebrow + heading, centered)
    ├── Performer Carousel (7 stacked full-height panels: numeral watermark + image + text/badges)
    ├── Sponsor Video Message (native embedded video)
    ├── Presenting Sponsor (large logo/wordmark)
    ├── Community Partners (3-col logo grid)
    ├── Media Partners (3-col logo grid, structurally identical to Community Partners)
    ├── Get Involved (stat bullet list + sponsor CTA, diagonal-stripe gradient bg)
    ├── Media / Gallery (4-col image+video grid, "Load More" + "Follow on Instagram")
    └── Footer (dark navy — About blurb, Contact, Links, Get in Touch/socials, copyright bar)
```

- **OBSERVED** — Nav logo and hero headline share a left inset; footer columns share a separate, wider left inset — a consistent gutter is plausible but was not pixel-verified as identical between header and footer this session (**INFERRED** shared container, not MEASURED).
- **OBSERVED** — Section headers ("COMMUNITY PARTNERS", "GET INVOLVED") are center-aligned in large uppercase type, while their content grids/lists below are left-aligned or grid-centered — same "centered headline, structured body" pattern used throughout.

## 8. Responsive System

- **UNKNOWN** — Breakpoints could not be measured this session (no source CSS access, no viewport resize available). Given the WordPress/page-builder origin, standard builder breakpoints (typically ~768px tablet, ~480px mobile for Elementor-family themes) are **plausible but unconfirmed** — do not treat as fact.
- **OBSERVED** — No horizontal scrolling occurred at the 1512px capture width.
- **UNKNOWN** — Nav collapse behavior (hamburger menu, stacking) at narrow widths was not observable this session.
- **UNKNOWN** — Whether type sizes are fluid (`clamp()`/`vw`) or fixed-with-breakpoint-overrides could not be determined without multi-width testing.

## 9. Radius System

| Token | Value | Usage | Evidence |
|---|---|---|---|
| `radius.button` | `8px` | Primary CTA button ("View Event Highlights") | MEASURED |
| `radius.pill` | `20px` | Active nav pill ("Home"), month/day outline badges | MEASURED (both independently computed to `20px`) |
| `radius.card` | Rounded rectangle, visual estimate ~16–20px | Sponsor/partner logo tiles | OBSERVED, not pixel-measured |
| `radius.image-mask` | Organic/irregular (blob, guitar-pick, full circle) | Day-card and performer photography | OBSERVED — **not a simple radius value**; achieved via CSS `clip-path` or SVG mask rather than `border-radius`, based on the non-uniform, non-elliptical contour visible in screenshots (**INFERRED** mechanism) |

Unlike Electric Island's two-tier "sharp panels + full-round pills" system, this system uses a **single mid-size radius (~8px) for rectangular UI** and reserves fully-round treatment for badges/pills only — large content images bypass the radius system entirely in favor of organic masking.

## 10. Border System

- **MEASURED** — Badge/pill outline: `1px solid`, color matching (or closely related to) the badge's text color (`#BAC8D1` on the one measured instance).
- **NOT OBSERVED** — Borders on buttons (the primary CTA has `border: 0` — its edge is defined by fill color only, not a stroke).
- **UNKNOWN** — Card/panel borders on the sponsor grid were not directly measured; screenshots suggest soft/no visible border, with separation coming from the translucent panel fill against the gradient background rather than a drawn line.

## 11. Shadows and Elevation

- **NOT OBSERVED** — No pronounced drop shadows were visible on buttons, cards, or images in any capture.
- **INFERRED** — The sponsor/partner logo tiles appear to sit on a **translucent white panel** over the orange gradient (a glassmorphism-adjacent treatment) rather than a shadow-based card — this reads as a soft, low-contrast surface rather than genuine elevation, but a light `backdrop-filter: blur()` cannot be ruled out from screenshots alone.
- Overall, this system — like Electric Island's — appears to avoid heavy elevation effects, but for a different reason: it relies on **photography, color, and translucency** rather than flat opacity contrast, so it is visually "softer" even without shadows.

## 12. Iconography

- **OBSERVED** — Consistent social icon set in both the nav and footer: **TikTok, Instagram, Facebook, YouTube** (nav shows TikTok/Instagram/Facebook/YouTube; footer shows Facebook/YouTube/Instagram/TikTok in a slightly different order) — simple black (nav, on light bg) / light-grey (footer, on dark bg) glyphs, square/circular touch targets, evenly spaced.
- **OBSERVED** — A small mail-envelope icon precedes the "info@acisa.ca" contact line in the footer.
- **OBSERVED** — Play-button icons (red YouTube-style triangle-in-circle) overlay each video thumbnail in the Media/Gallery grid.
- **UNKNOWN** — Exact icon library/source (could not be confirmed from DOM inspection this session — likely a standard icon font or SVG sprite bundled with the WordPress theme).

## 13. Image System

- **OBSERVED** — Full-color, natural (non-filtered) event and lifestyle photography throughout — a direct contrast to any duotone/monochrome treatment.
- **OBSERVED** — Two distinct masking conventions: **organic blob/"guitar pick" shapes** for the four festival-day feature images, and **full circles** for secondary supporting photography within those same sections and the performer carousel's smaller inset shots.
- **OBSERVED** — Performer carousel main images are **rectangular, full-bleed within their half of the panel**, sometimes desaturated/black-and-white (e.g., the "Shallum & Khurram" card) for visual variety against their colorful polygon background — not a uniform treatment across all seven cards.
- **OBSERVED** — Sponsor/partner logos are shown as flat, largely monochrome/muted marks inside uniform translucent tiles — a deliberately restrained treatment that contrasts with the vibrant photography elsewhere, likely to keep third-party branding visually subordinate.
- **OBSERVED** — Media/Gallery grid uses uniform square crops (`object-fit: cover`-style behavior) for a dense Instagram-style feed layout, mixing static photos and video thumbnails with play-button overlays.
- **UNKNOWN** — Exact aspect ratios and responsive `srcset` behavior were not inspected.

## 14. Motion System

| Animation | Trigger | Element | Duration/Delay/Easing | Transform/Opacity | Repeat | Evidence |
|---|---|---|---|---|---|---|
| Scroll fade/reveal-in | Scroll into view | Day-card headline, paragraph, meta lines; "GET INVOLVED" stat bullet list | Not measured — captured mid-transition at low opacity (~20–40%) before settling to full opacity | Opacity 0→1, likely paired with a subtle upward translate (common for this pattern; not conclusively isolated from screenshots) | Once per element per scroll-into-view | OBSERVED (two consecutive screenshots of the same elements at different opacity states) |
| Sticky/pinned navigation | Scroll (continuous) | Header/nav bar | N/A (persists at top) | Position remains fixed at viewport top | Continuous while scrolling | OBSERVED (nav bar present at identical position across every scroll depth captured) |
| Giant numeral watermark | Static (scroll-linked reveal plausible but not confirmed) | Performer carousel background numerals ("01"–"07") | UNKNOWN | UNKNOWN | — | OBSERVED as a static compositional device; whether it animates in was not isolated |
| Native video playback | Click | Recap video, sponsor message video, gallery video thumbnails | N/A — standard HTML5/YouTube player controls | N/A | User-controlled | OBSERVED (paused-by-default players with visible controls/play buttons) |

- **NOT OBSERVED** — marquee/ticker text, live countdown timer, character-scramble text effects, or scroll-pinned "stacking" transitions (all present on the Electric Island site but absent here).
- **UNKNOWN** — Hover states for buttons, nav pills, and sponsor logos were not captured via direct hover interaction this session.

## 15. Component Inventory

Present and directly observed:

- Header / Navbar (rainbow-mosaic logo, pill-style nav items with active-state pill, social icon row, implicit CTA integration)
- Sticky Navigation behavior
- Hero (headline, subhead, date/venue line, tagline, intro paragraph, full-bleed photo background)
- Recap Video Embed
- Festival Day Card (eyebrow, heading, paragraph, meta lines, CTA button, organic-masked photo) × 4, alternating layout
- Section Intro (eyebrow + centered heading) — reused before the performer carousel and elsewhere
- Performer Carousel Card (pagination index, eyebrow, name, sub-name/genre, tag line, month/day badges, giant numeral watermark, photo) × 7
- Sponsor Video Message
- Presenting Sponsor Block
- Partner Logo Grid (Community Partners / Media Partners — same component, two instances)
- Get Involved Stat List + Sponsor CTA
- Media / Gallery Grid (photo + video tiles, Load More, Follow-on-Instagram CTA)
- Footer (About blurb, Contact block, Links column, Get in Touch/socials column, watermark logo, copyright bar)

Not present / not found on the homepage: countdown timer, pricing/ticket-tier tables, testimonials/reviews, tabs, accordions, marquee ticker.

## 16. Component Anatomy

### Header / Navbar
```
Anatomy:
- Rainbow-mosaic "VIBRANT" + black "BRAMPTON" + pink-script "Summer Fest" logo lockup, left
- Pill-style nav items (Home, Performers, About Us, Media, Gallery, VSTAR, Plan Your Visit, Get Involved), center-right
- Active item rendered as a filled black pill with gold text; inactive items are plain black text, no visible pill
- Social icon row (TikTok, Instagram, Facebook, YouTube), far right
Typography: Epilogue 700 14px for active pill; nav item font not separately measured for inactive state
Colors: black active-pill bg (#111111), gold active text (#FFD700), black text for inactive items, warm cream/gold gradient bar background
Radius: active pill 20px (fully round given its height)
Behavior: persists at top of viewport through scroll (sticky, mechanism uncertain — see §6)
```

### Button — Primary
```
Anatomy: single filled rectangle (not a pill), label only, no icon observed
Typography: Epilogue, 600, 16px
Colors: background #FFD700 (gold), text #202020 (near-black)
Padding: 18px 40px
Radius: 8px
Border: none
Usage: "View Event Highlights" (day cards), "Get in Touch" (footer), likely reused for other primary CTAs sitewide
```

### Festival Day Card
```
Anatomy:
- Organic-masked photo (blob/"guitar pick" shape), one half
- Eyebrow label (e.g. "INVITATION ONLY", "FREE ENTRY | FREE PARKING") — muted mauve-grey, Work Sans
- Heading (mixed case, e.g. "DAY 1 – Gala Evening") — large, dark text
- Body paragraph — Work Sans regular
- Meta lines (date/time, venue) — bold dark text
- Primary button ("View Event Highlights")
Background: cream-to-orange gradient with low-poly triangle texture (shared across all 4 day cards)
Layout: alternates image-left/text-right and image-right/text-left across the 4 cards
Interaction: scroll-triggered fade/opacity reveal (see §14)
```

### Performer Carousel Card
```
Anatomy:
- Full-bleed unique multi-color low-poly polygon background (per performer)
- Giant, low-opacity watermark numeral (e.g. "04") in a back layer
- Photo (rectangular, sometimes desaturated), one half
- Pagination index ("04 / 07") — small, muted
- Eyebrow ("PERFORMER · 2026") — uppercase, letter-spaced, white/light
- Performer name — large, bold, white
- Sub-name/group or title — smaller, lighter weight, sometimes accent-colored (e.g. blue "FUZON")
- Genre/descriptor line — smaller, muted (e.g. "Desi Dhamaka", "NXT Wave")
- Two outline pill badges side by side — month + day (e.g. "July" "18")
- Footer note ("• VIBRANT BRAMPTON 2026")
Radius: badges 20px, border 1px
Repeats: 7 instances (one per confirmed 2026 headliner)
```

### Partner/Sponsor Logo Tile
```
Anatomy: single logo image/wordmark centered inside a translucent rounded rectangle tile
Layout: 3-column grid, used identically for "Community Partners" and "Media Partners" sections
Colors: muted/monochrome logo treatment on a semi-transparent light panel over the orange gradient
Radius: visually ~16–20px (not pixel-measured)
```

### Footer
```
Anatomy:
- About blurb (short paragraph) + CTA button, left column
- Watermark full-color logo, background layer
- "CONTACT US" (muted label) + email link with icon
- "Links" column (Home, Plan your visit, About Us, Our Team, VStar2026)
- "Get in Touch" column + social icon row (Facebook, YouTube, Instagram, TikTok)
- Divider rule
- Copyright bar: "© 2026. VIBRANT BRAMPTON. ALL RIGHTS RESERVED." (left) + "Site by TRIOTECHSYSTEMS" credit (right)
Colors: dark navy/near-black background (a deliberate departure from the page's warm palette), light/muted text
```

## 17. Component Variants

- **Button:** only one filled variant was directly observed/measured (gold-fill, dark text, 8px radius). No outline/secondary button variant was found on the homepage (the "Follow on Instagram" and "Load More" buttons in the gallery use different fills — dark and blue respectively — visually observed but not computed; treat as **additional variants, not fully specified**).
- **Section intro pattern:** the "eyebrow + centered heading" block is reused at least twice (before the performer carousel, and implicitly at the top of "Get Involved") — a confirmed reusable pattern, not a one-off.
- **Image mask:** at least three distinct mask types confirmed — organic blob (day cards), full circle (secondary photography), plain rectangle (performer carousel main photos) — **no evidence of a fourth type**, do not invent additional mask shapes.
- **Partner grid:** identical component reused for two content sets (Community/Media Partners) — confirmed single variant.

## 18. Interaction States

| Component | Default | Hover | Focus | Active | Disabled |
|---|---|---|---|---|---|
| Nav item (current page) | OBSERVED (filled black pill, gold text) | NOT OBSERVED | NOT OBSERVED | OBSERVED (this *is* the active/current state, shown as default while on that page) | — |
| Nav item (other pages) | OBSERVED (plain black text, no pill) | NOT OBSERVED | NOT OBSERVED | — | — |
| Primary button | OBSERVED (gold fill) | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED |
| Video player | OBSERVED (paused, controls visible) | — | — | OBSERVED (playing, after user click — not captured mid-play) | — |
| Gallery tile | OBSERVED (static thumbnail with play icon) | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED |

Selected / Expanded / Collapsed / Loading states: **NOT OBSERVED**.

## 19. Navigation Architecture

**Information architecture (OBSERVED, from nav bar):**
Home, Performers, About Us, Media, Gallery, VSTAR, Plan Your Visit, Get Involved.

**Footer link set (OBSERVED, partially different):** Home, Plan your visit, About Us, Our Team, VStar2026 — note "Our Team" appears only in the footer, not the primary nav; nav's "Media"/"Gallery"/"Get Involved" are not repeated in the footer's Links column.

**Visual/behavioral:**
- Nav renders as a **pill-button list** rather than plain text links — a materially different pattern from Electric Island's flat link list.
- Active-state indication: **OBSERVED and clear** — the current page is a filled pill, unlike Electric Island where no active-state indicator was found.
- Sticky behavior: **OBSERVED** (nav remains visible at top through scroll); exact CSS mechanism **INFERRED**, not confirmed.
- Mobile menu / hamburger pattern: **UNKNOWN** — not observable at the tested 1512px width; a nav with 8 pill items would very likely need to collapse at narrower widths, but the actual pattern (hamburger, horizontal scroll, stacked) was not confirmed.

## 20. Page Templates

```
Festival Homepage (the only template directly observed)
Header (sticky, logo + pill nav + social icons)
↓
Hero (headline + subhead + date/venue + tagline + intro paragraph, full-bleed photo bg)
↓
Recap Video (embedded YouTube)
↓
Festival Day Cards ×4 (alternating image/text, organic photo mask, CTA)
↓
Section Intro ("2026 Headliners")
↓
Performer Carousel ×7 (numeral watermark + photo + name/badges)
↓
Sponsor Video Message
↓
Presenting Sponsor
↓
Community Partners (3-col logo grid)
↓
Media Partners (3-col logo grid)
↓
Get Involved (stat list + sponsor CTA)
↓
Media / Gallery (4-col grid + Load More + Instagram CTA)
↓
Footer (About + Contact + Links + Socials + copyright)
```

Other referenced-but-not-visited templates (from nav/footer): Performers (listing), About Us, Media, Gallery (dedicated page beyond the homepage grid), VSTAR / VStar2026, Plan Your Visit, Get Involved (dedicated page), Our Team — **UNKNOWN** structure, not inspected this session.

## 21. Design Tokens (Consolidated)

See §22 (CSS variables) and §27 (JSON) for the full machine-readable set. Categories with real MEASURED values: Typography (families + several exact sizes/weights), Radius (button/pill), select Spacing (padding on 3 components), select Colors (gold, near-black, muted mauve-grey). Categories that are largely INFERRED or UNKNOWN due to blocked source-CSS access this session: full spacing scale, breakpoints, container max-width, exact gradient stops, shadow/elevation specifics, z-index. Treat this token set as a **starting extraction, not a complete system** — a follow-up session with direct stylesheet access (or DevTools) would substantially raise confidence here.

## 22. CSS Variables

Only MEASURED or directly OBSERVED values are asserted as fact; gradient stops and unmeasured spacing are marked as estimates in comments.

```css
:root {
  /* Color — MEASURED */
  --color-brand-gold: #ffd700;
  --color-text-dark: #202020;
  --color-text-light: #ffffff;
  --color-text-muted: #b1a7a7;
  --color-nav-active-bg: #111111;
  --color-badge-border: #bac8d1; /* measured on one carousel card; varies per performer accent */

  /* Color — INFERRED (visual estimate only, not computed) */
  --color-gradient-start: #fff6d0;  /* approx cream */
  --color-gradient-end: #ff8a1e;    /* approx deep orange */
  --color-footer-bg: #12141c;       /* approx dark navy */

  /* Typography — MEASURED */
  --font-display: Epilogue, sans-serif;
  --font-body: "Work Sans", sans-serif;
  --font-badge: Inter, sans-serif;

  --text-h1-size: 102.816px;
  --text-h1-weight: 500;
  --text-h1-line-height: 102.816px;
  --text-h1-letter-spacing: -4.11264px;

  --text-button-size: 16px;
  --text-button-weight: 600;
  --text-nav-active-size: 14px;
  --text-nav-active-weight: 700;
  --text-badge-size: 19px;
  --text-badge-weight: 500;
  --text-body-size: 16px;
  --text-body-weight: 400;

  /* Spacing — MEASURED (isolated values only, no confirmed base scale) */
  --space-badge-padding: 3px 12px;
  --space-button-padding: 18px 40px;
  --space-nav-pill-padding: 8px 16px;

  /* Radius — MEASURED */
  --radius-button: 8px;
  --radius-pill: 20px;

  /* Radius — OBSERVED but not a simple value */
  --radius-image-mask: organic; /* clip-path / mask, not border-radius */

  /* Borders — MEASURED */
  --border-badge-width: 1px;
}
```

## 23. Component APIs

Proposed for implementation, constrained to observed variants only:

```text
<Button
  variant="primary"          // only confirmed variant this session
  href="..."
>
  View Event Highlights
</Button>

<NavPill
  active={true|false}        // active = filled black pill + gold text; inactive = plain text
  href="..."
>
  Home
</NavPill>

<FestivalDayCard
  eyebrow="INVITATION ONLY"
  heading="DAY 1 – Gala Evening"
  body="Experience an exclusive opening..."
  dateTime="July 16, 6:00 PM to 9:00 PM"
  venue="CONSERVATORY, BRAMPTON CITY HALL"
  ctaLabel="View Event Highlights"
  ctaHref="..."
  imageSrc="..."
  imageMask="blob"            // observed: "blob" | "circle" | "rect" (performer cards)
  layout="image-left" | "image-right"
/>

<PerformerCard
  index={4}
  total={7}
  name="SHALLUM & KHURRAM"
  subName="FUZON"
  genre="Desi Dhamaka"
  month="July"
  day="18"
  footerNote="VIBRANT BRAMPTON 2026"
  backgroundPalette="teal-purple-brown"   // per-card, not a shared token
  imageSrc="..."
/>

<PartnerLogoGrid
  title="COMMUNITY PARTNERS"
  logos={[...]}
  columns={3}
/>

<SiteFooter
  aboutText="..."
  contactEmail="info@acisa.ca"
  linksColumn={[...]}
  socials={["facebook","youtube","instagram","tiktok"]}
  creditLine="Site by TRIOTECHSYSTEMS"
/>
```

Required vs. optional props, exact validation, and responsive slot behavior are **UNKNOWN** beyond what's inferable from the rendered markup.

## 24. Tailwind Mapping

```text
color.brand.primary (#FFD700)     → bg-yellow-400 (close default) or bg-[#FFD700] for exact fidelity
color.text.primary.dark (#202020) → text-neutral-900 (close) or text-[#202020] for exact fidelity
color.text.muted (#B1A7A7)        → text-[#B1A7A7] (no close Tailwind default — mauve-grey is not a standard stop)
radius.button (8px)               → rounded-lg
radius.pill (20px)                → rounded-[20px]  (between Tailwind's rounded-2xl [16px] and rounded-3xl [24px] — keep custom)
button padding (18px 40px)        → py-[18px] px-10
nav-pill padding (8px 16px)       → py-2 px-4
badge padding (3px 12px)          → py-[3px] px-3
font-display (Epilogue)           → font-['Epilogue'] (custom, not in default stack)
font-body (Work Sans)             → font-['Work_Sans'] (custom, not in default stack)
```

Given the largely unmeasured spacing/breakpoint scale, **do not assume this system maps cleanly onto Tailwind's default scale** — use arbitrary values (`[…]`) for anything not explicitly confirmed above rather than rounding to the nearest Tailwind default.

## 25. Accessibility

**Observed:**
- Contrast: gold-on-black (nav active pill) and near-black-on-gold (button) both read as high contrast; white text over photography (hero) has variable contrast depending on the underlying image area — no systematic overlay/scrim was confirmed under the hero text, which is a potential legibility risk depending on image content (**INFERRED risk, not measured**).
- The muted mauve-grey text color (`#B1A7A7`) used for eyebrow labels is a notably **low-contrast choice** against the light cream/gold backgrounds it commonly sits on — this would need a WCAG contrast-ratio check before reuse at small sizes (**not computed this session**).
- Video embeds use standard native/YouTube controls (accessible by default via those platforms).
- Semantic hierarchy: an `<h1>` was found and used for the top-level hero headline; deeper heading usage was not fully audited.

**Recommended (not applied to the extracted system, offered as guidance only):**
- Verify contrast of the mauve-grey muted text against every background it appears on (cream, orange, dark navy footer) — it is reused across very different backgrounds and may fail WCAG AA in some of them.
- Confirm alt text exists on the organic-masked photography and performer images (not inspected this session).
- Given the nav is icon/pill-heavy, verify keyboard focus states and ARIA labeling on the active-pill pattern (not inspected).

## 26. Implementation Architecture

```text
design-system/
├── tokens/
│   ├── colors.ts          (§3 — gold brand accent + warm gradient + per-card decorative palettes)
│   ├── typography.ts       (§4 — Epilogue display/UI, Work Sans body, Inter badges)
│   ├── spacing.ts            (§5 — partial: only 3 confirmed padding values, no full scale)
│   ├── radius.ts               (§9 — 8px rectangular, 20px pill, organic image masks)
│   └── borders.ts                (§10 — 1px badge outline only)
│
├── components/
│   ├── Navbar/                (logo lockup, pill nav, active-state pill, socials, sticky)
│   ├── Button/                 (single confirmed primary variant)
│   ├── FestivalDayCard/         (alternating layout, organic image mask)
│   ├── PerformerCard/            (numeral watermark, per-card palette, badges)
│   ├── PartnerLogoGrid/            (3-col, reused for 2 sections)
│   ├── MediaGalleryGrid/            (4-col, photo + video tiles)
│   └── Footer/                       (About/Contact/Links/Socials)
│
├── patterns/
│   ├── FestivalDaySequence/    (composes FestivalDayCard × 4, alternating)
│   ├── PerformerShowcase/       (composes PerformerCard × N, stacked)
│   ├── SponsorSection/           (video + presenting sponsor + partner grids)
│   └── GetInvolvedSection/        (stat list + CTA)
│
└── templates/
    └── FestivalHomepage/          (§20 page template order)
```

**Note:** because this report's source-CSS access was blocked, treat the tokens above as a **verified-but-partial extraction**. Before a production rebuild, re-run this audit with direct DevTools/stylesheet access to fill in the full spacing scale, breakpoints, gradient stop values, and hover/focus states that could not be captured through computed-style sampling alone.

## 27. Machine-Readable JSON

See the accompanying `tokens.json` file (full contents below).

```json
{
  "brand": {
    "name": "Vibrant Brampton Summer Fest",
    "edition": "2026 (11th Annual)",
    "platform": "WordPress (custom theme, page-builder structure inferred)"
  },
  "colors": {
    "brand": { "primary": "#ffd700" },
    "text": {
      "dark": "#202020",
      "light": "#ffffff",
      "muted": "#b1a7a7"
    },
    "nav": { "activeBackground": "#111111" },
    "badge": { "border": "#bac8d1" },
    "estimated": {
      "gradientStart": "#fff6d0",
      "gradientEnd": "#ff8a1e",
      "footerBackground": "#12141c"
    }
  },
  "typography": {
    "families": {
      "display": "Epilogue, sans-serif",
      "body": "\"Work Sans\", sans-serif",
      "badge": "Inter, sans-serif"
    },
    "scale": {
      "h1": { "sizePx": 102.816, "weight": 500, "lineHeightPx": 102.816, "letterSpacingPx": -4.11264 },
      "button": { "sizePx": 16, "weight": 600 },
      "navActive": { "sizePx": 14, "weight": 700 },
      "badge": { "sizePx": 19, "weight": 500 },
      "body": { "sizePx": 16, "weight": 400 }
    }
  },
  "spacing": {
    "measured": {
      "badgePadding": "3px 12px",
      "buttonPadding": "18px 40px",
      "navPillPadding": "8px 16px"
    },
    "fullScale": "UNKNOWN — not derivable without source CSS access"
  },
  "radius": {
    "button": "8px",
    "pill": "20px",
    "imageMask": "organic (clip-path/mask, not a radius value)"
  },
  "borders": {
    "badgeWidth": "1px"
  },
  "shadows": {
    "status": "not clearly observed; translucent panels used instead of shadow-based elevation"
  },
  "breakpoints": {
    "status": "UNKNOWN — not measurable this session"
  },
  "components": {
    "navbar": { "style": "pill-nav", "activeIndicator": "filled-pill", "sticky": true },
    "button": { "variants": ["primary"], "radius": "8px", "padding": "18px 40px" },
    "festivalDayCard": { "count": 4, "layout": "alternating", "imageMask": "blob" },
    "performerCard": { "count": 7, "hasNumeralWatermark": true, "badgeRadius": "20px" },
    "partnerLogoGrid": { "columns": 3, "instances": ["Community Partners", "Media Partners"] },
    "mediaGalleryGrid": { "columns": 4 },
    "footer": { "background": "dark", "columns": ["About/Contact", "Links", "Get in Touch"] }
  },
  "patterns": {
    "pageTemplate": [
      "Header", "Hero", "RecapVideo", "FestivalDayCards",
      "SectionIntro", "PerformerCarousel", "SponsorVideo",
      "PresentingSponsor", "CommunityPartners", "MediaPartners",
      "GetInvolved", "MediaGallery", "Footer"
    ]
  }
}
```

## 28. Observed vs Measured vs Inferred vs Unknown — Summary

| Category | Status breakdown |
|---|---|
| Core accent color (gold) | MEASURED |
| Warm background gradient stops | INFERRED (visual estimate only) |
| Font families | MEASURED (computed style on multiple elements) |
| Full type scale (all headings) | Partially MEASURED (h1 only), rest INFERRED/visual |
| Spacing — 3 component paddings | MEASURED |
| Full spacing scale | **UNKNOWN** |
| Radius (button, pill) | MEASURED |
| Image mask mechanism | INFERRED (visually organic, mechanism not confirmed) |
| Shadows/elevation | Largely absent — INFERRED translucency rather than shadow |
| Breakpoints | **UNKNOWN** |
| Mobile/tablet rendered layout | **UNKNOWN** — viewport resize unavailable this session |
| Sticky-nav CSS mechanism | INFERRED (effect OBSERVED, implementation uncertain) |
| Hover/focus/active states | Mostly **NOT OBSERVED** (only the nav's persistent active-pill state was captured) |
| Icon library source | **UNKNOWN** |
| Source stylesheet content | **BLOCKED** this session (data-safety filter on this domain) — all findings are computed-style/visual, not source-CSS-derived |

## 29. Recommendations for Recreating the Visual System

1. **Treat the low-poly triangle-mosaic-on-warm-gradient as the connective background motif**, the way Electric Island uses the duotone photo filter — apply it consistently behind every major section rather than treating it as a one-off hero effect.
2. **Keep headline type in mixed case**, not uppercase — this is a deliberate, consistent choice throughout (hero, day headings) and is part of what makes the tone feel welcoming rather than commanding.
3. **Preserve the organic/blob and circle photo masks** for day-card and secondary imagery; do not default to plain rectangular crops, which would flatten a distinctive part of the identity.
4. **Keep the "per-card unique palette" approach in the performer carousel** — resist the instinct to unify all seven cards onto one shared accent color; the intentional variety is core to the "many sounds" concept.
5. **Reserve the fully-round pill radius for badges and the active-nav indicator only**; use the flatter 8px radius for rectangular UI like buttons — do not make buttons fully round, which would blur the distinction this system draws between "action" (rectangular button) and "status/tag" (round pill).
6. **Re-run a follow-up technical audit with direct stylesheet/DevTools access** before finalizing a production token set — this report's spacing scale, breakpoints, and gradient stop values are the weakest-evidence sections and should not be treated as final without that follow-up (see §28).
7. **Do not introduce drop shadows or hard card borders** — this system's softness comes from translucency and color, and adding conventional elevation would fight the source's tone the same way it would on Electric Island, for the opposite reason (busy/warm vs. flat/stark).
