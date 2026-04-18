# claude-skills

A collection of Claude Code skills for various workflows.

## Skills

### figma-to-elementor
Convert any Figma design URL into a live Elementor page on WordPress — automatically, end-to-end.

**Trigger:** `/figma-to-elementor`

**What it does:**
- Validates all prerequisites (Figma MCP, Playwright, SSH, WP-CLI, Elementor)
- Auto-installs missing dependencies (Playwright, WP-CLI)
- Builds an HTML intermediate layer for accuracy
- QA screenshots at every step (HTML vs Figma, live vs HTML)
- Deploys via SSH + WP-CLI
- Handles RTL (Hebrew/Arabic) correctly

**Installation:**
```bash
cp -r figma-to-elementor ~/.claude/skills/
```

Then add to `~/.claude/CLAUDE.md`:
```markdown
# figma-to-elementor
- **figma-to-elementor** (`~/.claude/skills/figma-to-elementor/SKILL.md`) - Convert Figma URL to live Elementor WordPress page. Trigger: `/figma-to-elementor`
When the user types `/figma-to-elementor`, invoke the Skill tool with `skill: "figma-to-elementor"` before doing anything else.
```
