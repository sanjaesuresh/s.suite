# <PROJECT NAME>

<!-- TEMPLATE: Replace every <placeholder> before committing. Delete this comment. -->

<One-line description of what this project does and who uses it.>

---

## WORK-SAFETY NOTICE

**If this is an employer or client repo**, keep ALL project context here in this local file.
Do NOT let Claude copy proprietary details into:
- Global memory or saved preferences (`~/.claude/`)
- Global skills or agents (`~/.claude/skills/`, `~/.claude/agents/`)
- Any synced or public toolkit repository
- Generated documentation that could leave the repo

Claude should rely only on local project context (this file, `.claude/`, session context).
When in doubt, ask before writing anything to a location outside this repo.

---

## Project Rules Override Global

Settings and instructions in this file and in `.claude/settings.json` take precedence
over any global Claude configuration for this project.

---

## How to Run

```bash
# Install dependencies
<e.g. npm install / pip install -r requirements.txt / go mod download>

# Start dev server / run the app
<e.g. npm run dev / python -m uvicorn app.main:app --reload>

# Run all tests
<e.g. npm test / pytest / go test ./...>

# Run a single test file
<e.g. npm test -- src/foo.test.ts / pytest tests/test_foo.py>
```

## How to Build

```bash
# Production build
<e.g. npm run build / make build / docker build -t <image> .>
```

## How to Lint / Format

```bash
# Lint
<e.g. npm run lint / ruff check . / golangci-lint run>

# Format
<e.g. npm run format / ruff format . / gofmt -w .>
```

---

## Architecture Notes

<!-- Describe the major layers, services, or modules. Keep it factual. -->

- **<Layer / Service 1>**: <what it does, where it lives>
- **<Layer / Service 2>**: <what it does, where it lives>
- **<Data store>**: <type, location, access pattern>
- **<External integrations>**: <APIs or services this project depends on>

Key entry points:
- `<path/to/main entry>` — <what it does>
- `<path/to/config>` — <what it controls>

---

## Conventions to Follow

**Style**
- Language version: <e.g. TypeScript 5.x strict mode / Python 3.12 / Go 1.22>
- Formatter: <e.g. Prettier, Ruff, gofmt — already enforced by the format hook in .claude/settings.json>
- Linter rules: <e.g. ESLint config at .eslintrc.json — do not disable rules without a comment>

**Naming**
- Files: <e.g. kebab-case for modules, PascalCase for React components>
- Functions: <e.g. camelCase, verb-first (getUser, updateRecord)>
- Database columns: <e.g. snake_case>
- Environment variables: <e.g. SCREAMING_SNAKE_CASE, documented in .env.example>

**Testing expectations**
- Tests live next to source files at `<e.g. foo.test.ts>` / in `<e.g. tests/>`.
- Every new function needs at least one unit test covering the happy path and one covering the primary error case.
- Do not mock the database in integration tests — use the test database defined by `<e.g. TEST_DATABASE_URL>`.
- Test coverage threshold: <e.g. 80% — enforced in CI>.

**Commits**
- Format: `<type>(<scope>): <subject>` — e.g. `fix(auth): handle expired token refresh`.
- Do not commit directly to `main` / `master`. Open a PR.

**PRs**
- Every PR must update the relevant tests. Do not merge with failing tests.
- Link to the issue or ticket in the PR description.

---

## Domain Glossary

<!-- Define terms that are specific to this project's domain. -->
<!-- Claude will use these definitions when reading or writing code. -->

| Term | Definition |
|---|---|
| <Term 1> | <What it means in this project's context> |
| <Term 2> | <What it means in this project's context> |
| <Term 3> | <What it means in this project's context> |

---

## Do Not Touch

<!-- List files, directories, or patterns Claude must never edit without explicit instruction. -->

- `<e.g. config/production.yml>` — production config, edits require a separate review
- `<e.g. migrations/>` — never edit existing migrations; add new ones only
- `<e.g. .env, .env.*>` — never read or write secrets files (also blocked in .claude/settings.json)
