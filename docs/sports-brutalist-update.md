# Sports Pages - Brutalist Design Update

## Overview

Updated the sports archive and detail pages to follow the brutalist design system with consistent 2px borders, eggwhite backgrounds, and removed hardcoded headers in favor of the unified sidebar navigation.

## Changes Implemented

### Layout Improvements

#### Removed Hardcoded Headers
- **Before**: Each sports view had its own redundant header/navigation
- **After**: Relies on the main sidebar navigation (left side of screen)
- **Benefit**: DRY principle, consistent navigation across all pages

#### Main Navigation
- The sidebar serves as the primary navigation
- No need for duplicate headers on individual pages
- Cleaner, more focused content presentation

### Design System Compliance

#### Border Specifications
- **Maximum Width**: 2px (strict limit across entire design system)
- **Style**: `border-2 border-black` for all elements
- **Application**: Cards, sections, buttons, tabs, dividers

#### Color Palette
- **Background**: `bg-eggwhite` for main areas
- **Accent Background**: `bg-eggwhite-dark` for hover states
- **Text**: Pure black (`text-black`) with bold/semibold weights
- **Highlights**: `bg-yellow-300` for PR badges, `bg-green-300` for upcoming events

#### Typography
- **Headings**: Large, bold black text (5xl-6xl for page titles)
- **Body**: Black text with semibold weights
- **Links**: Underline on hover, no color changes

#### Interactive Elements
- **Hover States**: Background color shift (eggwhite → eggwhite-dark)
- **Buttons**: Black borders with color inversions on hover
- **No Transitions**: Removed smooth transitions and animations

## File Changes

### `app/views/sports/index.html.erb`

**Key Updates:**
- Removed redundant page header (title and description moved to dedicated section)
- Updated sport type tabs with brutalist styling
  - Active tab: `border-b-2 border-black` with bold text
  - Inactive tabs: Hover underline effect
- Benchmark cards:
  - `border-2 border-black` (no rounded corners)
  - `hover:bg-eggwhite-dark` (no shadows)
  - Section headers have `border-b-2 border-black pb-2`
- Recent results:
  - Sport badges: `bg-black text-eggwhite` with 2px borders
  - PR badges: `bg-yellow-300 text-black` with 2px borders
  - Large result values in black (removed blue accent)
- Upcoming events:
  - Clean cards with 2px borders
  - Event type badges with black backgrounds
  - Location info with emoji prefix

### `app/views/sports/show.html.erb`

**Key Updates:**
- Back button: Black with underline hover (no color transitions)
- Page title section with bottom border divider (`border-b-2 border-black pb-6`)
- Section headers with bottom borders for visual hierarchy
- Benchmarks:
  - 2px black borders on all cards
  - Large black values (removed blue accent)
  - Grid layout with consistent spacing
- Personal Records:
  - `bg-yellow-200` with `hover:bg-yellow-300`
  - 2px black borders (no gradients)
  - Trophy emoji for visual interest
  - Clean, flat design
- Recent Results:
  - Consistent 2px borders
  - PR badges in yellow-300 with black text
  - Action buttons with borders and hover inversions
- Upcoming Events:
  - Status badges: Green-300 for upcoming, eggwhite-dark for completed
  - All elements use 2px borders
  - Hover state background changes only

### `app/assets/tailwind/application.css`

**Updated:**
- Focus outline reduced from 3px to 2px
- Removed old border utility classes (border-brutalist, border-brutalist-thin, border-brutalist-thick)
- Simplified to use standard Tailwind `border-2` throughout

### `app/views/layouts/application.html.erb`

**Updated:**
- Navigation bar: `border-b-2` (was `border-b-4`)
- Footer: `border-t-2` (was `border-t-4`)
- Flash messages: `border-2` (was `border-3`)
- Mobile menu: `border-t-2` (was `border-t-3`)

### `app/views/shared/_sidebar.html.erb`

**Updated:**
- Profile card: `border-2` (was `border-3`)
- Action buttons: `border-2` (was `border-3`)
- Maintained 2px borders throughout

### `docs/brutalist-design-changes.md`

**Updated:**
- Corrected border specifications to 2px max
- Removed references to 3px and 4px borders
- Updated all component examples
- Clarified border consistency rules

## Design Patterns Established

### Card Component Pattern
```erb
<div class="bg-eggwhite border-2 border-black p-6 hover:bg-eggwhite-dark">
  <!-- Content -->
</div>
```

### Badge Component Pattern
```erb
<!-- Black badge -->
<span class="px-2 py-1 bg-black text-eggwhite text-xs font-bold uppercase border-2 border-black">
  Label
</span>

<!-- Accent badge -->
<span class="px-2 py-1 bg-yellow-300 text-black text-xs font-bold uppercase border-2 border-black">
  PR
</span>
```

### Button Component Pattern
```erb
<!-- Primary button -->
<button class="bg-black text-eggwhite border-2 border-black px-3 py-1 hover:bg-gray-800">
  Action
</button>

<!-- Secondary button -->
<button class="bg-eggwhite text-black border-2 border-black px-3 py-1 hover:bg-black hover:text-eggwhite">
  Action
</button>
```

### Section Header Pattern
```erb
<h2 class="text-3xl font-bold text-black mb-8 border-b-2 border-black pb-3">
  Section Title
</h2>
```

## Benefits of Changes

### Consistency
- All borders are exactly 2px across the entire site
- Unified color palette (eggwhite, black, yellow accents)
- Predictable hover states

### Simplicity
- No gradients or complex shadows
- Flat design that's easier to maintain
- Clear visual hierarchy through borders and typography

### Performance
- Removed backdrop filters
- Eliminated transition animations
- Faster rendering

### Accessibility
- High contrast (black on eggwhite) exceeds WCAG AAA
- Clear focus states with 2px outlines
- No reliance on color alone (uses borders and text weight)

### Maintainability
- Consistent patterns easy to replicate
- DRY principles (no duplicate headers)
- Clear documentation of component patterns

## Future Considerations

### Potential Enhancements
- Add brutalist-style data visualizations (bar charts with thick borders)
- Consider ASCII art section dividers
- Explore brutalist form designs for adding/editing records
- Add print-friendly styles (already well-suited for B&W printing)

### Areas to Monitor
- Ensure new pages follow 2px max border rule
- Maintain eggwhite/black color consistency
- Avoid introducing rounded corners or shadows
- Keep hover states simple (color changes only)

## Testing Checklist

When reviewing the sports pages:
- [ ] All borders are 2px or less
- [ ] No rounded corners present
- [ ] No box shadows or gradients
- [ ] Text is pure black on eggwhite
- [ ] Hover states are simple color changes
- [ ] No hardcoded headers (relies on sidebar)
- [ ] Badges have 2px borders
- [ ] Buttons invert colors on hover
- [ ] Cards use eggwhite backgrounds
- [ ] Typography is bold/semibold
- [ ] Links underline on hover

## Related Documentation

- `docs/brutalist-design-changes.md` - Main design system documentation
- `CLAUDE.md` - Project rules including DRY principles
- `app/assets/tailwind/application.css` - Custom theme configuration
