# Project Single View Feature

## Overview

Added individual project pages that display full details about each project, including description, tech stack, project info, and related projects. All styling follows the brutalist design system with 2px borders and eggwhite backgrounds.

## Implementation

### Routes

Added `show` action to projects routes:

```ruby
# config/routes.rb
resources :projects, only: [ :index, :show ]
```

### Controller

Added `show` action in `ProjectsController`:

```ruby
# app/controllers/projects_controller.rb
def show
  @project = Project.find(params[:id])
  @related_projects = Project.where(project_type: @project.project_type)
                             .where.not(id: @project.id)
                             .ordered
                             .limit(3)
end
```

**Related Projects Logic:**
- Finds projects of the same type (startup, side_project, experiment)
- Excludes the current project
- Returns up to 3 related projects
- Ordered by position (asc)

### Model Updates

Added `url_host` helper method to `Project` model:

```ruby
# app/models/project.rb
def url_host
  return "" unless has_url?
  begin
    URI.parse(url).host
  rescue URI::InvalidURIError
    url
  end
end
```

**Purpose:**
- Safely extracts host from project URL
- Displays clean domain name (e.g., "example.com" instead of full URL)
- Handles invalid URIs gracefully
- Returns empty string if no URL present

### View Structure

Created `app/views/projects/show.html.erb` with brutalist design:

#### Page Layout

1. **Back Button**
   - Returns to projects index
   - Black text with underline on hover
   - SVG arrow icon

2. **Project Header**
   - Badges: Type, Status, Featured (if applicable)
   - Large title (5xl-6xl font)
   - Logo display (if available)
   - "Visit Project" button (if URL exists)
   - Bottom border divider

3. **Main Content Grid** (2-column on large screens)
   - **Main Column (2/3 width):**
     - About section with rich text description
     - Tech stack section with badges
   
   - **Sidebar (1/3 width):**
     - Project Info card (type, status, URL, created date)
     - Quick Actions (visit website, view all projects)

4. **Related Projects Section**
   - Shows 3 similar projects (same type)
   - 3-column responsive grid
   - Linked cards with hover states

### Index Page Updates

Modified `app/views/projects/index.html.erb` to link to single pages:

**Changes:**
- Converted project cards to clickable `link_to` blocks
- Changed "View Project →" external links to "View Details →"
- External URLs now only shown on single project page
- Entire card is now clickable and navigates to show page

## Design System Compliance

### Colors & Backgrounds

- **Main Background**: `bg-eggwhite`
- **Card Backgrounds**: `bg-eggwhite` or `bg-yellow-200` (featured)
- **Hover States**: `bg-eggwhite-dark` or `bg-yellow-300`
- **Text**: Pure black (`text-black`)
- **Borders**: 2px black borders throughout

### Typography

- **Page Title**: 5xl-6xl, bold
- **Section Headers**: 3xl, bold, with bottom border
- **Card Titles**: xl-2xl, bold
- **Body Text**: sm-base, semibold
- **Labels**: xs, bold, uppercase

### Components

#### Badge Patterns

```erb
<!-- Type Badge -->
<span class="px-2 py-1 bg-black text-eggwhite text-xs font-bold uppercase border-2 border-black">
  Startup
</span>

<!-- Status Badge - Active -->
<span class="px-2 py-1 bg-green-300 text-black text-xs font-bold border-2 border-black">
  Active
</span>

<!-- Status Badge - In Development -->
<span class="px-2 py-1 bg-yellow-300 text-black text-xs font-bold border-2 border-black">
  In Development
</span>

<!-- Featured Badge -->
<span class="px-2 py-1 bg-yellow-300 text-black text-xs font-bold uppercase border-2 border-black">
  ⭐ Featured
</span>
```

#### Tech Stack Tags

```erb
<span class="px-4 py-2 bg-black text-eggwhite text-sm font-bold border-2 border-black">
  Ruby on Rails
</span>
```

#### Info Card Sections

```erb
<div class="border-b-2 border-black pb-3">
  <p class="text-xs font-bold text-black uppercase mb-1">Label</p>
  <p class="text-black font-semibold">Value</p>
</div>
```

#### Action Buttons

```erb
<!-- Primary Button -->
<a class="block w-full bg-black text-eggwhite border-2 border-black py-3 px-4 text-center font-bold hover:bg-gray-800">
  Primary Action
</a>

<!-- Secondary Button -->
<a class="block w-full bg-eggwhite text-black border-2 border-black py-3 px-4 text-center font-bold hover:bg-eggwhite-dark">
  Secondary Action
</a>
```

#### Related Project Cards

```erb
<%= link_to project_path(project), class: "block bg-eggwhite border-2 border-black p-6 hover:bg-eggwhite-dark" do %>
  <!-- Card content -->
<% end %>
```

### Borders & Spacing

- **Maximum border width**: 2px
- **Card borders**: `border-2 border-black`
- **Section dividers**: `border-b-2 border-black pb-3`
- **Internal dividers**: `border-b-2 border-black pb-3` (in info cards)
- **Card padding**: `p-4` to `p-6`
- **Section spacing**: `mb-8` to `mb-16`

## User Experience

### Navigation Flow

1. **Projects Index** → Click any project card → **Project Detail Page**
2. **Project Detail** → Click "Back to Projects" → **Projects Index**
3. **Project Detail** → Click "View All Projects" → **Projects Index**
4. **Project Detail** → Click related project → **Another Project Detail**

### Information Hierarchy

1. **Project Identity** (badges, title, logo)
2. **Primary Action** (visit website button - if available)
3. **Description** (main content area)
4. **Tech Stack** (technologies used)
5. **Project Info** (metadata in sidebar)
6. **Quick Actions** (sidebar buttons)
7. **Related Projects** (discovery at bottom)

### Content Display

#### With URL
- "Visit Project" button in header
- "Visit Website" button in sidebar
- Clean domain name displayed in info card

#### Without URL
- No visit buttons shown
- Website field omitted from info card
- User can still view all project details

#### With Logo
- Logo displayed in bordered box
- 96x96px (w-24 h-24)
- Object-contain fit
- Positioned in header next to title

#### Without Logo
- No logo box shown
- More space for title and badges

### Related Projects

**Display Logic:**
- Only shows if related projects exist
- Maximum 3 projects shown
- Same project type (startup/side_project/experiment)
- Current project excluded
- Ordered by position

**Content Shown:**
- Project name
- Status badge
- Short description (100 chars)
- First 3 tech stack items (+ count if more)
- Clickable card navigates to that project

## Benefits

### User Benefits

1. **Deep Dive Information**: Full descriptions and tech details
2. **Easy Navigation**: Back button and breadcrumb-style navigation
3. **Discovery**: Related projects encourage exploration
4. **Direct Access**: Quick links to live projects
5. **Context**: See project type, status, and timeline

### Content Benefits

1. **Rich Text Support**: Full ActionText descriptions
2. **Complete Tech Stack**: All technologies listed
3. **Metadata Display**: Creation date, status, type
4. **Logo Showcase**: Visual branding when available
5. **External Links**: Direct access to live projects

### SEO Benefits

1. **Dedicated URLs**: Each project has unique URL (`/projects/:id`)
2. **Rich Content**: Full descriptions indexed by search engines
3. **Internal Linking**: Related projects create link network
4. **Semantic HTML**: Proper heading hierarchy and structure

## Testing Checklist

### Display Tests

- [ ] Project title displays correctly
- [ ] All badges show appropriate colors
- [ ] Featured badge only shows when featured=true
- [ ] Logo displays when logo_url present
- [ ] Logo omitted when logo_url blank
- [ ] Description renders rich text properly
- [ ] Tech stack tags all display
- [ ] Status badge shows correct color

### Link Tests

- [ ] Back button returns to projects index
- [ ] "Visit Project" opens in new tab (when URL present)
- [ ] "Visit Website" in sidebar works
- [ ] "View All Projects" returns to index
- [ ] Related project cards navigate correctly
- [ ] Cards from index navigate to show page

### Content Tests

- [ ] Empty description shows placeholder
- [ ] No tech stack hides section entirely
- [ ] URL host displays cleanly
- [ ] Creation date formats properly
- [ ] Related projects filter by type
- [ ] Related projects exclude current project
- [ ] Maximum 3 related projects shown

### Responsive Tests

- [ ] 2-column grid stacks on mobile
- [ ] Logo doesn't break layout on small screens
- [ ] Related projects grid responsive (3→2→1 cols)
- [ ] Buttons full-width on mobile
- [ ] Text doesn't overflow containers

### Edge Cases

- [ ] Very long project names wrap properly
- [ ] Very long URLs don't break layout
- [ ] Missing URL hides buttons correctly
- [ ] No related projects hides section
- [ ] Invalid URL handled gracefully
- [ ] Empty tech stack array handled
- [ ] No description shows message

## Files Modified

- ✅ `config/routes.rb` - Added show route
- ✅ `app/controllers/projects_controller.rb` - Added show action
- ✅ `app/models/project.rb` - Added url_host helper
- ✅ `app/views/projects/show.html.erb` - Created show view
- ✅ `app/views/projects/index.html.erb` - Updated cards to link to show pages
- ✅ `docs/project-single-view.md` - This documentation

## Future Enhancements

### Potential Additions

- [ ] Add project screenshots/images gallery
- [ ] Include project timeline/milestones
- [ ] Show GitHub stats (stars, forks) if open source
- [ ] Add social sharing buttons
- [ ] Include team members section
- [ ] Show project metrics (users, revenue, etc.)
- [ ] Add comments/testimonials section
- [ ] Include related blog posts
- [ ] Add tags/categories for better filtering
- [ ] Create project comparison view

### Technical Improvements

- [ ] Add slug-based URLs (`/projects/my-project` instead of `/projects/1`)
- [ ] Implement breadcrumb navigation
- [ ] Add structured data (Schema.org) for SEO
- [ ] Create project sitemap
- [ ] Add meta tags for social sharing (Open Graph)
- [ ] Implement view counter
- [ ] Add "Recently Viewed" section
- [ ] Create project search functionality

## Related Documentation

- `docs/brutalist-design-changes.md` - Design system
- `docs/projects-books-brutalist-update.md` - Projects index page
- `CLAUDE.md` - Project rules and DRY principles
