# Kitze.io Replica - Complete Implementation Plan

## 📋 Project Overview

This document outlines the complete step-by-step plan to create a replica of Kitze.io, a modern portfolio website showcasing projects, talks, blog posts, and content.

**Original Site:** https://www.kitze.io/
**Target Stack:** Rails 8, Turbo, Tailwind CSS

---

## 🎨 Design Analysis

### Key Design Elements
1. **Dark theme** with modern aesthetics
2. **Hero section** with animated gradient text
3. **Card-based layouts** for projects/content
4. **Grid systems** for project showcases
5. **Interactive elements** (hover effects, animations)
6. **Social proof** (follower counts, stats)
7. **Multi-section layout** (talks, projects, blog, YouTube)

### Color Scheme
```css
- Background: Dark (#0a0a0a to #1a1a1a)
- Text: Light (#ffffff, #e5e5e5)
- Accent: Gradient (purple/pink/blue)
- Cards: Semi-transparent with backdrop blur
- Borders: Subtle gradients
```

### Typography
- Modern sans-serif font (Inter, Outfit, or similar)
- Large hero text (4xl-8xl)
- Good contrast and hierarchy
- Proper line heights and spacing

---

## 📐 Site Structure

### Sections Identified
1. **Header/Navigation** - Logo, dark mode toggle, menu
2. **Hero Section** - Introduction with animated roles
3. **Social Stats Bar** - Follower counts and links
4. **Sports Section** - Fitness activities and achievements
   - **Crossfit** - Benchmarks, Results, Next Events
   - **Hyrox** - Benchmarks, Results, Next Events
   - **Running** - Benchmarks, Results, Next Events
5. **Startups Section** - Featured products with descriptions
6. **Side Projects Grid** - Experiment showcase
7. **Books Section** - Reading reviews, notes, and affiliate links
8. **Gear Section** - Equipment recommendations with affiliate links
9. **Blog/Writing** - Article list with excerpts
10. **Footer** - Social links, contact, newsletter

---

## 🗄️ Phase 1: Data Models

### Models to Create

#### 1. SportActivity Model
```ruby
# app/models/sport_activity.rb
class SportActivity < ApplicationRecord
  # Fields:
  # - sport_type:string (crossfit, hyrox, running)
  # - category:string (benchmark, result, event)
  # - title:string
  # - description:text
  # - value:string (time, weight, distance)
  # - unit:string (minutes, kg, km)
  # - date:date
  # - event_name:string (for upcoming events)
  # - location:string (for events)
  # - result_url:string (link to proof/certificate)
  # - personal_record:boolean
  
  validates :sport_type, :category, :title, presence: true
  
  scope :crossfit, -> { where(sport_type: 'crossfit') }
  scope :hyrox, -> { where(sport_type: 'hyrox') }
  scope :running, -> { where(sport_type: 'running') }
  scope :benchmarks, -> { where(category: 'benchmark') }
  scope :results, -> { where(category: 'result').order(date: :desc) }
  scope :events, -> { where(category: 'event').order(date: :asc) }
  scope :personal_records, -> { where(personal_record: true) }
end
```

#### 2. Book Model
```ruby
# app/models/book.rb
class Book < ApplicationRecord
  # Fields:
  # - title:string
  # - author:string
  # - cover_url:string
  # - affiliate_link:string
  # - review:text
  # - notes:text
  # - rating:integer (1-5 stars)
  # - read_date:date
  # - isbn:string
  # - category:string (business, tech, fiction, etc.)
  # - featured:boolean
  
  validates :title, :author, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  
  scope :reviewed, -> { where.not(review: nil).order(read_date: :desc) }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) }
end
```

#### 3. GearItem Model
```ruby
# app/models/gear_item.rb
class GearItem < ApplicationRecord
  # Fields:
  # - name:string
  # - description:text
  # - category:string (tech, fitness, everyday, etc.)
  # - affiliate_link:string
  # - image_url:string
  # - price:decimal
  # - featured:boolean
  # - position:integer
  
  validates :name, :category, presence: true
  
  scope :featured, -> { where(featured: true).order(position: :asc) }
  scope :by_category, ->(category) { where(category: category).order(position: :asc) }
end
```

#### 4. Project Model
```ruby
# app/models/project.rb
class Project < ApplicationRecord
  # Fields:
  # - name:string
  # - description:text
  # - url:string
  # - logo_url:string
  # - project_type:string (startup, side_project, experiment)
  # - featured:boolean
  # - tech_stack:text (JSON array)
  # - status:string (active, archived, in_development)
  # - position:integer (for ordering)
  
  validates :name, :project_type, presence: true
  
  scope :startups, -> { where(project_type: 'startup').order(position: :asc) }
  scope :side_projects, -> { where(project_type: 'side_project').order(position: :asc) }
  scope :featured, -> { where(featured: true).order(position: :asc) }
end
```

#### 5. BlogPost Model
```ruby
# app/models/blog_post.rb
class BlogPost < ApplicationRecord
  # Fields:
  # - title:string
  # - slug:string
  # - excerpt:text
  # - content:text
  # - published_at:datetime
  # - viral:boolean
  # - featured:boolean
  # - views_count:integer
  # - reading_time:integer (minutes)
  
  validates :title, :slug, :content, presence: true
  validates :slug, uniqueness: true
  
  scope :published, -> { where.not(published_at: nil).order(published_at: :desc) }
  scope :viral, -> { where(viral: true) }
  
  before_validation :generate_slug
  before_save :calculate_reading_time
  
  private
  
  def generate_slug
    self.slug ||= title.parameterize if title.present?
  end
  
  def calculate_reading_time
    # Approximately 200 words per minute
    words = content.split.size
    self.reading_time = (words / 200.0).ceil
  end
end
```

#### 6. SocialLink Model
```ruby
# app/models/social_link.rb
class SocialLink < ApplicationRecord
  # Fields:
  # - platform:string (twitter, youtube, github, etc.)
  # - url:string
  # - follower_count:integer
  # - username:string
  # - display_in_header:boolean
  
  validates :platform, :url, presence: true
  
  scope :header_links, -> { where(display_in_header: true) }
end
```

---

## 🏗️ Phase 2: Controllers & Routes

### Routes Structure
```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "portfolio#index"
  
  # Portfolio sections (if split into separate pages)
  get "projects", to: "portfolio#projects"
  get "sports", to: "portfolio#sports"
  get "sports/:sport_type", to: "portfolio#sport_detail", as: :sport_detail
  get "books", to: "portfolio#books"
  get "gear", to: "portfolio#gear"
  get "blog", to: "blog_posts#index"
  get "blog/:slug", to: "blog_posts#show", as: :blog_post
  
  # Admin namespace
  namespace :admin do
    root "dashboard#index"
    resources :sport_activities
    resources :books
    resources :gear_items
    resources :projects
    resources :blog_posts
    resources :social_links
  end
  
  # API endpoints (optional)
  namespace :api do
    namespace :v1 do
      resources :projects, only: [:index, :show]
      resources :blog_posts, only: [:index, :show]
      resources :sport_activities, only: [:index, :show]
      resources :books, only: [:index, :show]
      resources :gear_items, only: [:index, :show]
    end
  end
end
```

### Controllers to Create
1. `PortfolioController` - Main landing page, sports, books, gear sections
2. `BlogPostsController` - Blog listing and individual posts
3. `Admin::SportActivitiesController` - Manage sport activities
4. `Admin::BooksController` - Manage books
5. `Admin::GearItemsController` - Manage gear items
6. `Admin::ProjectsController` - Manage projects
7. `Admin::BlogPostsController` - Manage blog posts
8. `Admin::SocialLinksController` - Manage social links

---

## 🎨 Phase 3: Frontend Structure (Step-by-Step)

### Step 1: Create Portfolio Layout
**File:** `app/views/layouts/portfolio.html.erb`

**Features:**
- Dark theme by default
- Minimal navigation header
- Dark mode toggle button
- Smooth scroll behavior
- Footer with social links
- No sidebar (unlike dashboard layout)

**Implementation:**
```erb
<!DOCTYPE html>
<html class="dark scroll-smooth">
  <head>
    <title><%= content_for(:title) || "Your Name - Developer, Creator, Educator" %></title>
    <!-- Meta tags, stylesheets, etc. -->
  </head>
  <body class="bg-gray-950 text-gray-100">
    <%= render "shared/navigation" %>
    
    <main class="min-h-screen">
      <%= yield %>
    </main>
    
    <%= render "shared/footer" %>
  </body>
</html>
```

---

### Step 2: Hero Section
**File:** `app/views/portfolio/_hero.html.erb`

**Components:**
- Large "Hi, I'm [Name]" heading
- Animated role carousel (Developer/Creator/Educator)
- Bio paragraph
- Location tagline
- Social stats bar

**Key Features:**
- Gradient text animation
- Typing effect for roles (Stimulus controller)
- Responsive font sizes
- Call-to-action buttons

**Tailwind Classes:**
```
- text-7xl md:text-9xl (heading)
- bg-gradient-to-r from-purple-400 via-pink-500 to-red-500
- bg-clip-text text-transparent (gradient text)
- animate-pulse, animate-bounce (subtle animations)
```

---

### Step 3: Social Stats Bar
**File:** `app/views/portfolio/_social_stats.html.erb`

**Display:**
- Twitter followers
- YouTube subscribers
- Newsletter subscribers
- GitHub stars

**Layout:**
- Horizontal bar with icons
- Animated counters
- Links to each platform
- Sticky on scroll (optional)

---

### Step 4: Sports Section
**File:** `app/views/portfolio/_sports.html.erb`

**Layout:**
- Section heading "Sports & Fitness"
- Three sub-sections with tabs: Crossfit, Hyrox, Running
- Each sport shows:
  - **Benchmarks**: Key metrics (Fran time, Back Squat 1RM, 5K time, etc.)
  - **Recent Results**: Latest achievements with dates and PRs highlighted
  - **Next Events**: Upcoming competitions/races with date, location, event name

**Implementation Notes:**
- Use tabs or accordion for each sport
- Display benchmarks as cards with big numbers
- Results timeline with PR badges
- Color coding: Crossfit (orange), Hyrox (blue), Running (green)
- Charts for progress over time (optional)

**Example Data:**
```ruby
@crossfit_benchmarks = SportActivity.crossfit.benchmarks
@crossfit_results = SportActivity.crossfit.results.limit(10)
@crossfit_events = SportActivity.crossfit.events.limit(5)
```

**Styling:**
- Large stat cards for benchmarks
- Timeline for results
- Calendar-style for upcoming events
- PR indicator (trophy icon, gradient highlight)

---

### Step 5: Startups Showcase
**File:** `app/views/portfolio/_startups.html.erb`

**Layout:**
- Section heading "Startups"
- Grid: 1 column mobile, 2-3 columns desktop
- Featured projects get larger cards

**Card Contents:**
- Project logo/icon
- Name (bold, large)
- Description (2-3 lines)
- Tech stack tags
- "Visit" or "Learn More" button
- Screenshot or mockup (optional)

**Styling:**
- Dark cards with subtle border
- Hover: lift effect (scale + shadow)
- Gradient borders
- Glass morphism effect

---

### Step 6: Side Projects Grid
**File:** `app/views/portfolio/_side_projects.html.erb`

**Layout:**
- Section heading "Experiments & Side Projects"
- Masonry grid (4-6 columns on desktop)
- Simple cards with just names
- Hover reveals description

**Interaction:**
- Click to expand modal with details
- Or click to visit external link
- Filter by technology/category
- "Show more" button if many projects

**Styling:**
- Minimal cards
- Colorful accents
- Fast hover transitions
- Compact layout

---

### Step 7: Books Section
**File:** `app/views/portfolio/_books.html.erb`

**Layout:**
- Section heading "Reading List"
- Grid of book cards (2-3 columns)
- Each book shows:
  - Book cover image
  - Title and author
  - Star rating
  - Brief review excerpt
  - "Read Review" and "Buy Now" buttons (affiliate link)
  - Optional: reading notes preview

**Features:**
- Filter by category (Business, Tech, Fiction, etc.)
- Toggle between "Reviews" and "Notes" view
- Expandable review/notes modal
- Featured books highlighted
- Amazon affiliate links

**Styling:**
- Book cover shadows (3D effect)
- Star ratings with color
- Hover effect: lift and show full review preview
- Affiliate disclosure notice

---

### Step 8: Gear Section
**File:** `app/views/portfolio/_gear.html.erb`

**Layout:**
- Section heading "Gear & Setup"
- Grid of gear cards by category
- Categories: Tech, Fitness, Everyday Carry, Desk Setup, etc.
- Each item shows:
  - Product image
  - Name
  - Brief description
  - Price (optional)
  - "Check it out" button (affiliate link)

**Features:**
- Category filter tabs
- Search functionality
- Featured gear highlighted
- Amazon/other affiliate links
- Affiliate disclosure notice

**Styling:**
- Clean product cards
- High-quality images
- Price tags with subtle styling
- Hover: scale and show more details
- Grid layout: 2-4 columns responsive

---

### Step 9: Blog/Writing Section
**File:** `app/views/portfolio/_blog.html.erb`

**Layout:**
- Section heading "Writer" or "Blog"
- List of recent posts (3-5)
- Each post shows:
  - Published date
  - Title
  - Excerpt (2-3 lines)
  - Tags (Viral, Featured)
  - Read time estimate
  - "Read more" link

**Styling:**
- Timeline-style with date on left
- Hover effect on post cards
- Tag badges with colors
- "Read All Archives" link at bottom

---

### Step 10: Footer
**File:** `app/views/shared/_footer.html.erb`

**Contents:**
- Social media links (icons)
- Newsletter signup form
- Copyright notice
- "Built with [tech stack]" note
- Back to top button

**Styling:**
- Dark background
- Subtle border top
- Centered content
- Icon animations on hover

---

## 🎭 Phase 4: Styling Details

### Component Styles

#### Card Base Style
```css
@apply bg-gray-900/50 backdrop-blur-sm rounded-xl p-6 
       border border-gray-800 
       hover:border-gray-700 hover:shadow-xl hover:scale-105 
       transition-all duration-300;
```

#### Gradient Text
```css
@apply bg-gradient-to-r from-purple-400 via-pink-500 to-red-500 
       bg-clip-text text-transparent;
```

#### Button Primary
```css
@apply bg-gradient-to-r from-purple-600 to-pink-600 
       text-gray-950 px-6 py-3 rounded-lg font-semibold
       hover:from-purple-700 hover:to-pink-700
       transition-all duration-300;
```

#### Section Container
```css
@apply max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16;
```

---

## ⚡ Phase 5: Interactive Features (Stimulus Controllers)

### 1. Dark Mode Toggle
**File:** `app/javascript/controllers/dark_mode_controller.js`

**Features:**
- Toggle dark/light theme
- Persist preference in localStorage
- Smooth transition between themes
- Update all components

### 2. Animated Roles/Titles
**File:** `app/javascript/controllers/typewriter_controller.js`

**Features:**
- Cycle through roles (Developer → Creator → Educator)
- Typing effect animation
- Cursor blink animation
- Loop continuously

### 3. Scroll Animations
**File:** `app/javascript/controllers/scroll_reveal_controller.js`

**Features:**
- Fade-in elements as they scroll into view
- Use Intersection Observer API
- Stagger animations for lists
- Parallax effects (subtle)

### 4. Project Filter
**File:** `app/javascript/controllers/filter_controller.js`

**Features:**
- Filter projects by category
- Search functionality
- Smooth show/hide animations
- Update URL params

### 5. Counter Animation
**File:** `app/javascript/controllers/counter_controller.js`

**Features:**
- Animate social stats numbers
- Count up from 0 to target
- Format large numbers (77K, 7.5K)
- Trigger on scroll into view

### 6. Video Modal
**File:** `app/javascript/controllers/video_modal_controller.js`

**Features:**
- Open video in modal
- Close on outside click or ESC
- Pause video on close
- Keyboard navigation

---

## 🗃️ Phase 6: Admin Interface

### Admin Dashboard
**Layout:** `app/views/layouts/admin.html.erb`
- Use existing dashboard layout
- Sidebar with admin navigation
- CRUD for all models

### Admin Controllers Setup
```ruby
# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  layout "dashboard"
  before_action :authenticate_admin! # Add authentication
  
  private
  
  def authenticate_admin!
    # Add your authentication logic
    # For now, can be simple HTTP Basic Auth
  end
end
```

### Forms
- Use Rails form helpers
- Rich text editor for blog content (Action Text)
- Image upload for project logos
- Date pickers for talks
- URL validation

---

## 📊 Phase 7: Database Migrations

### Migration Files to Create

```ruby
# db/migrate/XXXXXX_create_sport_activities.rb
class CreateSportActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :sport_activities do |t|
      t.string :sport_type, null: false
      t.string :category, null: false
      t.string :title, null: false
      t.text :description
      t.string :value
      t.string :unit
      t.date :date
      t.string :event_name
      t.string :location
      t.string :result_url
      t.boolean :personal_record, default: false
      t.timestamps
    end
    
    add_index :sport_activities, :sport_type
    add_index :sport_activities, :category
    add_index :sport_activities, :date
    add_index :sport_activities, :personal_record
  end
end

# db/migrate/XXXXXX_create_books.rb
class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :cover_url
      t.string :affiliate_link
      t.text :review
      t.text :notes
      t.integer :rating
      t.date :read_date
      t.string :isbn
      t.string :category
      t.boolean :featured, default: false
      t.timestamps
    end
    
    add_index :books, :rating
    add_index :books, :read_date
    add_index :books, :category
    add_index :books, :featured
  end
end

# db/migrate/XXXXXX_create_gear_items.rb
class CreateGearItems < ActiveRecord::Migration[8.1]
  def change
    create_table :gear_items do |t|
      t.string :name, null: false
      t.text :description
      t.string :category, null: false
      t.string :affiliate_link
      t.string :image_url
      t.decimal :price, precision: 10, scale: 2
      t.boolean :featured, default: false
      t.integer :position, default: 0
      t.timestamps
    end
    
    add_index :gear_items, :category
    add_index :gear_items, :featured
    add_index :gear_items, :position
  end
end

# db/migrate/XXXXXX_create_projects.rb
class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.string :url
      t.string :logo_url
      t.string :project_type, null: false
      t.boolean :featured, default: false
      t.text :tech_stack
      t.string :status, default: 'active'
      t.integer :position, default: 0
      t.timestamps
    end
    
    add_index :projects, :project_type
    add_index :projects, :featured
    add_index :projects, :position
  end
end

# db/migrate/XXXXXX_create_blog_posts.rb
class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :excerpt
      t.text :content
      t.datetime :published_at
      t.boolean :viral, default: false
      t.boolean :featured, default: false
      t.integer :views_count, default: 0
      t.integer :reading_time
      t.timestamps
    end
    
    add_index :blog_posts, :slug, unique: true
    add_index :blog_posts, :published_at
    add_index :blog_posts, :viral
  end
end

# db/migrate/XXXXXX_create_social_links.rb
class CreateSocialLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :social_links do |t|
      t.string :platform, null: false
      t.string :url, null: false
      t.integer :follower_count
      t.string :username
      t.boolean :display_in_header, default: true
      t.timestamps
    end
    
    add_index :social_links, :platform
  end
end
```

---

## 🌱 Phase 8: Database Seeding

### Seed File
**File:** `db/seeds.rb`

```ruby
# Clear existing data
[SportActivity, Book, GearItem, Project, BlogPost, SocialLink].each(&:destroy_all)

# Social Links
SocialLink.create([
  { platform: 'twitter', url: 'https://twitter.com/yourhandle', follower_count: 77000, username: '@yourhandle' },
  { platform: 'youtube', url: 'https://youtube.com/@yourchannel', follower_count: 7500, username: 'Your Channel' },
  { platform: 'github', url: 'https://github.com/yourusername', follower_count: 25100, username: 'yourusername' },
])

# Sport Activities - Crossfit
SportActivity.create([
  # Benchmarks
  { sport_type: 'crossfit', category: 'benchmark', title: 'Fran', value: '4:32', unit: 'minutes', description: '21-15-9 Thrusters (95lbs) and Pull-ups' },
  { sport_type: 'crossfit', category: 'benchmark', title: 'Back Squat 1RM', value: '315', unit: 'lbs', description: 'One rep max back squat' },
  { sport_type: 'crossfit', category: 'benchmark', title: 'Deadlift 1RM', value: '405', unit: 'lbs', description: 'One rep max deadlift' },
  
  # Results
  { sport_type: 'crossfit', category: 'result', title: 'Open 24.1', value: '245', unit: 'reps', date: Date.new(2025, 2, 29), personal_record: true, description: 'CrossFit Open workout' },
  { sport_type: 'crossfit', category: 'result', title: 'Murph', value: '43:21', unit: 'minutes', date: Date.new(2025, 5, 27), description: 'Memorial Day Murph' },
  
  # Events
  { sport_type: 'crossfit', category: 'event', title: 'Local Throwdown', event_name: 'City CrossFit Competition', location: 'Local Box', date: Date.new(2025, 6, 15) },
])

# Sport Activities - Hyrox
SportActivity.create([
  # Benchmarks
  { sport_type: 'hyrox', category: 'benchmark', title: 'Best Time', value: '1:24:35', unit: 'hours', description: 'Personal best Hyrox finish time' },
  { sport_type: 'hyrox', category: 'benchmark', title: 'SkiErg 1000m', value: '3:42', unit: 'minutes', description: 'SkiErg benchmark time' },
  
  # Results
  { sport_type: 'hyrox', category: 'result', title: 'Hyrox Chicago', value: '1:28:12', unit: 'hours', date: Date.new(2025, 11, 10), personal_record: false, location: 'Chicago, IL' },
  
  # Events
  { sport_type: 'hyrox', category: 'event', title: 'Hyrox World Championships', event_name: 'Hyrox World Championships', location: 'Nice, France', date: Date.new(2025, 5, 24) },
])

# Sport Activities - Running
SportActivity.create([
  # Benchmarks
  { sport_type: 'running', category: 'benchmark', title: '5K PR', value: '21:34', unit: 'minutes', description: 'Personal record 5K time' },
  { sport_type: 'running', category: 'benchmark', title: 'Half Marathon PR', value: '1:42:18', unit: 'hours', description: 'Personal record half marathon' },
  { sport_type: 'running', category: 'benchmark', title: 'Marathon PR', value: '3:35:42', unit: 'hours', description: 'Personal record marathon' },
  
  # Results
  { sport_type: 'running', category: 'result', title: 'Chicago Marathon', value: '3:42:15', unit: 'hours', date: Date.new(2025, 10, 13), location: 'Chicago, IL' },
  { sport_type: 'running', category: 'result', title: 'Turkey Trot 5K', value: '22:05', unit: 'minutes', date: Date.new(2025, 11, 28) },
  
  # Events
  { sport_type: 'running', category: 'event', title: 'Boston Marathon', event_name: 'Boston Marathon', location: 'Boston, MA', date: Date.new(2025, 4, 21) },
  { sport_type: 'running', category: 'event', title: 'NYC Marathon', event_name: 'TCS New York City Marathon', location: 'New York, NY', date: Date.new(2025, 11, 2) },
])

# Books
Book.create([
  {
    title: 'Atomic Habits',
    author: 'James Clear',
    rating: 5,
    category: 'Self-Help',
    review: 'An incredibly practical guide to building good habits and breaking bad ones. The 1% improvement philosophy is transformative.',
    notes: 'Key takeaway: Focus on systems, not goals. Make it obvious, attractive, easy, and satisfying.',
    read_date: Date.new(2025, 1, 15),
    featured: true,
    affiliate_link: 'https://amazon.com/atomic-habits'
  },
  {
    title: 'The Pragmatic Programmer',
    author: 'David Thomas, Andrew Hunt',
    rating: 5,
    category: 'Tech',
    review: 'A must-read for any software developer. Timeless advice on craftsmanship and professional development.',
    notes: 'DRY principle, orthogonality, tracer bullets, prototyping techniques.',
    read_date: Date.new(2025, 3, 10),
    featured: true,
    affiliate_link: 'https://amazon.com/pragmatic-programmer'
  },
  {
    title: 'Deep Work',
    author: 'Cal Newport',
    rating: 4,
    category: 'Productivity',
    review: 'Excellent framework for focusing on meaningful work in a distracted world.',
    notes: 'Schedule deep work blocks. Embrace boredom. Quit social media (or be intentional).',
    read_date: Date.new(2025, 2, 20),
    featured: false,
    affiliate_link: 'https://amazon.com/deep-work'
  }
])

# Gear Items
GearItem.create([
  # Tech
  {
    name: 'MacBook Pro 16" M3 Max',
    description: 'My primary development machine. Incredible performance for coding and video editing.',
    category: 'tech',
    price: 3499.00,
    featured: true,
    position: 1,
    affiliate_link: 'https://amazon.com/macbook-pro'
  },
  {
    name: 'LG UltraWide 38"',
    description: 'Perfect for development work. Replaces my dual monitor setup.',
    category: 'tech',
    price: 1299.99,
    featured: true,
    position: 2,
    affiliate_link: 'https://amazon.com/lg-ultrawide'
  },
  
  # Fitness
  {
    name: 'Rogue Echo Bike',
    description: 'The best air bike for CrossFit workouts. Built like a tank.',
    category: 'fitness',
    price: 895.00,
    featured: true,
    position: 3,
    affiliate_link: 'https://rogueeurope.eu/rogue-echo-bike'
  },
  {
    name: 'Nike Metcon 9',
    description: 'My go-to CrossFit shoe. Great stability and durability.',
    category: 'fitness',
    price: 150.00,
    featured: false,
    position: 4,
    affiliate_link: 'https://amazon.com/nike-metcon-9'
  },
  {
    name: 'Garmin Forerunner 965',
    description: 'Best running watch. Training metrics are incredibly detailed.',
    category: 'fitness',
    price: 599.99,
    featured: true,
    position: 5,
    affiliate_link: 'https://amazon.com/garmin-forerunner-965'
  },
  
  # Everyday
  {
    name: 'AirPods Pro 2',
    description: 'Perfect for coding sessions and workouts. Noise cancellation is a game changer.',
    category: 'everyday',
    price: 249.00,
    featured: false,
    position: 6,
    affiliate_link: 'https://amazon.com/airpods-pro-2'
  }
])

# Startups
Project.create([
  {
    name: 'Sizzy',
    description: 'Browser built for developers with responsive testing across all devices simultaneously. Test, debug, and design websites in one powerful workspace.',
    url: 'https://sizzy.co',
    project_type: 'startup',
    featured: true,
    tech_stack: ['Electron', 'React', 'Node.js'].to_json
  },
  {
    name: 'Benji',
    description: 'A personal life operating system that helps you organize, track, and optimize every aspect of your life in one beautiful interface.',
    url: 'https://benji.app',
    project_type: 'startup',
    featured: true,
    tech_stack: ['Rails', 'React', 'PostgreSQL'].to_json
  },
  {
    name: 'Zero To Shipped',
    description: 'Interactive video course teaching you to build and ship full-stack applications fast. From idea to production with modern tools and best practices.',
    url: 'https://zerotoshipped.com',
    project_type: 'startup',
    featured: true,
    tech_stack: ['Next.js', 'TypeScript', 'Stripe'].to_json
  }
])

# Side Projects
['Sotto', 'Code DMX', 'Casper', 'Mindy', 'ComeBackLater', 'Kitze UI', 'PalPal', 
 'Mooom', 'Glink', 'Popcorner', 'Mememes', 'Hookz'].each_with_index do |name, index|
  Project.create(
    name: name,
    project_type: 'side_project',
    position: index,
    url: "https://github.com/yourusername/#{name.parameterize}"
  )
end

# Blog Posts
BlogPost.create([
  {
    title: 'GPT-3 is the beginning of the end',
    slug: 'gpt-3-beginning-of-end',
    excerpt: 'Developers are scared of change. But why? Here are my thoughts on how no-code tools, AI, and GPT-3 will change the web development industry as we know it.',
    published_at: Date.new(2020, 7, 22),
    viral: false,
    content: 'Full blog post content here...'
  },
  {
    title: "GitHub stars won't pay your rent",
    slug: 'github-stars-wont-pay-rent',
    excerpt: 'Going from OSS to SaaS. Mistakes made and lessons learned from launching Sizzy - The Browser For Developers.',
    published_at: Date.new(2020, 7, 9),
    viral: true,
    content: 'Full blog post content here...'
  },
  {
    title: 'The saddest "Just Ship It" story ever',
    slug: 'saddest-just-ship-it-story',
    excerpt: 'This is a story of how it took me way too long to ship a product, and I ended up paying for a competitor product instead.',
    published_at: Date.new(2020, 6, 23),
    viral: true,
    content: 'Full blog post content here...'
  }
])

puts "Seeded #{SportActivity.count} sport activities"
puts "Seeded #{Book.count} books"
puts "Seeded #{GearItem.count} gear items"
puts "Seeded #{Project.count} projects"
puts "Seeded #{BlogPost.count} blog posts"
puts "Seeded #{SocialLink.count} social links"
```

---

## 🚀 Phase 9: Implementation Sprints

### Sprint 1: Foundation (Days 1-3)
**Goal:** Basic structure and data models

- [ ] Create all database migrations
- [ ] Create all models with validations
- [ ] Create seeds.rb with sample data
- [ ] Run migrations and seeds
- [ ] Create PortfolioController
- [ ] Create portfolio layout
- [ ] Create basic hero section
- [ ] Test that data is loading

### Sprint 2: Core Sections (Days 4-7)
**Goal:** Build all major content sections

- [ ] Social stats bar component
- [ ] Sports section (Crossfit/Hyrox/Running with tabs)
- [ ] Startups showcase section
- [ ] Side projects grid
- [ ] Books section with reviews and affiliate links
- [ ] Gear section with product cards and affiliate links
- [ ] Blog/writing section
- [ ] Footer component

### Sprint 3: Styling & Design (Days 8-10)
**Goal:** Make it beautiful

- [ ] Implement dark theme colors
- [ ] Style all cards with glass morphism
- [ ] Add gradient text effects
- [ ] Create hover states for all interactive elements
- [ ] Implement responsive design (mobile/tablet/desktop)
- [ ] Add custom fonts
- [ ] Create gradient borders
- [ ] Add subtle shadows and lighting effects

### Sprint 4: Interactivity (Days 11-13)
**Goal:** Add dynamic features

- [ ] Dark mode toggle (Stimulus)
- [ ] Animated role carousel (Stimulus)
- [ ] Scroll reveal animations (Stimulus)
- [ ] Counter animations for social stats
- [ ] Project filtering
- [ ] Video modal
- [ ] Smooth scroll navigation
- [ ] Loading states

### Sprint 5: Admin Interface (Days 14-16)
**Goal:** Content management

- [ ] Admin authentication
- [ ] Admin layout/navigation
- [ ] Sport activities CRUD interface
- [ ] Books CRUD interface (with review and notes fields)
- [ ] Gear items CRUD interface
- [ ] Projects CRUD interface
- [ ] Blog posts CRUD interface
- [ ] Rich text editor for blog and reviews (Action Text)
- [ ] Image upload for gear items and book covers

### Sprint 6: Polish & Optimization (Days 17-19)
**Goal:** Performance and final touches

- [ ] Image optimization and lazy loading
- [ ] Tailwind CSS purging
- [ ] Page meta tags and SEO
- [ ] Open Graph images
- [ ] Performance audit
- [ ] Mobile testing
- [ ] Browser compatibility testing
- [ ] Accessibility audit (WCAG)

### Sprint 7: Advanced Features (Optional)
**Goal:** Nice-to-haves

- [ ] Newsletter integration
- [ ] RSS feeds
- [ ] Full-text search
- [ ] Analytics integration
- [ ] API endpoints
- [ ] Rate limiting
- [ ] Sitemap generation
- [ ] robots.txt

---

## 🛠️ Technical Requirements

### Gems to Add
```ruby
# Gemfile additions
gem 'friendly_id', '~> 5.5'           # Slugs for blog posts
gem 'pagy', '~> 6.0'                  # Pagination
gem 'redcarpet', '~> 3.6'             # Markdown rendering
gem 'acts-as-taggable-on', '~> 10.0'  # Tagging system
gem 'view_component', '~> 3.0'        # View components (optional)
gem 'chartkick', '~> 5.0'             # Charts for sports progress (optional)
gem 'groupdate', '~> 6.0'             # Group data by date for charts

group :development do
  gem 'faker', '~> 3.2'                # Fake data for seeds
end
```

### Stimulus Controllers Needed
1. `dark_mode_controller.js` - Theme toggle
2. `typewriter_controller.js` - Animated text
3. `scroll_reveal_controller.js` - Fade-in animations
4. `counter_controller.js` - Number animations
5. `filter_controller.js` -

### Tailwind Configuration
```javascript
// config/tailwind.config.js
module.exports = {
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#faf5ff',
          // ... gradient colors
          900: '#4c1d95',
        }
      },
      animation: {
        'gradient': 'gradient 8s linear infinite',
        'float': 'float 3s ease-in-out infinite',
      },
      keyframes: {
        gradient: {
          '0%, 100%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-10px)' },
        }
      }
    }
  }
}
```

---

## 📱 Responsive Breakpoints

```css
/* Mobile First Approach */
- Mobile: default (< 640px)
- Tablet: sm: (640px)
- Desktop: md: (768px), lg: (1024px)
- Large: xl: (1280px), 2xl: (1536px)

/* Section Layouts */
Hero: Full width, centered
Stats Bar: Stack vertical on mobile, horizontal on desktop
Talks: 1 column mobile, 2 columns tablet, 3 columns desktop
Startups: 1 column mobile, 2 columns tablet, 3 columns desktop
Side Projects: 2 columns mobile, 4 columns tablet, 6 columns desktop
Blog: 1 column all sizes (with varying widths)
```

---

## ♿ Accessibility Checklist

- [ ] Semantic HTML5 elements
- [ ] Proper heading hierarchy (h1 → h2 → h3)
- [ ] Alt text for all images
- [ ] ARIA labels for interactive elements
- [ ] Keyboard navigation support
- [ ] Focus indicators visible
- [ ] Color contrast ratios meet WCAG AA
- [ ] Skip to content link
- [ ] Screen reader tested

---

## 🔍 SEO Checklist

- [ ] Dynamic meta titles and descriptions
- [ ] Open Graph tags for social sharing
- [ ] Twitter card meta tags
- [ ] Structured data (JSON-LD)
- [ ] XML sitemap
- [ ] robots.txt
- [ ] Canonical URLs
- [ ] Fast page load (< 3s)
- [ ] Mobile-friendly
- [ ] HTTPS enabled

---

## 📈 Performance Targets

- Lighthouse Score: 90+ in all categories
- First Contentful Paint: < 1.5s
- Largest Contentful Paint: < 2.5s
- Time to Interactive: < 3.5s
- Total Page Size: < 500KB (initial load)
- Images: WebP format, lazy loaded
- CSS: Purged and minified
- JS: Code splitting, async loading

---

## 🚢 Deployment Checklist

- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] Seeds run (if needed)
- [ ] Assets precompiled
- [ ] SSL certificate installed
- [ ] Domain configured
- [ ] CDN setup (Cloudflare)
- [ ] Error tracking (Sentry/Honeybadger)
- [ ] Analytics installed (Plausible/Google Analytics)
- [ ] Backup strategy configured
- [ ] Monitoring setup (Uptime Robot)

---

## 📚 Resources & References

### Design Inspiration
- https://www.kitze.io/ (original)
- https://leerob.io/
- https://brittanychiang.com/
- https://dribbble.com/tags/portfolio

### Tailwind Components
- https://tailwindui.com/
- https://www.hyperui.dev/
- https://flowbite.com/
- https://daisyui.com/

### Animation Libraries (Optional)
- GSAP (for complex animations)
- Framer Motion (if using React)
- AOS (Animate On Scroll)
- Lottie (for animations)

### Icons
- Heroicons (recommended - matches Tailwind)
- Font Awesome
- Lucide Icons
- Simple Icons (for brand logos)
