# Feature Folder CLAUDE.md Template

A sub-folder CLAUDE.md is a focused brief about ONE feature/domain. Target: 30-80 lines. If you exceed 100, the folder probably needs to be split.

## When to create one

Create a sub-folder CLAUDE.md when ALL of these are true:
- The folder represents a coherent domain (auth, payments, db, etc.)
- It has 5+ files OR clear sub-structure
- It has rules/conventions that don't apply elsewhere in the codebase
- A new contributor would benefit from reading it before editing

## When NOT to create one

Skip if:
- The folder has 1-3 simple files
- The folder is a leaf utility folder (`utils/`, `helpers/`)
- The conventions are the same as the rest of the codebase

## Section order

1. Title + one-line subtitle
2. What this folder does (1-2 sentences)
3. Files (table, only if >3 files)
4. Key Invariants (only if any)
5. Gotchas (only if any)
6. Related (always — links up and across)

## Related section structure

- **Parent context**: link to root CLAUDE.md
- **Calls into**: what other folders this depends on
- **Called by**: what other folders depend on this
- **Tests**: where the tests live

This section helps Claude understand the dependency graph at a glance.

## Anti-patterns to avoid

- **Don't dump every function** — only files. Functions live in code.
- **Don't repeat root invariants** — they're inherited.
- **Don't write narrative** — just rules and pointers.
- **Don't skip "Related"** — it's the most navigationally useful section.
