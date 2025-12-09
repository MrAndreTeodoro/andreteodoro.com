# Lexxy Rich Text Editor - Quick Troubleshooting

**Quick Reference Card** - Most common Lexxy issues and instant fixes

## 🚨 Most Common Issue: Editor Not Rendering

### Symptoms
- Oversized toolbar icons
- No formatting buttons work
- Editor looks broken/unstyled
- Console errors about missing modules

### Instant Fix
```bash
bin/update_lexxy_assets
```

Then restart your server:
```bash
# Stop server (Ctrl+C)
bin/dev
```

Hard refresh browser: `Cmd+Shift+R` (Mac) or `Ctrl+F5` (Windows)

**Why?** Lexxy assets must be copied from the gem to your app directories.

---

## Quick Diagnostic Checklist

### ✅ 1. Assets Copied?
```bash
# Check JavaScript
ls vendor/javascript/lexxy.js
# Should exist (~585KB)

# Check CSS
ls app/assets/stylesheets/lexxy*.css
# Should show 4 files: lexxy.css, lexxy-content.css, lexxy-editor.css, lexxy-variables.css
```

**If missing:** Run `bin/update_lexxy_assets`

### ✅ 2. Importmap Configured?
```bash
cat config/importmap.rb | grep lexxy
```

**Should show:**
```ruby
pin "lexxy", to: "lexxy.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
```

**If missing:** See [Lexxy Asset Setup Guide](../implementation/lexxy-asset-setup.md)

### ✅ 3. JavaScript Imported?
```bash
cat app/javascript/application.js | grep lexxy
```

**Should show:**
```javascript
import "lexxy"
import "@rails/activestorage"
```

**If missing:** Add those imports

### ✅ 4. Stylesheets Linked?
```bash
grep -n "stylesheet_link_tag.*lexxy" app/views/layouts/application.html.erb
```

**Should show:**
```erb
<%= stylesheet_link_tag "lexxy", "data-turbo-track": "reload" %>
```

**If missing:** Add to layout `<head>`

---

## Common Errors & Instant Fixes

### Error: "Failed to load module specifier 'lexxy'"
**Cause:** JavaScript not in vendor/javascript/  
**Fix:**
```bash
bin/update_lexxy_assets
```

### Error: "GET /assets/lexxy.css 404 Not Found"
**Cause:** CSS not in app/assets/stylesheets/  
**Fix:**
```bash
bin/update_lexxy_assets
```

### Error: Icons are huge/unstyled
**Cause:** CSS not loading or import broken  
**Fix:**
1. Check CSS file exists:
   ```bash
   ls app/assets/stylesheets/lexxy.css
   ```
2. If missing: `bin/update_lexxy_assets`
3. Check imports in lexxy.css:
   ```bash
   cat app/assets/stylesheets/lexxy.css
   ```
   Should have:
   ```css
   @import url("lexxy-content.css");
   @import url("lexxy-editor.css");
   ```
4. Clear browser cache: `Cmd+Shift+R`

### Error: Editor appears but doesn't work
**Cause:** JavaScript loaded but not initialized  
**Fix:**
1. Check browser console for errors
2. Verify Turbo isn't blocking:
   ```javascript
   // app/javascript/application.js should have:
   import "@hotwired/turbo-rails"
   import "lexxy"
   ```
3. Check syntax_highlight controller exists:
   ```bash
   ls app/javascript/controllers/syntax_highlight_controller.js
   ```

### Error: "Cannot read properties of null"
**Cause:** DOM element not found  
**Fix:**
1. Check form uses `rich_text_area`:
   ```erb
   <%= f.rich_text_area :content %>
   ```
   NOT `text_area`
2. Ensure ActionText migrations ran:
   ```bash
   bin/rails db:migrate:status | grep action_text
   ```

---

## Browser Debugging

### Open Browser Console
- **Chrome/Edge:** `F12` or `Cmd+Opt+J` (Mac) / `Ctrl+Shift+J` (Windows)
- **Firefox:** `F12` or `Cmd+Opt+K` (Mac) / `Ctrl+Shift+K` (Windows)
- **Safari:** `Cmd+Opt+C` (enable Developer menu first)

### Check for Errors
Look for red errors mentioning:
- `lexxy`
- `Failed to load`
- `404`
- `Cannot read properties`

### Check Network Tab
1. Open DevTools → Network tab
2. Reload page
3. Filter by "lexxy"
4. Should see:
   - `lexxy.js` - Status 200
   - `lexxy.css` - Status 200
   - `lexxy-content.css` - Status 200
   - `lexxy-editor.css` - Status 200

Any 404s? Run `bin/update_lexxy_assets`

---

## Nuclear Option: Complete Reset

If nothing works, try a complete reset:

```bash
# 1. Stop server
# (Ctrl+C)

# 2. Clean everything
bin/rails assets:clobber
rm -rf tmp/cache

# 3. Re-copy assets
bin/update_lexxy_assets

# 4. Verify files
ls vendor/javascript/lexxy.js
ls app/assets/stylesheets/lexxy*.css

# 5. Restart server
bin/dev

# 6. Hard refresh browser
# Cmd+Shift+R (Mac) or Ctrl+F5 (Windows)
```

---

## When To Run Asset Update

Run `bin/update_lexxy_assets` after:

- ✅ Fresh `git clone` (but `bin/setup` does this automatically)
- ✅ `bundle update lexxy`
- ✅ `bundle update actiontext` or `bundle update activestorage`
- ✅ Switching branches that changed Lexxy version
- ✅ Editor stops working after gem updates

---

## Testing If Lexxy Works

### Quick Test
1. Go to any admin form with rich text (e.g., `/admin/blog_posts/new`)
2. Click in the content field
3. You should see:
   - Normal-sized toolbar with icons
   - Clickable formatting buttons
   - Text cursor in editor
   - Type and format text works

### Detailed Test
1. Type some text
2. Select text
3. Click **Bold** button - text should become bold
4. Click **Italic** button - text should become italic
5. Try adding:
   - Heading (Type `## Heading` and space)
   - List (Type `- Item` and space)
   - Code block (Click code button)
6. All should work smoothly

---

## Getting Help

### Documentation
- [Complete Lexxy Setup Guide](../implementation/lexxy-asset-setup.md)
- [Lexxy Implementation Docs](../implementation/lexxy-rich-text-editor.md)

### External Resources
- [Lexxy GitHub Issues](https://github.com/basecamp/lexxy/issues)
- [ActionText Guides](https://guides.rubyonrails.org/action_text_overview.html)

### Check Versions
```bash
bundle list | grep lexxy
bundle list | grep actiontext
rails --version
```

---

## TL;DR - Just Fix It

95% of Lexxy issues are solved by:

```bash
bin/update_lexxy_assets
bin/dev
# Then hard refresh browser (Cmd+Shift+R)
```

That's it! 🎉
