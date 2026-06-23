# Accessibility, ARIA, and semantic HTML

Checkable rules. Automated tools catch only ~40% of WCAG 2.2 issues — the rest need a
keyboard pass and a screen-reader smoke test. Target: **WCAG 2.2 AA**.

## Semantic HTML first (this prevents most a11y bugs)

- **`<button>` for actions, `<a href>` for navigation.** A clickable `<div>` or an
  `<a href="#">` wired with JS is wrong: buttons fire on Enter *and* Space, anchors only
  on Enter, and a div has neither focus nor role. Using the right element gives you
  keyboard, focus, and role for free.
- **One `<main>`, one `<h1>` per page.** Landmarks (`<header> <nav> <main> <aside>
  <footer>`) must be top-level (or properly nested) to be exposed. Don't bury `<main>`.
- **Headings descend without skipping** (h1 → h2 → h3). Pick heading level by document
  structure, size it with CSS. The `<h1>` matches the visible page title.
- **Real lists** (`<ul>/<ol>/<li>`) for grouped items — screen readers announce count
  and position. Don't fake them with `<div>`s.
- **Prefer native `<dialog>` and the Popover API** over hand-rolled modals/menus — you
  get focus management, top-layer stacking, and Esc-to-close for free.
- **Label repeated landmarks** (`<nav aria-label="Primary">` / `"Footer"`).
- **Skip link** ("Skip to main content") as the first focusable element.

## Keyboard and focus (the highest-frequency real failures)

- **Every interactive element reachable and operable by keyboard alone** — Tab/Shift-Tab,
  Enter/Space, Esc, arrows where appropriate — with **no keyboard traps** (SC 2.1.1,
  2.1.2). Test the whole flow with the mouse unplugged.
- **Visible focus indicator on every focusable element** — Focus Visible, **SC 2.4.7
  (Level A)**. The indicator's contrast against adjacent colors must be **≥3:1** (Non-text
  Contrast, SC 1.4.11, AA). The stricter shape rule — a ≥2px-thick perimeter and a ≥3:1
  change between the focused and unfocused states of the *same* pixels — is **Focus
  Appearance, SC 2.4.13 (Level AAA)**: aim for it, but it is not an AA gate. Never
  `outline: none` without a deliberate replacement.
- **Manage focus on dynamic UI and route changes.** Modal opens → move focus in, trap it,
  restore focus to the trigger on close. SPA navigation → move focus to the new `<h1>` or
  a focusable container so the new page is announced.
- **Sticky headers must not obscure the focused element** (SC 2.4.11 Focus Not Obscured)
  — set `scroll-padding-top` so focused items aren't hidden under fixed bars.

## ARIA — use it correctly or not at all

WebAIM Million: pages *with* ARIA average **41% more** detected errors. ARIA fills gaps in
native HTML; it does not build accessibility from nothing.

- **First rule of ARIA: don't use ARIA.** If a native element gives the behavior, use it.
  Reserve ARIA for genuinely custom widgets with no native equivalent.
- **Never `aria-hidden="true"` on a focusable element** — it leaves the element in tab
  order but hidden from the a11y tree, stranding screen-reader users. To fully hide, use
  `display:none` / `visibility:hidden`.
- **`aria-label` must not contradict visible text** (SC 2.5.3 Label in Name). Don't add it
  to an element that already has a `<label>` or visible text.
- **Every `aria-labelledby` / `aria-describedby` ID must exist** — a typo silently drops
  the label/description.
- **Don't use `role="menu"/"menubar"` for site nav** — those promise OS-menu arrow-key
  semantics you almost certainly didn't implement. Use the disclosure (button + expanded
  region) pattern.
- **Any custom ARIA widget must implement its keyboard model** — `role="button"` on a div
  needs Enter/Space handlers and `tabindex="0"`.
- **`aria-live` for async status** — `polite` for non-urgent, `assertive`/`role="alert"`
  for errors. (It's `role="alert"`, not `aria-role="alert"`.)

## Contrast

- **Body text ≥ 4.5:1.** Large text (≥24px, or ≥18.66px bold) and UI components/graphics
  **≥ 3:1** (SC 1.4.3, 1.4.11). Check **both** light and dark themes — dark mode is not a
  free inversion.

## Verify

- **Run axe (axe-core / `@axe-core/playwright`) in CI**, then do a manual VoiceOver/NVDA
  smoke test on the primary flow. Automation misses focus order, label quality, and
  live-region behavior.

Sources: [WCAG 2.2](https://www.w3.org/TR/WCAG22/) ·
[Focus Visible 2.4.7 (A)](https://www.w3.org/WAI/WCAG22/Understanding/focus-visible.html) ·
[Non-text Contrast 1.4.11 (AA)](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html) ·
[Focus Appearance 2.4.13 (AAA)](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html) ·
[Focus Not Obscured 2.4.11 (AA)](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html) ·
[Target Size 2.5.8 (AA)](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum) ·
[WebAIM semantic structure](https://webaim.org/techniques/semanticstructure/) ·
[Common ARIA mistakes](https://www.oidaisdes.org/blog/common-aria-mistakes/) ·
[Button vs anchor](https://niquette.ca/articles/button-or-anchor/)
