# Blog Post Editing Fix - Quick Reference

**Status:** ✅ Fixed  
**Date:** December 2024  
**Issue:** Blog posts not saving when edited

## Problem

When editing blog posts in the admin interface:
- Changes made in the editor were not saving
- No error messages appeared
- Form submitted successfully but changes were lost
- Affected both content and other fields

## Quick Fix

Updated the form to use numeric IDs instead of slugs.

**File Changed:** `app/views/admin/blog_posts/_form.html.erb`

```erb
<!-- Before -->
<%= form_with(model: [:admin, @blog_post], class: "space-y-6") do |f| %>

<!-- After -->
<%= form_with(model: [:admin, @blog_post], 
              url: @blog_post.persisted? ? admin_blog_post_path(@blog_post.id) : admin_blog_posts_path, 
              class: "space-y-6") do |f| %>
```

## Why It Happened

The `BlogPost` model has a custom `to_param` method that returns the slug:

```ruby
def to_param
  slug  # Returns "my-blog-slug" instead of "123"
end
```

This is great for public URLs (SEO-friendly), but caused issues in the admin form because:

1. Form generated URL: `/admin/blog_posts/my-blog-slug`
2. Controller expected: `/admin/blog_posts/123`
3. Controller tried: `BlogPost.find("my-blog-slug")`
4. Result: Record not found → changes lost

## Verification

### Test It Works

1. Go to `/admin/blog_posts`
2. Click "Edit" on any blog post
3. Make changes to the content
4. Click "Update Blog Post"
5. Verify:
   - ✅ "Blog post was successfully updated" message appears
   - ✅ Changes are saved
   - ✅ Content persists after page reload

### Check the URL

When editing a post, the browser URL should be:
```
http://localhost:3000/admin/blog_posts/123/edit
```

NOT:
```
http://localhost:3000/admin/blog_posts/my-blog-slug/edit
```

### Check Form Action

Inspect the form element in DevTools:
```html
<form action="/admin/blog_posts/123" method="post">
```

The action should use the numeric ID (123), not the slug.

## Related Fixes

This is part of a series of fixes for the `to_param` slug issue:

- ✅ Admin navigation links (edit, delete, publish buttons)
- ✅ Admin edit view links
- ✅ Admin dashboard links
- ✅ **Admin form submission** (this fix)

## Pattern for Other Models

If you add `to_param` to other models, follow this pattern:

### Public Routes (Use Object)
```erb
<%= link_to "View", blog_post_path(@blog_post) %>
<!-- URL: /blog/my-slug -->
```

### Admin Routes (Use .id)
```erb
<%= link_to "Edit", edit_admin_blog_post_path(@blog_post.id) %>
<!-- URL: /admin/blog_posts/123/edit -->
```

### Admin Forms (Explicit URL)
```erb
<%= form_with(model: [:admin, @blog_post],
              url: @blog_post.persisted? ? admin_blog_post_path(@blog_post.id) : admin_blog_posts_path) do |f| %>
```

## Complete Documentation

For full details, see:
- [Blog Post Form Submission Fix](../bugfixes/blog-post-form-submission.md)
- [Blog Post Admin Routing](../bugfixes/blog-post-admin-routing.md)

## TL;DR

**Problem:** Form used slug in URL, controller expected numeric ID  
**Fix:** Explicitly set form URL to use `.id`  
**Result:** Blog posts now save correctly ✅
