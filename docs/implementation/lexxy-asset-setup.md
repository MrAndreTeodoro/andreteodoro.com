# Lexxy Asset Setup Guide

**Date:** December 2024  
**Status:** ✅ Complete  
**Issue:** Lexxy editor not rendering properly (oversized icons, no functionality)

## Problem

When using Lexxy rich text editor with Rails + Propshaft + Importmap, the editor doesn't render correctly because:
- CSS files aren't automatically copied from the gem
- JavaScript files aren't in the importmap-accessible locations
- Asset pipeline doesn't automatically include gem assets

**Symptoms:**
- Oversized toolbar icons
- No editor functionality
- Missing styles
- Console errors about missing modules

## Solution

Lexxy and ActionText assets need to be **manually copied** to locations where Propshaft and Importmap can serve them.

### Asset Locations

**JavaScript files go to:** `vendor/javascript/`
**CSS files go to:** `app/assets/stylesheets/`

### Automated Setup Script

We created `bin/update_lexxy_assets` to automate this process.

## Quick Fix

Run this command to copy all required assets:

```bash
bin/update_lexxy_assets
```

This script:
1. Copies `lexxy.js` to `vendor/javascript/`
2. Copies `activestorage.esm.js` to `vendor/javascript/`
3. Copies `actiontext.esm.js` to `vendor/javascript/`
4. Copies all Lexxy CSS files to `app/assets/stylesheets/`

## Manual Setup (if needed)

If you don't want to use the script, copy files manually:

### Step 1: Copy JavaScript Files

```bash
# Get gem path
LEXXY_PATH=$(bundle show lexxy)
ACTIVESTORAGE_PATH=$(bundle show activestorage)
ACTIONTEXT_PATH=$(bundle show actiontext)

# Copy JavaScript files
cp "$LEXXY_PATH/app/assets/javascript/lexxy.js" vendor/javascript/
cp "$ACTIVESTORAGE_PATH/app/assets/javascripts/activestorage.esm.js" vendor/javascript/
cp "$ACTIONTEXT_PATH/app/assets/javascripts/actiontext.esm.js" vendor/javascript/
```

### Step 2: Copy CSS Files

```bash
# Copy all Lexxy stylesheets
cp "$LEXXY_PATH/app/assets/stylesheets/"*.css app/assets/stylesheets/
```

This copies:
- `lexxy.css` (main file with imports)
- `lexxy-content.css` (content display styles)
- `lexxy-editor.css` (editor interface styles)
- `lexxy-variables.css` (CSS custom properties)

### Step 3: Verify Files Are Copied

```bash
# Check JavaScript
ls -lh vendor/javascript/
# Should show: lexxy.js, activestorage.esm.js, actiontext.esm.js

# Check CSS
ls -lh app/assets/stylesheets/
# Should show: lexxy.css, lexxy-*.css files
```

## Configuration Already Done

These configurations are already in place (no action needed):

### Importmap Configuration (`config/importmap.rb`)
```ruby
pin "lexxy", to: "lexxy.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "@rails/actiontext", to: "actiontext.esm.js"  # Not used, but available
```

### Application JavaScript (`app/javascript/application.js`)
```javascript
import "lexxy"
import "@rails/activestorage"
```

### Layout Stylesheet Links (`app/views/layouts/application.html.erb`)
```erb
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "lexxy", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "actiontext", "data-turbo-track": "reload" %>
```

## Why This Is Needed

### Propshaft vs Sprockets

**Sprockets** (old Rails asset pipeline):
- Automatically processes gem assets
- Includes all files in `app/assets` from all gems
- Complex preprocessing pipeline

**Propshaft** (modern Rails 7+ asset pipeline):
- Simple, fast asset serving
- Doesn't automatically process gem assets
- Only serves files from configured paths
- Better for HTTP/2 and modern deployments

### Importmap Constraints

Importmap requires JavaScript files to be in:
- `app/javascript/`
- `vendor/javascript/`
- Explicitly configured paths

It **cannot** directly access files inside gem directories.

## Verification Steps

### 1. Check Assets Are Accessible

```bash
# Start Rails server
bin/dev

# In another terminal, test asset URLs:
curl -I http://localhost:3000/assets/lexxy.js
curl -I http://localhost:3000/assets/lexxy.css
```

Both should return `200 OK` (or show the digested filename).

### 2. Check Browser Console

1. Open any admin form with rich text editor
2. Open browser DevTools → Console
3. Should see NO errors about:
   - "Failed to load module"
   - "404 Not Found"
   - Missing CSS files

### 3. Check Editor Rendering

The Lexxy editor should display:
- ✅ Normal-sized toolbar icons
- ✅ Formatting buttons (Bold, Italic, etc.)
- ✅ Functional text area
- ✅ Proper styling
- ✅ Code highlighting (when adding code blocks)

### 4. Test Functionality

1. Click in the editor
2. Type some text
3. Select text and click Bold
4. Text should become bold
5. Try adding a heading, list, or code block

## When To Re-run Setup

Run `bin/update_lexxy_assets` whenever you:

### Update Lexxy Gem
```bash
bundle update lexxy
bin/update_lexxy_assets
```

### Update Rails/ActionText
```bash
bundle update actiontext activestorage
bin/update_lexxy_assets
```

### After Fresh Clone
```bash
git clone <repo>
cd andreteodoro
bundle install
bin/update_lexxy_assets  # Copy assets
bin/setup                # Setup database and start
```

## Troubleshooting

### Editor Still Not Working

**Problem:** Assets copied but editor still broken

**Solutions:**

1. **Clear browser cache:**
   ```
   Hard refresh: Cmd+Shift+R (Mac) / Ctrl+F5 (Windows)
   ```

2. **Restart Rails server:**
   ```bash
   # Stop current server (Ctrl+C)
   bin/dev
   ```

3. **Clear asset cache:**
   ```bash
   bin/rails assets:clobber
   bin/dev
   ```

4. **Verify importmap:**
   ```bash
   bin/rails importmap:audit
   ```

### Console Errors

**Error:** `Failed to load module specifier "lexxy"`

**Solution:** JavaScript file not in `vendor/javascript/`
```bash
ls vendor/javascript/lexxy.js  # Should exist
bin/update_lexxy_assets         # If missing
```

**Error:** `GET /assets/lexxy.css 404 Not Found`

**Solution:** CSS file not in `app/assets/stylesheets/`
```bash
ls app/assets/stylesheets/lexxy.css  # Should exist
bin/update_lexxy_assets              # If missing
```

**Error:** `Cannot read properties of null`

**Solution:** DOM not ready when Lexxy initializes
- This should be handled by Turbo
- Check `application.js` imports `lexxy`

### Oversized Icons Still Showing

**Problem:** Icons are SVGs rendered without proper CSS

**Solution:**

1. Check CSS is loaded:
   ```bash
   curl -s http://localhost:3000/assets/lexxy.css | head -20
   ```

2. Should see CSS rules, not 404

3. Check browser DevTools → Network tab:
   - Look for `lexxy.css` request
   - Should be 200 status
   - Should have content-type: `text/css`

4. Verify CSS imports work:
   ```bash
   cat app/assets/stylesheets/lexxy.css
   ```
   Should show:
   ```css
   @import url("lexxy-content.css");
   @import url("lexxy-editor.css");
   ```

5. Check imported files exist:
   ```bash
   ls app/assets/stylesheets/lexxy-*.css
   ```

### Production Deployment

For production, assets are compiled:

```bash
# Precompile assets
RAILS_ENV=production bin/rails assets:precompile

# Deploy with Kamal (or your deployment tool)
kamal deploy
```

Assets are automatically digested and served correctly.

## Script Details

### bin/update_lexxy_assets

**What it does:**
1. Finds gem installation paths
2. Copies JavaScript to `vendor/javascript/`
3. Copies CSS to `app/assets/stylesheets/`
4. Reports success/failure for each file

**Usage:**
```bash
# Make executable (already done)
chmod +x bin/update_lexxy_assets

# Run anytime
bin/update_lexxy_assets
```

**Output:**
```
Updating Lexxy and ActionText assets...

Copying JavaScript files to vendor/javascript/...
✓ Copied lexxy.js to vendor/javascript/lexxy.js
✓ Copied activestorage.esm.js to vendor/javascript/activestorage.esm.js
✓ Copied actiontext.esm.js to vendor/javascript/actiontext.esm.js

Copying Lexxy CSS files to app/assets/stylesheets/...
✓ Copied lexxy.css to app/assets/stylesheets/lexxy.css
✓ Copied lexxy-content.css to app/assets/stylesheets/lexxy-content.css
✓ Copied lexxy-editor.css to app/assets/stylesheets/lexxy-editor.css
✓ Copied lexxy-variables.css to app/assets/stylesheets/lexxy-variables.css

✅ All assets updated successfully!

Note: Run this script whenever you update the Lexxy gem version
```

## File Checklist

After running `bin/update_lexxy_assets`, verify these files exist:

### JavaScript (vendor/javascript/)
- [ ] `lexxy.js` (~585KB)
- [ ] `activestorage.esm.js` (~28KB)
- [ ] `actiontext.esm.js` (~31KB)

### CSS (app/assets/stylesheets/)
- [ ] `lexxy.css` (imports other files)
- [ ] `lexxy-content.css` (~8KB)
- [ ] `lexxy-editor.css` (~11KB)
- [ ] `lexxy-variables.css` (~3KB)
- [ ] `actiontext.css` (from ActionText install)

## Alternative: CDN Approach (Not Recommended)

You could load Lexxy from a CDN, but this approach is **not recommended** because:
- Requires internet connection in development
- Adds external dependency
- Version mismatches between gem and CDN
- Not compatible with ActionText integration

**If you must use CDN:**
```erb
<!-- In layout <head> -->
<link rel="stylesheet" href="https://unpkg.com/@37signals/lexxy/dist/lexxy.css">
<script type="module" src="https://unpkg.com/@37signals/lexxy/dist/lexxy.js"></script>
```

## Summary

**Problem:** Lexxy assets not accessible to Propshaft/Importmap  
**Solution:** Copy assets to `vendor/javascript/` and `app/assets/stylesheets/`  
**Tool:** `bin/update_lexxy_assets` script  
**When:** After gem updates or fresh clone  
**Result:** Fully functional rich text editor 🎉

## References

- [Lexxy GitHub](https://github.com/basecamp/lexxy)
- [Propshaft Docs](https://github.com/rails/propshaft)
- [Importmap Rails](https://github.com/rails/importmap-rails)
- [ActionText Guide](https://guides.rubyonrails.org/action_text_overview.html)
