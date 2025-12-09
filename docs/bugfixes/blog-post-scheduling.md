# Blog Post Scheduling Issues

**Date:** 2024
**Status:** ✅ Fixed
**Severity:** High (Data integrity and security issue)

## Problems Identified

Three critical issues were discovered with blog post publishing and scheduling:

### 1. Future-Dated Posts Treated as Drafts ❌
- **Issue**: Creating a post with a future `published_at` date was incorrectly treated as a draft
- **Impact**: Posts couldn't be scheduled for future publication

### 2. Scheduled Posts Showing as Published in Admin ❌
- **Issue**: Posts with future dates appeared in the "Published" filter
- **Impact**: Admins couldn't distinguish between published and scheduled content

### 3. Scheduled/Draft Posts Visible on Public Frontend ❌
- **Issue**: Posts that shouldn't be public were visible to visitors
- **Impact**: **SECURITY/PRIVACY VIOLATION** - Unpublished content was leaked

## Root Cause

### The Scope Mismatch Problem

The model had **inconsistent definitions** of "published":

**Instance Method (Correct):**
```ruby
def published?
  published_at.present? && published_at <= Time.current
end
```

**Scope (WRONG):**
```ruby
scope :published, -> { where.not(published_at: nil).order(published_at: :desc) }
```

The scope only checked if `published_at` was present, **not if it was in the past**. This meant:
- A post scheduled for tomorrow had `published_at = tomorrow`
- The `published` scope included it (because `published_at` is not nil)
- The public controller used this scope → **future posts were visible**

### Cascading Effects

1. **Public Controller** used `BlogPost.published` → included future posts ❌
2. **Admin Controller** used same scope for filtering → wrong categorization ❌
3. **Viral/Featured Scopes** chained to `published` → included future posts ❌

## Solution

### 1. Fixed the `published` Scope

```ruby
# Before (❌ Includes future posts)
scope :published, -> { where.not(published_at: nil).order(published_at: :desc) }

# After (✅ Only past/present posts)
scope :published, -> { where("published_at IS NOT NULL AND published_at <= ?", Time.current).order(published_at: :desc) }
```

### 2. Added `scheduled` Scope and Method

```ruby
# New scope for scheduled posts
scope :scheduled, -> { where("published_at > ?", Time.current).order(published_at: :asc) }

# New instance method
def scheduled?
  published_at.present? && published_at > Time.current
end
```

### 3. Fixed Dependent Scopes

```ruby
# Before (❌ Could include scheduled posts)
scope :viral, -> { where(viral: true).order(published_at: :desc) }
scope :featured, -> { where(featured: true).order(published_at: :desc) }

# After (✅ Only truly published posts)
scope :viral, -> { where(viral: true).published.order(published_at: :desc) }
scope :featured, -> { where(featured: true).published.order(published_at: :desc) }
```

### 4. Updated Admin Interface

#### Added Scheduled Status Card
```erb
<div class="bg-white rounded-lg shadow border border-gray-200 p-4">
  <p class="text-sm text-gray-600">Scheduled</p>
  <p class="text-2xl font-bold text-orange-600 mt-1">
    <%= BlogPost.scheduled.count %>
  </p>
</div>
```

#### Added Scheduled Filter Button
```ruby
elsif params[:status] == "scheduled"
  @blog_posts = @blog_posts.scheduled
```

#### Added Scheduled Status Badge
```erb
<% elsif blog_post.scheduled? %>
  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800">
    <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
    </svg>
    Scheduled
  </span>
```

#### Added "Publish Now" for Scheduled Posts
```erb
<% if blog_post.draft? || blog_post.scheduled? %>
  <%= button_to publish_admin_blog_post_path(blog_post.id), method: :patch, 
      class: "text-green-600 hover:text-green-900", 
      title: "Publish Now", 
      form: { data: { turbo_confirm: "Publish this post now?" } } do %>
    <!-- Publish icon -->
  <% end %>
<% end %>
```

### 5. Enhanced Formatted Date Display

```ruby
def formatted_published_date
  return "Draft" if draft?
  return "Scheduled for #{published_at.strftime("%B %d, %Y")}" if scheduled?
  published_at.strftime("%B %d, %Y")
end
```

## Three Status System

Posts now have **three distinct statuses**:

| Status | Condition | Admin View | Public View | Color |
|--------|-----------|------------|-------------|-------|
| **Draft** | `published_at` is `nil` | ✅ Visible | ❌ Hidden | Gray |
| **Scheduled** | `published_at` > now | ✅ Visible | ❌ Hidden | Orange |
| **Published** | `published_at` ≤ now | ✅ Visible | ✅ Visible | Green |

### State Transitions

```
Draft → Scheduled: Set published_at to future date
Draft → Published: Set published_at to past/present
Scheduled → Draft: Clear published_at (unpublish)
Scheduled → Published: Set published_at to now (publish now)
Published → Draft: Clear published_at (unpublish)
```

## Security Impact

**CRITICAL:** Before this fix, the public frontend showed:
- ✅ Published posts (correct)
- ❌ Scheduled posts (LEAK - not yet ready)
- ❌ Draft posts if published_at was mistakenly set (LEAK - unpublished content)

**After this fix:**
- ✅ Only truly published posts (published_at ≤ now) are visible
- ✅ Scheduled and draft posts remain private until explicitly published

## Testing

Added 9 comprehensive tests for scheduling:

```ruby
test "scheduled? returns true for future published_at"
test "scheduled? returns false for past published_at"
test "scheduled? returns false for drafts"
test "published? returns false for scheduled posts"
test "scheduled scope includes future posts"
test "scheduled scope excludes past posts"
test "scheduled scope excludes drafts"
test "published scope excludes scheduled posts"
test "formatted_published_date shows scheduled date for future posts"
```

### Test Results

```bash
# Model tests (9 new tests added)
bin/rails test test/models/blog_post_test.rb
# 26 runs, 34 assertions, 0 failures ✅

# Full test suite
bin/rails test
# 438 runs, 1067 assertions, 0 failures ✅
```

## Files Changed

### Models
- ✅ `app/models/blog_post.rb` - Fixed scopes, added `scheduled?` method

### Controllers
- ✅ `app/controllers/admin/blog_posts_controller.rb` - Added scheduled filter
- ✅ `app/controllers/blog_posts_controller.rb` - Already used correct scope ✅

### Views
- ✅ `app/views/admin/blog_posts/index.html.erb` - Scheduled stats, filter, badges
- ✅ `app/views/admin/blog_posts/edit.html.erb` - Scheduled status badge
- ✅ `app/views/admin/blog_posts/_form.html.erb` - Scheduled status display

### Tests
- ✅ `test/models/blog_post_test.rb` - Added 9 scheduling tests

## User Experience Improvements

### For Content Creators
- 🎯 Schedule posts by setting future `published_at` dates
- 👁️ See scheduled posts separately from published/draft
- ⏰ View "Scheduled for [date]" instead of confusing status
- ⚡ "Publish Now" button to immediately publish scheduled posts

### For Site Visitors
- 🔒 Never see unfinished/scheduled content
- ✅ Only see content that's truly ready for public viewing

### For Admins
- 📊 Clear statistics: Total, Published, Scheduled, Drafts, Views
- 🎨 Color-coded statuses: Green (published), Orange (scheduled), Gray (draft)
- 🔍 Filter by any status
- 🚀 One-click actions: Publish Now, Move to Drafts, Edit, Delete

## Prevention

### When Working with Time-Based Publishing:

1. ✅ **Always check against `Time.current` in scopes**, not just presence
2. ✅ **Test with future dates** to catch scheduling bugs
3. ✅ **Ensure instance methods match scopes** for consistency
4. ✅ **Review public-facing queries** for security implications
5. ✅ **Chain dependent scopes** to parent scopes for consistency

### Code Review Checklist:

```ruby
# ❌ BAD: Only checks presence
scope :published, -> { where.not(published_at: nil) }

# ✅ GOOD: Checks date is in past
scope :published, -> { where("published_at IS NOT NULL AND published_at <= ?", Time.current) }

# ✅ GOOD: Dependent scopes chain to parent
scope :featured, -> { where(featured: true).published }

# ✅ GOOD: Public controllers use secure scopes
@posts = BlogPost.published  # Not BlogPost.where.not(published_at: nil)
```

## Verification Steps

### 1. Test Scheduling Flow
```bash
# 1. Start Rails console
bin/rails console

# 2. Create a scheduled post
post = BlogPost.create!(
  title: "Future Post",
  content: "Coming soon",
  published_at: 1.day.from_now
)

# 3. Verify status
post.scheduled?  # => true
post.published?  # => false
post.draft?      # => false

# 4. Check scopes
BlogPost.scheduled.include?(post)  # => true
BlogPost.published.include?(post)  # => false
BlogPost.drafted.include?(post)    # => false
```

### 2. Test Public Visibility
```bash
# Visit public blog page
# Scheduled posts should NOT appear

# Visit admin interface
# Scheduled posts should appear in "Scheduled" filter
```

### 3. Test Publishing Flow
```bash
# In admin interface:
# 1. Create post with future date → Shows as "Scheduled" (orange)
# 2. Click "Publish Now" → Changes to "Published" (green)
# 3. Post now visible on public site
```

## Status

**✅ RESOLVED** - Blog posts now correctly handle:
- Draft status (unpublished)
- Scheduled status (future publishing)
- Published status (live on site)
- Secure public visibility (only published posts shown)
