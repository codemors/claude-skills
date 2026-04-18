# CSS Overrides in Elementor

## The `selector` Placeholder

Elementor's `custom_css` field uses `selector` as a placeholder that compiles
to the actual CSS selector for that widget/container.

```json
{
  "settings": {
    "custom_css": "selector{background:#000;padding:20px;}"
  }
}
```

Do NOT use `.elementor-element`, IDs, or class names — always `selector`.

## Multiple Rules

```
selector{property:value;}selector .child-selector{property:value;}
```

No newlines — all on one line (minified format).

## !important Usage

Use `!important` when Elementor's default styles override your values.
Common cases: width, height, flex properties, direction.

```
selector{width:256px!important;height:203px!important;}
```

## Common Override Patterns

### Fix image size in a flex container:
```
selector{width:300px!important;height:250px!important;flex-shrink:0!important;}selector img{width:300px!important;height:250px!important;object-fit:cover!important;display:block!important;}
```

### Force LTR on a row container:
```
selector{direction:ltr!important;}
```

### Fix photo grid (multiple images in a row):
```
selector{direction:ltr!important;flex-direction:row!important;flex-wrap:wrap!important;gap:4px!important;}
```

### Fix review/card width:
```
selector{width:256px!important;flex-shrink:0!important;}
```

### Dark background section:
```
selector{background-color:#0d0d0d!important;}
```

### Custom font application:
```
selector{font-family:"Hornset",serif!important;}
```

## Elementor Kit Global CSS

For site-wide rules (fonts, background), add to Elementor kit:

```php
$kit_id = get_option('elementor_active_kit', 0);
$settings = get_post_meta($kit_id, '_elementor_page_settings', true);
$settings['custom_css'] = '@font-face { font-family: "Hornset"; src: url("...") format("truetype"); }' . "\n" . ($settings['custom_css'] ?? '');
update_post_meta($kit_id, '_elementor_page_settings', $settings);
```

## Lazy Loading Disable (3 Levels)

```php
// Level 1: Elementor option
update_option('elementor_lazy_load_background_images', '');
update_option('elementor_optimized_image_loading', '');
update_option('elementor_experiment-e_lazyload', 'inactive');

// Level 2: WordPress filter (add to child theme functions.php)
add_filter('wp_lazy_loading_enabled', '__return_false');

// Level 3: Per-image widget setting
$el['settings']['image_loading'] = '';
```
