---
name: scaffold-claude-md
description: "Audit-first CLAUDE.md scaffold and maintenance. Builds a clean, hierarchical CLAUDE.md structure for a project, or audits an existing one without rewriting it. Supports four explicit modes (scaffold-new-project, audit-existing-project, focused-doc-fix, dedupe-cleanup) so mature projects are never silently overwritten."
---

# Scaffold a CLAUDE.md hierarchy

A conversational skill that produces or audits a navigable CLAUDE.md system, instead of one giant file that nobody reads.

This is **not** an "auto-fix my CLAUDE.md" tool. On any project that already has a CLAUDE.md, the skill defaults to **audit only** — it reports findings and stops before editing.

## What it produces (scaffold mode)

```
your-project/
├── CLAUDE.md                  ← root: 30-second pitch, key files, gotchas
├── src/
│   ├── auth/
│   │   └── CLAUDE.md          ← per-feature: invariants, files, related
│   ├── api/
│   │   └── CLAUDE.md
│   └── ...
└── docs/                      ← if exists, root CLAUDE.md links to it
```

## Modes (pick one explicitly before doing anything)

The skill supports four modes. Always state which mode you are in before generating or editing files. If the user did not specify, ask.

| Mode | When to use | Touches existing files? |
|------|-------------|-------------------------|
| `scaffold-new-project` | Project has **no** CLAUDE.md anywhere | Creates new files only |
| `audit-existing-project` | Project already has CLAUDE.md(s) | **Read-only.** Produces a stale-docs report and stops. |
| `focused-doc-fix` | User points at one specific stale fact / wrong section | Edits only the named section, with diff preview |
| `dedupe-cleanup` | Trim duplicates, consolidate sections | **High risk.** Separate branch recommended. |

## Existing-project safety rule (load-bearing)

If existing CLAUDE.md files are detected during analysis, the default behavior is **audit-only**:

- Do **not** overwrite existing CLAUDE.md
- Do **not** rebuild or regenerate
- Do **not** trim, delete, or move sections
- Produce a **stale-docs report** first (what looks outdated, what's missing, what duplicates what)
- Stop before any edit and wait for the user to pick a mode

The user must explicitly opt into `focused-doc-fix` or `dedupe-cleanup` after reading the report. Bulk rewrites of an existing CLAUDE.md without explicit consent are forbidden.

## Commit hygiene rule (load-bearing, mature projects)

For mature projects, **never mix factual fixes and broad cleanup in the same commit.** Keep these as separate commits (and ideally separate branches):

1. Stale-doc fixes (a wrong fact, an outdated path, a renamed command)
2. Safety fixes (unguarded instruction, missing "load-bearing" marker)
3. Dedupe / trim / restructure cleanup

Mixing these makes review impossible and makes reverts unsafe.

## Phases

### Phase 1: Analyze (silent)

Run `scripts/analyze-project.sh` from project root. Detects stack, entry points, candidate feature folders, **and existing CLAUDE.md files**. See [`references/analysis.md`](references/analysis.md).

If the analysis shows existing CLAUDE.md files, switch to `audit-existing-project` mode by default and tell the user. Do not proceed to scaffold without explicit confirmation.

### Phase 2: Conversation (5-6 turns, scaffold mode only)

Ask the user the questions whose answers you can't infer from the code. One per turn. See [`references/conversation.md`](references/conversation.md).

In `audit-existing-project` mode, skip the conversation. Produce the report instead.

### Phase 3: Generate (scaffold mode) or Report (audit mode)

- **Scaffold:** write root CLAUDE.md using [`references/root-template.md`](references/root-template.md), per-folder using [`references/feature-template.md`](references/feature-template.md).
- **Audit:** write a single stale-docs report to stdout (or to `CLAUDE-AUDIT.md` if user requests). Do not modify existing files.

### Phase 4: Preview + iterate

Show generated files or report. Offer to expand/trim sections.

### Phase 5: Save + close

Write files. Tell user where they are. In audit/dedupe modes, remind the user about the commit hygiene rule before they stage changes.

## Reference map

| Need | Load |
|------|------|
| Analyze the project | [`references/analysis.md`](references/analysis.md) |
| Run the conversation | [`references/conversation.md`](references/conversation.md) |
| Generate root CLAUDE.md | [`references/root-template.md`](references/root-template.md) |
| Generate sub-folder CLAUDE.md | [`references/feature-template.md`](references/feature-template.md) |
| Refresher on best practices | [`references/principles.md`](references/principles.md) |
| Need a "good vs bad" example | [`references/examples.md`](references/examples.md) |

## Scripts

`scripts/analyze-project.sh` — run from project root. Outputs JSON with detected stack, entry points, folder candidates, package manager, line counts, and any existing CLAUDE.md paths. Idempotent.

## Rules (apply during scaffold mode)

- **Don't write everything you can detect.** Half of a good CLAUDE.md is what you DELETE. Aim for 100-200 lines on root, 30-80 lines per sub-folder.
- **Lead with WHY.** First section is "what is this project and how does it fit together", not "here are all the files".
- **Tables over paragraphs.** For file lists, command lists, gotcha symptoms.
- **Gotchas are first-class.** Every project has 1-3. Surface them. Format: Symptom → Fix → Why.
- **Mark load-bearing rules.** Use the phrase "load-bearing" so future readers know not to change without thinking.
- **Link, don't duplicate.** If `docs/architecture.md` exists, root CLAUDE.md says "see docs/architecture.md for full details" — doesn't repeat.
- **Sub-CLAUDE.md is optional.** Only create one when the folder has its own non-obvious rules. A folder with 3 simple files doesn't need one.

## Done when

- (Scaffold) Root `CLAUDE.md` exists and is under 250 lines
- (Scaffold) Each sub-folder CLAUDE.md (if any) is under 100 lines
- (Audit) Stale-docs report delivered, no files modified
- (Focused fix / dedupe) Diff previewed, user approved, separate commit per category
- User has read the preview / report and confirmed

## Notes on Claude Code's loading behavior

When Claude Code opens a file, it auto-loads CLAUDE.md from the file's folder AND all parent folders up to the project root. So sub-folder CLAUDE.md files are automatically used when working in that folder.

You don't need to add `@./src/auth/CLAUDE.md` references in the root — Claude Code finds them. But the root SHOULD list which sub-folders have their own CLAUDE.md, so a human reading the root can navigate the hierarchy.
