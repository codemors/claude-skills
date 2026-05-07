# Good vs Bad Examples

Real patterns to imitate (good) and avoid (bad). Pull from these when writing.

## Quick Context section

**✗ Bad:** Marketing tone, no signal, padding everywhere. "Welcome to MyApp! This is a really exciting project..."

**✓ Good:** "CLI tool that scrapes invoices from supplier portals and writes them to QuickBooks. Single binary, runs on a cron, idempotent."

## Key Files table

**✗ Bad:** Prose dumping every file. Unscannable.

**✓ Good:** Table with 3-8 most important files, 5-word purpose each. Defers detail to sub-folders.

## Gotchas section

**✗ Bad:** "Sometimes the build fails. There's an issue with the database. Auth tokens have weird behavior." Vague, no actionable fix.

**✓ Good:** Each gotcha has searchable title + Symptom → Fix → Why structure. Exact commands, not descriptions.

## Sub-folder CLAUDE.md

**✗ Bad:** 200-line textbook repeating root rules.

**✓ Good:** 30 lines, scannable, navigationally useful (Related section links the dependency graph).

## Architecture section

**✗ Bad:** Duplicates docs/architecture.md in 50 paragraphs.

**✓ Good:** Link first + 1-paragraph summary + surfaces the load-bearing rule.

## When to OMIT a section

| Section | Skip if... |
|---------|-----------|
| The Big Rule | No genuinely load-bearing convention exists |
| Gotchas | Project is genuinely simple, no surprises |
| Folders With Their Own CLAUDE.md | You're not creating any sub-files |
| Troubleshooting | All issues are obvious ("check logs") |
| Docs Index | No `docs/` folder exists |

A 90-line CLAUDE.md with 5 sections is better than a 250-line one with 10 sections half of which are filler.

## The 60-second test

After writing CLAUDE.md, set a timer. Try to answer:
1. What is this project?
2. What's the most important rule I shouldn't break?
3. Where would I look to add a new feature?
4. What command runs the tests?

If you can't answer all 4 in 60 seconds — it needs editing.
