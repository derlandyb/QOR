# Toronto Caribbean Carnival — Design System Specification
### Reverse-engineered from https://torontocarnival.ca/ (captured 2026-08-22)

**Method:** Live inspection of the rendered homepage via headless browser (desktop viewport 1512×797), computed-style extraction (`getComputedStyle`) on headings, navigation, buttons, and footer elements, plus direct visual observation across the full page (5,917px tall). The site is a **WordPress build on a heavily template-kit-based theme**: `document.fonts` returned dozens of unloaded font families whose names match common Elementor/page-builder demo-kit categories (`digital`, `beauty-spa`, `fitness`, `hosting-template`, `mechanic`, `Influencer-Set`), indicating the theme ships with many unused pre-built page templates and this site uses only a subset of them. Icon fonts present include Dashicons, Ionicons, and two Font Awesome 6 sets. Only six font families actually render on this page: **Barlow, Inter, Montserrat, Kantumruy Pro, Oswald/Outfit (present but not confirmed rendered), and Sacramento** (a script face, present in the font list but not confirmed visually rendered anywhere on this page). This report is built entirely from computed-style/visual evidence — no raw stylesheet was fetched.

**Important caveat before reading further:** unlike the electricisland.to and vibrantbrampton.ca audits, this site does **not** present a single coherent, intentional visual system. Evidence gathered below shows a different accent color used almost per-section (magenta, purple, teal, orange/brown, green, blue all appear as "primary" heading/button colors in different places), inconsistent button shapes (a sharp-cornered chamfered pill, a plain rounded pill, and a two-color gradient pill all coexist), and duplicate/near-empty heading tags in the DOM. This reads as a page assembled from multiple independent page-builder section templates rather than a designed system with shared tokens. Per the audit's own rules ("do not invent variants," "distinguish observations from assumptions"), this report documents what is actually there — including the inconsistency itself — rather than smoothing it into a false single system. Treat this specification as a **catalog of the patterns in current use**, useful for matching the site's existing look, rather than as evidence of a deliberate token architecture to imitate structurally.

---

## 1. Executive Summary

Toronto Caribbean Carnival's homepage is built from a sequence of visually distinct, independently-styled page-builder sections stitched together with decorative SVG divider graphics (an audio-equalizer/soundwave bar pattern, a jagged mountain-peak zigzag, layered translucent wave shapes). Photography is vivid, full-color carnival costume and performer imagery (feathers, sequins, masquerade headdresses) used in circular photo masks and full-bleed collage banners with a neon-glow text treatment. Typography leans on bold, heavy-weight Montserrat for major headings and Barlow for secondary text and navigation. Rather than one brand accent color, the page cycles through several: hot magenta/pink for the (largely hidden/SEO) H1 and one primary button, purple for subheadings and nav links, and a distinct color per "Get Involved" CTA column (teal, orange-brown, green). A recurring gradient-fill pill button (magenta-to-orange) appears at higher-emphasis moments (footer CTAs). The footer transitions from a purple gradient to near-black and carries a 4-column link structure, a small rainbow-syllable wordmark echo, and a sponsor-logo row.

## 2. Visual Identity

- **OBSERVED** — Photography is vivid, full-color, unfiltered Caribbean carnival costume/performance imagery — feathers, sequins, elaborate headdresses — the visual opposite of Electric Island's duotone treatment and distinct even from Vibrant Brampton's warm-but-still-photographic approach; the color *comes from* the subject matter itself rather than an applied filter.
- **OBSERVED** — The "Events" section banner uses a **neon-glow oversized wordmark** ("Events") overlaid directly on a photo collage of costumed performers, with a soft pink/purple bloom/glow effect around the letterforms — the one clearly deliberate "effect" treatment on the page.
- **OBSERVED** — Section-to-section transitions are marked by **unique decorative SVG divider shapes** — a purple vertical-bar audio-equalizer/soundwave pattern, a jagged mountain-peak zigzag, and layered translucent wave silhouettes are each used exactly once, not as a repeating system element — this is a "different divider per transition" approach rather than one reusable divider component.
- **OBSERVED** — Color usage is **not unified around a single brand accent**: the (largely non-visible) H1 and one CTA button are hot magenta/pink (`#ED177A`); subheadings, links, and nav items are purple (`#9E5AFF`); the three "Get Involved" CTAs are individually teal, orange-brown, and green; the footer runs on a purple-to-black gradient. No single color recurs across more than two or three of these contexts.
- **OBSERVED** — Circular photo masks are used for both the "Our Story" feature image and the board-of-directors headshot grid — the one consistently reused image-shape convention on the page.
- **INFERRED** — The overall personality reads as "energetic community festival site assembled from a page-builder's decorative section library" — vibrant and colorful by way of *photographic subject matter and varied decorative widgets*, rather than a controlled, intentional palette the way Electric Island (single accent) or even Vibrant Brampton (one fixed gold accent + varied decorative palettes) are controlled.
- **NOT OBSERVED** — a single wordmark/logotype color scheme is used consistently: the main header logo is a rainbow-gradient "TORONTO...CARNIVAL" lockup with a multicolor feather/flame icon, and this same rainbow-per-letter treatment recurs in miniature in the footer ("ToronTOCarnival") — this *is* a consistently reused brand mark, even though the surrounding page's accent colors are not consistent with it or each other.

## 3. Color System

| Token | Value | Usage | Evidence |
|---|---|---|---|
| `color.accent.magenta` | `rgb(237,23,122)` (`#ED177A`) | Primary (SEO/hidden) H1 color; primary "Learn More" button fill | MEASURED |
| `color.accent.purple` | `rgb(158,90,255)` (`#9E5AFF`) | Nav links (Home/Events), hero intro subheading, "Our Story" heading fragment, inline link color | MEASURED |
| `color.accent.teal` | Visually ≈`#3FB6C9`-range (gradient) | "Join A Band" heading + button gradient | OBSERVED (visual only, not computed) |
| `color.accent.orange-brown` | Visually ≈`#C9820F`-range (gradient) | "Be A Vendor" heading + button gradient | OBSERVED (visual only) |
| `color.accent.green` | Visually ≈`#4C9A2A`-range (gradient) | "Be A Volunteer" heading + button gradient | OBSERVED (visual only) |
| `color.gradient.cta` | Magenta → orange (`#ED177A`-ish → `#F5A623`-ish) | "Explore Bands" / "Sponsor Now" footer-area pill buttons | OBSERVED (visual only) |
| `color.background.footer.top` | Medium purple (visually ≈`#7B3FE4`) | Footer top / CTA band | OBSERVED (visual only) |
| `color.background.footer.bottom` | Near-black (visually ≈`#0F0620`) | Footer link columns / copyright bar | OBSERVED (visual only) |
| `color.text.body` | Dark indigo/near-black (visually ≈`#2B2650`) | "Our Story" and general paragraph copy | OBSERVED |
| `color.text.gold-label` | Orange/gold (visually ≈`#F5A623`) | Footer column headers ("Our Story:", "Site Link:", "Legal:"), "Head Office:" label | OBSERVED |
| `color.ui.nav-pill-bg` | Pale pink/lavender (visually ≈`#FBEAF5`) | Nav item pill backgrounds (Home/Events/About Us) | OBSERVED |

**Note on color architecture:** unlike the two prior audits, this system shows **no evidence of a shared token set governing color** — each section/component appears to carry its own independently-chosen accent, including three different colors across three adjacent CTA columns in the same section. A rebuild aiming for visual fidelity should reproduce this section-by-section palette variety rather than attempt to consolidate it into fewer tokens, per the "do not invent" rule — but a rebuild aiming for a *cleaner* system should flag this as the single biggest improvement opportunity (see §29).

## 4. Typography System

**Font families (MEASURED via computed style + confirmed loaded in `document.fonts`):**

| Role | Family | Evidence |
|---|---|---|
| Major headings, buttons | **Montserrat** (weights 400/500/600/700/800 loaded) | MEASURED (H1, "Learn More" and "Sponsor Now" buttons all compute to `Montserrat`) |
| Secondary headings, nav, intro copy | **Barlow** (weight 500 loaded, others present unloaded) | MEASURED (hero subheading, "Our Story" fragment, nav links) |
| Body/UI (loaded, not isolated to a specific measured element this session) | **Inter** (300/400/500/600 loaded) | INFERRED — confirmed loaded in `document.fonts`, but no body-paragraph element was isolated and measured directly this session |
| Present but unconfirmed in rendered use | **Kantumruy Pro, Oswald, Outfit, Sacramento** (script) | Listed as loaded/present font-face declarations; **not confirmed visually rendered** anywhere on the captured page — do not assume these are active brand fonts without further verification |

| Token | Font | Size (MEASURED) | Weight | Line Height | Color | Usage |
|---|---|---:|---:|---:|---|---|
| `typography.h1` | Montserrat | `60px` | `800` | `96px` (1.6×, very loose) | `#ED177A` | Site-title H1 — appears **duplicated multiple times in the DOM** and was not visually located as large on-page magenta text in any screenshot; likely a visually-hidden/SEO-only heading rather than the visible hero banner text |
| `typography.hero-intro` | Barlow, Arial, Helvetica, sans-serif | `26px` | `500` | `39px` (1.5×) | `#9E5AFF` | "Discover Toronto Caribbean Carnival Events 2026" intro line |
| `typography.section-label` | Barlow, Arial, Helvetica, sans-serif | `14px` | `500` | `23.8px` (1.7×) | `#9E5AFF` | Small purple label/link fragments |
| `typography.button.primary` | Montserrat | `18px` | `500` | normal | `#fff` on `#ED177A` fill | "Learn More" filled button |
| `typography.button.outline` | Montserrat | `13px` | `500` | normal | `#fff` on transparent, 2px white border | Small outline CTA variant |
| `typography.h3.footer` | Montserrat | `21px` | `500` | `29.4px` (1.4×) | `rgba(0,0,0,.65)` | "Get In Touch"-style H3 (found in DOM; exact on-page usage not visually isolated) |

Compared to both prior audits, this system's type scale shows **notably loose line-heights** (1.4×–1.7× the font size) rather than the tight (≈1×) line-heights seen on Electric Island and Vibrant Brampton — a genuine, measured structural difference worth preserving if matching this site specifically.

## 5. Spacing System

**UNKNOWN** — no source CSS access this session and no systematic padding/margin measurement across enough components to derive a scale. The only directly measured spacing values are button paddings (§9/§16). A full spacing scale cannot be responsibly reported without further measurement; do not assume a scale from the other two audits transfers here — these are three unrelated codebases.

## 6. Layout System

- **OBSERVED** — Full page height at this viewport: **5,917px** — a long, single-scroll homepage assembling roughly a dozen distinct sections.
- **OBSERVED** — `document.body` computed `overflow: hidden scroll` — mouse-wheel scroll events did not reliably advance the page in this session's automation; direct `window.scrollTo()` calls were required to move through the page. This suggests a custom scroll-handling script (common with "smooth scroll" or parallax plugins) intercepts/overrides default scroll behavior — **INFERRED** mechanism, **OBSERVED** effect.
- **OBSERVED** — Content below the fold **lazy-loads its imagery** — the event-flyer row and sponsor-logo row both rendered as empty black-outlined placeholder boxes immediately on page load / before being scrolled into view, then populated with real images once scrolled to. This is a functioning lazy-load pattern, not a broken state — worth noting for implementation (§26) but not a design flaw.
- **OBSERVED** — Section widths alternate between a constrained centered column (hero intro card, "Our Story" text block) and full-bleed edge-to-edge treatments (Events photo banner, decorative dividers, footer).
- **OBSERVED** — The "Get Involved" section uses a **3-column layout with vertically offset/staggered card backgrounds** (alternating light-grey and white zones, not aligned to a single row) — a deliberately asymmetric composition rather than a uniform grid.
- **OBSERVED** — The board-of-directors section is a **horizontally-scrolling carousel** with visible previous/next arrow controls, not a static grid.
- **UNKNOWN** — container max-width and horizontal gutter values were not measured.

## 7. Grid & Alignment

```
Page
├── Header (logo center, pill-style nav left, mystery icon-button right)
├── Hero Intro Card (centered text block on light grey-to-white gradient)
├── "Events" Photo/Neon-Text Banner (full-bleed)
├── Event Flyer Row (lazy-loaded, horizontal row of poster-style cards)
├── "Our Story" (two-column: text block left, circular photo right)
├── Soundwave/Equalizer Divider (decorative, full-bleed)
├── Purple Gradient Photo Panel (full-bleed, feather/costume texture)
├── "Get Involved" 3-Column CTAs (Join a Band / Be a Vendor / Be a Volunteer — staggered backgrounds, each its own accent color)
├── Board of Directors Carousel (circular headshots, name captions, arrow nav)
├── Purple-to-black Gradient Panel (transitional, mostly empty at capture time)
├── Jagged Mountain-Peak Divider (decorative, full-bleed)
├── Layered Wave Divider (decorative, full-bleed)
├── Contact/CTA Band (Head Office address + Explore Bands / Sponsor Now pill buttons, purple gradient bg)
└── Footer (4-column links, mini rainbow wordmark, secondary nav, sponsor logo row, utility bar, copyright)
```

- **OBSERVED** — No single shared left/right gutter could be confirmed across sections — the hero intro card, "Our Story" block, and footer columns each appear to use their own container width, consistent with the "assembled from independent sections" reading in §1.
- **OBSERVED** — Section headings are inconsistently aligned: some centered (hero intro, "Events"), some left-aligned within a two-column split ("Our Story", "Get Involved" columns).

## 8. Responsive System

- **UNKNOWN** — No breakpoints could be measured (no source CSS access, no viewport resize available this session).
- **UNKNOWN** — Mobile nav pattern, grid stacking, and type scaling were not observable.
- **OBSERVED** — No horizontal scrolling occurred at the 1512px capture width (aside from the intentional board-of-directors carousel).

## 9. Radius System

| Token | Value | Usage | Evidence |
|---|---|---|---|
| `radius.button.chamfered` | `5px 35px 35px 5px` (asymmetric — near-sharp left corners, fully rounded right corners) | "Learn More" primary magenta button | MEASURED — a distinctive, unusual shape not seen on either prior audited site |
| `radius.button.pill` | `50px` | Outline/transparent secondary button | MEASURED |
| `radius.button.gradient-pill` | Visually fully round | "Explore Bands" / "Sponsor Now" gradient CTAs | OBSERVED (visual only) |
| `radius.card.event-flyer` | Visually small/near-sharp (~4–8px) | Event flyer poster cards | OBSERVED (visual only) |
| `radius.avatar.circle` | `50%` (full circle) | Board-of-directors headshots, "Our Story" feature photo | OBSERVED |
| `radius.sponsor-tile` | Visually small (~4–6px), near-sharp | Sponsor logo tiles (bordered white rectangles) | OBSERVED (visual only) |

The **asymmetric chamfered radius** (`5px 35px 35px 5px`) on the primary button is the single most distinctive, specific shape signature found in this audit — a deliberate design choice worth preserving exactly if replicating this site, even though it does not recur elsewhere in the measured components.

## 10. Border System

- **MEASURED** — Outline button: `2px solid #ffffff`.
- **OBSERVED** — Sponsor logo tiles: thin dark border (~1–2px, near-black) around each white logo card.
- **OBSERVED** — Board-of-directors carousel photo tiles: thin light border between adjacent headshots.
- **NOT OBSERVED** — no border on the primary magenta or gradient-pill buttons (edges defined by fill color only).

## 11. Shadows and Elevation

- **NOT OBSERVED** — no drop shadows were visible on buttons, cards, or the photo elements captured this session.
- **OBSERVED** — Depth is instead suggested through **layered decorative graphics** (the wave dividers overlap section boundaries) and gradient panels rather than shadow-based elevation — consistent with the "no shadow system" pattern seen on both prior audited sites, though for a third distinct stylistic reason (decorative-graphic layering rather than flat-opacity contrast or photographic translucency).

## 12. Iconography

- **OBSERVED** — Multiple icon font families are loaded (Dashicons, Ionicons, Font Awesome 6 Free/Brands) — standard WordPress-plugin-bundled icon sets, confirming a conventional WP plugin stack rather than custom iconography.
- **OBSERVED** — Previous/next arrow controls on the board-of-directors carousel: simple circular buttons with chevron-style arrow glyphs.
- **OBSERVED** — Chevron-right icons (`›`) appear inside the "Explore Bands" and "Sponsor Now" pill buttons.
- **OBSERVED (DOM-level oddity)** — At least one `<h1>` element's text content renders as the literal string **"arrow_forward"** rather than a visible glyph — this is the ligature name used by Google's Material Symbols/Icons font convention (a `<span>` intended to display an icon via a ligature-mapped font). Since this text was not visually located as readable on-page content in any screenshot, it is most likely a zero-size or visually-hidden element rather than a user-facing bug — but it indicates an icon component whose intended font may not always resolve correctly, which is worth a direct code-level check before reuse. **OBSERVED as a DOM fact; user-facing severity UNKNOWN.**
- **UNKNOWN** — no additional custom icon styling (stroke width, fill vs. outline convention) was systematically measured.

## 13. Image System

- **OBSERVED** — Full-color, high-saturation event/costume photography — feathers, sequins, elaborate carnival headdresses — used both as full-bleed collage banners (with a neon-glow text overlay) and as individually-masked feature images.
- **OBSERVED** — Two photo-masking conventions: **circular crops** (Our Story feature image, board-of-directors headshots) and **plain rectangular crops** (event flyers, sponsor logos, purple gradient panel background).
- **OBSERVED** — Event flyer images are literal **designed poster/flyer graphics** (title art, QR code, "FOR MORE INFORMATION VISIT OUR WEBSITE" caption, Toronto Carnival watermark) rather than photographs — a distinct content type from the site's other photographic sections.
- **OBSERVED** — Sponsor logos are shown as **flat brand marks on plain white rectangular tiles** with a thin dark border — Government of Canada, Toronto FC, STC, TTC, Hotel X Toronto, and Ontario Science Centre were all directly visible.
- **OBSERVED** — Images below the fold are **lazy-loaded** (render as empty bordered placeholders until scrolled into view) — see §6.
- **UNKNOWN** — exact aspect ratios and responsive `srcset` behavior were not inspected.

## 14. Motion System

| Element | Trigger | Behavior | Evidence |
|---|---|---|---|
| Board-of-directors carousel | Click arrow controls | Horizontal scroll/slide to next set of headshots | OBSERVED (arrow controls present; actual slide transition not captured mid-motion) |
| Page scroll | Mouse wheel | Did not reliably register in this automated session; required direct `scrollTo()` calls — suggests a custom scroll-handling/smooth-scroll script is present | OBSERVED (effect), INFERRED (mechanism) |
| Image lazy-load | Scroll into view | Placeholder → populated image swap | OBSERVED |
| Neon-glow "Events" text | Static (possibly animated glow/pulse in production, not confirmed) | Soft bloom/glow effect around large wordmark | OBSERVED as a static effect this session; a pulsing/breathing glow animation is plausible for this visual style but **NOT CONFIRMED** |

- **NOT OBSERVED** — scroll-reveal fade-ins, parallax, marquee/ticker text, or countdown timers (all present on one or both of the previously audited sites, absent or unconfirmed here).

## 15. Component Inventory

Present and directly observed:

- Header / Navbar (rainbow-gradient logo, pill-style nav links, unidentified icon-button control)
- Hero Intro Card (gradient background panel, centered heading + paragraph)
- Full-Bleed Photo Banner with Neon-Glow Text ("Events")
- Event Flyer Card (lazy-loaded poster graphic + QR code + caption)
- Two-Column Feature Block ("Our Story": text + circular photo)
- Decorative Section Dividers (equalizer bars, mountain zigzag, layered waves) — three distinct one-off graphics, not a single reusable component
- Get-Involved CTA Column (heading + quote-style paragraph + gradient button) × 3, each independently colored
- Board of Directors Carousel (circular headshot + name caption, arrow navigation)
- Contact/CTA Band (address block + two pill buttons)
- Footer (4-column links, mini wordmark, secondary nav, sponsor logo grid, utility bar, copyright)

Not present / not found on the homepage: countdown timer, testimonials, tabs, accordions, pricing tables, marquee ticker, video embeds.

## 16. Component Anatomy

### Header / Navbar
```
Anatomy:
- Rainbow-gradient "TORONTO CARIBBEAN CARNIVAL" logo lockup with multicolor feather/flame icon, center
- Pill-style nav items (Home, Events, About Us), left, each on a pale pink/lavender pill background
- An icon-only button with a dropdown chevron, right — function not identified this session (possibly a language/region or menu toggle)
Typography: Barlow 500 14px for nav link text, color purple (#9E5AFF) on the two measured instances
Colors: pale pink/lavender pill backgrounds, mixed text colors per item (observed as brownish for "Home", purple for others — not fully explained by the two computed samples, which both returned the same purple)
```

### Button — Primary (chamfered)
```
Anatomy: single filled shape, label + no icon
Typography: Montserrat 500 18px, white text
Colors: background #ED177A (magenta)
Radius: 5px 35px 35px 5px (asymmetric — sharp-left, round-right)
Padding: 17px 40px
Border: none
Usage: "Learn More" (hero-area CTA)
```

### Button — Outline (small)
```
Anatomy: single transparent-fill shape with border, label + no icon
Typography: Montserrat 500 13px, white text
Colors: transparent background, 2px solid white border
Radius: 50px (full pill)
Padding: 11px 23px
```

### Button — Gradient Pill
```
Anatomy: filled pill shape, label + trailing chevron icon
Colors: magenta-to-orange gradient fill, white text
Radius: fully round (visual)
Usage: "Explore Bands", "Sponsor Now" (footer-area CTAs)
Evidence: OBSERVED (visual), not computed this session
```

### Get-Involved CTA Column
```
Anatomy:
- Heading (bold, colored — unique per column)
- Quote-styled paragraph in quotation marks, with one or two words highlighted in a link-like accent color
- Gradient pill/rounded button ("Learn More"), colored to match the column's accent
Repeats: 3 instances ("Join A Band" – teal, "Be A Vendor" – orange/brown, "Be A Volunteer" – green)
Layout: staggered vertical offset between adjacent columns, alternating light-grey/white backgrounds
```

### Board of Directors Carousel
```
Anatomy: horizontally arranged circular(ish) headshot tiles with a semi-transparent dark caption bar at the bottom of each showing the person's name; left/right circular arrow controls
Typography: white text over photo, standard body size
Interaction: click-to-advance carousel (arrows), OBSERVED not to auto-rotate within the capture window (not conclusively tested for autoplay)
```

### Footer
```
Anatomy:
- Purple-gradient upper band containing: address ("Head Office:" + street address), "Explore Bands" / "Sponsor Now" gradient pill buttons
- 4-column link section on darkening gradient: "Our Story:" (blurb + link), "Site Link:" ×2 (Who We Are/Events/Gallery/Careers/Our Story; Marketplace/Volunteer/Our Core/Donate/Impact), "Legal:" (Terms/Privacy/FAQ/Support/Contest Rules)
- Mini rainbow-syllable wordmark ("ToronTOCarnival") + secondary nav (Blog | Help | Login | Newsletter)
- "Our Sponsors" logo row (6 flat white-tile logos, lazy-loaded)
- Bottom utility bar (Privacy Policy | Terms Of Use | Contest Rules | COVID Protocols) + copyright line
Colors: purple-to-near-black vertical gradient, gold/orange column headers, white/lavender link text
```

## 17. Component Variants

- **Button:** at least **three visually distinct shapes** were found — asymmetric chamfered-pill (magenta, "Learn More"), plain rounded pill with outline (transparent, small CTA), and full gradient pill (magenta-to-orange, footer CTAs) — this is a genuinely inconsistent set, not one component with clean variants; a rebuild should either reproduce all three as-is or flag consolidating them as a recommended fix (§29).
- **CTA column accent color:** three independently-colored instances confirmed (teal/orange-brown/green) — no evidence of a fourth or of the colors being systematically assignable (e.g., no clear rule like "teal = participate, green = give back" was confirmed from copy alone).
- **Photo mask:** two confirmed types (circle, plain rectangle) — no blob/organic mask evidence found here (contrast with Vibrant Brampton).

## 18. Interaction States

| Component | Default | Hover | Focus | Active | Disabled |
|---|---|---|---|---|---|
| Nav pill link | OBSERVED (pale pill bg, colored text) | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED | — |
| Primary button | OBSERVED (magenta fill) | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED |
| Carousel arrow | OBSERVED (circular icon button, default state) | NOT OBSERVED | NOT OBSERVED | NOT OBSERVED | — |
| Lazy-loaded image | OBSERVED (empty bordered placeholder → populated) | — | — | — | — |

Selected / Expanded / Collapsed / Loading (aside from image lazy-load) states: **NOT OBSERVED**.

## 19. Navigation Architecture

**Primary nav (OBSERVED):** Home, Events, About Us.

**Footer link columns (OBSERVED, three separate groups):**
- "Our Story:" — Learn More About TCC (single link)
- "Site Link:" (first) — Who We Are, Events, Gallery, Careers, Our Story
- "Site Link:" (second) — Marketplace, Volunteer, Our Core, Donate, Impact
- "Legal:" — Terms & Conditions, Privacy Policy, FAQ, Support, Contest Rules
- Secondary utility row — Blog, Help, Login, Newsletter
- Bottom utility bar — Privacy Policy, Terms Of Use, Contest Rules, COVID Protocols

Note the primary nav (3 items) is far sparser than the footer's implied site map (15+ distinct links across About/Events/Gallery/Careers/Marketplace/Volunteer/Donate/Impact/Blog/etc.) — most of the site's actual structure is only discoverable via the footer, not the header nav. **OBSERVED**, and worth flagging as an information-architecture inconsistency rather than a visual-design one.

- **Sticky/fixed header:** **UNKNOWN** — not conclusively tested this session.
- **Active-state indication:** **NOT OBSERVED** — no current-page highlighting was confirmed in the nav pills.
- **Mobile menu:** **UNKNOWN** — not observable at the tested 1512px width.

## 20. Page Templates

```
Festival Homepage (the only template directly observed)
Header (logo + 3-item pill nav)
↓
Hero Intro Card
↓
Events Photo/Neon-Text Banner
↓
Event Flyer Row (lazy-loaded)
↓
Our Story (text + circular photo)
↓
Decorative Divider (equalizer bars)
↓
Purple Gradient Photo Panel
↓
Get Involved (3 independently-colored CTA columns)
↓
Board of Directors Carousel
↓
Purple-to-black Gradient Panel
↓
Decorative Dividers (mountain zigzag, layered waves)
↓
Contact/CTA Band (address + 2 pill buttons)
↓
Footer (4-column links, wordmark, sponsors, copyright)
```

Other referenced-but-not-visited pages (from nav/footer): About Us, Events (listing), Gallery, Careers, Marketplace, Volunteer, Our Core, Donate, Impact, Blog, Help, Login, Newsletter, FAQ, Support, Contest Rules, COVID Protocols — **UNKNOWN** structure, not inspected this session.

## 21. Design Tokens (Consolidated)

Given the fragmented color evidence (§3) and unmeasured spacing (§5), this system yields a **much thinner confirmed token set** than the other two audits. Confirmed with real values: select typography (2 families, several sizes/weights), 2 button radii, 1 border width, a handful of hex/rgb colors. Everything else (full color palette, spacing scale, breakpoints, shadows, z-index) is UNKNOWN or visual-estimate-only. See §27 for the full JSON, which is intentionally sparse rather than padded with invented values.

## 22. CSS Variables

```css
:root {
  /* Color — MEASURED */
  --color-accent-magenta: #ed177a;
  --color-accent-purple: #9e5aff;
  --color-text-body: #2b2650; /* visual estimate */
  --color-text-gold-label: #f5a623; /* visual estimate */
  --color-nav-pill-bg: #fbeaf5; /* visual estimate */
  --color-footer-top: #7b3fe4; /* visual estimate */
  --color-footer-bottom: #0f0620; /* visual estimate */

  /* Color — per-section accents, NOT a shared token set (see §3) */
  --color-cta-teal: #3fb6c9; /* visual estimate */
  --color-cta-orange: #c9820f; /* visual estimate */
  --color-cta-green: #4c9a2a; /* visual estimate */

  /* Typography — MEASURED */
  --font-heading: Montserrat, sans-serif;
  --font-body-alt: Barlow, Arial, Helvetica, sans-serif;

  --text-h1-size: 60px;
  --text-h1-weight: 800;
  --text-h1-line-height: 96px;

  --text-hero-intro-size: 26px;
  --text-hero-intro-weight: 500;
  --text-hero-intro-line-height: 39px;

  --text-button-primary-size: 18px;
  --text-button-outline-size: 13px;

  /* Radius — MEASURED */
  --radius-button-chamfered: 5px 35px 35px 5px;
  --radius-button-pill: 50px;

  /* Borders — MEASURED */
  --border-outline-button: 2px solid #ffffff;

  /* Spacing — MEASURED (isolated values only) */
  --space-button-primary-padding: 17px 40px;
  --space-button-outline-padding: 11px 23px;
}
```

## 23. Component APIs

```text
<Button
  variant="primary-chamfered" | "outline" | "gradient-pill"   // three confirmed shapes, not unified
  href="..."
>
  Learn More
</Button>

<CTAColumn
  heading="Join A Band"
  accentColor="teal"          // per-instance, not a shared token (teal | orange | green confirmed)
  quote="Want to participate in the 2026 Toronto Caribbean Carnival? Join a band and play mas!"
  ctaLabel="Learn More"
  ctaHref="..."
/>

<EventFlyerCard
  posterImageSrc="..."
  qrCodeSrc="..."
  caption="FOR MORE INFORMATION VISIT OUR WEBSITE"
/>

<DirectorCard
  name="Anne Marie"
  photoSrc="..."
/>

<SiteFooter
  addressLines={["716 Gordon Baker Road, Suite 201", "Toronto, Ontario, Canada M2H3B4"]}
  phone="(416) 391-5608"
  linkColumns={[...]}
  sponsors={[...]}
/>
```

Required vs. optional props, validation, and responsive behavior are **UNKNOWN** beyond what's inferable from rendered markup.

## 24. Tailwind Mapping

```text
color.accent.magenta (#ED177A)  → text-pink-600 / bg-pink-600 (close default) or bg-[#ED177A] for exact fidelity
color.accent.purple (#9E5AFF)   → text-violet-400 (close) or text-[#9E5AFF] for exact fidelity
radius.button.pill (50px)       → rounded-full
radius.button.chamfered         → rounded-l-[5px] rounded-r-[35px]  (no Tailwind default covers this asymmetric shape — must be custom)
border.outline (2px white)      → border-2 border-white
button padding (17px 40px)      → py-[17px] px-10
```

Given the thin, fragmented evidence base (§21), **resist mapping unmeasured colors/spacing to Tailwind defaults** — only the values explicitly marked MEASURED above should be treated as ground truth; everything else is a visual approximation and should be re-verified against the live site before being hard-coded into a design system.

## 25. Accessibility

**Observed:**
- Duplicate/multiple `<h1>` elements exist in the DOM (see §12/§14) — multiple `<h1>`s on one page is a common WCAG/SEO concern; the practical impact depends on which are visually hidden vs. rendered, which was not fully resolved this session.
- The gold/orange footer label color and purple accent color both read as reasonably high-contrast against their respective dark/light backgrounds in screenshots, but no contrast ratios were computed.
- The board-of-directors carousel has visible, clickable arrow controls (a positive sign for non-drag-dependent interaction), but keyboard operability was not tested.
- Lazy-loaded images (§6, §13) should be checked for proper `alt` text and loading-state accessibility (e.g., `aria-busy`) — not inspected this session.

**Recommended (not applied to the extracted system, offered as guidance only):**
- Resolve the duplicate-H1 / "arrow_forward" ligature-text DOM issue — confirm intended icon rendering and ensure only one true page-level `<h1>` exists.
- Establish and document a single primary accent color for interactive elements (buttons/links) — the current per-section color variety (§3) makes it harder for users to learn "what color means clickable" on this site, a genuine usability consideration distinct from pure visual style.
- Verify contrast for the pale-lavender nav pill background against its various text colors.

## 26. Implementation Architecture

```text
design-system/
├── tokens/
│   ├── colors.ts        (§3 — fragmented; document per-section accents explicitly, do not force-unify)
│   ├── typography.ts     (§4 — Montserrat headings/buttons, Barlow secondary, Inter loaded-but-unconfirmed)
│   ├── radius.ts           (§9 — 3 distinct button shapes)
│   └── borders.ts            (§10 — single 2px white outline value)
│
├── components/
│   ├── Navbar/                (pill-style nav, 3 items)
│   ├── Button/                 (3 variants: chamfered-primary, outline, gradient-pill — NOT unified)
│   ├── HeroIntroCard/
│   ├── EventFlyerCard/          (lazy-loaded poster + QR)
│   ├── CTAColumn/                 (per-instance accent color)
│   ├── DirectorCarousel/            (circular headshot + arrow nav)
│   └── Footer/                        (4-column links, sponsor grid)
│
├── patterns/
│   ├── OurStorySection/
│   ├── GetInvolvedSection/        (composes CTAColumn × 3)
│   └── ContactCTABand/
│
└── templates/
    └── FestivalHomepage/           (§20 page template order)
```

**Note:** because this site's own component set is internally inconsistent (§1, §17), a "faithful rebuild" and a "cleaned-up design system inspired by this site" are two different deliverables — decide explicitly which one is wanted before implementation. §29 gives recommendations for the latter.

## 27. Machine-Readable JSON

See the accompanying `tokens.json` file (full contents below) — intentionally sparse where evidence is thin, per the audit's "do not invent" rule.

```json
{
  "brand": {
    "name": "Toronto Caribbean Carnival",
    "edition": "2026 (59th year)",
    "platform": "WordPress (page-builder / template-kit theme)"
  },
  "colors": {
    "measured": {
      "accentMagenta": "#ed177a",
      "accentPurple": "#9e5aff"
    },
    "visualEstimateOnly": {
      "textBody": "#2b2650",
      "goldLabel": "#f5a623",
      "navPillBackground": "#fbeaf5",
      "footerTop": "#7b3fe4",
      "footerBottom": "#0f0620",
      "ctaTeal": "#3fb6c9",
      "ctaOrange": "#c9820f",
      "ctaGreen": "#4c9a2a"
    },
    "note": "No single unified accent color found — see DESIGN_SYSTEM.md §3"
  },
  "typography": {
    "families": {
      "heading": "Montserrat, sans-serif",
      "secondary": "Barlow, Arial, Helvetica, sans-serif",
      "bodyLoadedUnconfirmed": "Inter, sans-serif"
    },
    "scale": {
      "h1": { "sizePx": 60, "weight": 800, "lineHeightPx": 96, "color": "#ed177a" },
      "heroIntro": { "sizePx": 26, "weight": 500, "lineHeightPx": 39, "color": "#9e5aff" },
      "buttonPrimary": { "sizePx": 18, "weight": 500 },
      "buttonOutline": { "sizePx": 13, "weight": 500 }
    }
  },
  "spacing": {
    "measured": {
      "buttonPrimaryPadding": "17px 40px",
      "buttonOutlinePadding": "11px 23px"
    },
    "fullScale": "UNKNOWN"
  },
  "radius": {
    "buttonChamfered": "5px 35px 35px 5px",
    "buttonPill": "50px"
  },
  "borders": {
    "outlineButtonWidth": "2px"
  },
  "shadows": { "status": "not observed" },
  "breakpoints": { "status": "UNKNOWN" },
  "components": {
    "navbar": { "items": 3, "style": "pill-link" },
    "button": { "variants": ["primary-chamfered", "outline", "gradient-pill"], "unified": false },
    "ctaColumn": { "count": 3, "accentColors": ["teal", "orange-brown", "green"] },
    "directorCarousel": { "photoShape": "circle", "hasArrowControls": true },
    "footer": { "columns": 4, "sponsorLogos": 6 }
  },
  "patterns": {
    "pageTemplate": [
      "Header", "HeroIntroCard", "EventsBanner", "EventFlyerRow",
      "OurStory", "DecorativeDivider", "PhotoPanel", "GetInvolved",
      "DirectorCarousel", "DecorativeDividers", "ContactCTABand", "Footer"
    ]
  }
}
```

## 28. Observed vs Measured vs Inferred vs Unknown — Summary

| Category | Status breakdown |
|---|---|
| Font families (Montserrat, Barlow) | MEASURED |
| Font families listed but unconfirmed rendered (Kantumruy Pro, Oswald, Outfit, Sacramento) | Loaded per `document.fonts`, usage **UNKNOWN** |
| Core colors (magenta, purple) | MEASURED |
| Per-section CTA colors (teal/orange/green), gradient stops, footer gradient | INFERRED / visual estimate only |
| Button radii (chamfered, pill) | MEASURED |
| Border width (outline button) | MEASURED |
| Full spacing scale | **UNKNOWN** |
| Breakpoints / mobile layout | **UNKNOWN** |
| Shadows/elevation | Not observed |
| Lazy-load behavior | OBSERVED (confirmed functional, not a defect) |
| Scroll-handling mechanism | Effect OBSERVED, exact implementation INFERRED |
| Duplicate H1 / icon-ligature DOM oddity | OBSERVED (DOM fact); user-facing severity UNKNOWN |
| Hover/focus/active states | **NOT OBSERVED** anywhere on the page this session |
| Whether the color variety is an intentional design choice vs. an artifact of assembling unrelated page-builder sections | **UNKNOWN** — flagged as the central interpretive uncertainty of this audit |

## 29. Recommendations for Recreating the Visual System

1. **Decide explicitly whether the goal is a faithful clone or a cleaned-up system** — this site's color and button-shape inconsistency (§1, §3, §17) is real and documented, not a measurement artifact. Reproducing it exactly is valid if visual fidelity to the *current* site is the goal; consolidating it is valid (and recommended) if the goal is a maintainable design system inspired by this site's energy.
2. **If cleaning up:** pick one primary accent (magenta `#ED177A` is the strongest candidate, appearing on both the SEO H1 and the primary button) and demote purple/teal/orange/green to a small, deliberate secondary palette rather than letting each new section invent its own.
3. **If cleaning up:** consolidate the three button shapes (chamfered-pill, outline-pill, gradient-pill) into one primary + one secondary variant, choosing whichever shape best fits the brand (the asymmetric chamfer is distinctive and worth keeping as the signature shape if only one is kept).
4. **Preserve the vivid, unfiltered carnival photography and circular photo-mask convention** — this is a genuine, consistently-applied identity element worth keeping regardless of the color cleanup above.
5. **Preserve the decorative section-divider graphics as a category** (equalizer bars, zigzag, waves) even if consolidating to fewer unique shapes — they are a distinctive structural device that differentiates this site from a flat, undifferentiated single-background page.
6. **Fix the duplicate-H1/icon-ligature DOM issue** (§12, §25) at the code level before treating this as a template for a new build — it's a small, concrete, fixable technical debt item independent of the visual-design questions above.
7. **Re-run this audit with direct source-CSS access** before finalizing any production token set — as with the vibrantbrampton.ca audit, this report's spacing scale, breakpoints, and several colors are visual estimates rather than measured values, and should be verified with DevTools before being hard-coded.
