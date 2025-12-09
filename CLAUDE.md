# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Technology Stack

- **Rails 8.1.1** with Ruby 3.4.3
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS, Importmap
- **Database**: SQLite3 (development/production)
- **Caching/Jobs**: Solid Cache, Solid Queue, Solid Cable
- **Deployment**: Kamal with Docker, Thruster for production serving
- **Code Quality**: RuboCop (Rails Omakase), Brakeman, Bundler Audit
- **Rich Text Editor**: Lexxy (with ActionText)

## Development Commands

### Setup
```bash
bin/setup                    # Install dependencies, prepare database, start server
bin/setup --skip-server      # Setup without starting server
bin/setup --reset            # Reset database before setup
bin/update_lexxy_assets      # Copy Lexxy rich text editor assets (required after gem updates)
```

**Note:** The `bin/setup` script automatically runs `bin/update_lexxy_assets`. You only need to run it manually after updating the Lexxy gem.

### System Dependencies

**libvips** (required for ActiveStorage image processing):
```bash
brew install vips            # macOS - Required for image uploads and variants
```

If libvips is not installed, you'll see errors when uploading images or generating image variants.

### Running the Application
```bash
bin/dev                      # Start development server with Foreman (Rails server + Tailwind watch)
bin/rails server             # Start Rails server only (port 3000 by default)
PORT=3001 bin/dev            # Start on custom port
```

### Testing
```bash
bin/rails test               # Run all unit/integration tests
bin/rails test:system        # Run system tests
bin/rails test test/path/to/specific_test.rb              # Run single test file
bin/rails test test/path/to/specific_test.rb:line_number  # Run single test
```

### Code Quality & Security
```bash
bin/rubocop                  # Run RuboCop linter (Rails Omakase style)
bin/rubocop -a               # Auto-correct safe violations
bin/brakeman                 # Security analysis
bin/bundler-audit            # Gem vulnerability audit
bin/importmap audit          # Importmap vulnerability audit
bin/ci                       # Run full CI suite (setup, style, security, tests)
```

### Database
```bash
bin/rails db:prepare         # Create database and run migrations
bin/rails db:migrate         # Run pending migrations
bin/rails db:rollback        # Rollback last migration
bin/rails db:reset           # Drop, create, and migrate database
bin/rails db:seed            # Seed database
bin/rails db:seed:replant    # Reset and reseed database
```

### Assets
```bash
bin/rails tailwindcss:watch  # Watch and rebuild Tailwind CSS
bin/rails assets:precompile  # Precompile assets for production
```

## Architecture

### Database Architecture (Production)

Production uses **multiple SQLite databases** for separation of concerns:
- **primary**: Main application data (`storage/production.sqlite3`)
- **cache**: Solid Cache storage (`storage/production_cache.sqlite3`, migrations in `db/cache_migrate`)
- **queue**: Solid Queue jobs (`storage/production_queue.sqlite3`, migrations in `db/queue_migrate`)
- **cable**: Solid Cable connections (`storage/production_cable.sqlite3`, migrations in `db/cable_migrate`)

This multi-database setup requires awareness when:
- Creating migrations (use correct `migrations_paths` for non-primary databases)
- Writing queries (specify database if querying cache/queue/cable data)
- Running migrations (Rails handles routing automatically)

### Frontend Architecture

This is a **Hotwire application**, not a traditional SPA:
- **Turbo Drive**: Converts link clicks and form submissions into AJAX requests for faster navigation
- **Turbo Frames**: Enables partial page updates without full page reloads
- **Turbo Streams**: Allows server to push real-time updates via WebSocket or after form submissions
- **Stimulus**: Minimal JavaScript controllers for interactive elements
- **Importmap**: JavaScript modules without bundling (no Node.js required)
- **Tailwind CSS**: Utility-first styling, compiled via `tailwindcss-rails`

When adding interactivity:
1. Prefer Turbo solutions over JavaScript when possible
2. Use Stimulus controllers for reusable JavaScript behaviors
3. Add JavaScript packages via `bin/importmap pin package-name`

### Deployment

Uses **Kamal** for Docker-based deployment:
- Configuration in `.kamal/` directory
- `bin/thrust` wraps Puma with HTTP caching/compression in production
- Port 80 exposed in Docker (Thruster handles this)
- Database mounted as persistent volume in production

## Code Style

Follows **Rails Omakase** style via `rubocop-rails-omakase`. Always run `bin/rubocop` before committing.

## Design Principles & Best Practices

### DRY (Don't Repeat Yourself)

**Always apply DRY principles** when writing code. This is a critical requirement:

#### Layouts
- **Use conditional logic** in layouts rather than duplicating entire layout files
- Example: The `application.html.erb` layout conditionally renders auth vs portfolio layouts
- **Don't create separate layouts** for similar purposes - use partials or conditions instead

#### Views
- **Extract repeated markup into partials** (`_partial.html.erb`)
  - Navigation bars → `_navigation.html.erb`
  - Footers → `_footer.html.erb`
  - Form sections → `_form.html.erb`
  - Card components → `_card.html.erb`
- **Share form partials** between `new` and `edit` views
- **Use helpers** for repeated logic in views

#### Controllers
- **Extract common logic to `before_action` callbacks**
  - Example: `before_action :set_resource, only: [:edit, :update, :destroy]`
- **Use inheritance** for shared controller behavior
  - Example: `Admin::BaseController` defines layout and authentication for all admin controllers
- **Don't repeat strong parameters** - define once in private methods

#### Models
- **Use scopes** for repeated queries
  - Example: `scope :featured, -> { where(featured: true) }`
- **Create helper methods** for repeated display logic
  - Example: `formatted_price`, `star_rating`, `category_display_name`
- **Use callbacks** for repeated data transformations
  - Example: `before_validation :normalize_category`

#### Documentation
- **Follow established patterns** when documenting new features
- **Use templates** for consistency (technical, quickstart, implementation docs)
- **Reference existing docs** instead of duplicating information

### Code Organization

#### Controller Patterns
```ruby
class Admin::ResourcesController < Admin::BaseController
  before_action :set_resource, only: [:edit, :update, :destroy]
  
  # Standard CRUD order: index, new, create, edit, update, destroy
  # Private methods at bottom: set_resource, resource_params
end
```

#### View Patterns
- **Index pages**: Search/filters → Statistics → Main content → Empty state
- **Form pages**: Breadcrumbs → Form (with sections) → Tips/help section
- **Edit pages**: Breadcrumbs → Info banner → Form → Danger zone

#### Model Patterns
- **Order**: Validations → Scopes → Callbacks → Public methods → Private methods
- **Use built-in Rails validations** before custom ones
- **Name scopes clearly** (e.g., `featured`, `by_category`, `recently_read`)

### When to Extract Code

#### Create a Partial When:
- ✅ Markup is repeated in 2+ places
- ✅ A section is self-contained (nav, footer, form)
- ✅ Code exceeds 50-100 lines and has clear boundaries

#### Create a Helper When:
- ✅ View logic is repeated across multiple views
- ✅ Complex formatting/display logic clutters templates
- ✅ Conditional HTML classes/attributes are complex

#### Create a Concern When:
- ✅ Multiple models share the same behavior
- ✅ Controller logic is repeated across controllers
- ✅ Code is cohesive and belongs together

### Anti-Patterns to Avoid

❌ **Don't duplicate entire files** when only small sections differ
❌ **Don't copy-paste code blocks** without extracting to methods/partials
❌ **Don't write inline SQL** when scopes or ActiveRecord methods exist
❌ **Don't repeat validation rules** across models
❌ **Don't duplicate layout declarations** across controllers
❌ **Don't create similar views** without considering partials first

### Decision Making Process

When adding new features, ask:

1. **Does similar code already exist?** → Reuse or extract it
2. **Will this code be repeated?** → Extract it proactively
3. **Can I use a callback/scope/helper?** → Prefer Rails conventions
4. **Is there a simpler way?** → Favor simplicity over cleverness
5. **Does this follow project patterns?** → Check existing implementations

### Examples from This Project

#### ✅ Good: Consolidated Layout
```ruby
# application.html.erb uses conditional rendering
<% if controller_name.in?(%w[sessions passwords]) %>
  <!-- Simple layout -->
<% else %>
  <!-- Full layout -->
<% end %>
```

#### ✅ Good: Shared Form Partial
```ruby
# Both new.html.erb and edit.html.erb use:
<%= render "form" %>
```

#### ✅ Good: Controller Inheritance
```ruby
# All admin controllers inherit from Admin::BaseController
class Admin::BooksController < Admin::BaseController
  # Automatically gets layout, authentication, etc.
end
```

#### ✅ Good: Reusable Scopes
```ruby
# Model scopes used across controllers and views
Book.featured.limit(6)
SportActivity.personal_records.crossfit
```

#### ❌ Bad: Separate Identical Layouts
```ruby
# DON'T create portfolio.html.erb and public.html.erb 
# when they're 95% identical
# INSTEAD: Use conditional rendering in application.html.erb
```

#### ❌ Bad: Repeated Query Logic
```ruby
# DON'T repeat this in multiple places:
Book.where(featured: true).order(read_date: :desc)

# DO create a scope:
scope :featured, -> { where(featured: true).order(read_date: :desc) }
```

### Testing DRY Principles

Before committing, ask:
- [ ] Could any code be extracted to a partial/helper/method?
- [ ] Am I repeating logic from elsewhere in the codebase?
- [ ] Could future changes require updating multiple places?
- [ ] Is there a Rails convention I should use instead?

### Resources

- [Rails Guides - Layouts and Rendering](https://guides.rubyonrails.org/layouts_and_rendering.html)
- [Rails Guides - Active Record Callbacks](https://guides.rubyonrails.org/active_record_callbacks.html)
- [The Rails Doctrine - Convention over Configuration](https://rubyonrails.org/doctrine)
