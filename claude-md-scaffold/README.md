# CLAUDE.md Scaffold

**Audit-first CLAUDE.md scaffold and maintenance skill** for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

Use it to create a clean, hierarchical `CLAUDE.md` system for a new project, or to audit and carefully maintain an existing one. It is **not** an auto-rewrite tool.

> This is not "auto-fix my CLAUDE.md".
> This is "audit-first CLAUDE.md scaffold and maintenance".

## When to use

- **New project with no CLAUDE.md** — generate a root + per-folder CLAUDE.md hierarchy from scratch.
- **Existing project that needs a docs audit** — get a stale/missing/contradictory report without touching your files.
- **Focused CLAUDE.md fixes after code changes** — patch one specific section that drifted from reality.
- **Controlled cleanup / dedupe** — consolidate or trim, on a separate branch, with explicit approval.

## Safety defaults (important)

If existing `CLAUDE.md` files are detected during analysis, the skill defaults to **audit-only**:

- Does **not** overwrite existing docs.
- Does **not** rebuild from scratch.
- Does **not** trim, delete, or move sections without explicit approval.
- Always shows a plan or diff before any edit.

You must explicitly opt into a mode that edits files. Bulk rewrites of an existing CLAUDE.md without consent are forbidden.

## Modes

The skill has four explicit modes. The skill will state which mode it is in before generating or editing anything. If you don't pick one, it will ask.

| Mode | When to use | Touches existing files? |
|------|-------------|-------------------------|
| `scaffold-new-project` | Project has **no** CLAUDE.md anywhere | Creates new files only |
| `audit-existing-project` | Project already has CLAUDE.md(s) | **Read-only.** Produces a stale-docs report and stops. |
| `focused-doc-fix` | You point at one specific stale fact / wrong section | Edits only the named section, with diff preview |
| `dedupe-cleanup` | Trim duplicates, consolidate sections | **High risk. Use a separate branch.** |

## Recommended workflow (mature projects)

1. **Run the audit** in `audit-existing-project` mode.
2. **Review** the stale / missing / contradictory items in the report.
3. **Approve specific edits** one at a time via `focused-doc-fix`.
4. **Commit** focused docs-only changes — one logical fix per commit.
5. **Keep cleanup separate** from factual fixes. Run `dedupe-cleanup` on its own branch and PR.

This separation makes review possible and reverts safe.

## What this skill should NOT do

- Should **not** change code.
- Should **not** mutate the database.
- Should **not** deploy.
- Should **not** touch secrets or `.env` files.
- Should **not** modify production systems.
- Should **not** do broad cleanup in the same commit as factual fixes.
- Should **not** edit payment code, auth/security code, database migrations, cron jobs, edge functions, deployment config, or notification/SMS/email-sending logic — unless you explicitly asked for that exact area.
- Should **not** auto-create `CLAUDE-AUDIT.md` or any other output file during an audit. The report goes to chat first; a file is written only if you explicitly ask.

The analyze phase is **read-only**: no file writes, no package installs, no migrations, no servers, no deploys, no git state changes, no env or secret access. See `SKILL.md` ("Read-only analyze rule" and "Production-system safety") for the full rules.

If you ask it to do any of the above, it should refuse or redirect you to the appropriate tool.

## Example prompts

```
Audit existing CLAUDE.md files and stop before editing.
```

```
Create a CLAUDE.md hierarchy for this new project.
```

```
Update docs only for the changes in this diff — don't touch anything else.
```

## Install / use

This is a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills). Drop the `claude-md-scaffold/` folder under a skills directory:

```
~/.claude/skills/claude-md-scaffold/
├── SKILL.md
├── README.md
├── references/
└── scripts/
```

Then invoke it from Claude Code (e.g. `/claude-md-scaffold` or by asking Claude to "scaffold a CLAUDE.md hierarchy" / "audit my CLAUDE.md").

## Files

| Path | Purpose |
|------|---------|
| `SKILL.md` | The skill itself — modes, safety rules, phases. |
| `scripts/analyze-project.sh` | Read-only project scan. Outputs JSON. Detects existing CLAUDE.md files. |
| `references/analysis.md` | Phase 1 — analysis logic and the existing-CLAUDE.md gate. |
| `references/conversation.md` | Phase 2 — the 5-6 turn conversation (scaffold mode only). |
| `references/root-template.md` | Template for the root CLAUDE.md. |
| `references/feature-template.md` | Template for sub-folder CLAUDE.md. |
| `references/principles.md` | The 6 principles of a good CLAUDE.md. |
| `references/examples.md` | Good-vs-bad examples. |

## License

See the parent repository's license.
