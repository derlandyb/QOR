# PRODUCTION DESIGN SYSTEM SPECIFICATION: NIGHTLIFE-GV

Platform: Music event discovery for Greater Vitória (Vitória, Vila Velha, Serra, Cariacica). No checkout/ticketing — discovery, agenda, and deep-links to venue maps + Instagram only.

---

## 1. Visual Concept & Theming

NIGHTLIFE-GV fuses three references into one system:

- **Color (from TorontoCarnival):** a rich, near-black nightlife base — not flat black, but a desaturated deep navy-charcoal — punched through with four ultra-vibrant tropical accents (hot pink, solar orange/yellow, neon purple, electric blue). Dark surfaces make flyer/artist photography glow; accents are reserved for actions, tags, and state — never backgrounds.
- **Motion (from VibrantBrampton):** everything moves like it has a beat. Hover states scale and shift gradients rather than just fading; entrances stagger in with a slight overshoot, giving cards a rhythmic, musical cadence without becoming gimmicky.
- **Structure (from ElectricIsland):** strict grid, generous negative space, sharp (not soft, not fully square) corners. The event flyer/artist image is always the largest, least-interrupted element on the card. UI chrome (badges, metadata, buttons) is compact and stays out of the image's way.

Net result: a dark, editorial, high-contrast canvas where tropical color and subtle motion carry the "festival energy," while layout discipline keeps it scannable and uncluttered — built for fast browsing of dozens of events across four cities.

---

## 2. Design Tokens

### 2.1 Global Color Palette

Base neutrals are cool-toned (blue-black), matching a nightlife/dark-mode-first product.

| Token | Hex | oklch | Usage |
|---|---|---|---|
| `--color-bg-deep` | `#0B0D14` | `oklch(0.16 0.02 265)` | App background, deepest layer |
| `--color-bg-base` | `#12141D` | `oklch(0.20 0.02 265)` | Section background, below cards |
| `--color-surface-card` | `#1B1E29` | `oklch(0.25 0.02 265)` | Card surfaces |
| `--color-surface-card-hover` | `#232733` | `oklch(0.29 0.02 265)` | Card hover surface |
| `--color-border-subtle` | `#2A2E3B` | `oklch(0.33 0.02 265)` | Hairline borders, dividers |
| `--color-text-primary` | `#F5F6FA` | `oklch(0.97 0.01 265)` | Titles, primary text |
| `--color-text-secondary` | `#9A9FB0` | `oklch(0.65 0.02 265)` | Metadata, dates, venue sub-text |
| `--color-text-tertiary` | `#666B7D` | `oklch(0.47 0.02 265)` | Disabled, timestamps, fine print |

**Vibrant Accents** (from TorontoCarnival — same high chroma/lightness family, hue-shifted; hex given for direct use, oklch for programmatic harmony):

| Token | Hex | oklch | Role |
|---|---|---|---|
| `--accent-pink` | `#FF2E7E` | `oklch(0.65 0.24 5)` | Primary CTA, "live now" pulse, Sertanejo tag |
| `--accent-orange` | `#FF8A1E` | `oklch(0.75 0.19 55)` | Secondary CTA, Rock tag, date badge |
| `--accent-purple` | `#B14EFF` | `oklch(0.62 0.26 305)` | Eletrônico tag, hover glows, focus rings |
| `--accent-blue` | `#2EC5FF` | `oklch(0.75 0.16 235)` | Reggae tag, links, map icon |

Accent usage rule: max 1 accent as a solid fill per component; combine 2 accents only in a gradient (see §3). Never place accent-on-accent text.

**Semantic aliases**
| Token | Value | Usage |
|---|---|---|
| `--color-success` | `--accent-blue` | "Confirmed" / open now |
| `--color-live` | `--accent-pink` | "Ao vivo agora" pulse dot |
| `--color-danger` | `#FF4D4D` | Sold-out / cancelled (info only, no checkout) |

### 2.2 Typography Scale

Font pairing: **Space Grotesk** (display/headings — geometric, slightly technical, reads as "electronic/festival") + **Inter** (body/metadata — neutral, highly legible at small sizes). Both are Google Fonts, web-safe fallback `system-ui, sans-serif`.

| Token | Font | Weight | Size / Line-height | Letter-spacing | Usage |
|---|---|---|---|---|---|
| `--text-event-title` | Space Grotesk | 700 | 22px / 1.15 | -0.01em | Event card title |
| `--text-event-title-lg` | Space Grotesk | 700 | 32px / 1.1 | -0.015em | Event detail page H1 |
| `--text-venue-name` | Inter | 600 | 15px / 1.3 | 0 | Venue name |
| `--text-city-label` | Inter | 600 | 12px / 1.2 | 0.02em, uppercase | City/hub sub-label |
| `--text-metadata` | Inter | 500 | 13px / 1.4 | 0 | Date, time, price-free/cover info |
| `--text-badge` | Space Grotesk | 600 | 11px / 1 | 0.04em, uppercase | Genre/city badge text |
| `--text-body` | Inter | 400 | 14px / 1.5 | 0 | Descriptions |
| `--text-button` | Space Grotesk | 600 | 14px / 1 | 0.01em | CTA button label |

### 2.3 Spacing & Borders (8px base grid)

| Token | Value |
|---|---|
| `--space-1` | 4px (micro, icon-to-text gap only) |
| `--space-2` | 8px |
| `--space-3` | 16px |
| `--space-4` | 24px |
| `--space-5` | 32px |
| `--space-6` | 48px |
| `--space-7` | 64px |

| Token | Value | Usage |
|---|---|---|
| `--radius-sm` | 6px | Badges, tags, chips |
| `--radius-md` | 12px | Buttons, inputs |
| `--radius-lg` | 16px | Event cards |
| `--radius-image` | 14px | Flyer/image holder (2px less than card, nests cleanly) |
| `--radius-pill` | 999px | Filter bar badges |
| `--border-width-hairline` | 1px | Card borders, dividers |

Card internal padding: `--space-3` (16px). Grid gutter: `--space-4` (24px) desktop, `--space-3` (16px) mobile. Section vertical rhythm: `--space-6` (48px) between major sections.

---

## 3. Interaction & Animation Spec

Motion principle: fast in, smooth out, always with a hint of overshoot — like a beat drop, not a fade.

| Token | Value | Usage |
|---|---|---|
| `--ease-beat` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Hover scale, entrance pop (overshoot) |
| `--ease-smooth` | `cubic-bezier(0.4, 0, 0.2, 1)` | Color/gradient shifts, opacity |
| `--duration-fast` | 150ms | Icon/badge state change |
| `--duration-base` | 250ms | Card hover, button hover |
| `--duration-slow` | 450ms | Entrance animation, page transitions |
| `--duration-stagger` | 60ms | Delay increment per card in a grid entrance |

**Card hover** (Tailwind-equivalent):
```
transition: transform 250ms var(--ease-beat), box-shadow 250ms var(--ease-smooth);
hover: transform: scale(1.03) translateY(-4px);
       box-shadow: 0 12px 32px -8px rgba(255, 46, 126, 0.25); /* pink-tinted glow */
```
Tailwind: `transition-transform duration-250 ease-[cubic-bezier(0.34,1.56,0.64,1)] hover:scale-[1.03] hover:-translate-y-1`

**Gradient hover shift** (buttons, live badges): background is a 2-accent gradient (`--accent-pink` → `--accent-purple`) at `background-size: 200% 100%`, `background-position: 0% 0%`; on hover animate `background-position` to `100% 0%` over `--duration-base` with `--ease-smooth`. Tailwind: `bg-gradient-to-r from-[#FF2E7E] to-[#B14EFF] bg-[length:200%_100%] bg-left hover:bg-right transition-[background-position] duration-300`.

**Entrance sequence** (grid of event cards on load/filter change): each card fades + rises + slightly scales in, staggered by `--duration-stagger` per index.
```
@keyframes card-enter {
  from { opacity: 0; transform: translateY(16px) scale(0.96); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}
animation: card-enter var(--duration-slow) var(--ease-beat) both;
animation-delay: calc(var(--duration-stagger) * var(--card-index));
```

**Filter badge active/inactive toggle:** background + text color cross-fade over `--duration-base` with `--ease-smooth`; active state additionally scales to `1.05` with `--ease-beat`.

**Focus ring (accessibility):** `2px solid var(--accent-blue)`, `outline-offset: 2px`, no animation (instant, for keyboard nav clarity).

**Live pulse dot** (for "ao vivo agora" events): `box-shadow` pulse using `--accent-pink`, 1.8s ease-in-out infinite — the one continuous-loop animation in the system; everything else is interaction-triggered.

---

## 4. Component Blueprints

### 4.1 Event Card

```html
<article class="group relative flex flex-col bg-[#1B1E29] border border-[#2A2E3B] rounded-2xl overflow-hidden
                 transition-transform duration-250 ease-[cubic-bezier(0.34,1.56,0.64,1)]
                 hover:scale-[1.03] hover:-translate-y-1 hover:shadow-[0_12px_32px_-8px_rgba(255,46,126,0.25)]">

  <!-- Image holder: dominant element, ElectricIsland discipline -->
  <div class="relative w-full aspect-[4/5] rounded-t-[14px] overflow-hidden bg-[#12141D]">
    <img src="{flyer_url}" alt="{event_name} flyer"
         class="w-full h-full object-cover transition-transform duration-500 ease-[cubic-bezier(0.4,0,0.2,1)] group-hover:scale-105" />

    <!-- Date badge, top-left, floats over image -->
    <div class="absolute top-3 left-3 flex flex-col items-center justify-center w-12 h-12 rounded-lg
                bg-[#0B0D14]/80 backdrop-blur-sm border border-white/10">
      <span class="text-[10px] font-semibold uppercase tracking-wide text-[#9A9FB0] leading-none">{month}</span>
      <span class="text-lg font-bold text-[#F5F6FA] leading-none font-[Space_Grotesk]">{day}</span>
    </div>

    <!-- Genre tag, top-right -->
    <span class="absolute top-3 right-3 px-2.5 py-1 rounded-md text-[11px] font-semibold uppercase tracking-wider
                 bg-[#FF8A1E] text-[#12141D] font-[Space_Grotesk]">{genre}</span>
  </div>

  <!-- Content block -->
  <div class="flex flex-col gap-2 p-4">
    <h3 class="font-[Space_Grotesk] font-bold text-[22px] leading-[1.15] tracking-[-0.01em] text-[#F5F6FA] line-clamp-2">
      {event_name}
    </h3>

    <!-- Venue + City row -->
    <div class="flex items-center justify-between">
      <div class="flex flex-col">
        <span class="font-semibold text-[15px] text-[#F5F6FA]">{venue_name}</span>
        <span class="text-[13px] text-[#9A9FB0]">{time}, {day_of_week}</span>
      </div>
      <span class="px-2 py-1 rounded-full text-[11px] font-semibold uppercase tracking-wide
                   bg-[#2EC5FF]/15 text-[#2EC5FF] whitespace-nowrap">{city_hub}</span>
    </div>

    <!-- CTA row -->
    <div class="flex gap-2 mt-2">
      <a href="{maps_deep_link}" class="flex-1 ...">Ver no Mapa</a>
      <a href="{instagram_deep_link}" class="flex-1 ...">Ver Instagram</a>
    </div>
  </div>
</article>
```

### 4.2 Horizontal City Filter Bar

Badge treatments are hub-specific hues drawn from the accent set, so the four Greater Vitória hubs are instantly distinguishable at a glance.

| Hub | Badge accent (inactive bg / active bg) | Text |
|---|---|---|
| Vitória (Praia do Canto/Triângulo) | `--accent-pink` @ 15% / 100% | dark text on active |
| Vila Velha (Itapuã/Coqueiral) | `--accent-blue` @ 15% / 100% | dark text on active |
| Serra (Laranjeiras/Manguinhos) | `--accent-orange` @ 15% / 100% | dark text on active |
| Cariacica | `--accent-purple` @ 15% / 100% | white text on active |

```html
<nav class="flex flex-wrap gap-2 px-4 py-3 overflow-x-auto">
  <button aria-pressed="true"
          class="px-4 py-2 rounded-full text-[12px] font-semibold uppercase tracking-wide font-[Space_Grotesk]
                 bg-[#FF2E7E] text-[#0B0D14] scale-105
                 transition-all duration-250 ease-[cubic-bezier(0.4,0,0.2,1)]">
    Vitória
  </button>
  <button aria-pressed="false"
          class="px-4 py-2 rounded-full text-[12px] font-semibold uppercase tracking-wide font-[Space_Grotesk]
                 bg-[#2EC5FF]/15 text-[#2EC5FF] hover:bg-[#2EC5FF]/25
                 transition-all duration-250 ease-[cubic-bezier(0.4,0,0.2,1)]">
    Vila Velha
  </button>
  <button aria-pressed="false"
          class="px-4 py-2 rounded-full text-[12px] font-semibold uppercase tracking-wide font-[Space_Grotesk]
                 bg-[#FF8A1E]/15 text-[#FF8A1E] hover:bg-[#FF8A1E]/25
                 transition-all duration-250 ease-[cubic-bezier(0.4,0,0.2,1)]">
    Serra
  </button>
  <button aria-pressed="false"
          class="px-4 py-2 rounded-full text-[12px] font-semibold uppercase tracking-wide font-[Space_Grotesk]
                 bg-[#B14EFF]/15 text-[#B14EFF] hover:bg-[#B14EFF]/25
                 transition-all duration-250 ease-[cubic-bezier(0.4,0,0.2,1)]">
    Cariacica
  </button>
</nav>
```

### 4.3 Genre Tag Set (for chips/labels elsewhere in the UI)

| Genre | bg / text |
|---|---|
| Rock | `--accent-orange` @ 15% bg / `--accent-orange` text |
| Samba | `--accent-pink` @ 15% bg / `--accent-pink` text |
| Sertanejo | `--accent-pink` solid bg / `#12141D` text |
| Eletrônico | `--accent-purple` @ 15% bg / `--accent-purple` text |
| Reggae | `--accent-blue` @ 15% bg / `--accent-blue` text |

`class="px-2.5 py-1 rounded-md text-[11px] font-semibold uppercase tracking-wider font-[Space_Grotesk]"`

### 4.4 Call-To-Action Buttons

Two CTA types, both deep-link out of the app (no in-app checkout):

**"Ver no Mapa"** — primary-adjacent, blue accent (maps association):
```html
<a href="{maps_deep_link}" target="_blank" rel="noopener"
   class="flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl
          bg-[#2EC5FF]/10 border border-[#2EC5FF]/30 text-[#2EC5FF]
          font-[Space_Grotesk] font-semibold text-[14px] tracking-[0.01em]
          transition-all duration-250 ease-[cubic-bezier(0.34,1.56,0.64,1)]
          hover:bg-[#2EC5FF] hover:text-[#0B0D14] hover:scale-[1.03]">
  <svg class="w-4 h-4" aria-hidden="true"><!-- pin icon --></svg>
  Ver no Mapa
</a>
```

**"Ver Instagram"** — gradient CTA, pink→purple (primary action weight):
```html
<a href="{instagram_deep_link}" target="_blank" rel="noopener"
   class="flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl
          bg-gradient-to-r from-[#FF2E7E] to-[#B14EFF] bg-[length:200%_100%] bg-left
          text-white font-[Space_Grotesk] font-semibold text-[14px] tracking-[0.01em]
          transition-[background-position,transform] duration-300 ease-[cubic-bezier(0.4,0,0.2,1)]
          hover:bg-right hover:scale-[1.03]">
  <svg class="w-4 h-4" aria-hidden="true"><!-- instagram icon --></svg>
  Ver Instagram
</a>
```

Both buttons: `--radius-md` (12px), height 44px min (touch target), full-width when paired in a card's CTA row (`flex-1` each with `--space-2` gap between).
