# Performance: Core Web Vitals, fonts, responsive, motion

Thresholds are the "good" rating at the 75th percentile. **LCP ≤ 2.5s · INP ≤ 200ms ·
CLS ≤ 0.1.** INP replaced FID in March 2024 and is now the most-failed CWV (~43% of sites
miss 200ms), so weight interaction latency heavily.

## LCP (Largest Contentful Paint) ≤ 2.5s

- **Identify the LCP element** (usually the hero image or headline) and prioritize it:
  `fetchpriority="high"`, preload it, and **never lazy-load it**.
- **Four highest-impact fixes:** preload the LCP image, inline critical CSS, preload fonts
  with `font-display: swap`, server-render the initial HTML.
- **Responsive, modern images** — AVIF/WebP, correct `srcset`/`sizes`.

## INP (Interaction to Next Paint) ≤ 200ms

INP = input delay + processing duration + presentation delay. Optimize all three.

- **No long tasks (>50ms) on the main thread.** Break event handlers into chunks and
  **yield** (`scheduler.yield()` where available, else `await`/`setTimeout(0)`).
- **In a handler, do only the visual-update work synchronously; defer the rest** —
  analytics, saves, spell-check, counts — to a later task.
- **Avoid layout thrashing** — don't write a style then read a computed layout value in
  the same task.
- **Move CPU-heavy work to a Web Worker.** Cut unnecessary DOM mutations during
  interactions.
- **`content-visibility: auto`** to skip rendering off-screen content.

## CLS (Cumulative Layout Shift) ≤ 0.1

- **Explicit `width`+`height` (or `aspect-ratio`)** on every `<img>/<video>/<iframe>`/ad
  slot.
- **Reserve space for anything async** — fonts, banners, embeds, injected content. Never
  insert content above existing content after load.

## Font loading (FOUT/FOIT and the swap shift)

- **`font-display: swap`** as default — render fallback immediately, swap on load. Avoid
  `block` (up to 3s invisible text).
- **Preload critical fonts** (those in the LCP element): `<link rel="preload" as="font"
  crossorigin>`. `crossorigin` is mandatory even same-origin.
- **Kill the swap shift** with `size-adjust` / `ascent-override` / `descent-override` on an
  `@font-face` fallback so its metrics match the webfont — the main webfont CLS fix.
- **Subset and self-host** the weights/characters you actually use; don't chain to a
  third-party origin.

## Responsive and cross-device

- **Container queries (`@container`)** so a component adapts to its container, not the
  viewport — reusable anywhere without per-page media-query patches.
- **Fluid type/spacing with `clamp(min, preferred, max)`** — cap the max so text doesn't
  balloon on 4K, floor the min for readability.
- **Tap targets ≥ 24×24 CSS px** (WCAG 2.5.8 AA); aim for 44–48px for primary mobile
  actions, or keep ≥24px spacing between smaller targets. Inline text links are exempt.
- **Safe areas** via `env(safe-area-inset-*)` + `viewport-fit=cover` for notches/home
  indicators.
- **Dynamic viewport units** (`dvh`/`svh`/`lvh`), not `100vh` (breaks under mobile chrome).
- **Test matrix:** ~320–360px phone, tablet, desktop, **plus 200% zoom and 400% reflow**
  (WCAG 1.4.10) — no horizontal scroll, no clipping.

## Motion that doesn't cost performance

- **Animate only `transform` and `opacity`** (compositor-friendly). Animating
  `width/height/top/left/margin` triggers layout → jank + shift.
- **Motion must be layout-shift-free** — animate within reserved space; never push
  surrounding content (counts against CLS).
- **Durations:** micro-interactions ~150–300ms; longer only for large-distance/entrance
  moves. `ease-out` entering, `ease-in` leaving, `ease-in-out` looping. Avoid linear.
- **Gate non-essential motion behind `@media (prefers-reduced-motion: no-preference)`**
  and provide a reduced/instant variant.
- **Motion signals causality** (what happened / where it came from), it doesn't decorate.
  If it doesn't aid understanding, cut it.

## JS budget

- **Ship less client JS** to protect INP. Audit bundle size; `dynamic import` below-the-
  fold and rarely-used heavy components; watch client-only libs that force a whole subtree
  client-side.

Sources: [Web Vitals](https://web.dev/articles/vitals) ·
[Optimize INP](https://web.dev/explore/how-to-optimize-inp) ·
[Optimize long tasks](https://web.dev/articles/optimize-long-tasks) ·
[Font best practices](https://web.dev/articles/font-best-practices) ·
[Target Size 2.5.8](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html) ·
[prefers-reduced-motion — Josh Comeau](https://www.joshwcomeau.com/react/prefers-reduced-motion/)
