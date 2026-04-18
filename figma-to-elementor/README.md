# figma-to-elementor

Convert any Figma design URL into a live Elementor page on WordPress — automatically, end-to-end, with no technical knowledge required.

## What it does

1. **5-gate wizard** — validates and auto-fixes all prerequisites before starting
2. **HTML intermediate layer** — builds a pixel-faithful HTML page from the Figma design for accuracy
3. **QA1** — screenshots HTML vs Figma reference, pauses if diff > 5%
4. **Converts to Elementor JSON** — using Flexbox Container model (Elementor Pro 4.x)
5. **Deploys via SSH + WP-CLI** — uploads and runs a PHP script on the server
6. **QA2** — screenshots the live page vs HTML, reports match percentage
7. **Final report** — URL, Post ID, QA scores, warnings

## Prerequisites

- Claude Code with Figma MCP connected
- SSH access to your WordPress server
- Elementor Pro installed and licensed (≥ 3.6)

Missing dependencies (Playwright, WP-CLI) are installed automatically.

## Usage

```
/figma-to-elementor
```

Then provide:
1. Figma URL (e.g. `https://figma.com/design/...?node-id=...`)
2. SSH credentials (host, username, WordPress path)

## Installation

```bash
cp -r figma-to-elementor ~/.claude/skills/
```

Add to `~/.claude/CLAUDE.md`:
```markdown
# figma-to-elementor
- **figma-to-elementor** (`~/.claude/skills/figma-to-elementor/SKILL.md`) - Convert Figma URL to live Elementor WordPress page. Trigger: `/figma-to-elementor`
When the user types `/figma-to-elementor`, invoke the Skill tool with `skill: "figma-to-elementor"` before doing anything else.
```

## Features

- Auto-installs Playwright and WP-CLI if missing
- Handles Hebrew/Arabic RTL layouts correctly
- Custom font upload with skip option
- Disables Elementor lazy loading at 3 levels
- Runtime error recovery (404, broken images, font issues, wrong sizes)
- Works on Cloudways, SiteGround, WP Engine, and any SSH-accessible host

## References

The skill loads these reference files on demand:

| File | Contents |
|------|----------|
| `references/elementor-json-spec.md` | Elementor Pro 4.x JSON structure, all widget types |
| `references/rtl-gotchas.md` | Hebrew/Arabic RTL rules — critical for correct layouts |
| `references/css-overrides.md` | `selector` CSS pattern, common override snippets |
| `references/deployment.md` | SSH + WP-CLI commands, PHP deploy template |
| `references/html-intermediate.md` | HTML build rules, Figma→HTML→Elementor mapping |
