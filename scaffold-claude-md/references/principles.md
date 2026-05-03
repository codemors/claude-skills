# 6 Principles of a Good CLAUDE.md

Distilled from reading well-maintained CLAUDE.md files. Use as a checklist.

## 1. Lead with WHY, not HOW

The reader needs to know **what they're looking at and why it exists** before they care about file paths. Open with the WHY in 1-2 sentences. Files come later.

## 2. Tables > paragraphs (for lookups)

Anything that's "X → Y" should be a table. Same information, scannable in 2 seconds.

## 3. Gotchas are first-class

Every project has 1-3 things that surprise new contributors. Document them with consistent format: Symptom → Fix → Why. Highest-value content per line.

## 4. Mark load-bearing rules

Use the phrase "load-bearing" — tells future-you (and AI): "don't refactor without understanding why this exists." Stops well-intentioned but harmful changes.

## 5. Link, don't duplicate

If you have a `docs/` folder, root CLAUDE.md should LINK to deep docs, not summarize them. Less to maintain, more to find.

## 6. Keep it under 250 lines (root) / 100 lines (sub-folder)

CLAUDE.md is loaded into every Claude conversation. Long CLAUDE.md = high token cost + reader fatigue. The discipline of brevity forces clear thinking.

## Bonus: the "future Claude" test

A fresh Claude conversation lands in this codebase 3 months from now. Will it know:
1. What this project IS in 30 seconds?
2. NOT to refactor X because it's load-bearing?
3. The right file to find fast?
4. Common pitfalls to avoid?
5. How to run tests?

If yes to all — ship it.
