# Homepage Design Documentation

## Overview

The homepage has been redesigned with a modern sidebar layout inspired by professional portfolio sites like Kitze's personal website. The new design features a three-column layout with fixed sidebar navigation, a profile card column, and a main content area.

## Layout Structure

### 1. Left Sidebar Navigation (Fixed)
- **Width**: 80px (w-20)
- **Position**: Fixed to the left edge
- **Background**: White with right border
- **Z-index**: 40

**Navigation Icons:**
- Home
- Sports (Lightning bolt)
- Projects (Briefcase)
- Books (Book)
- Blog (Pencil)
- Talks/Speaking (Microphone) - Placeholder
- Music (Musical note) - Placeholder
- Gear (Sliders)
- Settings (Bottom)
- Dark Mode Toggle (Bottom)

**Active State:**
- Active pages show with `bg-gray-900 text-white`
- Inactive pages show `text-gray-600 hover:bg-gray-100`

### 2. Middle Column: Profile Card (320px)
- **Width**: 320px (w-80)
- **Position**: Fixed scroll container
- **Background**: White with right border

**Components:**

#### Profile Card
- Gradient avatar circle (80x80px) with initials "AT"
- Name: "Andre Teodoro"
- Social media icons (4 icons: Twitter, GitHub, YouTube, LinkedIn)
- Bio text
- Location: "Based in the cloud, shipping to the world"
- Social stats (follower counts for top 3 platforms)

#### Upcoming Events
- Section header: "UPCOMING EVENTS"
- Event cards with:
  - Event name
  - Location with pin emoji
  - Date
  - Left blue border accent

#### Startups
- Section header: "STARTUPS"
- List of startup projects with rocket emoji
- Clickable links to project URLs

#### Side Projects
- Section header: "SIDE PROJECTS"
- List of side projects with lightbulb emoji
- Up to 10 projects displayed
- Clickable links where available

#### Recent Posts
- Section header: "RECENT POSTS"
- Last 3 blog posts with:
  - Title (2 lines max)
  - Published date

#### Action Buttons
- **Meet Button**: Black background, white text with user icon
- **Merch Button**: White background, border, with shopping bag icon (links to Gear page)

### 3. Main Content Area (Flexible)
- **Position**: Scrollable
- **Max Width**: 1024px (max-w-4xl) centered
- **Padding**: 32px vertical, 32px horizontal

**Sections:**

#### Hero Section
- Greeting: "👋 Hi, I'm"
- Name: Large gradient text (6xl-7xl) - Blue → Purple → Pink gradient
- Roles: "Developer", "Creator", "Educator"
- Bio paragraph
- Spacing: 64px bottom margin

#### Sports & Fitness
- Section header with "View All →" link
- 3-column grid:
  - CrossFit benchmarks (🏋️)
  - Hyrox records (⚡)
  - Running times (🏃)
- Shows top 2 records per sport
- Hover effect: border color change and shadow

#### Currently Reading
- Section header with "View All →" link
- 3-column grid of book cards
- Each card shows:
  - Title
  - Author
  - Star rating (if available)
- Hover effect: border and shadow

#### Favorite Gear
- Section header with "View All →" link
- 2-column grid
- Shows first 4 featured items
- Each card shows:
  - Name
  - Category badge
  - Price (if available)
  - Short description

## Key Features

### Responsive Design
- Fixed sidebar ensures consistent navigation
- Profile column provides quick access to key information
- Main content scrolls independently
- Mobile breakpoints at md (768px)

### Visual Hierarchy
- Gradient text for name creates focal point
- Emoji icons provide visual scanning aids
- Consistent card design across sections
- White cards on gray-50 background for depth

### Navigation Flow
- Sidebar provides quick access to all sections
- "View All →" links encourage deeper exploration
- Social links in profile card
- Action buttons (Meet, Merch) prominently placed

### Data Integration
Controller loads:
- `@social_links`: Social media links with follower counts
- `@crossfit_benchmarks`, `@hyrox_benchmarks`, `@running_benchmarks`: Sport achievements
- `@upcoming_events`: Future sport events
- `@featured_projects`: Startup projects
- `@side_projects`: Side projects (limit 12)
- `@featured_books`: Currently reading (limit 3)
- `@featured_gear`: Favorite gear (limit 6)
- `@recent_posts`: Latest blog posts

## Layout Modifications

### Application Layout Changes
The `application.html.erb` layout now:
1. Hides top navigation bar on homepage (`unless controller_name == 'home' && action_name == 'index'`)
2. Hides footer on homepage
3. Removes top padding on homepage (`pt-16` removed)

This allows the sidebar homepage to take full advantage of the viewport without conflicting navigation elements.

## Color Scheme

### Primary Colors
- **Gradient**: Blue-600 → Purple-600 → Pink-600
- **Background**: Gray-50
- **Cards**: White
- **Borders**: Gray-200
- **Active Nav**: Gray-900
- **Text**: Gray-900 (primary), Gray-600 (secondary)

### Interactive States
- **Hover**: Border-gray-300, Shadow-lg
- **Active Links**: Text-blue-600
- **Buttons**: Hover scale and color transitions

## Typography

### Font Sizes
- **Hero Name**: 6xl-7xl (60-72px)
- **Hero Roles**: 3xl-4xl (30-36px)
- **Section Headers**: 2xl (24px)
- **Card Titles**: base-lg (16-18px)
- **Body Text**: sm (14px)
- **Metadata**: xs (12px)

### Font Weights
- **Bold**: 700 (names, headers)
- **Semibold**: 600 (stats, labels)
- **Medium**: 500 (links)
- **Regular**: 400 (body text)

## Performance Considerations

1. **Fixed Sidebar**: No reflow on scroll
2. **Optimized Queries**: Controller loads only necessary data
3. **Lazy Images**: Cards support ActiveStorage variants
4. **CSS Transitions**: Hardware-accelerated transforms

## Future Enhancements

### Planned Features
- [ ] Dark mode toggle functionality
- [ ] Talks/Speaking section with real data
- [ ] Music/Playlists section
- [ ] Animated stats counters
- [ ] Scroll progress indicator
- [ ] Skeleton loading states

### Mobile Responsive Improvements
- [ ] Collapsible sidebar for mobile
- [ ] Bottom navigation bar for mobile
- [ ] Swipeable profile cards
- [ ] Hamburger menu for small screens

## Design Inspiration

This layout is inspired by modern portfolio sites that prioritize:
- **Information density**: Maximum content without clutter
- **Quick navigation**: Sidebar for instant section access
- **Personal branding**: Profile card establishes identity
- **Content showcase**: Main area highlights achievements

## Browser Compatibility

- Modern browsers (Chrome, Firefox, Safari, Edge)
- CSS Grid support required
- Flexbox support required
- SVG support required
- Tested on latest 2 versions of major browsers

## Accessibility

- Semantic HTML structure
- ARIA labels on icon buttons
- Keyboard navigation support
- Focus states on interactive elements
- Sufficient color contrast (WCAG AA)

## Maintenance

### Adding New Sections
1. Add data loading to `HomeController#index`
2. Create section in main content area
3. Follow existing card pattern
4. Add "View All →" link if applicable

### Updating Sidebar Icons
1. Icons use Heroicons (outline style)
2. Add new link with SVG path
3. Use conditional classes for active state
4. Add hover and transition classes

### Modifying Profile Card
1. Profile data comes from database (SocialLinks, etc.)
2. Update bio text in view directly
3. Stats auto-populate from social links
4. Action buttons can be customized with links
