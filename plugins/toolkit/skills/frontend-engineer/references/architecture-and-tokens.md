# Component architecture, state, design tokens, and testing

## Component architecture and state (React / RSC)

- **The best derived state is no state.** If a value is computable from props/state,
  compute it during render (or `useMemo`) — never store it via `useEffect`. The effect
  pattern causes a double render and stale-value bugs.
- **`useEffect` is for synchronizing with external systems only** (subscriptions, DOM
  nodes, network you can't do in an event handler). It should be the exception — not for
  transforming data, caching calculations, or handling user events.
- **Default to Server Components; put `"use client"` at the leaf, not high in the tree.**
  `"use client"` promotes the entire subtree to the client and forfeits RSC benefits.
- **Client components only for:** interactivity/events, browser APIs, hooks
  (`useState`/`useEffect`/`useContext`), or client state. Data fetching, composition, and
  heavy deps stay server-side to cut shipped JS.
- **Every server→client prop is public network data** (serialized into the RSC/Flight
  payload) — never pass secrets; keep props small (large nested props bloat payload and
  delay hydration).
- **Reading cookies/headers forces dynamic rendering** — read them only where needed, not
  in a root layout, or you lose static/PPR.
- **Lift state only as high as needed.** Context for genuinely global, low-churn concerns
  (theme, auth, locale); props for local. Reach for Zustand/Jotai/Redux only when
  Context's re-render or structure limits actually bite.

## Design tokens and theming

- **No hardcoded values in components.** Spacing, color, radius, type, shadow all
  reference tokens (CSS custom properties / Tailwind v4 `@theme`). A raw `#3b82f6` or
  `margin: 13px` is a smell.
- **Spacing from a fixed scale** (4px base: 4/8/12/16/24/32…). Type from a modular scale,
  not arbitrary px.
- **Define color in OKLCH** for perceptually even steps and predictable theming — adjust L
  (and C) to derive dark/high-contrast modes without re-authoring the palette.
- **Dark mode is not inverted light mode.** Re-check every pair for ≥4.5:1 (text) / ≥3:1
  (UI). Avoid pure `#000` background and pure-white text (halation); soften both.
- **Token layers:** primitives (raw palette) → semantic (`--color-bg`, `--color-text`,
  `--color-danger`) → component. Components consume **semantic** tokens only, so theming is
  one layer's job.

## Frontend testing

- **Test behavior, not implementation.** With Testing Library, query by accessible
  role/label/text (`getByRole('button', {name})`), not test IDs or internal props — tests
  double as a11y assertions.
- **Layer the suite:** unit (Vitest/Jest) for logic → component tests for UI in isolation
  → Playwright E2E for **critical flows only**. Don't E2E everything; it's slow and flaky.
- **Run axe-core in component/E2E tests** to auto-catch missing labels, contrast, ARIA
  violations — but it covers ~40% of issues, so keep a manual SR pass for key flows.
- **Visual regression complements, never replaces, functional tests.** Snapshot
  **components**, not full pages (smaller scope = clearer diffs, less flake). Pin
  OS + browser version.
- **Don't over-test:** skip "prop was passed", internal state shape, or styling that visual
  tests cover. Test the observable contract.
- **Use Playwright auto-waiting / web-first assertions** instead of `sleep()`.

## Modern stack footguns (2025–2026)

- **Next.js App Router:** keep `"use client"` at leaves; don't read cookies/headers in root
  layouts (kills static/PPR); prefer fine-grained `revalidateTag` over blanket
  `revalidatePath`; don't over-fragment with too many `<Suspense>` boundaries.
- **Tailwind v4:** config moved to CSS (`@theme`), colors OKLCH by default — define
  semantic tokens; don't sprinkle arbitrary `[#hex]`/`[13px]` values that bypass the scale.
- **Library compatibility:** many client-only libs force `"use client"` and silently
  de-optimize a subtree — check before adopting.

Sources:
[You Might Not Need an Effect — React](https://react.dev/learn/you-might-not-need-an-effect) ·
[Server & Client Components — Next.js](https://nextjs.org/docs/app/getting-started/server-and-client-components) ·
[OKLCH explained](https://uxdesign.cc/oklch-explained-for-designers-dc6af4433611) ·
[Playwright best practices](https://playwright.dev/docs/best-practices) ·
[React state management 2025 — Developer Way](https://www.developerway.com/posts/react-state-management-2025)
