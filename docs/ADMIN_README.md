# Admin Panel Documentation

## 📋 Overview

This application has **two distinct areas**:

### 1. **PUBLIC SITE** (Portfolio/Homepage)
- **URL:** `https://yoursite.com/`
- **Purpose:** Public-facing portfolio showcasing projects, sports, books, gear, and blog
- **Access:** Anyone can view
- **Controllers:** `HomeController`, `SportsController`, `BooksController`, `GearItemsController`, `ProjectsController`, `BlogPostsController`
- **Layout:** `app/views/layouts/portfolio.html.erb`

### 2. **ADMIN PANEL** (Content Management)
- **URL:** `https://yoursite.com/admin`
- **Purpose:** Manage all content (CRUD operations)
- **Access:** **Requires authentication** (login required)
- **Controllers:** `Admin::DashboardController`, `Admin::SportActivitiesController`, etc.
- **Layout:** `app/views/layouts/admin.html.erb`

---

## 🔐 Authentication

### Default Admin Credentials
```
Email: admin@example.com
Password: password
```

**⚠️ IMPORTANT:** Change this password after first login!

### How to Login
1. Visit `/admin` or click any admin link
2. You'll be redirected to `/session/new` (login page)
3. Enter your email and password
4. Access the admin dashboard

### How to Logout
- Click "Sign Out" in the admin sidebar
- Or visit `/session` and delete

---

## 📁 File Structure

```
app/
├── controllers/
│   ├── PUBLIC SITE CONTROLLERS
│   ├── home_controller.rb              # Homepage
│   ├── sports_controller.rb            # Sports pages
│   ├── books_controller.rb             # Books page
│   ├── gear_items_controller.rb        # Gear page
│   ├── projects_controller.rb          # Projects page
│   ├── blog_posts_controller.rb        # Blog pages
│   │
│   ├── AUTHENTICATION
│   ├── sessions_controller.rb          # Login/logout
│   ├── passwords_controller.rb         # Password reset
│   │
│   └── admin/                          # ADMIN PANEL
│       ├── base_controller.rb          # Base with authentication check
│       ├── dashboard_controller.rb     # Admin homepage
│       ├── sport_activities_controller.rb
│       ├── books_controller.rb
│       ├── gear_items_controller.rb
│       ├── projects_controller.rb
│       ├── blog_posts_controller.rb
│       └── social_links_controller.rb
│
├── views/
│   ├── layouts/
│   │   ├── portfolio.html.erb         # Public site layout
│   │   └── admin.html.erb             # Admin panel layout
│   │
│   ├── PUBLIC SITE VIEWS
│   ├── home/
│   ├── sports/
│   ├── books/
│   ├── gear_items/
│   ├── projects/
│   ├── blog_posts/
│   │
│   ├── AUTHENTICATION VIEWS
│   ├── sessions/
│   └── passwords/
│   │
│   └── admin/                         # ADMIN PANEL VIEWS
│       ├── dashboard/
│       ├── sport_activities/
│       ├── books/
│       ├── gear_items/
│       ├── projects/
│       ├── blog_posts/
│       └── social_links/
│
└── models/
    ├── user.rb                        # Admin user
    ├── session.rb                     # User sessions
    ├── sport_activity.rb              # Content models
    ├── book.rb
    ├── gear_item.rb
    ├── project.rb
    ├── blog_post.rb
    └── social_link.rb
```

---

## 🛣️ Routes

### Public Site Routes
```ruby
GET  /                      # Homepage (home#index)
GET  /sports                # Sports index (sports#index)
GET  /sports/:id            # Individual sport (sports#show)
GET  /books                 # Books list (books#index)
GET  /gear                  # Gear list (gear_items#index)
GET  /projects              # Projects list (projects#index)
GET  /blog                  # Blog index (blog_posts#index)
GET  /blog/:slug            # Individual post (blog_posts#show)
```

### Authentication Routes
```ruby
GET    /session/new         # Login page
POST   /session             # Create session (login)
DELETE /session             # Destroy session (logout)
GET    /passwords/new       # Password reset request
POST   /passwords           # Send reset email
GET    /passwords/:token/edit  # Password reset form
PATCH  /passwords/:token    # Update password
```

### Admin Panel Routes
```ruby
GET  /admin                          # Admin dashboard

# Sport Activities
GET    /admin/sport_activities       # List all
GET    /admin/sport_activities/new   # New form
POST   /admin/sport_activities       # Create
GET    /admin/sport_activities/:id   # Show
GET    /admin/sport_activities/:id/edit  # Edit form
PATCH  /admin/sport_activities/:id   # Update
DELETE /admin/sport_activities/:id   # Delete

# Books (same pattern)
GET    /admin/books
GET    /admin/books/new
POST   /admin/books
...

# Gear Items (same pattern)
GET    /admin/gear_items
...

# Projects (same pattern)
GET    /admin/projects
...

# Blog Posts (same pattern)
GET    /admin/blog_posts
...

# Social Links (same pattern)
GET    /admin/social_links
...
```

---

## 🔒 Admin Base Controller

All admin controllers inherit from `Admin::BaseController`:

```ruby
class Admin::BaseController < ApplicationController
  layout "admin"                      # Use admin layout
  before_action :require_authentication  # Must be logged in
  before_action :set_no_cache_headers   # No caching for admin
end
```

This ensures:
- ✅ All admin pages require login
- ✅ Admin pages use the admin layout
- ✅ Admin pages aren't cached

---

## 🎨 Layouts

### Portfolio Layout (`layouts/portfolio.html.erb`)
- Dark theme design
- Navigation: Home, Sports, Projects, Books, Gear, Blog
- Used for all public pages
- Footer with social links

### Admin Layout (`layouts/admin.html.erb`)
- Light dashboard design
- Sidebar navigation for all admin sections
- Stats and quick actions
- "View Site" and "Sign Out" buttons

---

## 📊 Admin Dashboard Features

The admin dashboard (`/admin`) shows:

### Statistics Cards
- Sport Activities count
- Books count (+ featured count)
- Gear Items count
- Projects count (+ active count)
- Blog Posts count (+ published/draft split)
- Social Links count

### Quick Stats
- Total blog views
- Published posts count
- Featured books count

### Recent Activity
- Latest 5 blog posts
- Latest 5 projects
- Latest 5 books
- Latest 5 sport activities

### Quick Actions
- Fast links to create new content in any section

---

## 🚀 Creating New Admin CRUD Resources

If you need to add a new content type to the admin panel:

1. **Generate the controller:**
   ```bash
   rails generate controller Admin::ResourceName --skip-routes
   ```

2. **Make it inherit from Admin::BaseController:**
   ```ruby
   class Admin::ResourceNameController < Admin::BaseController
     # CRUD actions here
   end
   ```

3. **Add to routes:**
   ```ruby
   namespace :admin do
     resources :resource_names
   end
   ```

4. **Add to admin sidebar** in `layouts/admin.html.erb`

5. **Add to dashboard stats** in `admin/dashboard_controller.rb`

---

## 🔑 User Management

### Creating New Admin Users

Via Rails console:
```ruby
rails console

User.create!(
  email_address: "newemail@example.com",
  password: "securepassword",
  password_confirmation: "securepassword"
)
```

Via seeds file (`db/seeds.rb`):
```ruby
User.create!(
  email_address: "admin@example.com",
  password: "password",
  password_confirmation: "password"
)
```

### Changing Password

Via Rails console:
```ruby
user = User.find_by(email_address: "admin@example.com")
user.update!(password: "newpassword", password_confirmation: "newpassword")
```

---

## 🛡️ Security Notes

1. **Authentication Required:** All `/admin/*` routes require login
2. **Session-based:** Uses Rails session cookies
3. **Password Hashing:** Uses bcrypt for secure password storage
4. **CSRF Protection:** Enabled by default in Rails
5. **No Public Registration:** Only admins can create users (no signup page)

---

## 📝 Common Tasks

### Seeding Admin User
```bash
rails db:seed
```

### Resetting Database with Admin User
```bash
rails db:reset
# This will drop, create, migrate, and seed (including admin user)
```

### Accessing Admin Panel
1. Start server: `bin/dev`
2. Visit: `http://localhost:3000/admin`
3. Login with credentials
4. Manage content

### Testing Authentication
```ruby
# In rails console
user = User.first
user.authenticate("password")  # Returns user if valid, false if invalid
```

---

## 🐛 Troubleshooting

### "You must be signed in" error
- You're not logged in
- Your session expired
- Solution: Go to `/session/new` and login

### Can't access admin routes
- Check `Admin::BaseController` has `before_action :require_authentication`
- Check your controller inherits from `Admin::BaseController`
- Check you're logged in

### Admin layout not showing
- Check controller has `layout "admin"` or inherits from `Admin::BaseController`
- Check `app/views/layouts/admin.html.erb` exists

---

## 📚 Related Documentation

- Main project plan: `KITZE_REPLICA_PLAN.md`
- Rails authentication: Built-in Rails 8 authentication
- Models: See individual model files for validations and scopes

---

## 🎯 Summary

**Simple Rule:**
- **Public Site** = Portfolio for visitors (`/`, `/sports`, `/blog`, etc.)
- **Admin Panel** = Content management for you (`/admin/*`)
- **Authentication** = Login system to protect admin panel
