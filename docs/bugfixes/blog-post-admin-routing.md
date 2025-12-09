# Blog Post Admin Routing Issue

**Date:** 2024
**Status:** ✅ Fixed
**Severity:** High (Blocked admin CRUD operations)

## Problem

Admin users encountered `ActiveRecord::RecordNotFound` errors when trying to edit, delete, or manage blog posts through the admin interface:

```
ActiveRecord::RecordNotFound in Admin::BlogPostsController#edit
Couldn't find BlogPost with 'id'="building-in-public"
```

## Root Cause

The `BlogPost` model implements a custom `to_param` method that returns the `slug` instead of the numeric `id`:

```ruby
# app/models/blog_post.rb
def to_param
  slug
end
```

This is intentional for **public-facing URLs** (SEO-friendly):
- Public: `/blog/building-in-public` ✅ Uses slug
- Admin: `/admin/blog_posts/123/edit` ✅ Should use ID

However, when Rails helpers like `edit_admin_blog_post_path(blog_post)` were called in admin views, they used `to_param`, generating URLs like `/admin/blog_posts/building-in-public/edit`.

The admin controller then tried to find the record using:
```ruby
BlogPost.find(params[:id])  # params[:id] = "building-in-public"
```

Since `find()` expects a numeric ID, not a slug, it raised `RecordNotFound`.

## Why Seed Data vs Real Data Doesn't Matter

This issue affects **both seed data and real records** because:
1. The `to_param` method applies to all `BlogPost` instances
2. Rails URL helpers automatically call `to_param` on model instances
3. The controller's `find()` method expects numeric IDs regardless of data source

The error occurs whenever a blog post has a slug, which is always the case due to the `before_validation :generate_slug` callback.

## Solution

Explicitly pass the numeric `id` attribute to admin path helpers instead of relying on `to_param`:

### Changes Made

#### 1. Admin Index View (`app/views/admin/blog_posts/index.html.erb`)
```ruby
# Before (❌ Uses to_param, returns slug)
edit_admin_blog_post_path(blog_post)
publish_admin_blog_post_path(blog_post)
admin_blog_post_path(blog_post)

# After (✅ Explicitly uses numeric ID)
edit_admin_blog_post_path(blog_post.id)
publish_admin_blog_post_path(blog_post.id)
admin_blog_post_path(blog_post.id)
```

#### 2. Admin Form Partial (`app/views/admin/blog_posts/_form.html.erb`)
```ruby
# Before (❌)
unpublish_admin_blog_post_path(@blog_post)
publish_admin_blog_post_path(@blog_post)

# After (✅)
unpublish_admin_blog_post_path(@blog_post.id)
publish_admin_blog_post_path(@blog_post.id)
```

#### 3. Admin Edit View (`app/views/admin/blog_posts/edit.html.erb`)
```ruby
# Admin delete button (❌)
admin_blog_post_path(@blog_post)

# Fixed (✅)
admin_blog_post_path(@blog_post.id)

# Public view link (kept as slug, correct)
blog_post_path(@blog_post.slug)  # Still uses slug for public URLs
```

#### 4. Admin Dashboard View (`app/views/admin/dashboard/index.html.erb`)
```ruby
# Before (❌)
edit_admin_blog_post_path(post)

# After (✅)
edit_admin_blog_post_path(post.id)
```

## Key Learnings

### 1. Namespace-Specific Routing
- **Public routes** (`blog_post_path`) should use slugs for SEO
- **Admin routes** (`admin_blog_post_path`) should use numeric IDs for reliability

### 2. Custom `to_param` Considerations
When implementing `to_param`:
- ✅ Great for public-facing URLs
- ⚠️ Must explicitly use `.id` in admin/internal views
- ✅ Public controller uses `find_by!(slug: params[:slug])`
- ✅ Admin controller uses `find(params[:id])`

### 3. Testing Importance
The comprehensive test suite caught no regressions:
```bash
429 runs, 1053 assertions, 0 failures, 0 errors, 0 skips
```

All 17 blog post controller tests continued to pass because they correctly use numeric IDs in test helpers.

## Prevention

**When adding custom `to_param` to other models:**

1. ✅ Use slugs in public-facing controllers and views
2. ✅ Explicitly use `.id` in all admin views and internal links
3. ✅ Document the dual routing approach
4. ✅ Write tests for both routing approaches

**Pattern to follow:**
```ruby
# Public views (use model directly, to_param applies)
link_to "View", blog_post_path(blog_post)  # /blog/my-slug

# Admin views (explicitly use .id)
link_to "Edit", edit_admin_blog_post_path(blog_post.id)  # /admin/blog_posts/123/edit
```

## Verification

```bash
# Run blog post controller tests
bin/rails test test/controllers/admin/blog_posts_controller_test.rb
# ✅ 17 runs, 36 assertions, 0 failures

# Run full test suite
bin/rails test
# ✅ 429 runs, 1053 assertions, 0 failures
```

## Related Files

- `app/models/blog_post.rb` - Model with `to_param` override
- `app/controllers/admin/blog_posts_controller.rb` - Admin controller (uses numeric IDs)
- `app/controllers/blog_posts_controller.rb` - Public controller (uses slugs)
- `app/views/admin/blog_posts/index.html.erb` - Admin index view (fixed)
- `app/views/admin/blog_posts/_form.html.erb` - Admin form partial (fixed)
- `app/views/admin/blog_posts/edit.html.erb` - Admin edit view (fixed)
- `app/views/admin/dashboard/index.html.erb` - Admin dashboard view (fixed)

## Status

**✅ RESOLVED** - All admin blog post CRUD operations now work correctly with both seeded and real data.
