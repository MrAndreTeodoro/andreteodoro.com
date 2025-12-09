# Blog Post Publish Button Fix

**Date:** December 2024
**Status:** ✅ Fixed
**Severity:** Medium (Feature not working)

## Problem

The "Publish Now" and "Move to Drafts" buttons inside the blog post edit form were not working. Clicking them had no effect on the post's published status.

## Symptoms

- Click "Publish Now" button on a draft post
- Nothing happens - post remains a draft
- No error messages shown
- Same issue with "Move to Drafts" button on published posts

## Root Cause

The publish/unpublish buttons were placed **inside** the main form using `button_to`:

```erb
<%= form_with(model: [:admin, @blog_post], ...) do |f| %>
  <!-- form fields -->
  
  <!-- Form Actions -->
  <div class="flex items-center gap-3">
    <%= button_to "Publish Now", publish_admin_blog_post_path(@blog_post.id), method: :patch %>
    <%= f.submit "Update Blog Post" %>
  </div>
<% end %>
```

**The Problem:** `button_to` generates its own `<form>` element. When placed inside another form, it creates **nested forms**, which are invalid HTML and don't work properly.

```html
<!-- What Rails generated (invalid HTML) -->
<form action="/admin/blog_posts/123" method="post">
  <!-- main form fields -->
  
  <form action="/admin/blog_posts/123/publish" method="post">
    <button>Publish Now</button>
  </form>
  
  <button type="submit">Update Blog Post</button>
</form>
```

Browsers don't handle nested forms correctly, causing the publish button to either:
- Do nothing
- Submit the outer form instead
- Cause unpredictable behavior

## Solution

Moved the publish/unpublish buttons **outside** the main form:

**File:** `app/views/admin/blog_posts/_form.html.erb`

### Before (❌ Nested Forms)
```erb
<%= form_with(model: [:admin, @blog_post], ...) do |f| %>
  <!-- form fields -->
  
  <div class="flex items-center gap-3">
    <% if @blog_post.published? %>
      <%= button_to "Move to Drafts", unpublish_admin_blog_post_path(@blog_post.id), method: :patch %>
    <% elsif @blog_post.draft? || @blog_post.scheduled? %>
      <%= button_to "Publish Now", publish_admin_blog_post_path(@blog_post.id), method: :patch %>
    <% end %>
    
    <%= f.submit "Update Blog Post" %>
  </div>
<% end %>
```

### After (✅ Separate Forms)
```erb
<%= form_with(model: [:admin, @blog_post], ...) do |f| %>
  <!-- form fields -->
  
  <div class="flex items-center gap-3">
    <%= f.submit "Update Blog Post" %>
  </div>
<% end %>

<!-- Publish/Unpublish Actions (outside form to avoid nesting) -->
<% if @blog_post.persisted? %>
  <div class="flex items-center justify-end gap-3 mt-4">
    <% if @blog_post.published? %>
      <%= button_to "Move to Drafts", unpublish_admin_blog_post_path(@blog_post.id), method: :patch %>
    <% elsif @blog_post.draft? || @blog_post.scheduled? %>
      <%= button_to "Publish Now", publish_admin_blog_post_path(@blog_post.id), method: :patch %>
    <% end %>
  </div>
<% end %>
```

Now each form is independent:
1. Main form updates the blog post fields
2. Publish/unpublish form is separate and works correctly

## Why button_to Creates a Form

The `button_to` helper creates a form because:
- It needs to send a non-GET request (PATCH, POST, DELETE)
- Browsers can only send non-GET requests via forms
- A simple link can't specify the HTTP method

```ruby
button_to "Publish", publish_admin_blog_post_path(@blog_post.id), method: :patch
```

Generates:
```html
<form action="/admin/blog_posts/123/publish" method="post">
  <input type="hidden" name="_method" value="patch">
  <button type="submit">Publish</button>
</form>
```

## Alternative Solutions

### Option 1: Use link_to with data-turbo-method (Turbo 7.2+)
```erb
<%= link_to "Publish Now", 
            publish_admin_blog_post_path(@blog_post.id), 
            data: { turbo_method: :patch },
            class: "..." %>
```

**Pros:**
- No form element created
- Can be placed anywhere
- Works with Turbo Drive

**Cons:**
- Requires Turbo
- Less semantic (it's an action, not navigation)

### Option 2: Custom JavaScript
```erb
<button data-action="click->blog-post#publish" 
        data-blog-post-id="<%= @blog_post.id %>"
        class="...">
  Publish Now
</button>
```

**Pros:**
- Full control over behavior
- Can add loading states, confirmations, etc.

**Cons:**
- More complex
- Requires custom Stimulus controller

### Option 3: Move buttons outside form (chosen solution)
**Pros:**
- Simple, semantic HTML
- Works without JavaScript
- Clear separation of concerns

**Cons:**
- Slightly more layout coordination needed

## Testing

### Manual Test
1. Go to `/admin/blog_posts`
2. Create or edit a draft post
3. Click "Publish Now" button (below the form)
4. Verify:
   - ✅ Post status changes to "Published"
   - ✅ Success message: "Blog post was successfully published"
   - ✅ Post appears in published filter
   - ✅ `published_at` is set to current time

5. Click "Move to Drafts" button
6. Verify:
   - ✅ Post status changes to "Draft"
   - ✅ Success message: "Blog post was moved to drafts"
   - ✅ Post appears in drafts filter
   - ✅ `published_at` is set to `nil`

### Check HTML Structure
Inspect the page HTML:
```html
<!-- Main form -->
<form action="/admin/blog_posts/123" method="post">
  <!-- fields -->
  <button type="submit">Update Blog Post</button>
</form>

<!-- Separate publish form (not nested!) -->
<form action="/admin/blog_posts/123/publish" method="post">
  <input type="hidden" name="_method" value="patch">
  <button type="submit">Publish Now</button>
</form>
```

No nested `<form>` tags! ✅

### Check Browser Console
No JavaScript errors about form submission.

## Related Controller Actions

The publish/unpublish actions in the controller:

```ruby
# app/controllers/admin/blog_posts_controller.rb

def publish
  if @blog_post.publish!
    redirect_to admin_blog_posts_path, notice: "Blog post was successfully published."
  else
    redirect_to admin_blog_posts_path, alert: "Failed to publish blog post."
  end
end

def unpublish
  if @blog_post.unpublish!
    redirect_to admin_blog_posts_path, notice: "Blog post was moved to drafts."
  else
    redirect_to admin_blog_posts_path, alert: "Failed to unpublish blog post."
  end
end
```

Model methods:

```ruby
# app/models/blog_post.rb

def publish!
  update(published_at: Time.current)
end

def unpublish!
  update(published_at: nil)
end
```

These were already working correctly - the issue was purely with the form HTML structure.

## Best Practices

### When Using button_to

**✅ DO:**
- Place `button_to` outside other forms
- Use for actions (not navigation)
- Include confirmation for destructive actions

**❌ DON'T:**
- Nest `button_to` inside other forms
- Use for simple GET requests (use `link_to` instead)
- Forget to specify the HTTP method

### Form Design Pattern

```erb
<!-- Main form for editing -->
<%= form_with(model: resource) do |f| %>
  <!-- fields -->
  <%= f.submit "Save" %>
<% end %>

<!-- Separate actions outside form -->
<% if resource.persisted? %>
  <%= button_to "Delete", resource_path(resource), method: :delete, data: { turbo_confirm: "Are you sure?" } %>
  <%= button_to "Archive", archive_resource_path(resource), method: :patch %>
<% end %>
```

## Status

**✅ RESOLVED** - Publish and unpublish buttons now work correctly.

## Related Issues

- [Blog Post Form Submission](blog-post-form-submission.md) - Form URL using slug issue
- [Blog Post Admin Routing](blog-post-admin-routing.md) - ID vs slug routing issues
- [Blog Post Scheduling](blog-post-scheduling.md) - Published/scheduled/draft status logic

## References

- [Rails button_to documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)
- [HTML form nesting rules](https://html.spec.whatwg.org/multipage/forms.html#the-form-element)
- [Turbo data-turbo-method](https://turbo.hotwired.dev/reference/attributes)
