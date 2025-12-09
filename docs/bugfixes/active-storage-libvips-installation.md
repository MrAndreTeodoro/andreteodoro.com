# ActiveStorage libvips Installation Fix

## Problem

When attempting to view blog posts with featured images, ActiveStorage threw a `LoadError` when trying to create image variants:

```
LoadError in ActiveStorage::Representations::RedirectController#show
Could not open library 'vips.42': dlopen(vips.42, 0x0005): tried: 'vips.42' (no such file)...
Could not open library 'libvips.42.dylib': dlopen(libvips.42.dylib, 0x0005): tried: 'libvips.42.dylib' (no such file)...
```

This error occurred because Rails' ActiveStorage requires the **libvips** image processing library to be installed on the system, but it was missing.

## Root Cause

- The `image_processing` gem was present in the Gemfile (required for ActiveStorage variants)
- The `image_processing` gem depends on the `ruby-vips` gem
- The `ruby-vips` gem is a Ruby binding for the **libvips** C library
- The **libvips** system library was not installed on the development machine

When ActiveStorage attempted to create image variants (thumbnails, resized images, etc.), it tried to load libvips but couldn't find it.

## Solution

### Install libvips via Homebrew (macOS)

```bash
brew install vips
```

This installs:
- libvips 8.17.3 (the core image processing library)
- All required dependencies (cfitsio, cgif, gcc, fftw, libexif, etc.)

### Verification

After installation, verify that:

1. **libvips is installed:**
   ```bash
   vips --version
   # Output: vips-8.17.3
   ```

2. **Ruby can load the vips gem:**
   ```bash
   bin/rails runner "require 'vips'; puts Vips::version_string"
   # Output: 8.17.3
   ```

3. **ActiveStorage is configured to use vips:**
   ```bash
   bin/rails runner "puts ActiveStorage.variant_processor"
   # Output: vips
   ```

## How ActiveStorage Uses libvips

ActiveStorage automatically uses libvips (via the `image_processing` gem) to:

- **Generate variants** - Create resized/cropped versions of uploaded images
- **Create thumbnails** - Generate preview images for the admin interface
- **Process transformations** - Apply filters, rotations, format conversions
- **Optimize performance** - libvips is significantly faster than ImageMagick

### Example Usage in Code

```ruby
# In the view
<%= image_tag blog_post.featured_image.variant(resize_to_limit: [800, 600]) %>

# In the model
blog_post.featured_image.variant(resize_to_fill: [300, 200])
```

## Alternative: MiniMagick (Not Recommended)

If you prefer to use ImageMagick instead of libvips, you can:

1. Install ImageMagick:
   ```bash
   brew install imagemagick
   ```

2. Configure Rails to use mini_magick:
   ```ruby
   # config/application.rb
   config.active_storage.variant_processor = :mini_magick
   ```

**However, vips is recommended because:**
- ⚡ **Faster** - vips is 4-10x faster than ImageMagick
- 💾 **Lower memory usage** - Streaming processing uses less RAM
- 🔧 **Better defaults** - Works out of the box with Rails 7+

## Dependencies Installed

The `brew install vips` command installed the following dependencies:

- **cfitsio** - FITS file format support
- **cgif** - GIF encoding
- **gcc** - GNU Compiler Collection (for building native extensions)
- **fftw** - Fast Fourier Transform library
- **libexif** - EXIF metadata reading
- **libimagequant** - PNG quantization
- **hdf5** - Hierarchical Data Format
- **libmatio** - MATLAB file format support
- **gdk-pixbuf** - Image loading library
- **librsvg** - SVG rendering
- **libspng** - PNG support
- **mozjpeg** - JPEG encoding
- **libdicom** - DICOM medical imaging format
- **openslide** - Whole-slide imaging support

## Production Deployment

### Docker (Kamal)

Add libvips to your Dockerfile:

```dockerfile
# Dockerfile
FROM ruby:3.4.3

# Install libvips
RUN apt-get update && \
    apt-get install -y libvips42 libvips-dev && \
    rm -rf /var/lib/apt/lists/*

# ... rest of Dockerfile
```

### Heroku

Libvips is included in Heroku's default stack, no additional configuration needed.

### Other Platforms

Consult the [libvips installation guide](https://www.libvips.org/install.html) for platform-specific instructions.

## Testing

After installing libvips, test image processing:

```bash
# Start the development server
bin/dev

# Create or edit a blog post with a featured image
# Verify that:
# 1. Images upload successfully
# 2. Image variants are generated without errors
# 3. Blog post show pages display images correctly
```

## Gemfile Configuration

No changes needed to the Gemfile - it already includes the correct gem:

```ruby
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"
```

The `image_processing` gem automatically:
- Detects which variant processor is available (vips or mini_magick)
- Uses vips by default if both are available
- Provides a unified API regardless of the underlying processor

## Related Files

- **Gemfile** - Contains `image_processing` gem
- **config/application.rb** - Can override variant processor (not needed)
- **config/storage.yml** - ActiveStorage storage configuration
- **app/models/blog_post.rb** - Defines `has_one_attached :featured_image`
- **app/views/admin/blog_posts/_form.html.erb** - Image upload form
- **app/views/blog_posts/show.html.erb** - Displays featured image with variants

## Resources

- [libvips Official Site](https://www.libvips.org/)
- [ruby-vips Gem](https://github.com/libvips/ruby-vips)
- [image_processing Gem](https://github.com/janko/image_processing)
- [Rails ActiveStorage Guide](https://guides.rubyonrails.org/active_storage_overview.html)
- [Rails ActiveStorage Variants](https://guides.rubyonrails.org/active_storage_overview.html#transforming-images)

## Date

2025-01-XX (Updated during blog post featured image implementation)

## Status

✅ **Resolved** - libvips installed, ActiveStorage image processing working correctly
