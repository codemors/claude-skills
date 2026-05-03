# Root CLAUDE.md Template

The root CLAUDE.md is the project's "front door" for any AI working on it. Target: 100-200 lines. If you exceed 250, split into sub-folder files.

## Section order (this order matters — Claude reads top-down)

1. Title + one-line subtitle
2. Quick Context (3-5 sentences)
3. The Big Rule (load-bearing invariant, if any)
4. Architecture (brief, link to docs/ for depth)
5. Key Files (table)
6. Folders With Their Own CLAUDE.md (only if applicable)
7. Gotchas (only if any exist)
8. Development (commands)
9. Troubleshooting (only if non-obvious)
10. Docs Index (only if docs/ folder exists)

See SKILL repo for the full markdown template with placeholders.

## Anti-patterns to avoid

- **Don't dump every file** in Key Files. Be selective.
- **Don't write prose where a table works.** Tables are scannable.
- **Don't repeat README.md.** README is for humans onboarding, CLAUDE.md is for AI.
- **Don't include personal context.** That's persona, not project context.
- **Don't lecture.** Just state the rule.
- **Don't add fluff sections** ("Welcome!", "About this project"). Get to the point.
