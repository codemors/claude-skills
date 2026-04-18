# RTL Gotchas — Hebrew/Arabic WordPress + Elementor

## The Core Rule

Hebrew/Arabic WordPress sets `dir="rtl"` globally on `<html>`. Every element
inherits RTL text direction automatically. **Do not fight this — work with it.**

## The Single Most Important Rule

**NEVER apply `direction:ltr` to text widget containers** (heading, text-editor, icon-box).

Why: Hebrew WP already sets text-align:right and direction:rtl globally.
Applying direction:ltr to a text widget's container BREAKS text alignment —
text becomes left-aligned instead of right-aligned.

**ONLY apply `direction:ltr` to flex layout containers** (elType: "container" with flex_direction: "row").

Why: Elementor flex containers inherit RTL, which reverses the element order
in a row (last element appears first). `direction:ltr` on the container
restores left-to-right DOM order for image+text layouts.

## Decision Table

| Element type | RTL site? | Apply direction:ltr? |
|---|---|---|
| Container with flex_direction:row | Yes | YES — on container only |
| Container with flex_direction:column | Yes | NO — columns not affected |
| heading widget | Yes | NEVER |
| text-editor widget | Yes | NEVER |
| image widget | Yes | No (no text content) |
| button widget | Yes | No (inherits correctly) |

## Correct Pattern

```json
{
  "elType": "container",
  "settings": {
    "flex_direction": "row",
    "custom_css": "selector{direction:ltr!important;}"
  },
  "elements": [
    {
      "elType": "widget",
      "widgetType": "image",
      "settings": {}
    },
    {
      "elType": "widget",
      "widgetType": "heading",
      "settings": {
        "title": "כותרת בעברית"
      }
    }
  ]
}
```

The image appears on the left, Hebrew heading on the right — correct RTL layout.

## Wrong Pattern (Breaks Everything)

```json
{
  "elType": "widget",
  "widgetType": "heading",
  "settings": {
    "title": "כותרת בעברית",
    "custom_css": "selector{direction:ltr;}"
  }
}
```

## Elementor RTL Mode Setting

Enable via WP-CLI if site language is Hebrew/Arabic/Farsi/Urdu:

```bash
wp option update elementor_rtl_enabled yes --path=/path/to/wordpress
```

Detect need: check `WPLANG` in wp-config.php or `wp option get WPLANG`.
Hebrew = `he_IL`, Arabic = `ar`, Farsi = `fa_IR`.

## Text Alignment

Never set `text-align:right` manually on Hebrew text widgets — it's automatic.
If text appears left-aligned, the cause is almost always an erroneous
`direction:ltr` on an ancestor element. Remove it.
