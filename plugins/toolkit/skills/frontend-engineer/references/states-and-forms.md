# Component states, forms, and resilience

A component that only renders the happy path is unfinished. The difference between a demo
and production UI is mostly the states below.

## Every component must handle these states

- **Loading.** Use a **skeleton** for content that's appearing (match the final layout to
  cut perceived wait); use a **spinner** for an action/process or a small in-place region.
  Don't use both for the same region.
- **Don't flash an indicator for sub-~300ms loads** — a flicker is worse than nothing.
  Delay the spinner, or show nothing.
- **Empty (zero items)** — distinct from loading. A loaded-but-empty list needs an empty
  state with guidance/CTA, not a blank box or a stuck spinner.
- **Error** — a human message plus a **retry** affordance. Never a blank screen or a raw
  exception reaching a generic error boundary.
- **Zero / one / many** — test all three: singular vs plural copy, layout with one item vs
  hundreds (**virtualize** long lists).
- **Long content** — long names, long URLs, big numbers must not break layout. Truncate
  (with full text available), wrap, or scroll.
- **Partial / stale** — when some data loaded and some failed, render what you have and
  flag the rest. Consider optimistic UI with rollback on failure.
- **Offline / slow** — detect failed fetches and degrade gracefully instead of spinning
  forever.

## Forms and validation UX

- **Validate on blur, not on every keystroke.** Errors while the user is still typing
  measurably hurt usability. Exceptions: password-strength meters, username-availability.
- **Best pattern:** validate on submit the first time; once a field has errored, switch
  *that* field to live re-validation so the user sees it clear as they fix it.
- **Error messages say what's wrong AND how to fix it** — "Password must be at least 8
  characters", not "Invalid input". Place it adjacent to the field, link via
  `aria-describedby`, and set `aria-invalid="true"`.
- **Correct `autocomplete` tokens** (`email`, `name`, `current-password`, `one-time-code`,
  `postal-code`, …) — faster, fewer errors, better for assistive tech.
- **`inputmode`/`type` for the right mobile keyboard** — `inputmode="numeric"`,
  `type="email"`, `type="tel"`.
- **Disable submit only while submitting, and reflect state** (in-button spinner,
  `aria-busy`). Don't pre-disable submit pending "valid" — it hides what's wrong.
- **On submit error, move focus to the first invalid field** (or an error summary) and
  announce it via a live region.
- **Prefer uncontrolled inputs** (native form + `FormData`) unless you must react to every
  keystroke — fewer re-renders, less code.

## Resilience and frontend security (don't bolt these on later)

- **Error boundaries are a first-class concern.** Wrap async/region boundaries so one
  failed widget doesn't blank the page. Pair with retry.
- **XSS:** never pass unsanitized HTML to `dangerouslySetInnerHTML` / `innerHTML`. Sanitize
  or avoid.
- **`target="_blank"` needs `rel="noopener"`** (and usually `noreferrer`).
- **Never leak secrets into the client bundle or across the server→client boundary** —
  props passed to a client component are serialized into the public payload.
- **i18n / RTL robustness** — layouts must survive text expansion (German ~+35%) and
  `dir="rtl"`; don't bake text into images; use logical CSS properties
  (`margin-inline`, `padding-block`) over physical ones.

Sources:
[Loading/error/empty states in React — LogRocket](https://blog.logrocket.com/ui-design-best-practices-loading-error-empty-state-react/) ·
[Skeleton vs spinner — Onething](https://www.onething.design/post/skeleton-screens-vs-loading-spinners) ·
[Inline validation UX — Smashing](https://www.smashingmagazine.com/2022/09/inline-validation-web-forms-ux/) ·
[Avoid early real-time validation — Designary](https://blog.designary.com/p/avoid-early-real-time-validation-for-forms-as-it-harms-usability)
