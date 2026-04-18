# figma-to-elementor

Convert any Figma design URL into a live Elementor page on WordPress.
Automatic, end-to-end, requires zero technical knowledge from the user.

**Announce at start:** "I'm using the figma-to-elementor skill to build your Elementor page."

---

## What You Need From The User

Ask ONLY these two things before starting:

1. **Figma URL** — the design frame to convert (e.g. `https://figma.com/design/...?node-id=...`)
2. **WordPress SSH credentials:**
   - Host (e.g. `mysite.cloudwaysapps.com`)
   - SSH username
   - WordPress path on server (e.g. `/home/.../public_html`)
   - SSH port (default: 22) — ask only if connection fails

If the user doesn't know their SSH credentials, say:
> "כדי להתחבר לוורדפרס שלך, אני צריך את פרטי ה-SSH. תוכל למצוא אותם בפאנל האחסון שלך (Cloudways / SiteGround / WP Engine וכו')"

---

## Phase 1: Five Gates (Run Before Any Conversion)

Run all 5 gates in order. Fix issues automatically wherever possible.
If a gate cannot be auto-fixed, explain clearly and wait for user action.

### Gate 1: Figma Connection

- Call `mcp__figma__get_design_context` with the user's URL
- If **MCP not connected**: "פתח את פיגמה בדפדפן, לחץ על התוסף figma-mcp ואפשר חיבור"
- If **URL format wrong**: parse and correct — `node-id` param must use `-` not `:`
- If **permission error**: "הדיזיין נעול. בפיגמה: Share → Anyone with the link → Can view"
- If **design too large**: split by top-level frames, process each separately

### Gate 2: Playwright

```bash
node -e "require('playwright')" 2>/dev/null && echo "OK" || echo "MISSING"
```

- If **missing**: run automatically — no user action needed:
  ```bash
  npx playwright install --with-deps chromium
  ```
  Report: "Playwright לא היה מותקן — הותקן אוטומטית."
- Test after install:
  ```bash
  node -e "const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();await b.close();console.log('OK');})()"
  ```
- If test still fails: try adding `--no-sandbox` flag to all Playwright launches

### Gate 3: SSH / WordPress

```bash
ssh -o ConnectTimeout=10 -p 22 USER@HOST "echo OK"
```

- If **connection refused on 22**: try port 2222
- If **auth fails**: "בדוק את שם המשתמש והסיסמה. אם אתה משתמש ב-SSH key, וודא שה-key נוסף לשרת"
- If **connected but WordPress not found at path**: search common locations:
  ```bash
  ssh USER@HOST "find / -name 'wp-config.php' -maxdepth 8 2>/dev/null | head -5"
  ```
- If **wp-config.php not readable**:
  ```bash
  ssh USER@HOST "chmod 644 PATH/wp-config.php"
  ```

### Gate 4: WP-CLI

```bash
ssh USER@HOST "wp cli info --path=WP_PATH" 2>/dev/null || echo "MISSING"
```

- If **missing**: install automatically:
  ```bash
  ssh USER@HOST "curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar"
  ```
  Then use `php ~/wp-cli.phar` instead of `wp` for all subsequent commands.
- Test: `ssh USER@HOST "php ~/wp-cli.phar cli info --path=WP_PATH"`
- If **DB error**: surface exact message from `wp db check`

### Gate 5: Elementor + Settings

```bash
ssh USER@HOST "wp plugin list --path=WP_PATH --field=name"
```

Check list for `elementor` and `elementor-pro`:

| Finding | Action |
|---------|--------|
| Elementor not installed | STOP: "אנא התקן Elementor מ: wp-admin → תוספים → הוסף חדש" |
| Elementor installed, no Pro | Warn: "Elementor Pro נדרש לפריסות Flexbox Container. ניתן להמשיך עם תמיכה מוגבלת." |
| Elementor version < 3.6 | Warn and offer classic (section/column) fallback |
| Pro installed, license inactive | STOP: "אנא הפעל את רישיון Elementor Pro מ: Elementor → License" |

Auto-enable required settings:
```bash
# Enable Flexbox Container
ssh USER@HOST "wp option update elementor_experiment-container active --path=WP_PATH"

# Detect language and enable RTL if needed
LANG=$(ssh USER@HOST "wp option get WPLANG --path=WP_PATH")
if [[ "$LANG" == "he_IL" || "$LANG" == "ar" || "$LANG" == "fa_IR" ]]; then
  ssh USER@HOST "wp option update elementor_rtl_enabled yes --path=WP_PATH"
fi

# Disable lazy loading
ssh USER@HOST "wp option update elementor_lazy_load_background_images '' --path=WP_PATH"
ssh USER@HOST "wp option update elementor_experiment-e_lazyload inactive --path=WP_PATH"
```

### Gate 5b: Fonts

Detect custom fonts from Figma design context response.

For each non-system, non-Google font found, ask:

```
🔤 גופנים מיוחדים
הדיזיין משתמש בגופן "[FONT_NAME]" שאינו גופן מערכת.
• יש לך את קובץ הגופן? הכנס את הנתיב המלא (לדוגמה: /Users/you/Downloads/Font.ttf)
• רוצה לדלג ולהשתמש בגופן חלופי? הקלד: דלג
```

- **User provides path**:
  ```bash
  scp -O PATH_TO_FONT USER@HOST:/tmp/custom_font.ttf
  ssh USER@HOST "mkdir -p WP_CONTENT/uploads/fonts && mv /tmp/custom_font.ttf WP_CONTENT/uploads/fonts/FONT_NAME.ttf"
  ```
  Then add `@font-face` to Elementor kit CSS (see `references/css-overrides.md`).

- **User skips**: substitute with closest Google Font or system serif/sans-serif.
  Add to final report: `⚠️ גופן "[FONT_NAME]" לא הועלה — הועברה חלופה: [FALLBACK]`

- **Google Font detected**: auto-enqueue via Elementor settings — no file needed.

---

## Phase 2: Conversion Pipeline

All gates passed. Now convert.

### Step 1: Fetch Figma Design

```
mcp__figma__get_design_context(fileKey, nodeId)
mcp__figma__get_screenshot(fileKey, nodeId)  → save to /tmp/figma_ref.png
```

If response too large: call `mcp__figma__get_metadata` first, then fetch child nodes individually.

Load reference: `references/elementor-json-spec.md` — for widget types and JSON structure.
Load reference: `references/rtl-gotchas.md` — if RTL site detected.

### Step 2: Download Assets

For each image/SVG in the design context response:
```bash
curl -sL "IMAGE_URL" -o /tmp/asset_NAME.jpg
```

Upload to WP Media Library:
```bash
scp -O -P SSH_PORT /tmp/asset_NAME.jpg USER@HOST:/tmp/asset_NAME.jpg
ssh -p SSH_PORT USER@HOST "wp media import /tmp/asset_NAME.jpg --title='Asset Name' --porcelain --path=WP_PATH"
```

Save the returned attachment ID for use in image widget JSON.

### Step 3: Build HTML Intermediate

Load reference: `references/html-intermediate.md`

Build a complete HTML file at `/tmp/figma_intermediate.html`:
- Exact colors, sizes, fonts from Figma
- `dir="rtl"` on `<html>` for Hebrew/Arabic sites
- All images referenced by local `/tmp/` path
- No frameworks, no dependencies

### Step 4: QA1 — HTML vs Figma

```bash
node -e "
const {chromium}=require('playwright');
(async()=>{
  const b=await chromium.launch({args:['--no-sandbox']});
  const p=await b.newPage();
  await p.setViewportSize({width:1440,height:900});
  await p.goto('file:///tmp/figma_intermediate.html');
  await p.waitForLoadState('networkidle');
  await p.screenshot({path:'/tmp/qa_html.png',fullPage:true});
  await b.close();
})()
"
```

Compare `/tmp/qa_html.png` vs `/tmp/figma_ref.png` visually.

- **Diff < 5%**: proceed
- **Diff > 5%**: show both images to user, report differences, ask:
  > "יש פער בין ה-HTML לדיזיין. רוצה שאמשיך בכל זאת, או שאתקן קודם?"

### Step 5: Convert HTML → Elementor JSON

Load reference: `references/html-intermediate.md` (HTML→Elementor mapping table)
Load reference: `references/css-overrides.md` (CSS patterns)
Load reference: `references/rtl-gotchas.md` (RTL rules)

Build the Elementor JSON array following:
- Container model: `elType: "container"` only (no sections/columns)
- Unique 8-char hex IDs for every node
- RTL rule: `direction:ltr` ONLY on flex row containers, NEVER on text widgets
- Images: use WP attachment IDs from Step 2
- Custom CSS via `selector{...}` pattern for layout fixes

### Step 6: Deploy

Load reference: `references/deployment.md`

Write PHP deploy script to `/tmp/elementor_deploy.php`:

```php
<?php
$_SERVER['HTTP_HOST'] = 'SITE_DOMAIN';
$_SERVER['REQUEST_URI'] = '/';
require_once 'WP_PATH/wp-load.php';

global $wpdb;

// Create page
$post_id = wp_insert_post([
    'post_title'  => 'PAGE_TITLE',
    'post_status' => 'publish',
    'post_type'   => 'page',
    'post_name'   => 'PAGE_SLUG',
]);

// Set Elementor meta
update_post_meta($post_id, '_wp_page_template', 'elementor_canvas');
update_post_meta($post_id, '_elementor_edit_mode', 'builder');
update_post_meta($post_id, '_elementor_template_type', 'wp-page');
update_post_meta($post_id, '_elementor_version', '3.21.0');

// Store Elementor data
$data = ELEMENTOR_JSON_HERE;
$min = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
$wpdb->update($wpdb->postmeta, ['meta_value' => $min],
    ['post_id' => $post_id, 'meta_key' => '_elementor_data'], ['%s'], ['%d','%s']);

// Add lazy loading disable to child theme
$fn = get_stylesheet_directory() . '/functions.php';
$content = file_get_contents($fn);
if (strpos($content, 'wp_lazy_loading_enabled') === false) {
    file_put_contents($fn, $content . "\nadd_filter('wp_lazy_loading_enabled','__return_false');\n");
}

// Clear all caches
delete_post_meta($post_id, '_elementor_css');
if (class_exists('\Elementor\Plugin')) \Elementor\Plugin::instance()->files_manager->clear_cache();
$css_dir = WP_CONTENT_DIR . '/uploads/elementor/css/';
foreach (glob($css_dir . 'post-' . $post_id . '*.css') as $f) unlink($f);

echo "post_id:$post_id\n";
echo "url:" . get_permalink($post_id) . "\n";
echo "Done\n";
```

Deploy:
```bash
scp -O -P SSH_PORT /tmp/elementor_deploy.php USER@HOST:/tmp/elementor_deploy.php
ssh -p SSH_PORT USER@HOST "wp eval-file /tmp/elementor_deploy.php --path=WP_PATH"
ssh -p SSH_PORT USER@HOST "rm /tmp/elementor_deploy.php"
```

Parse `post_id` and `url` from output.

### Step 7: Post-Deploy Fixes

```bash
ssh -p SSH_PORT USER@HOST "wp rewrite flush --path=WP_PATH"
```

If page returns 404: `wp rewrite flush` again, wait 2s, retest.

### Step 8: QA2 — Live vs HTML

```bash
node -e "
const {chromium}=require('playwright');
(async()=>{
  const b=await chromium.launch({args:['--no-sandbox']});
  const p=await b.newPage();
  await p.setViewportSize({width:1440,height:900});
  await p.goto('LIVE_URL');
  await p.waitForLoadState('networkidle');
  await p.waitForTimeout(2000);
  await p.screenshot({path:'/tmp/qa_live.png',fullPage:true});
  await b.close();
})()
"
```

Compare `/tmp/qa_live.png` vs `/tmp/qa_html.png` visually.

- **Diff < 10%**: done
- **Diff 10–20%**: show diff, identify issues, auto-fix (see Runtime Error Recovery below)
- **Diff > 20%**: show to user, offer to re-run conversion

### Step 9: Runtime Error Recovery

Load reference: `references/deployment.md` for PHP patterns.
Load reference: `references/css-overrides.md` for CSS fixes.

| Issue | Fix |
|-------|-----|
| Images broken (naturalWidth=0) | Lazy loading still active — re-run disable script |
| Images wrong size | Patch `custom_css` on image widget container |
| Text aligned wrong | Find parent flex container with `direction:ltr` — remove it if it's a text widget |
| Layout broken on mobile | Add responsive breakpoint CSS via `custom_css` |
| 404 | `wp rewrite flush` |
| Fonts not loading | Re-upload font, re-add `@font-face` to kit CSS |
| Page exists | Slug already taken — append `-2`, redeploy |
| Elementor CSS not generated | Force cache clear script via SSH |

### Step 10: Final Report

```
✅ הדף נוצר בהצלחה!
🔗 URL: [LIVE_URL]
📄 Post ID: [POST_ID]
📊 QA1 (HTML vs Figma): [X]% match
📊 QA2 (Live vs HTML): [X]% match
[⚠️  warnings if any]

לעריכה ב-Elementor: [WP_ADMIN_URL]/post.php?post=[POST_ID]&action=elementor
```

---

## Reference Files (Load On Demand)

- `references/elementor-json-spec.md` — widget types, settings keys, storage rules
- `references/rtl-gotchas.md` — Hebrew/Arabic RTL rules
- `references/css-overrides.md` — CSS patterns using `selector` placeholder
- `references/deployment.md` — SSH commands, WP-CLI, PHP deploy template
- `references/html-intermediate.md` — HTML intermediate build + QA screenshot
