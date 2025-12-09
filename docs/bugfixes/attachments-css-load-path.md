# Attachments CSS Load Path Fix

**Date:** December 2024
**Status:** ✅ Fixed
**Severity:** Low (Asset loading error)

## Problem

After adding custom CSS for ActionText attachments, the application failed to load with error:

```
The asset 'attachments.css' was not found in the load path.
```

**Location:** `app/views/layouts/application.html.erb:34`

## Root Cause

Propshaft (Rails 7+ asset pipeline) doesn't automatically process separate CSS files like Sprockets did. When we added:

```erb
<%= stylesheet_link_tag "attachments", "data-turbo-track": "reload" %>
```

Propshaft couldn't find `attachments.css` in its load path, even though the file existed in `app/assets/stylesheets/`.

## Why This Happens

**Propshaft vs Sprockets:**

- **Sprockets** (old): Automatically processes and serves all files in `app/assets/stylesheets/`
- **Propshaft** (new): Only serves files explicitly referenced or in configured paths

With Propshaft, you either need to:
1. Import CSS files into a main manifest file
2. Use `@import` statements
3. Add them to the Propshaft load path configuration

## Solution

**Merged attachment styles into `application.css`** instead of maintaining a separate file.

### Steps Taken

1. **Appended styles to application.css:**
   ```bash
   cat app/assets/stylesheets/attachments.css >> app/assets/stylesheets/application.css
   ```

2. **Removed stylesheet link from layout:**
   ```erb
   <!-- REMOVED -->
   <%= stylesheet_link_tag "attachments", "data-turbo-track": "reload" %>
   ```

3. **Deleted separate file:**
   ```bash
   rm app/assets/stylesheets/attachments.css
   ```

### Result

All attachment styles are now in `application.css` which is already loaded via:
```erb
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
```

## Alternative Solutions

### Option 1: Use @import (Not Recommended)

In `application.css`:
```css
@import url("attachments.css");
```

**Cons:**
- Multiple HTTP requests
- Loading performance impact
- Not the Propshaft way

### Option 2: Configure Propshaft Load Path

In `config/initializers/assets.rb`:
```ruby
Rails.application.config.assets.paths << Rails.root.join("app/assets/stylesheets")
```

**Cons:**
- Extra configuration
- Still need to manage multiple files

### Option 3: Merge into Main Stylesheet (Chosen)

**Pros:**
- ✅ Single HTTP request
- ✅ No extra configuration
- ✅ Works with Propshaft defaults
- ✅ Simpler deployment

**Cons:**
- Slightly larger main CSS file (but negligible - only 221 lines)

## File Structure After Fix

```
app/assets/stylesheets/
├── actiontext.css          (ActionText default styles)
├── application.css         (Main + attachment styles - 231 lines)
├── lexxy.css              (Lexxy editor styles)
├── lexxy-content.css      (Lexxy content display)
├── lexxy-editor.css       (Lexxy editor UI)
└── lexxy-variables.css    (Lexxy CSS variables)
```

## Verification

### Check File Exists
```bash
ls -la app/assets/stylesheets/application.css
# Should show 231 lines
wc -l app/assets/stylesheets/application.css
```

### Check Styles Load
1. Start server: `bin/dev`
2. Visit any page
3. Inspect element
4. Check Styles tab - should see attachment styles
5. Look for `.lexxy-content img` or `.attachment` styles

### Check No Errors
```bash
# Check logs
tail -f log/development.log
# Should not show asset errors
```

## What the Attachment Styles Do

The merged styles provide:
- Image rendering and sizing
- Dark mode support
- Figure and caption styling
- File attachment display
- Responsive design
- Gallery layouts
- Loading states

**Example styles now in application.css:**
```css
/* Image attachments */
.lexxy-content img,
.trix-content img {
  max-width: 100%;
  height: auto;
  border-radius: 0.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

/* Dark theme */
.dark .lexxy-content img {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.1);
}
```

## Best Practices for Propshaft

### Single Main Stylesheet
**✅ DO:**
```erb
<%= stylesheet_link_tag :app %>
```
Then include all styles in `application.css`.

### Multiple Stylesheets (Advanced)
**✅ DO:** If you need separate files:
```ruby
# config/initializers/assets.rb
Rails.application.config.assets.paths << Rails.root.join("app/assets/stylesheets")
Rails.application.config.assets.precompile += %w( attachments.css )
```

### Per-Page Stylesheets
**✅ DO:** For large apps with page-specific styles:
```erb
<%= stylesheet_link_tag "admin", "data-turbo-track": "reload" if controller.controller_path.start_with?("admin") %>
```

But ensure the file is precompiled:
```ruby
Rails.application.config.assets.precompile += %w( admin.css )
```

## Related Issues

This is similar to the Lexxy assets issue where gem assets needed to be copied to accessible locations. The difference:
- **Lexxy**: Gem assets needed copying to `vendor/javascript/` and `app/assets/stylesheets/`
- **Attachments**: Our own CSS file wasn't in Propshaft's auto-load list

## Prevention

When adding new CSS files with Propshaft:

1. **Option A (Simple):** Add styles to existing `application.css`
2. **Option B (Complex):** Configure precompilation and load paths

For most apps, **Option A is recommended** unless you have a good reason to separate (e.g., very large stylesheets, per-page loading).

## Status

**✅ RESOLVED** - Attachment styles now load correctly from `application.css`.

## Impact

- ✅ No functionality lost
- ✅ Slightly faster (one less HTTP request)
- ✅ Simpler asset pipeline
- ✅ Works in development and production

## Testing

```bash
# 1. Start server
bin/dev

# 2. Visit a blog post with images
open http://localhost:3000/blog/your-post-slug

# 3. Check images render with styles:
# - Rounded corners
# - Shadow
# - Proper sizing
# - Dark mode support (if applicable)

# 4. Upload new image in admin
# - Should render with same styles
```

## Related Documentation

- [Lexxy Asset Setup](../implementation/lexxy-asset-setup.md)
- [ActiveStorage Images](../implementation/active-storage-images.md)
- [Propshaft Guide](https://github.com/rails/propshaft)
