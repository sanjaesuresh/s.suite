# Production readiness: SEO, security headers, media pipeline, observability, CI gates

The look and the component-level engineering get you a good page. These are what a senior
frontend engineer also owns before it ships. Apply the ones relevant to the surface (a
marketing page needs SEO; an internal dashboard mostly doesn't).

## SEO and metadata (for any public, indexable page)

- **One unique `<title>` and `<meta name="description">` per page** — not a site-wide
  default. The `<title>` is the strongest on-page signal and the SERP/tab label.
- **Canonical URL** (`<link rel="canonical">`) on every page to avoid duplicate-content
  splitting (querystring/tracking variants).
- **Open Graph + Twitter Card tags** (`og:title`, `og:description`, `og:image` at
  1200×630, `twitter:card`) so shared links render a card, not a bare URL.
- **Structured data as JSON-LD** (`schema.org` — `Article`, `Product`, `BreadcrumbList`,
  `Organization`) for rich results; validate with the Rich Results Test.
- **`robots.txt` + XML sitemap**; never `noindex` a page you want indexed (a classic
  staging-config-leaks-to-prod bug). Set per-page robots intentionally.
- SEO rests on the semantics already required elsewhere: one `<h1>`, ordered headings,
  real links with descriptive text, `alt` on meaningful images.

Sources: [Title links — Google](https://developers.google.com/search/docs/appearance/title-link) ·
[Structured data intro — Google](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data) ·
[Open Graph protocol](https://ogp.me/)

## Security headers and supply chain (beyond XSS sanitizing)

- **Content-Security-Policy** — at minimum restrict `default-src`/`script-src`; prefer a
  nonce/hash over `'unsafe-inline'`. CSP is the second line of defense after output
  encoding.
- **Send the baseline headers:** `Strict-Transport-Security` (HSTS),
  `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`,
  and frame protection via CSP `frame-ancestors` (modern replacement for
  `X-Frame-Options`).
- **Subresource Integrity (`integrity` + `crossorigin`)** on any third-party
  `<script>`/`<link>` loaded from a CDN, so a compromised CDN can't swap the file.
- **`rel="noopener"`** (and usually `noreferrer`) on every `target="_blank"` link —
  prevents reverse-tabnabbing.
- **Audit dependencies** (`npm audit` / Dependabot) and treat each client dependency as
  shipped attack surface; every third-party script runs with full page privileges.

Sources: [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/) ·
[CSP — MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP) ·
[SRI — MDN](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity)

## Image and media pipeline (usually the biggest payload)

- **Serve modern formats** — AVIF first, WebP fallback, then JPEG/PNG (`<picture>` with
  `type`). AVIF is smaller but slower to encode; WebP is the safe broad default.
- **Correct `srcset` + `sizes`.** `srcset` lists widths; `sizes` tells the browser the
  rendered width *before* layout — a wrong `sizes` makes responsive images useless. Verify
  the chosen candidate in DevTools.
- **Explicit `width`/`height` (or `aspect-ratio`)** on every image to reserve space (CLS).
- **`loading="lazy"` for below-the-fold images; never on the LCP image** — and pair the
  LCP image with `fetchpriority="high"`.
- **LQIP/blur placeholder** (tiny inlined preview) for large hero/content images to avoid
  a blank-then-pop.

Sources: [Image best practices — web.dev](https://web.dev/learn/images) ·
[srcset/sizes — MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Responsive_images) ·
[Optimize LCP — web.dev](https://web.dev/articles/optimize-lcp)

## Observability (you can't fix what you can't see)

- **Measure Core Web Vitals from real users (RUM)**, not just lab — ship the `web-vitals`
  library (or your provider's RUM) and report LCP/INP/CLS at p75. Lab scores lie about INP.
- **Client error tracking** (Sentry or equivalent) with **source maps uploaded** so
  minified stack traces are readable; scrub PII from breadcrumbs/payloads.
- **Set an error boundary that reports** — a caught render error should log to the tracker,
  not vanish.

Sources: [web-vitals library](https://github.com/GoogleChrome/web-vitals) ·
[INP field measurement — web.dev](https://web.dev/articles/inp#measure_inp_in_the_field)

## CI / developer-experience gates (catch this automatically, not by memory)

The rules in these references are only enforced if a machine checks them on every PR.

- **`eslint-plugin-jsx-a11y`** (or framework equivalent) in lint — catches missing `alt`,
  label-less controls, invalid ARIA, click-without-key-handler at author time.
- **`axe-core` in component/E2E tests** on the primary flows (covers ~40% of WCAG; keep a
  manual screen-reader pass for the rest).
- **TypeScript `strict`** (or equivalent type safety) — most "undefined is not a function"
  runtime UI bugs are type errors caught for free.
- **Lighthouse CI with budgets** — gate the build on performance/a11y/SEO score and a JS
  byte budget so regressions can't merge silently.
- **`stylelint`** to keep CSS/tokens consistent and flag hardcoded values that bypass the
  scale.

Sources: [eslint-plugin-jsx-a11y](https://github.com/jsx-eslint/eslint-plugin-jsx-a11y) ·
[Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) ·
[axe-core](https://github.com/dequelabs/axe-core)

## Privacy and consent (if you load third-party/tracking scripts)

- **Don't load non-essential third-party scripts before consent** where required (GDPR/
  ePrivacy). Gate analytics/ads/pixels behind the consent state.
- **Govern third-party scripts** — each one is a performance, privacy, and security
  liability; load `async`/`defer`, audit what you actually need, and prefer first-party.
