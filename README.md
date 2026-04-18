# claude-skills

A collection of Claude Code skills built by [Mor M.](https://github.com/MorMaman).

---

## What are Claude Code Skills?

Claude Code skills are reusable instruction files that extend Claude's capabilities with specialized workflows. When you install a skill, Claude can invoke it on demand — bringing domain expertise, step-by-step processes, and battle-tested patterns into any project.

Think of them as plugins for Claude: drop them into `~/.claude/skills/`, register them in `~/.claude/CLAUDE.md`, and trigger them with a `/command`.

---

## How to Install a Skill

**1. Copy the skill folder to your Claude skills directory:**
```bash
cp -r <skill-name> ~/.claude/skills/
```

**2. Register it in `~/.claude/CLAUDE.md`:**
```markdown
# skill-name
- **skill-name** (`~/.claude/skills/skill-name/SKILL.md`) - What it does. Trigger: `/skill-name`
When the user types `/skill-name`, invoke the Skill tool with `skill: "skill-name"` before doing anything else.
```

**3. Use it in any Claude Code session:**
```
/skill-name
```

That's it. Claude will load the skill and follow its workflow.

---

## Skills

### [figma-to-elementor](./figma-to-elementor/)
Convert any Figma design URL into a live Elementor WordPress page — automatically, end-to-end.

- 5-gate wizard (validates Figma MCP, Playwright, SSH, WP-CLI, Elementor)
- Auto-installs missing dependencies
- HTML intermediate layer for pixel-accurate conversion
- QA screenshots at every step
- Full Hebrew/Arabic RTL support
- Custom font handling with upload or skip option

**Trigger:** `/figma-to-elementor`

---

### [vibe-security-scan](./vibe-security-scan/)
Scan your project for the 5 most common vibe-coding security mistakes before going live.

- Hardcoded secrets detection
- Broken auth / IDOR checks
- Missing RLS (Supabase/Firebase)
- Source maps in production
- Insecure dependencies audit

**Trigger:** `/vibe-security-scan`

---

## Credits

Skills designed and built by **Mor M.** — [@MorMaman](https://github.com/MorMaman)

---

## Contributing

Have a skill to add? Open a PR with your skill folder and a README.
