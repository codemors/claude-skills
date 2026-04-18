# vibe-security-scan

Scans the current project for the 5 most common vibe-coding security mistakes before going live. Read-only — makes no changes to your code.

## What it checks

| # | Check | Severity |
|---|-------|----------|
| 1 | Hardcoded secrets (API keys, passwords, tokens) | 🚨 CRITICAL |
| 2 | Broken auth / IDOR (missing ownership checks on API routes) | ⚠️ HIGH |
| 3 | Missing RLS policies (Supabase / Firebase) | 🚨 CRITICAL |
| 4 | Source maps exposed in production build | ⚠️ HIGH |
| 5 | Insecure dependencies (`npm audit`, `pip audit`) | ⚠️ HIGH |

## Supported stacks

- JavaScript / TypeScript (Next.js, React, Express, Vite)
- Python (Flask, FastAPI)
- PHP
- Supabase
- Firebase

## Usage

```
/vibe-security-scan
```

Run this before any production deployment.

## Installation

```bash
cp -r vibe-security-scan ~/.claude/skills/
```

Add to `~/.claude/CLAUDE.md`:
```markdown
# vibe-security-scan
- **vibe-security-scan** (`~/.claude/skills/vibe-security-scan/SKILL.md`) - Scan project for security issues before going live. Trigger: `/vibe-security-scan`
When the user types `/vibe-security-scan`, invoke the Skill tool with `skill: "vibe-security-scan"` before doing anything else.
```

## Output format

```
🔍 Vibe Security Scan — Results
================================
🚨 CRITICAL — Hardcoded Secrets (1 found)
  src/api/client.js:12 — API key hardcoded in source

✅  PASS — Source Maps

================================
Summary: 1 CRITICAL · 0 HIGH
Fix these before going live.
```
