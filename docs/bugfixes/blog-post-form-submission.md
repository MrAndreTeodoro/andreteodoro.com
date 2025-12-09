# Blog Post Form Submission Fix

**Date:** December 2024
**Status:** ✅ Fixed
**Severity:** High (Data not saving)

## Problem

Blog posts were not saving changes when editing content in the admin interface. The form would submit without errors, but changes were lost.

## Symptoms

- Edit a blog post's content
- Click "Update Blog Post"
- No error message displayed
- Redirected back to the index
- Changes not saved
- Database shows old content

## Root Cause

The issue was caused by the `to_param` override in the BlogPost model:

```ruby
def to_param
  slug
end
```

This caused the form to generate URLs like:
```
PATCH /admin/blog_posts/my-blog-slug
```

Instead of:
```
PATCH /admin/blog_posts/123
```

The controller's `set_blog_post` method uses:
```ruby
@blog_post = BlogPost.find(params[:id])
```

This expects a numeric ID, not a slug, causing a `RecordNotFound` error that was silently failing.

## Investigation

From the Rails logs, we could see:

```
Parameters: {"blog_post"=>{"title"=>"...", "content"=>"..."}, "id"=>"github-stars-wont-pay-your-rent"}

BlogPost Load (0.1ms)  SELECT "blog_posts".* FROM "blog_posts" WHERE "blog_posts"."id" = NULL LIMIT 1

ActiveRecord::RecordNotFound (Couldn't find BlogPost with 'id'="github-stars-wont-pay-your-rent")
```

The content WAS being submitted correctly, but the record lookup failed because it was using the slug instead of the numeric ID.

## Solution

Updated the form to explicitly specify the URL using the numeric ID:

**File:** `app/views/admin/blog_posts/_form.html.erb`

### Before (❌ Broken)
```erb
<%= form_with(model: [:admin, @blog_post], class: "space-y-6") do |f| %>
```

This automatically generated the URL using `to_param`, which returns the slug.

### After (✅ Fixed)
```erb
<%= form_with(model: [:admin, @blog_post], 
              url: @blog_post.persisted? ? admin_blog_post_path(@blog_post.id) : admin_blog_posts_path, 
              class: "space-y-6") do |f| %>
```

This explicitly uses:
- `admin_blog_post_path(@blog_post.id)` for updates (uses numeric ID)
- `admin_blog_posts_path` for creates (POST to collection)

## Why This Happened

The `to_param` method is used throughout Rails for URL generation. It's perfect for public-facing URLs (SEO-friendly slugs), but causes issues in admin interfaces that expect numeric IDs.

**Other places we already fixed:**
- Admin index view links (edit, delete, publish buttons)
- Admin edit view links
- Admin dashboard links

**This was the missing piece:** The form's `action` attribute.

## Related Issue

This is the same root cause as the earlier routing issue documented in `blog-post-admin-routing.md`, but manifesting in form submission rather than navigation.

## Verification

### Test Manually

1. Go to `/admin/blog_posts`
2. Click "Edit" on any post
3. Change the content
4. Click "Update Blog Post"
5. Check that:
   - ✅ Success message appears: "Blog post was successfully updated."
   - ✅ Content is saved
   - ✅ Changes persist on page reload

### Test via Rails Console

```ruby
# Get a blog post
post = BlogPost.first

# Simulate form submission
post.update(content: "Updated content")

# Verify
post.reload
post.content.to_plain_text
# Should show "Updated content"
```

### Check Logs

After submitting the form, logs should show:

```
Processing by Admin::BlogPostsController#update as TURBO_STREAM
  Parameters: {"blog_post"=>{"title"=>"...", "content"=>"..."}, "id"=>"123"}
  BlogPost Load (0.1ms)  SELECT "blog_posts".* FROM "blog_posts" WHERE "blog_posts"."id" = 123 LIMIT 1
  ↳ app/controllers/admin/blog_posts_controller.rb:93:in 'set_blog_post'
  BlogPost Update (2.3ms)  UPDATE "blog_posts" SET "title" = ?, "updated_at" = ? WHERE "blog_posts"."id" = ?
Redirected to http://localhost:3000/admin/blog_posts
Completed 302 Found
```

Note: `"id"=>"123"` (numeric), not `"id"=>"my-slug"` (string).

## ActionText Considerations

While debugging, we confirmed that:

- ✅ ActionText content IS submitted correctly in the parameters
- ✅ Strong parameters don't need special handling for rich text fields
- ✅ The rich text editor itself works fine
- ❌ The only issue was the form URL using slug instead of ID

The content parameter shows the full HTML:
```ruby
"content" => "<p>Full HTML content here...</p>"
```

This gets properly saved to the `action_text_rich_texts` table when the record is found and updated.

## Preventing Similar Issues

### For Models with Custom to_param

When a model uses `to_param` for SEO-friendly URLs:

1. **Public routes**: Use the model object directly
   ```erb
   <%= link_to "View", blog_post_path(blog_post) %>
   <!-- Generates: /blog/my-slug -->
   ```

2. **Admin routes**: Explicitly use `.id`
   ```erb
   <%= link_to "Edit", edit_admin_blog_post_path(blog_post.id) %>
   <!-- Generates: /admin/blog_posts/123/edit -->
   ```

3. **Admin forms**: Explicitly set URL
   ```erb
   <%= form_with(model: [:admin, @resource], 
                 url: @resource.persisted? ? admin_resource_path(@resource.id) : admin_resources_path) do |f| %>
   ```

### Pattern to Follow

```ruby
# Model
class BlogPost < ApplicationRecord
  def to_param
    slug  # For public URLs
  end
end

# Public Controller
def show
  @blog_post = BlogPost.find_by!(slug: params[:slug])
end

# Admin Controller  
def edit
  @blog_post = BlogPost.find(params[:id])  # Expects numeric ID
end

# Public View
<%= link_to blog_post_path(@blog_post) %>
<!-- Uses slug via to_param -->

# Admin View - Links
<%= link_to edit_admin_blog_post_path(@blog_post.id) %>
<!-- Explicitly uses ID -->

# Admin View - Forms
<%= form_with(model: [:admin, @blog_post],
              url: @blog_post.persisted? ? admin_blog_post_path(@blog_post.id) : admin_blog_posts_path) %>
<!-- Explicitly uses ID -->
```

## Status

**✅ RESOLVED** - Blog posts now save correctly. All CRUD operations work as expected.

## Related Documentation

- [Blog Post Admin Routing](blog-post-admin-routing.md) - Related ID vs slug routing issues
- [Blog Post Scheduling](blog-post-scheduling.md) - Publishing status fixes
