# Elementor JSON Specification

## Model: Flexbox Container (Elementor Pro 4.x)

Requires Elementor Pro ≥ 3.6 with `elementor_experiment-container` set to `active`.

## Top-Level Structure

`_elementor_data` post meta = minified JSON array of section/container objects.

```json
[
  {
    "id": "a1b2c3d4",
    "elType": "container",
    "settings": { ... },
    "elements": [ ... ],
    "isInner": false
  }
]
```

## Container Settings (elType: "container")

```json
{
  "flex_direction": "row",
  "content_width": "full",
  "width": {"unit": "px", "size": 1200, "sizes": []},
  "padding": {"unit": "px", "top": "0", "right": "0", "bottom": "0", "left": "0", "isLinked": false},
  "gap": {"unit": "px", "column": "0", "row": "0"},
  "flex_gap": {"unit": "px", "column": "16", "row": "16", "isLinked": true},
  "background_color": "#0d0d0d",
  "custom_css": "selector{ ... }",
  "_element_width": "full"
}
```

## Widget: heading

```json
{
  "id": "e5f6a7b8",
  "elType": "widget",
  "widgetType": "heading",
  "settings": {
    "title": "Your Title Text",
    "header_size": "h2",
    "align": "right",
    "title_color": "#ffffff",
    "typography_font_family": "Frank Ruhl Libre",
    "typography_font_size": {"unit": "px", "size": 36, "sizes": []},
    "typography_font_weight": "700"
  },
  "elements": []
}
```

## Widget: text-editor

```json
{
  "id": "c9d0e1f2",
  "elType": "widget",
  "widgetType": "text-editor",
  "settings": {
    "editor": "<p>Your content here</p>",
    "text_color": "#cccccc",
    "typography_font_size": {"unit": "px", "size": 16, "sizes": []}
  },
  "elements": []
}
```

## Widget: image

```json
{
  "id": "a3b4c5d6",
  "elType": "widget",
  "widgetType": "image",
  "settings": {
    "image": {
      "url": "https://yoursite.com/wp-content/uploads/image.jpg",
      "id": 456
    },
    "image_size": "full",
    "image_loading": "",
    "width": {"unit": "px", "size": 300, "sizes": []},
    "height": {"unit": "px", "size": 300, "sizes": []}
  },
  "elements": []
}
```

## Widget: button

```json
{
  "id": "e7f8a9b0",
  "elType": "widget",
  "widgetType": "button",
  "settings": {
    "text": "Button Label",
    "link": {"url": "#", "is_external": false, "nofollow": false},
    "background_color": "#c9a84c",
    "button_text_color": "#ffffff",
    "border_radius": {"unit": "px", "top": "4", "right": "4", "bottom": "4", "left": "4", "isLinked": true},
    "typography_font_size": {"unit": "px", "size": 16, "sizes": []}
  },
  "elements": []
}
```

## Widget: divider

```json
{
  "id": "c1d2e3f4",
  "elType": "widget",
  "widgetType": "divider",
  "settings": {
    "color": "#333333",
    "weight": {"unit": "px", "size": 1, "sizes": []}
  },
  "elements": []
}
```

## Widget: spacer

```json
{
  "id": "a5b6c7d8",
  "elType": "widget",
  "widgetType": "spacer",
  "settings": {
    "space": {"unit": "px", "size": 40, "sizes": []}
  },
  "elements": []
}
```

## ID Generation Rules

- 8-character lowercase hex string
- Must be unique within the entire JSON document
- Generate with: `bin2hex(random_bytes(4))` in PHP, or `Math.random().toString(16).slice(2,10)` in JS

## Storage Rules

CRITICAL: Always use `$wpdb->update()` directly — never `update_post_meta()`:

```php
$min = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
$wpdb->update(
    $wpdb->postmeta,
    ['meta_value' => $min],
    ['post_id' => $post_id, 'meta_key' => '_elementor_data'],
    ['%s'],
    ['%d', '%s']
);
```

Also set: `update_post_meta($post_id, '_elementor_template_type', 'wp-page')`

## Cache Clearing (Always Run After Update)

```php
delete_post_meta($post_id, '_elementor_css');
if (class_exists('\Elementor\Plugin')) {
    \Elementor\Plugin::instance()->files_manager->clear_cache();
}
$css_dir = WP_CONTENT_DIR . '/uploads/elementor/css/';
foreach (glob($css_dir . 'post-' . $post_id . '*.css') as $f) {
    unlink($f);
}
```

## Page Template

For full-width pages (no header/footer): set page template to `elementor_canvas`.

```php
update_post_meta($post_id, '_wp_page_template', 'elementor_canvas');
```
