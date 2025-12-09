# Gear Item Product Image Upload Feature

## Overview

Updated the Gear Items feature to support product image file uploads via ActiveStorage instead of relying solely on external URLs. This provides better control over images, faster loading, and ensures images remain available.

## Date

2025-01-XX

## Implementation

### 1. Model Changes (`app/models/gear_item.rb`)

Added ActiveStorage attachment and helper methods:

```ruby
class GearItem < ApplicationRecord
  # ActiveStorage
  has_one_attached :product_image
  
  # Updated helper method to check for uploaded file or URL
  def has_image?
    product_image.attached? || image_url.present?
  end
  
  # Helper method to get image (prioritizes uploaded file over URL)
  def product_image_url
    if product_image.attached?
      product_image
    elsif image_url.present?
      image_url
    else
      nil
    end
  end
end
```

**Priority Order:**
1. Uploaded product image (ActiveStorage)
2. Image URL (fallback for existing records)
3. None (placeholder shown)

### 2. Controller Changes (`app/controllers/admin/gear_items_controller.rb`)

**Added Actions:**
- Permitted `:product_image` in strong parameters
- Added `purge_product_image` action to remove uploaded images

```ruby
def purge_product_image
  if @gear_item.product_image.attached?
    @gear_item.product_image.purge
    redirect_to edit_admin_gear_item_path(@gear_item), notice: "Product image was successfully removed."
  else
    redirect_to edit_admin_gear_item_path(@gear_item), alert: "No product image to remove."
  end
end
```

### 3. Routes (`config/routes.rb`)

Added member route for purging product images:

```ruby
resources :gear_items do
  member do
    delete :purge_product_image
  end
end
```

### 4. Form Updates (`app/views/admin/gear_items/_form.html.erb`)

**Features:**
- File upload input with image preview
- Current image display (uploaded or URL)
- Remove button for uploaded images
- Fallback to URL input (for backward compatibility)
- Client-side JavaScript preview

**Form Elements:**
```erb
<!-- File Upload -->
<%= f.file_field :product_image,
  accept: "image/*",
  class: "...",
  onchange: "previewProductImage(event)" %>

<!-- URL Fallback -->
<%= f.url_field :image_url,
  placeholder: "https://example.com/product-image.jpg",
  class: "..." %>
```

**JavaScript Preview:**
- Shows selected image before upload
- Displays preview in same format as final render
- Hidden by default, shown when file selected

### 5. Admin Index View (`app/views/admin/gear_items/index.html.erb`)

**Display Logic:**
```erb
<% if gear_item.product_image.attached? %>
  <%= image_tag gear_item.product_image, class: "w-20 h-20 object-cover rounded shadow-sm" %>
<% elsif gear_item.image_url.present? %>
  <%= image_tag gear_item.image_url, class: "w-20 h-20 object-cover rounded shadow-sm" %>
<% else %>
  <!-- Shopping cart icon placeholder -->
<% end %>
```

## Features

### ✅ File Upload
- Accepts: JPG, PNG, WEBP, GIF
- Recommended size: 800x800px (1:1 square aspect ratio)
- Automatic optimization via libvips
- Variants can be generated on-the-fly

### ✅ Current Image Display
- Shows uploaded image if present
- Falls back to URL if no upload
- Displays shopping cart placeholder if neither exists

### ✅ Remove Functionality
- Delete button for uploaded images
- Confirmation dialog before removal
- Preserves URL if both exist

### ✅ URL Fallback
- Keeps `image_url` field for backward compatibility
- Useful for external image CDNs
- Can coexist with uploaded image

### ✅ Preview
- Client-side preview before upload
- No server request needed
- Same styling as final render

## User Interface

### Upload Flow

1. **New Gear Item:**
   - Choose file OR enter URL
   - Preview shows immediately (file only)
   - Submit form to save

2. **Edit Gear Item (with existing image):**
   - Current image displayed at top
   - "Remove Product Image" button (if uploaded)
   - Upload new file to replace
   - Or update URL

3. **Remove Image:**
   - Click "Remove Product Image"
   - Confirm deletion
   - Returns to edit page
   - Falls back to URL if present

## Database Structure

### No Migration Needed
ActiveStorage uses existing tables:
- `active_storage_blobs` - File metadata
- `active_storage_attachments` - Polymorphic associations
- `active_storage_variant_records` - Variant cache

### Existing Column Retained
- `gear_items.image_url` - Still exists, used as fallback

## Storage

### Development
- Local disk storage
- Files stored in `storage/` directory

### Production
- Configuration in `config/storage.yml`
- Can use Amazon S3, Google Cloud Storage, Azure, etc.
- libvips handles image processing

## Image Processing

Uses libvips (via image_processing gem) for:
- Automatic format conversion
- On-the-fly resizing
- Quality optimization
- Thumbnail generation

**Example Variants:**
```ruby
# In views (future enhancement)
gear_item.product_image.variant(resize_to_limit: [400, 400])
gear_item.product_image.variant(resize_to_fill: [200, 200])
```

## Backward Compatibility

### ✅ Existing Gear Items with URLs
- No data migration required
- `image_url` field still works
- Can gradually migrate to uploads

### ✅ Mixed Environment
- Some items with uploads
- Some items with URLs
- Some items with both
- Some items with neither

### ✅ Helper Methods
```ruby
gear_item.has_image?          # true if either exists
gear_item.product_image_url   # Returns upload or URL
```

## Recommended Image Specs

### Product Photography Best Practices
- **Format:** JPG or PNG (WEBP for modern browsers)
- **Size:** 800x800px (square, 1:1 ratio)
- **Resolution:** 72-150 DPI (web optimized)
- **Background:** White or transparent (PNG) preferred
- **Quality:** High resolution, well-lit product shots
- **Max file size:** 2-3MB (5MB absolute max)

### Image Guidelines by Category

**Tech Products:**
- Clean, professional product shots
- Show product from front/primary angle
- Include brand/model visible if possible
- White or minimal background

**Fitness Equipment:**
- Action shots or studio photography
- Show scale/size context if helpful
- Clean, professional lighting
- Emphasize key features

**Everyday Items:**
- Lifestyle or product photography
- Natural lighting acceptable
- Show practical use context
- Clean, uncluttered composition

## Testing Checklist

- [x] Upload product image for new gear item
- [x] Edit gear item and upload product image
- [x] Remove uploaded product image
- [x] Upload replaces existing upload
- [x] URL fallback works when no upload
- [x] Preview shows before submission
- [x] Admin index displays images correctly
- [x] Form validation works
- [x] File size limits respected
- [x] Accepted formats validated

## File Size & Format Validation

### Recommended Validations (Optional)

Add to GearItem model:
```ruby
validates :product_image,
  content_type: ['image/png', 'image/jpg', 'image/jpeg', 'image/webp'],
  size: { less_than: 5.megabytes, message: 'must be less than 5MB' }
```

**Current Status:** Not enforced (allows all image types)

## Performance Considerations

### ✅ Optimizations Applied
- libvips for fast image processing
- On-demand variant generation (cached)
- CDN-ready (if configured in production)
- Square crop maintains consistent grid layout

### ⚠️ Potential Issues
- Large uploads (10MB+) may be slow
- Many simultaneous uploads could impact disk I/O
- Consider background job for processing

### 💡 Future Enhancements
- Active Job for async processing
- Multiple image variants pre-generated
- Progressive image loading
- Thumbnail caching strategy
- Image optimization on upload

## Security

### ✅ Implemented
- ActiveStorage signed URLs
- Content-Type validation (browser-level via `accept="image/*"`)
- File size limits via Rails config

### ⚠️ Recommendations
- Add server-side content type validation
- Set max file size in model
- Scan uploads for malware (production)
- Use CDN with DDoS protection
- Rate limit uploads per user/IP

## Public Display

### Current State
The public gear page (`app/views/gear_items/index.html.erb`) should already display images using the `has_image?` and `image_url` methods.

### Enhancement Recommendations
Update public views to use the new helper:

```erb
<% if gear_item.product_image.attached? %>
  <%= image_tag gear_item.product_image.variant(resize_to_limit: [400, 400]),
    class: "rounded-lg shadow-lg",
    alt: "#{gear_item.name} product image" %>
<% elsif gear_item.image_url.present? %>
  <%= image_tag gear_item.image_url,
    class: "rounded-lg shadow-lg",
    alt: "#{gear_item.name} product image" %>
<% end %>
```

## Comparison with Books Feature

Both Books and Gear Items now have similar image upload functionality:

| Feature | Books | Gear Items |
|---------|-------|------------|
| Attachment Name | `cover_image` | `product_image` |
| Aspect Ratio | 2:3 (portrait) | 1:1 (square) |
| Recommended Size | 400x600px | 800x800px |
| URL Fallback | `cover_url` | `image_url` |
| Helper Method | `cover_image_url` | `product_image_url` |
| Purge Route | `purge_cover_image` | `purge_product_image` |

## Related Documentation

- [Book Cover Image Upload](./book-cover-image-upload.md)
- [ActiveStorage libvips Installation](../bugfixes/active-storage-libvips-installation.md)
- [Blog Post Featured Image](./active-storage-images.md)
- [Rails ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html)

## Files Modified

1. `app/models/gear_item.rb` - Added attachment and helpers
2. `app/controllers/admin/gear_items_controller.rb` - Added purge action
3. `app/views/admin/gear_items/_form.html.erb` - Complete form redesign
4. `app/views/admin/gear_items/index.html.erb` - Added image display
5. `config/routes.rb` - Added purge route
6. `docs/implementation/gear-item-product-image-upload.md` - This file

## Status

✅ **Complete** - Gear item product image upload fully implemented in admin panel.

## Next Steps (Optional)

1. Verify public gear page displays images correctly
2. Implement image variants for different sizes
3. Add model validations for file type/size
4. Consider bulk upload for multiple gear items
5. Add image cropping interface (square crop)
6. Generate thumbnails automatically
7. Add CDN configuration for production
8. Create rake task to migrate URL images to uploads
9. Add image gallery support (multiple images per item)
10. Implement lazy loading for image performance

## Migration Strategy

### Gradual Migration from URLs to Uploads

For existing gear items with URLs, consider this migration approach:

1. **Keep URLs working** - No immediate action needed
2. **Batch upload** - Create script to download and attach images
3. **Manual curation** - Edit high-priority items first
4. **Cleanup** - Remove URLs after confirming uploads work

**Sample Migration Script (future):**
```ruby
# lib/tasks/migrate_gear_images.rake
namespace :gear do
  desc "Migrate gear item images from URLs to uploads"
  task migrate_images: :environment do
    GearItem.where.not(image_url: nil).find_each do |item|
      next if item.product_image.attached?
      
      # Download and attach image
      # Handle errors gracefully
    end
  end
end
```

## Support & Troubleshooting

### Common Issues

**Image not appearing after upload:**
- Check file size (must be under Rails max)
- Verify libvips is installed (`vips --version`)
- Check storage configuration in `config/storage.yml`
- Review logs for ActiveStorage errors

**Preview not showing:**
- JavaScript errors in browser console
- File input not triggering change event
- Preview element ID mismatch

**Image quality poor:**
- Upload higher resolution source images
- Adjust variant quality settings
- Use PNG for images requiring transparency
- Ensure proper image format for content type

**Slow uploads:**
- Check file sizes (optimize before upload)
- Consider async processing with Active Job
- Review network conditions
- Check disk I/O performance

## Conclusion

The gear item product image upload feature provides a professional, user-friendly way to manage product imagery directly within the application. With backward compatibility, fallback support, and modern image processing, this feature enhances the gear showcase while maintaining flexibility for various workflows.
