# Projects & Books Pages - Brutalist Design Update

## Overview

Updated the projects and books archive pages to follow the brutalist design system with consistent 2px borders, eggwhite backgrounds, and removed hardcoded headers in favor of the unified sidebar navigation.

## Changes Implemented

### Common Updates (Both Pages)

#### Layout Improvements
- **Removed Redundant Headers**: Eliminated duplicate page titles/headers
- **Page Title Section**: Large, bold titles (5xl-6xl) with descriptive subtitles
- **Consistent Spacing**: Reduced top padding from `py-20` to `py-12`
- **Main Navigation**: Relies on sidebar for primary navigation

#### Design System Compliance
- **Border Maximum**: 2px across all elements
- **Typography**: Pure black text with bold/semibold weights
- **Backgrounds**: Eggwhite with eggwhite-dark for hover states
- **No Rounded Corners**: All sharp edges
- **No Shadows/Gradients**: Flat, brutalist aesthetic

---

## Projects Page (`app/views/projects/index.html.erb`)

### Page Structure

1. **Page Title Section**
   - Large emoji + title (🚀 Projects)
   - Descriptive subtitle in black

2. **Project Type Filter Tabs**
   - Border-bottom navigation style
   - Active tab: `border-b-2 border-black -mb-0.5` with bold text
   - Inactive tabs: Hover underline effect
   - Options: All Projects, Startups, Side Projects, Experiments

3. **Featured Projects Section** (when no filter applied)
   - Yellow background cards (`bg-yellow-200`)
   - Black "Featured" badge
   - Project type badges in black
   - Tech stack tags with borders
   - Status badges (green for active, yellow for in-development)

4. **All Projects Grid**
   - 3-column responsive grid
   - Standard eggwhite cards
   - Status badges in corner
   - Tech stack with max 4 visible tags
   - Links with border and hover inversion

5. **Project Stats** (when no filter applied)
   - 3-column stat cards
   - Startups count, Side Projects count, Active count
   - Clean, centered layout

### Key Design Patterns

#### Featured Project Card
```erb
<div class="bg-yellow-200 border-2 border-black p-6 hover:bg-yellow-300">
  <!-- Black "Featured" badge -->
  <span class="px-2 py-1 bg-black text-eggwhite text-xs font-bold uppercase border-2 border-black">
    Featured
  </span>
  <!-- Content -->
</div>
```

#### Status Badges
- **Active**: `bg-green-300 text-black` with 2px border
- **In Development**: `bg-yellow-300 text-black` with 2px border
- **Archived/Inactive**: `bg-eggwhite-dark text-black` with 2px border

#### Tech Stack Tags
```erb
<span class="px-2 py-1 bg-eggwhite-dark text-black text-xs font-semibold border-2 border-black">
  Technology Name
</span>
```

#### Project Links
```erb
<a class="text-black hover:underline font-bold text-sm border-2 border-black px-3 py-1 bg-eggwhite hover:bg-black hover:text-eggwhite">
  View Project →
</a>
```

### Color Usage
- **Featured Cards**: Yellow-200 background (highlights importance)
- **Regular Cards**: Eggwhite background (standard content)
- **Badges**: Black backgrounds for labels, colored for status
- **Hover States**: Yellow-300 for featured, eggwhite-dark for regular

---

## Books Page (`app/views/books/index.html.erb`)

### Page Structure

1. **Page Title Section**
   - Large emoji + title (📚 Reading List)
   - Descriptive subtitle in black

2. **Category Filter Buttons**
   - Pill-style buttons with borders
   - Active: `bg-black text-eggwhite`
   - Inactive: `bg-eggwhite text-black` with hover inversion
   - Dynamic categories from database

3. **Featured Books Section** (when no filter applied)
   - Yellow background cards (`bg-yellow-200`)
   - Black "Featured" badge
   - Star ratings in yellow-600
   - Category badges in black
   - Affiliate links with borders

4. **All Books Grid**
   - 2-column responsive grid (wider cards for content)
   - Book header with title, author, rating
   - Review section with 📝 icon
   - Notes section in eggwhite-dark box with 💡 icon
   - Category badges and read dates
   - ISBN display and Amazon links

5. **Top Rated Books** (when no filter applied)
   - 5-column compact grid
   - Small cards with title, author, rating
   - Hover changes to yellow-200

6. **Affiliate Disclaimer**
   - Bottom section with border
   - Eggwhite-dark background
   - Bold disclosure text

### Key Design Patterns

#### Featured Book Card
```erb
<div class="bg-yellow-200 border-2 border-black p-6 hover:bg-yellow-300">
  <!-- Black "Featured" badge -->
  <span class="px-2 py-1 bg-black text-eggwhite text-xs font-bold uppercase border-2 border-black">
    Featured
  </span>
  <!-- Content with rating -->
  <span class="text-yellow-600 text-sm font-bold">
    ⭐⭐⭐⭐⭐
  </span>
</div>
```

#### Book Review Section
```erb
<div class="mb-4">
  <h4 class="text-sm font-bold text-black mb-2">
    📝 Review
  </h4>
  <div class="text-black text-sm leading-relaxed prose max-w-none">
    <%= book.review %>
  </div>
</div>
```

#### Book Notes Section
```erb
<div class="mb-4 p-4 bg-eggwhite-dark border-2 border-black">
  <h4 class="text-sm font-bold text-black mb-2">
    💡 Notes
  </h4>
  <div class="text-black text-sm leading-relaxed prose max-w-none">
    <%= book.notes %>
  </div>
</div>
```

#### Category Filter Buttons
```erb
<%= link_to category, books_path(category: category), 
    class: "px-4 py-2 font-bold border-2 border-black #{selected ? 'bg-black text-eggwhite' : 'bg-eggwhite text-black hover:bg-black hover:text-eggwhite'}" %>
```

### Color Usage
- **Featured Cards**: Yellow-200 background (special books)
- **Regular Cards**: Eggwhite background (all books)
- **Notes Boxes**: Eggwhite-dark background (distinction)
- **Star Ratings**: Yellow-600 text (standard rating color)
- **Top Rated Hover**: Yellow-200 background (emphasis)

---

## Shared Patterns Across Both Pages

### Section Headers
```erb
<h2 class="text-3xl font-bold text-black mb-8 border-b-2 border-black pb-3">
  Section Title
</h2>
```

### Filter/Tab Navigation
- Bottom border on container: `border-b-2 border-black`
- Active state: Additional `border-b-2 border-black -mb-0.5` to overlap
- All text is black with bold weights

### Card Hover States
- **Standard**: `hover:bg-eggwhite-dark`
- **Featured**: `hover:bg-yellow-300`
- **Top Rated**: `hover:bg-yellow-200`
- No scale transforms, no shadows

### Empty States
```erb
<div class="bg-eggwhite border-2 border-black p-12 text-center">
  <p class="text-black text-lg font-bold">No items found.</p>
  <%= link_to "View All", path, class: "border-2 border-black px-4 py-2 hover:bg-black hover:text-eggwhite" %>
</div>
```

### Button/Link Pattern
```erb
<!-- Primary action -->
<a class="border-2 border-black px-3 py-1 bg-eggwhite hover:bg-black hover:text-eggwhite">
  Action Text →
</a>

<!-- Category/Badge -->
<span class="px-2 py-1 bg-black text-eggwhite text-xs font-bold border-2 border-black">
  Label
</span>
```

---

## Design Decisions

### Why Yellow for Featured Items?
- Creates clear visual hierarchy
- Stands out against eggwhite without color intensity
- Works well with black borders (high contrast)
- Retains brutalist aesthetic (flat, bold colors)

### Why 2-Column for Books vs 3-Column for Projects?
- Books have more content (reviews, notes)
- Wider cards accommodate longer text
- Projects are more compact (name, tags, status)

### Why Different Filter Styles?
- **Projects**: Tab-style with bottom borders (fewer categories)
- **Books**: Button pills (many dynamic categories)
- Both maintain 2px border consistency

### Typography Hierarchy
1. **Page Titles**: 5xl-6xl, bold
2. **Section Headers**: 3xl, bold, with bottom border
3. **Card Titles**: xl, bold
4. **Body Text**: sm, semibold or regular
5. **Labels/Badges**: xs, bold, uppercase

---

## Files Modified

### View Files
- ✅ `app/views/projects/index.html.erb` - Complete brutalist overhaul
- ✅ `app/views/books/index.html.erb` - Complete brutalist overhaul

### Documentation
- ✅ `docs/projects-books-brutalist-update.md` - This file

---

## Benefits of This Update

### Consistency
- Both pages follow identical design patterns
- 2px borders throughout
- Same color palette (eggwhite, black, yellow accents)
- Predictable hover states

### Readability
- High contrast black on eggwhite
- Clear visual hierarchy with borders
- Bold typography for emphasis
- Adequate spacing between elements

### Performance
- No gradients or backdrop filters
- No transition animations
- Simple hover state changes
- Faster page rendering

### Maintainability
- DRY principles (no duplicate headers)
- Consistent component patterns
- Easy to replicate for new pages
- Well-documented in code comments

---

## Testing Checklist

### Projects Page
- [ ] All borders are 2px max
- [ ] Featured projects have yellow backgrounds
- [ ] Status badges show correct colors
- [ ] Tech stack tags display properly
- [ ] Filter tabs highlight active state
- [ ] Project links invert on hover
- [ ] Empty state displays correctly
- [ ] Stats cards show on "All Projects" view

### Books Page
- [ ] All borders are 2px max
- [ ] Featured books have yellow backgrounds
- [ ] Star ratings display in yellow-600
- [ ] Category filter buttons work
- [ ] Review and notes sections styled correctly
- [ ] Top rated books grid displays
- [ ] Affiliate disclaimer shows at bottom
- [ ] Amazon links invert on hover
- [ ] Empty state displays correctly

### Shared Elements
- [ ] No rounded corners anywhere
- [ ] No box shadows present
- [ ] Text is pure black
- [ ] Links underline on hover
- [ ] Cards have simple hover states
- [ ] Section headers have bottom borders
- [ ] No gradients used

---

## Future Enhancements

### Potential Additions
- [ ] Add filtering/sorting controls with brutalist dropdowns
- [ ] Consider ASCII art section dividers
- [ ] Add brutalist-style pagination
- [ ] Explore grid-based layouts with thick dividers
- [ ] Add "Load More" buttons with brutalist styling

### Areas to Monitor
- Ensure rich text in reviews doesn't break layout
- Test with very long project/book titles
- Verify tech stack wrapping with many tags
- Check mobile responsiveness of filter buttons

---

## Related Documentation

- `docs/brutalist-design-changes.md` - Main design system
- `docs/sports-brutalist-update.md` - Sports pages update
- `CLAUDE.md` - Project rules and DRY principles
- `app/assets/tailwind/application.css` - Theme configuration
