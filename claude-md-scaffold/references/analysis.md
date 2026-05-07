# Phase 1: Project Analysis (silent, no UI)

Run `scripts/analyze-project.sh` from project root. Then synthesize what was found into "what I know vs what I need to ask".

## Existing-CLAUDE.md gate (check FIRST)

Before anything else, check the `existing_claude_md` field in the JSON output. If it's non-empty:

- Switch to `audit-existing-project` mode by default.
- Tell the user: "I found existing CLAUDE.md file(s) at: {paths}. Defaulting to audit-only. To overwrite or trim, you must explicitly pick `focused-doc-fix` or `dedupe-cleanup`."
- Skip Phase 2 (the conversation) and go straight to Phase 3 audit/report output.

This is load-bearing: never silently regenerate over an existing CLAUDE.md.

## What the script detects automatically

| Detected | How |
|---|---|
| **Stack** | Presence of `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, etc. |
| **Package manager** | Lock files: `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `package-lock.json` → npm, `bun.lock` → bun |
| **TypeScript?** | `tsconfig.json` exists |
| **Tests?** | `vitest.config.*`, `jest.config.*`, `pytest.ini`, `__tests__/`, `*.test.ts` files |
| **Entry point** | `package.json` `main`/`exports`, common patterns: `src/index.*`, `src/main.*`, `app.*` |
| **Dev commands** | `package.json` scripts, `Makefile` targets, `Justfile` recipes |
| **Folders worth a sub-CLAUDE.md** | folders with: ≥5 files OR has subfolders OR has tests OR has README |
| **Line counts** | per top-level folder, helps you understand scale |
| **Existing docs** | `docs/`, `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md` |

## What you should NOT try to detect (ask the user instead)

These need human judgment:

- **The 30-second pitch**: what does this project DO?
- **The big architectural rule**: what's load-bearing, what's optional?
- **Gotchas**: what surprised you when you joined?
- **Project type**: web app vs library vs CLI vs monorepo
- **Which folders truly deserve sub-CLAUDE.md** (you have candidates from heuristics, but the user knows which are stable cores vs throwaway scaffolding)

## How to filter the candidate folder list

Heuristic: folders that meet 2+ of these criteria are sub-CLAUDE.md candidates:

1. Has 5+ files
2. Has subfolders
3. Has its own tests
4. Has its own README
5. Name suggests a domain: `auth`, `api`, `db`, `payments`, `ui`, `services`, `models`, `routes`, `controllers`, `views`, `components`, `pages`, `lib`, `utils` (utils is borderline)

Folders to AUTOMATICALLY EXCLUDE:
- `node_modules/`, `.git/`, `dist/`, `build/`, `.next/`, `target/`, `__pycache__/`, `.venv/`, `venv/`, `.cache/`
- Anything matching `.*` (hidden) except `.github/`, `.husky/`
- `tmp/`, `temp/`, `logs/`, `coverage/`

## What to present to user in Phase 2

After analysis, summarize for the user:

```
I scanned the project. Here's what I see:

Type:     {Node web app | Python library | Go CLI | etc.}
Stack:    {TypeScript + Express | Python + FastAPI | etc.}
Tests:    {Vitest | Jest | pytest | none detected}
Manager:  {pnpm | npm | uv | etc.}

Entry point: {file}

Top folders by size:
  src/          12 files, 2.1K lines
  tests/         8 files, 0.4K lines
  docs/          3 files

I'd suggest sub-CLAUDE.md files for these (they look like distinct features):
  - src/auth/    (8 files, has tests)
  - src/api/     (12 files, has subfolders)
  - src/db/      (6 files, has README)

Does this match what you see? Anything to add or correct?
```

This single message confirms what was inferred and lets the user catch errors before we proceed.
