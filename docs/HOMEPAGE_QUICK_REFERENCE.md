# Homepage Quick Reference Guide

## 🎯 Quick Links

- **View File**: `app/views/home/index.html.erb`
- **Controller**: `app/controllers/home_controller.rb`
- **Layout**: `app/views/layouts/application.html.erb` (lines 49-223 modified)
- **Route**: `root GET / home#index`

---

## 📐 Layout Structure

```
┌─────────┬──────────────┬─────────────────────┐
│ Sidebar │ Profile Card │   Main Content      │
│  80px   │    320px     │  Flexible (1024px)  │
└─────────┴──────────────┴─────────────────────┘
```

---

## 🔧 Common Tasks

### Add New Sidebar Icon

**Location**: Lines 3-70 in `index.html.erb`

```erb
<%= link_to your_path, class: "p-3 rounded-lg #{controller_name == 'your_controller' ? 'bg-gray-900 text-white' : 'text-gray-600 hover:bg-gray-100'} transition-colors" do %>
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <!-- Your SVG path here -->
  </svg>
<% end %>
```

### Update Profile Bio

**Location**: Lines 109-113

```erb
<p class="text-gray-600 text-sm mb-4">
  Your new bio text here.
</p>
```

### Change Avatar

**Location**: Line 87-90

```erb
<div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white text-2xl font-bold">
  AT <!-- Change initials here -->
</div>
```

### Add New Content Section

**Pattern** (add after line 341):

```erb
<div class="mb-16">
  <div class="flex items-center justify-between mb-6">
    <h2 class="text-2xl font-bold text-gray-900">Section Title</h2>
    <%= link_to "View All →", your_path, class: "text-blue-600 hover:text-blue-700 transition-colors font-semibold text-sm" %>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
    <!-- Your cards here -->
  </div>
</div>
```

### Modify Action Buttons

**Location**: Lines 224-237

```erb
<div class="space-y-3">
  <button class="w-full bg-gray-900 text-white rounded-lg py-3 px-4 font-semibold hover:bg-gray-800 transition-colors flex items-center justify-center space-x-2">
    <!-- Icon -->
    <span>Button Text</span>
  </button>
</div>
```

---

## 🎨 Design Tokens

### Colors

```css
/* Backgrounds */
bg-gray-50     /* Page background */
bg-white       /* Cards, sidebar */
bg-gray-900    /* Active nav, primary button */

/* Borders */
border-gray-200  /* Default borders */
border-gray-300  /* Hover borders */

/* Text */
text-gray-900    /* Primary text */
text-gray-600    /* Secondary text */
text-gray-500    /* Tertiary text */
text-blue-600    /* Links */

/* Gradient */
from-blue-600 via-purple-600 to-pink-600
```

### Spacing

```css
/* Sections */
mb-16  /* Between major sections (64px) */
mb-6   /* Between subsections (24px) */
space-y-6  /* Vertical spacing in sidebar */

/* Cards */
p-6    /* Card padding (24px) */
gap-6  /* Grid gap (24px) */
```

### Typography

```css
/* Hero Name */
text-6xl md:text-7xl font-bold  /* 60-72px */

/* Hero Roles */
text-3xl md:text-4xl font-semibold  /* 30-36px */

/* Section Headers */
text-2xl font-bold  /* 24px */

/* Card Titles */
text-base to text-lg font-bold  /* 16-18px */

/* Body Text */
text-sm  /* 14px */

/* Metadata */
text-xs  /* 12px */
```

### Interactive States

```css
/* Hover */
hover:border-gray-300
hover:shadow-lg
hover:bg-gray-100

/* Active Navigation */
bg-gray-900 text-white

/* Transitions */
transition-colors
transition-all duration-300
```

---

## 📊 Data Sources

### Controller Variables

```ruby
@social_links          # SocialLink.header_links
@crossfit_benchmarks   # SportActivity.crossfit.benchmarks.limit(3)
@hyrox_benchmarks      # SportActivity.hyrox.benchmarks.limit(3)
@running_benchmarks    # SportActivity.running.benchmarks.limit(3)
@upcoming_events       # SportActivity.events.where("date >= ?", Date.today).limit(3)
@featured_projects     # Project.featured.startups.limit(3)
@side_projects         # Project.side_projects.limit(12)
@featured_books        # Book.featured.limit(3)
@featured_gear         # GearItem.featured.limit(6)
@recent_posts          # BlogPost.published.recent
```

### Usage Limits

```
Sidebar Icons:         9 visible + 2 bottom
Social Links:          First 4 for icons, first 3 for stats
Upcoming Events:       3 events (from controller)
Startups:              3 projects
Side Projects:         10 displayed (12 loaded)
Recent Posts:          3 posts
Sport Benchmarks:      2 per sport (3 loaded)
Books:                 3 books
Gear Items:            4 items (6 loaded)
```

---

## 🔍 Key Selectors

### Finding Components

```erb
<!-- Sidebar Navigation -->
Lines 2-70

<!-- Profile Card -->
Lines 74-238
  - Avatar: 85-96
  - Social Icons: 97-112
  - Stats: 116-128
  - Upcoming Events: 132-150
  - Startups: 153-172
  - Side Projects: 175-195
  - Recent Posts: 198-210
  - Action Buttons: 213-231

<!-- Main Content -->
Lines 241-392
  - Hero: 244-261
  - Sports: 264-340
  - Books: 343-360
  - Gear: 363-389
```

---

## ⚡ Performance Tips

1. **Fixed Positioning**: Sidebar and profile card use fixed positioning for performance
2. **Limit Data**: Controller already limits queries (use `.limit()`)
3. **Inline SVGs**: No external icon files to load
4. **CSS Grid**: Hardware-accelerated layout
5. **Lazy Loading**: Consider adding `loading="lazy"` to images

---

## 🐛 Common Issues

### Issue: Sidebar Icons Not Highlighting

**Check**: Active state conditional in icon link
```erb
#{controller_name == 'your_controller' ? 'bg-gray-900 text-white' : '...'}
```

### Issue: Profile Card Data Not Showing

**Check**: Controller loads data in `home_controller.rb`
**Check**: Variable names match view (e.g., `@social_links`)

### Issue: Layout Breaking on Other Pages

**Check**: Layout conditionals in `application.html.erb`
```erb
<% unless controller_name == 'home' && action_name == 'index' %>
```

### Issue: Cards Not Responsive

**Check**: Grid classes include breakpoints
```erb
class="grid grid-cols-1 md:grid-cols-3 gap-6"
```

---

## 📱 Responsive Breakpoints

```css
/* Mobile First */
default       /* < 768px */
md:           /* ≥ 768px (tablet) */
lg:           /* ≥ 1024px (desktop) */
xl:           /* ≥ 1280px (large desktop) */
```

**Current Implementation**:
- Sidebar: Fixed 80px on all sizes
- Profile: Fixed 320px on all sizes  
- Content: Responsive grid (1 → 2 → 3 columns)

**TODO**: Mobile optimization needed (<768px)

---

## 🎯 Testing Checklist

```markdown
- [ ] All links work correctly
- [ ] Sidebar active states work
- [ ] Profile card displays all data
- [ ] Social stats show correctly
- [ ] Upcoming events appear
- [ ] Projects list populates
- [ ] Recent posts show with dates
- [ ] Sports benchmarks display
- [ ] Books section loads
- [ ] Gear items appear
- [ ] Hover states work
- [ ] Transitions are smooth
- [ ] No console errors
- [ ] No broken images
- [ ] Navigation/footer hidden on homepage
- [ ] Navigation/footer visible on other pages
```

---

## 📚 Related Documentation

- **Full Design Doc**: `docs/HOMEPAGE_DESIGN.md`
- **Changelog**: `docs/CHANGELOG_HOMEPAGE_REFACTOR.md`
- **Visual Comparison**: `docs/HOMEPAGE_VISUAL_COMPARISON.md`
- **Main README**: `CLAUDE.md`

---

## 🚀 Quick Deploy

```bash
# Check for errors
bin/rails routes | grep home

# Test locally
bin/dev

# Run tests
bin/rails test

# Check code quality
bin/rubocop

# Deploy (Kamal)
kamal deploy
```

---

## 💡 Pro Tips

1. **Icons**: Use [Heroicons](https://heroicons.com) for consistency
2. **Colors**: Stick to gray scale + blue/purple/pink accents
3. **Spacing**: Use multiples of 4px (Tailwind default)
4. **Cards**: Keep consistent structure across sections
5. **Loading**: Add empty states for missing data
6. **Hover**: Always add `transition-colors` or `transition-all`

---

## 🔗 Useful Commands

```bash
# Find all homepage references
grep -r "home#index" app/

# Check Tailwind classes
grep -o "class=\"[^\"]*\"" app/views/home/index.html.erb

# Count lines
wc -l app/views/home/index.html.erb

# View specific section
sed -n '85,96p' app/views/home/index.html.erb
```

---

**Last Updated**: 2024  
**Version**: 1.0.0  
**Status**: ✅ Production Ready
