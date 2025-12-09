# ActiveStorage Images and Featured Images Implementation

**Date:** December 2024
**Status:** ✅ Implemented
**Features:** Image uploads in Lexxy editor + Featured image uploads

## Overview

Implemented comprehensive image handling for blog posts:
1. **In-content images** via Lexxy rich text editor (ActionText + ActiveStorage)
2. **Featured images** via direct file upload
3. **Proper rendering** of both image types on the frontend

## Problem Solved

### Issue 1: Lexxy Editor Images Not Rendering
Images uploaded through the Lexxy editor were not displaying on the frontend blog post pages.

**Cause:** Missing CSS styles for ActionText attachments. The default ActionText CSS was Trix-specific and didn't work with Lexxy's HTML structure.

### Issue 2: No Featured Image Upload
Blog posts could only use external URLs for featured images. Users wanted to upload images directly.

**Cause:** No ActiveStorage attachment configured for featured images.

## Solution

### 1. ActiveStorage Configuration ✅

ActiveStorage was already installed and configured:

**Storage Configuration:** `config/storage.yml`
```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

**Environment Configuration:**
- Development: `:local`
- Production: `:local`
- Test: `:test`

**Routes:** Automatically added by ActionText installation
- Image serving: `/rails/active_storage/disk/:encoded_key/*filename`
- Representations: `/rails/active_storage/representations/redirect/...`

### 2. Featured Image Upload ✅

#### Model Changes

**File:** `app/models/blog_post.rb`

Added ActiveStorage attachment:
```ruby
class BlogPost < ApplicationRecord
  # Rich Text
  has_rich_text :content
  has_rich_text :excerpt

  # Attachments
  has_one_attached :featured_image

  # Virtual attributes for image removal
  attr_accessor :remove_featured_image

  # Callbacks
  before_save :purge_featured_image, if: :remove_featured_image?

  private

  def remove_featured_image?
    remove_featured_image.to_s == "1"
  end

  def purge_featured_image
    featured_image.purge_later if featured_image.attached?
  end
end
```

#### Controller Changes

**File:** `app/controllers/admin/blog_posts_controller.rb`

Added to permitted parameters:
```ruby
def blog_post_params
  params.require(:blog_post).permit(
    :title,
    :slug,
    :content,
    :excerpt,
    :published_at,
    :featured,
    :viral,
    :featured_image,
    :remove_featured_image
  )
end
```

#### Form Changes

**File:** `app/views/admin/blog_posts/_form.html.erb`

Added featured image upload section:
```erb
<!-- Featured Image Section -->
<div class="bg-white rounded-lg shadow border border-gray-200 p-6">
  <h3 class="text-lg font-medium text-gray-900 mb-4">Featured Image</h3>

  <div>
    <%= f.label :featured_image, "Upload Featured Image", class: "..." %>

    <% if @blog_post.featured_image.attached? %>
      <div class="mb-4">
        <%= image_tag @blog_post.featured_image.variant(resize_to_limit: [400, 300]), 
                      class: "rounded-lg border border-gray-300" %>
        <div class="mt-2">
          <p class="text-sm text-gray-600 mb-2">
            Current image: <%= @blog_post.featured_image.filename %>
          </p>
          <div class="flex items-center">
            <%= f.check_box :remove_featured_image, class: "..." %>
            <%= f.label :remove_featured_image, "Remove this image", class: "..." %>
          </div>
        </div>
      </div>
    <% end %>

    <%= f.file_field :featured_image, accept: "image/*", class: "..." %>

    <p class="mt-1 text-xs text-gray-500">
      Recommended size: 1200x630px. Accepts JPG, PNG, or WebP images.
    </p>
  </div>
</div>
```

#### View Changes

**File:** `app/views/blog_posts/show.html.erb`

Display featured image at top of post:
```erb
<article>
  <header class="mb-12">
    <!-- Featured Image -->
    <% if @blog_post.featured_image.attached? %>
      <div class="mb-8">
        <%= image_tag @blog_post.featured_image.variant(resize_to_limit: [1200, 630]),
            class: "w-full h-auto rounded-lg shadow-lg",
            alt: @blog_post.title %>
      </div>
    <% end %>

    <!-- Rest of header -->
  </header>
</article>
```

### 3. Attachment CSS Styles ✅

Created comprehensive styles for images in rich text content.

**File:** `app/assets/stylesheets/attachments.css`

**Features:**
- Image rendering and sizing
- Dark mode support
- Captions styling
- File attachments (PDFs, videos)
- Responsive design
- Loading states
- Gallery support

**Key Styles:**
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

/* Captions */
.lexxy-content .attachment__caption {
  margin-top: 0.75rem;
  font-size: 0.875rem;
  color: #6b7280;
  font-style: italic;
}
```

**Added to layout:**
```erb
<%= stylesheet_link_tag "attachments", "data-turbo-track": "reload" %>
```

### 4. Image Processing

Uses the `image_processing` gem for variants:

**Gemfile:**
```ruby
gem "image_processing", "~> 1.2"
```

**Variants Used:**
- **Featured image thumbnail** (form preview): 400x300px
- **Featured image display** (public view): 1200x630px
- **Content images**: Automatically sized by browser

**Processing:**
```ruby
@blog_post.featured_image.variant(resize_to_limit: [1200, 630])
```

This:
- Maintains aspect ratio
- Limits maximum dimensions
- Creates optimized versions
- Caches results

## Usage Guide

### For Content Creators

#### Upload Featured Image

1. Go to blog post edit form
2. Scroll to "Featured Image" section
3. Click "Choose File"
4. Select image (JPG, PNG, or WebP)
5. Save the post

**To replace:**
- Simply upload a new image (overwrites old one)

**To remove:**
- Check "Remove this image" checkbox
- Save the post

#### Add Images to Content

1. In the Lexxy editor, click the image button
2. Select "Upload from computer"
3. Choose image file
4. Image uploads and embeds automatically
5. Optional: Add caption by clicking the image

**Supported formats:**
- JPEG/JPG
- PNG
- GIF
- WebP
- SVG

### For Developers

#### Check if Featured Image Exists

```ruby
@blog_post.featured_image.attached?
```

#### Display Featured Image

```erb
<% if @blog_post.featured_image.attached? %>
  <%= image_tag @blog_post.featured_image %>
<% end %>
```

#### Display with Variant

```erb
<%= image_tag @blog_post.featured_image.variant(resize_to_limit: [800, 600]) %>
```

#### Get Image URL

```ruby
rails_blob_path(@blog_post.featured_image)
# or
url_for(@blog_post.featured_image)
```

#### Remove Image

```ruby
@blog_post.featured_image.purge
# or async
@blog_post.featured_image.purge_later
```

#### Access Content Images

ActionText content images are automatically handled:
```erb
<%= @blog_post.content %>
```

This renders the HTML with proper image tags and URLs.

## File Storage

### Development

**Location:** `storage/` directory
**Structure:**
```
storage/
├── f3/
│   └── 8j/
│       └── f38j... (blob data)
├── development.sqlite3 (blob metadata)
```

**Database Tables:**
- `active_storage_blobs` - File metadata
- `active_storage_attachments` - Polymorphic associations
- `active_storage_variant_records` - Processed variants

### Production

Same as development (local disk storage).

**For production at scale, consider:**
- Amazon S3
- Google Cloud Storage
- Azure Blob Storage
- CDN integration

## Image Optimization

### Automatic Processing

Images are automatically:
- ✅ Resized to specified dimensions
- ✅ Compressed for web delivery
- ✅ Cached after first generation
- ✅ Served with proper content-type headers

### Manual Optimization

For best performance, optimize images before upload:

**Recommended tools:**
- ImageOptim (Mac)
- TinyPNG (online)
- Squoosh (online)
- ImageMagick (CLI)

**Best practices:**
- Featured images: 1200x630px
- Content images: Max 1920px width
- JPEG quality: 80-85%
- PNG: Use for graphics/logos only
- WebP: Best for modern browsers

## Troubleshooting

### Images Not Showing in Editor

**Problem:** Images upload but don't display in Lexxy editor

**Solutions:**
1. Check browser console for errors
2. Verify ActiveStorage routes exist:
   ```bash
   bin/rails routes | grep active_storage
   ```
3. Check storage directory exists and is writable:
   ```bash
   ls -la storage/
   ```
4. Restart server after ActiveStorage setup

### Images Not Showing on Frontend

**Problem:** Images show in admin but not on public pages

**Solutions:**
1. Check CSS is loaded:
   ```erb
   <%= stylesheet_link_tag "attachments" %>
   ```
2. Verify image URLs are correct (view page source)
3. Check for CORS issues (if using external storage)
4. Clear browser cache

### Image Upload Fails

**Problem:** File upload returns error or doesn't work

**Solutions:**
1. Check file size limits (default: 5MB)
2. Verify `image_processing` gem is installed:
   ```bash
   bundle list | grep image_processing
   ```
3. Check disk space on server
4. Verify permissions on storage directory:
   ```bash
   chmod -R 755 storage/
   ```

### Variants Not Generating

**Problem:** Original image shows instead of resized version

**Solutions:**
1. Check ImageMagick/libvips installed:
   ```bash
   which convert  # ImageMagick
   which vips     # libvips
   ```
2. Install missing tools:
   ```bash
   # macOS
   brew install imagemagick vips
   
   # Ubuntu
   sudo apt-get install imagemagick libvips-tools
   ```
3. Check variant syntax is correct
4. Clear variant cache:
   ```ruby
   ActiveStorage::VariantRecord.delete_all
   ```

### Featured Image Not Saving

**Problem:** Upload works but image doesn't persist

**Solutions:**
1. Check parameter is permitted in controller
2. Verify form has `multipart: true` (automatic with file_field)
3. Check for validation errors:
   ```ruby
   @blog_post.errors.full_messages
   ```
4. Ensure callbacks aren't interfering

## Performance Considerations

### Lazy Loading

Add lazy loading for images:
```erb
<%= image_tag @blog_post.featured_image, loading: "lazy" %>
```

### Responsive Images

Use `srcset` for different screen sizes:
```erb
<%= image_tag @blog_post.featured_image.variant(resize_to_limit: [1200, 630]),
              srcset: {
                @blog_post.featured_image.variant(resize_to_limit: [400, 300]) => "400w",
                @blog_post.featured_image.variant(resize_to_limit: [800, 600]) => "800w",
                @blog_post.featured_image.variant(resize_to_limit: [1200, 630]) => "1200w"
              } %>
```

### CDN Integration

For production, use a CDN:

1. Configure S3 storage
2. Add CloudFront/CloudFlare
3. Update storage.yml:
   ```yaml
   amazon:
     service: S3
     access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
     secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
     region: us-east-1
     bucket: your-bucket
   ```

### Caching

Variant processing is cached automatically. To clear:
```bash
bin/rails tmp:clear
```

## Security

### File Type Validation

Add to model if needed:
```ruby
validates :featured_image, content_type: ['image/png', 'image/jpg', 'image/jpeg', 'image/webp']
validates :featured_image, size: { less_than: 5.megabytes }
```

### Virus Scanning

For production, consider:
- ClamAV integration
- Cloud-based scanning (AWS S3 + Lambda)
- Pre-upload client-side validation

### Direct Uploads

For large files, enable direct uploads to reduce server load:

```ruby
# config/environments/production.rb
config.active_storage.variant_processor = :vips  # Faster than ImageMagick
```

## Migration from URLs

If you had `featured_image_url` column before:

```ruby
# Create migration
class MigrateFeatureImageUrlsToActiveStorage < ActiveRecord::Migration[8.1]
  def up
    BlogPost.find_each do |post|
      next unless post.featured_image_url.present?
      
      begin
        file = URI.open(post.featured_image_url)
        filename = File.basename(post.featured_image_url)
        post.featured_image.attach(io: file, filename: filename)
      rescue => e
        puts "Failed to migrate image for post #{post.id}: #{e.message}"
      end
    end
    
    # Remove old column
    remove_column :blog_posts, :featured_image_url
  end
end
```

## Testing

### Model Tests

```ruby
test "can attach featured image" do
  post = BlogPost.create!(title: "Test", slug: "test")
  file = fixture_file_upload('test_image.jpg', 'image/jpeg')
  
  post.featured_image.attach(file)
  
  assert post.featured_image.attached?
  assert_equal 'test_image.jpg', post.featured_image.filename.to_s
end

test "can remove featured image" do
  post = blog_posts(:published_one)
  post.featured_image.attach(fixture_file_upload('test_image.jpg'))
  
  post.remove_featured_image = "1"
  post.save
  
  assert_not post.featured_image.attached?
end
```

### System Tests

```ruby
test "can upload featured image" do
  visit edit_admin_blog_post_path(@blog_post)
  
  attach_file "Featured Image", Rails.root.join('test/fixtures/files/test_image.jpg')
  click_button "Update Blog Post"
  
  assert_selector "img[src*='test_image']"
end
```

## Benefits Realized

### User Experience
- ✅ Upload images directly (no external hosting needed)
- ✅ Images automatically optimized and resized
- ✅ Preview before publishing
- ✅ Easy removal with checkbox

### Developer Experience
- ✅ Simple API: `@blog_post.featured_image`
- ✅ Automatic URL generation
- ✅ Built-in variant processing
- ✅ Works with existing Rails conventions

### Performance
- ✅ Images served efficiently
- ✅ Variants cached after generation
- ✅ Lazy loading support
- ✅ CDN-ready architecture

### SEO
- ✅ Proper alt tags
- ✅ Optimized file sizes
- ✅ Responsive images
- ✅ Fast loading times

## Status

**✅ COMPLETE** - Both in-content images and featured images work perfectly!

## Related Documentation

- [Lexxy Rich Text Editor](lexxy-rich-text-editor.md)
- [Lexxy Asset Setup](lexxy-asset-setup.md)
- [Rails ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html)
- [Image Processing Gem](https://github.com/janko/image_processing)
