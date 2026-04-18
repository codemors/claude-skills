# HTML Intermediate Layer

## Purpose

The HTML intermediate layer serves two goals:
1. **Accuracy**: Produce a pixel-faithful HTML page from Figma context before converting to Elementor
2. **QA gate**: Screenshot the HTML and compare to Figma screenshot → catch conversion errors early

## Building the HTML Intermediate

### Starting point

Use `get_design_context(figma_url)` output. The response includes layout, typography,
colors, spacing, and component code (React+Tailwind). Treat this as a reference,
not final code.

### HTML Structure Rules

- Use plain HTML5 + inline `<style>` block — no framework dependencies
- Apply exact hex colors from Figma (no token substitution in HTML layer)
- Use exact pixel sizes from Figma for fonts, spacing, dimensions
- For RTL sites: add `dir="rtl"` to `<html>` and `<body>`
- Serve locally via `file://` for Playwright screenshot

### HTML Template

```html
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=1440">
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { background: #0d0d0d; font-family: 'Frank Ruhl Libre', serif; direction: rtl; }
@font-face {
  font-family: 'Hornset';
  src: url('/path/to/Hornset.ttf') format('truetype');
}
/* section-specific styles below */
</style>
</head>
<body>
<!-- sections here -->
</body>
</html>
```

### Figma-to-HTML Mapping

| Figma concept | HTML equivalent |
|---|---|
| Frame (horizontal) | `div` with `display:flex; flex-direction:row` |
| Frame (vertical) | `div` with `display:flex; flex-direction:column` |
| Text node | `<p>`, `<h1>`–`<h6>`, or `<span>` |
| Image | `<img>` with exact width/height |
| Auto Layout gap | `gap` in flexbox |
| Padding | `padding` |
| Fill color | `background-color` |
| Stroke | `border` |
| Corner radius | `border-radius` |
| Opacity | `opacity` |
| Drop shadow | `box-shadow` |

## HTML → Elementor JSON Mapping

| HTML structure | Elementor equivalent |
|---|---|
| `<section>` or top-level `<div>` | `elType: "container"` (outer section) |
| Flex row `<div>` | `elType: "container"`, `flex_direction: "row"` |
| Flex column `<div>` | `elType: "container"`, `flex_direction: "column"` |
| `<h1>`–`<h6>` | `widgetType: "heading"`, `header_size: "h1"`–`"h6"` |
| `<p>` or `<div>` with text | `widgetType: "text-editor"` |
| `<img>` | `widgetType: "image"` |
| `<a>` styled as button | `widgetType: "button"` |
| `<hr>` | `widgetType: "divider"` |
| Empty spacer div | `widgetType: "spacer"` |

## QA Screenshot with Playwright

```js
const { chromium } = require('playwright');
const path = require('path');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto('file://' + path.resolve('/tmp/kasuku-intermediate.html'));
  await page.waitForLoadState('networkidle');
  await page.screenshot({ path: '/tmp/qa_html.png', fullPage: true });
  await browser.close();
})();
```

Run: `node /tmp/qa_screenshot.js`

## Diff Score Calculation

Compare QA screenshot to Figma screenshot using pixel diff:

```bash
# Using ImageMagick (if available):
compare -metric PSNR /tmp/figma_ref.png /tmp/qa_html.png /tmp/diff.png 2>&1

# Manual: open both in browser side by side and report visually
```

Threshold: < 5% visual difference = proceed. > 5% = pause and review.

## Common HTML→Elementor Conversion Issues

| HTML issue | Fix in Elementor JSON |
|---|---|
| Image wrong size | Add `custom_css`: `selector{width:Xpx!important;...}selector img{...}` |
| Text aligned wrong | Check for erroneous `direction:ltr` on parent container |
| Elements in wrong order | Add `direction:ltr` to flex row container |
| Background not showing | Use `background_color` setting AND `custom_css` with `!important` |
| Fonts not rendering | Ensure `@font-face` added to Elementor kit CSS |
| Images lazy-loaded | Set `image_loading: ""` on each image widget + disable at WP level |
