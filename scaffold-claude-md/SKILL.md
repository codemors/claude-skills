---
name: scaffold-claude-md
description: Build a clean, hierarchical CLAUDE.md structure for any project. Analyzes the codebase, asks 5-6 high-signal questions, then generates a root CLAUDE.md plus optional sub-CLAUDE.md files in feature folders. Follows Anthropic's best practices: lead with WHY, tables over paragraphs, gotchas as first-class citizens. Works on any tech stack — Node, Python, Go, monorepo, anything.
---

# Scaffold a CLAUDE.md hierarchy

A 6-turn conversational skill that produces a navigable CLAUDE.md system for a project, instead of one giant file that nobody reads.

## What it produces

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

## When to use

- Joining a project that has no CLAUDE.md
- Existing CLAUDE.md is one giant file and you want to refactor it
- Adding a new major feature that needs its own context
- Onboarding others (human or AI) into the codebase

## Phases

### Phase 1: Analyze (silent)
Run `scripts/analyze-project.sh` from project root. Detects stack, entry points, candidate feature folders. See [`references/analysis.md`](references/analysis.md).

### Phase 2: Conversation (5-6 turns)
Ask the user the questions whose answers you can't infer from the code. See [`references/conversation.md`](references/conversation.md).

### Phase 3: Generate
Write root CLAUDE.md using the template in [`references/root-template.md`](references/root-template.md). Write per-folder CLAUDE.md files using [`references/feature-template.md`](references/feature-template.md).

### Phase 4: Preview + iterate
Show generated files. Offer to expand/trim sections.

### Phase 5: Save + close
Write files. Tell user where they are and how Claude Code uses them.

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

`scripts/analyze-project.sh` — run from project root. Outputs JSON with detected stack, entry points, folder candidates, package manager, line counts. Idempotent.

## Rules

- **Don't write everything you can detect.** Half of a good CLAUDE.md is what you DELETE. Aim for 100-200 lines on root, 30-80 lines per sub-folder.
- **Lead with WHY.** First section is "what is this project and how does it fit together", not "here are all the files".
- **Tables over paragraphs.** For file lists, command lists, gotcha symptoms.
- **Gotchas are first-class.** Every project has 1-3. Surface them. Format: Symptom → Fix → Why.
- **Mark load-bearing rules.** Use the phrase "load-bearing" so future readers know not to change without thinking.
- **Link, don't duplicate.** If `docs/architecture.md` exists, root CLAUDE.md says "see docs/architecture.md for full details" — doesn't repeat.
- **Sub-CLAUDE.md is optional.** Only create one when the folder has its own non-obvious rules. A folder with 3 simple files doesn't need one.

## Done when

- Root `CLAUDE.md` exists and is under 250 lines
- Each sub-folder CLAUDE.md (if any) is under 100 lines
- User has read the preview and confirmed
- All files committed to git (or staged, depending on user preference)

## Notes on Claude Code's loading behavior

When Claude Code opens a file, it auto-loads CLAUDE.md from the file's folder AND all parent folders up to the project root. So sub-folder CLAUDE.md files are automatically used when working in that folder.

You don't need to add `@./src/auth/CLAUDE.md` references in the root — Claude Code finds them. But the root SHOULD list which sub-folders have their own CLAUDE.md, so a human reading the root can navigate the hierarchy.
