# Deployment: SSH + WP-CLI Patterns

## SSH Connection

Always test connection first:
```bash
ssh -p 22 user@host "echo OK"
```
If port 22 fails, try 2222:
```bash
ssh -p 2222 user@host "echo OK"
```

## File Upload to Server

ALWAYS upload to `/tmp/` — never to `/home/` or `public_html/` directly:
```bash
scp -O -P 22 /tmp/local_script.php user@host:/tmp/script.php
```

The `-O` flag forces SCP legacy mode (avoids SFTP issues on some hosts).

## Running PHP via WP-CLI

```bash
ssh -p 22 user@host "wp eval-file /tmp/script.php --path=/path/to/wordpress"
```

With WP-CLI as phar:
```bash
ssh -p 22 user@host "php ~/wp-cli.phar eval-file /tmp/script.php --path=/path/to/wordpress"
```

Cleanup after running:
```bash
ssh -p 22 user@host "rm /tmp/script.php"
```

## WP-CLI Auto-Install

If `wp` not found on server:
```bash
ssh user@host "curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && echo 'export PATH=~/:\$PATH' >> ~/.bashrc"
```

Test: `ssh user@host "php ~/wp-cli.phar cli info"`

## Useful WP-CLI Commands

```bash
# Create new page
wp post create --post_type=page --post_status=publish --post_title="Page Name" --porcelain

# Get post ID by slug
wp post list --post_type=page --name=page-slug --field=ID

# Flush permalinks (fix 404)
wp rewrite flush

# Check Elementor version
wp plugin get elementor --field=version

# Enable Flexbox Container
wp option update elementor_experiment-container active

# Enable RTL
wp option update elementor_rtl_enabled yes

# Get site language
wp option get WPLANG

# Run PHP script
wp eval-file /tmp/script.php

# Sideload remote image to media library
wp media import https://example.com/image.jpg --title="Image Title" --porcelain
```

## PHP Deploy Script Template

Every deploy script must:
1. Bootstrap WordPress (`require_once wp-load.php`)
2. Make changes
3. Clear Elementor CSS cache
4. Echo confirmation

```php
<?php
$_SERVER['HTTP_HOST'] = 'yoursite.com';
$_SERVER['REQUEST_URI'] = '/';
require_once '/path/to/wordpress/wp-load.php';

global $wpdb;
$post_id = POST_ID_HERE;

// ... your changes ...

// Always clear cache:
delete_post_meta($post_id, '_elementor_css');
if (class_exists('\Elementor\Plugin')) {
    \Elementor\Plugin::instance()->files_manager->clear_cache();
}
$css_dir = WP_CONTENT_DIR . '/uploads/elementor/css/';
foreach (glob($css_dir . 'post-' . $post_id . '*.css') as $f) { unlink($f); }

echo "Done\n";
```

## Cloudways-Specific Notes

- SSH path format: `/home/1427884.cloudwaysapps.com/USERNAME/public_html/`
- HTTP_HOST format: `wordpress-APPID-SERVERID.cloudwaysapps.com`
- Default SSH port: 22
- wp-config.php is one level above public_html in some setups

## Create Page + Set Elementor Data (Full Script)

```php
<?php
$_SERVER['HTTP_HOST'] = 'yoursite.com';
$_SERVER['REQUEST_URI'] = '/';
require_once '/path/to/wp-load.php';

global $wpdb;

// 1. Create the page
$post_id = wp_insert_post([
    'post_title'   => 'New Page',
    'post_status'  => 'publish',
    'post_type'    => 'page',
    'post_name'    => 'new-page',
]);

// 2. Set Elementor template and canvas mode
update_post_meta($post_id, '_wp_page_template', 'elementor_canvas');
update_post_meta($post_id, '_elementor_edit_mode', 'builder');
update_post_meta($post_id, '_elementor_template_type', 'wp-page');
update_post_meta($post_id, '_elementor_version', '3.21.0');

// 3. Store Elementor data
$elementor_data = [/* your JSON array */];
$min = json_encode($elementor_data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
$wpdb->update(
    $wpdb->postmeta,
    ['meta_value' => $min],
    ['post_id' => $post_id, 'meta_key' => '_elementor_data'],
    ['%s'],
    ['%d', '%s']
);

// 4. Clear cache
delete_post_meta($post_id, '_elementor_css');
if (class_exists('\Elementor\Plugin')) {
    \Elementor\Plugin::instance()->files_manager->clear_cache();
}

echo "Post ID: $post_id\n";
echo "URL: " . get_permalink($post_id) . "\n";
echo "Done\n";
```
