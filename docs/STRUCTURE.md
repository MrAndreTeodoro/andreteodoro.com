# Application Structure

## Two Separate Areas

```
┌─────────────────────────────────────────────────────────────────┐
│                    YOUR APPLICATION                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │
                ┌─────────────┴──────────────┐
                │                            │
                ▼                            ▼
┌───────────────────────────┐  ┌────────────────────────────┐
│   PUBLIC SITE             │  │   ADMIN PANEL              │
│   (Portfolio)             │  │   (Content Management)     │
├───────────────────────────┤  ├────────────────────────────┤
│ URL: /                    │  │ URL: /admin                │
│ Layout: portfolio.html    │  │ Layout: admin.html         │
│ Access: Public            │  │ Access: 🔒 Login Required  │
├───────────────────────────┤  ├────────────────────────────┤
│ Controllers:              │  │ Controllers:               │
│ - HomeController          │  │ - Admin::DashboardController│
│ - SportsController        │  │ - Admin::SportActivities...│
│ - BooksController         │  │ - Admin::Books...          │
│ - GearItemsController     │  │ - Admin::GearItems...      │
│ - ProjectsController      │  │ - Admin::Projects...       │
│ - BlogPostsController     │  │ - Admin::BlogPosts...      │
│                           │  │ - Admin::SocialLinks...    │
└───────────────────────────┘  └────────────────────────────┘
```

## Controller Naming

### ✅ PUBLIC (No Namespace)
- `HomeController` → `/`
- `SportsController` → `/sports`
- `BooksController` → `/books`
- `GearItemsController` → `/gear`
- `ProjectsController` → `/projects`
- `BlogPostsController` → `/blog`

### ✅ ADMIN (Admin:: Namespace)
- `Admin::DashboardController` → `/admin` (dashboard homepage)
- `Admin::SportActivitiesController` → `/admin/sport_activities`
- `Admin::BooksController` → `/admin/books`
- `Admin::GearItemsController` → `/admin/gear_items`
- `Admin::ProjectsController` → `/admin/projects`
- `Admin::BlogPostsController` → `/admin/blog_posts`
- `Admin::SocialLinksController` → `/admin/social_links`

### ✅ AUTHENTICATION (No Namespace)
- `SessionsController` → `/session` (login/logout)
- `PasswordsController` → `/passwords` (reset)

## Files Location

```
app/
├── controllers/
│   ├── home_controller.rb              ← PUBLIC
│   ├── sports_controller.rb            ← PUBLIC
│   ├── books_controller.rb             ← PUBLIC
│   ├── gear_items_controller.rb        ← PUBLIC
│   ├── projects_controller.rb          ← PUBLIC
│   ├── blog_posts_controller.rb        ← PUBLIC
│   ├── sessions_controller.rb          ← AUTH
│   ├── passwords_controller.rb         ← AUTH
│   └── admin/                          ← ADMIN
│       ├── base_controller.rb          ← ADMIN BASE
│       ├── dashboard_controller.rb     ← ADMIN
│       ├── sport_activities_controller.rb
│       ├── books_controller.rb
│       ├── gear_items_controller.rb
│       ├── projects_controller.rb
│       ├── blog_posts_controller.rb
│       └── social_links_controller.rb
```

## Summary

**CLEAR SEPARATION:**
- **Public** = Show content to visitors
- **Admin** = Manage content (login required)
- **Admin::Dashboard** = Admin homepage (not a separate app)

**No more confusion!** ✨
