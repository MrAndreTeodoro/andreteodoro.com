# Upcoming Events Feature - Documentation

## Overview

Added support for upcoming sports events across all sport types (CrossFit, Hyrox, Running, OCR) with dedicated views in the sports pages and sidebar. Uses a simple boolean flag approach for marking future events.

## Implementation Details

### Database Changes

#### Migration 1: `AddIsUpcomingEventToSportActivities`
```ruby
add_column :sport_activities, :is_upcoming_event, :boolean, default: false, null: false
add_index :sport_activities, :is_upcoming_event
```

**Purpose:** Flag activities that are upcoming events to display in dedicated sections.

#### Migration 2: `AddSubTypeToSportActivities`
```ruby
add_column :sport_activities, :sub_type, :string
add_index :sport_activities, :sub_type
```

**Purpose:** Differentiate between running types (road/trail) for better categorization.

### Model Updates

#### `SportActivity` Model

**New Validations:**
```ruby
validates :sport_type, inclusion: { in: %w[crossfit hyrox running ocr] }
validates :sub_type, inclusion: { in: %w[road trail], allow_blank: true }
```

**New Scopes:**
```ruby
scope :ocr, -> { where(sport_type: "ocr") }
scope :road_running, -> { running.where(sub_type: "road") }
scope :trail_running, -> { running.where(sub_type: "trail") }
scope :upcoming_events, -> { 
  where(is_upcoming_event: true)
    .where("date >= ?", Date.today)
    .order(date: :asc) 
}
scope :past_events, -> { 
  where(is_upcoming_event: true)
    .where("date < ?", Date.today)
    .order(date: :desc) 
}
```

**Updated Helper Methods:**
```ruby
def sport_display_name
  case sport_type
  when "ocr"
    "OCR"
  when "running"
    sub_type.present? ? "#{sub_type.capitalize} Running" : "Running"
  else
    sport_type.capitalize
  end
end

def upcoming?
  is_upcoming_event && date.present? && date >= Date.today
end

def past?
  date.present? && date < Date.today
end

def full_sport_name
  if sport_type == "running" && sub_type.present?
    "#{sub_type.capitalize} Running"
  elsif sport_type == "ocr"
    "OCR"
  else
    sport_type.capitalize
  end
end

def sport_emoji
  case sport_type
  when "crossfit"
    "🏋️"
  when "hyrox"
    "⚡"
  when "running"
    "🏃"
  when "ocr"
    "🧗"
  else
    "🏅" # Default sports emoji
  end
end
```

## Supported Sport Types

### 1. **CrossFit** (`crossfit`)
- Emoji: 🏋️
- No sub-types
- Example: "CrossFit Open 2025"

### 2. **Hyrox** (`hyrox`)
- Emoji: ⚡
- No sub-types
- Example: "HYROX World Championship"

### 3. **Running** (`running`)
- Emoji: 🏃
- **Sub-types:**
  - `road` - Road Running
  - `trail` - Trail Running
- Examples: "Boston Marathon", "Ultra Trail du Mont-Blanc"

### 4. **OCR** (`ocr`)
- Emoji: 🧗
- No sub-types
- Example: "Spartan Race Super", "Tough Mudder Classic"

## Controller Updates

### `ApplicationController`
Updated sidebar data loading:
```ruby
@sidebar_upcoming_events = SportActivity.upcoming_events.limit(3)
```

### `HomeController`
Updated homepage upcoming events:
```ruby
@upcoming_events = SportActivity.upcoming_events.limit(3)
```

### `SportsController`
**Index action:**
```ruby
@upcoming_events = SportActivity.upcoming_events.limit(10)
```

**Show action:**
```ruby
# Updated to support 'ocr' sport type
unless %w[crossfit hyrox running ocr].include?(@sport_type)
  redirect_to sports_path, alert: "Invalid sport type"
  return
end

@events = SportActivity.where(sport_type: @sport_type).upcoming_events
```

## View Updates

### Sidebar (`_sidebar.html.erb`)

**Upcoming Events Section:**
- Shows sport emoji based on type
- Displays event title
- Shows location with 📍 emoji
- Date formatted as "MMM DD, YYYY"
- Left border highlight (4px black)
- Eggwhite-dark background

**Code Example:**
```erb
<div class="border-l-4 border-black pl-2 bg-eggwhite-dark">
  <div class="flex items-start gap-1 mb-1">
    <span class="text-xs">
      <%= event.sport_emoji %>
    </span>
    <p class="text-black font-bold text-xs flex-1"><%= event.title %></p>
  </div>
  <p class="text-xs text-black flex items-center">
    <span class="mr-1">📍</span> <%= event.location %>
  </p>
  <p class="text-xs text-black mt-0.5 font-semibold">
    <%= event.date.strftime("%b %d, %Y") %>
  </p>
</div>
```

**DRY Helper Method:**

The `sport_emoji` method centralizes emoji logic in one place. To add a new sport type:
1. Add to validation in model
2. Add case to `sport_emoji` method
3. Emojis automatically display everywhere!

No need to update views - the helper handles it. ✅
```

### Sports Index (`sports/index.html.erb`)

**Upcoming Events Section:**
- 3-column responsive grid
- Large sport emoji (text-2xl)
- Sport type badge (black background, eggwhite text)
- Date display
- Event title
- Location with emoji
- Rich text description support
- Border-bottom section header

**Design:**
- Cards: `bg-eggwhite border-2 border-black hover:bg-eggwhite-dark`
- Badges: `bg-black text-eggwhite border-2 border-black`

### Sports Show (`sports/show.html.erb`)

**Upcoming Events Section:**
- Similar to index but filtered by sport type
- Shows "Upcoming" badge for future events
- Shows "Completed" badge for past events
- Links to event details (if URL provided)
- Displays rich text descriptions

### Admin Form (`admin/sport_activities/_form.html.erb`)

**New Fields Added:**

1. **OCR Sport Type Option**
   ```erb
   ['OCR', 'ocr']
   ```

2. **Sub Type Field** (Running only)
   ```erb
   <%= f.select :sub_type,
     [
       ['Road', 'road'],
       ['Trail', 'trail']
     ],
     { include_blank: 'Not applicable' } %>
   ```
   - Only relevant for running activities
   - Optional field

3. **Is Upcoming Event Checkbox**
   ```erb
   <%= f.check_box :is_upcoming_event %>
   ```
   - Green calendar icon
   - Clear label: "Upcoming Event"
   - Help text: "Mark this as an upcoming event to display in the events section and sidebar"

## Data Flow

### Creating an Upcoming Event

1. Admin goes to "New Sport Activity"
2. Selects sport type (CrossFit, Hyrox, Running, OCR)
3. If Running, optionally selects sub-type (Road/Trail)
4. Enters event details (title, date, location)
5. **Checks "Upcoming Event" checkbox** ✅
6. Saves activity

### Display Logic

**Sidebar:**
```ruby
@sidebar_upcoming_events = SportActivity.upcoming_events.limit(3)
# WHERE is_upcoming_event = true AND date >= TODAY
# ORDER BY date ASC
# LIMIT 3
```

**Sports Pages:**
```ruby
@upcoming_events = SportActivity.upcoming_events.limit(10)
# Shows all upcoming events across all sports
```

**Individual Sport Page:**
```ruby
@events = SportActivity.where(sport_type: @sport_type).upcoming_events
# Shows upcoming events for specific sport only
```

### Automatic Filtering

The `upcoming_events` scope automatically:
- ✅ Filters by `is_upcoming_event = true`
- ✅ Filters by `date >= Date.today`
- ✅ Orders by date (ascending - soonest first)
- ✅ Excludes past events (even if marked as upcoming)

## Design System Compliance

All views follow brutalist design:
- ✅ 2px max border width
- ✅ Eggwhite backgrounds
- ✅ Pure black text and borders
- ✅ No rounded corners
- ✅ No shadows or gradients
- ✅ Bold typography
- ✅ Sport emojis for visual interest
- ✅ Simple hover states

### Color Usage

- **Cards**: `bg-eggwhite` with `hover:bg-eggwhite-dark`
- **Badges**: `bg-black text-eggwhite` (sport type)
- **Status Badges**:
  - Upcoming: `bg-green-300 text-black`
  - Completed: `bg-eggwhite-dark text-black`

## Usage Examples

### Example 1: CrossFit Competition
```ruby
SportActivity.create!(
  sport_type: 'crossfit',
  category: 'event',
  title: 'CrossFit Open 2025',
  date: Date.new(2025, 2, 15),
  location: 'Online',
  is_upcoming_event: true,
  description: 'Annual worldwide CrossFit competition'
)
```

### Example 2: Trail Running Race
```ruby
SportActivity.create!(
  sport_type: 'running',
  sub_type: 'trail',
  category: 'event',
  title: 'Ultra Trail du Mont-Blanc',
  date: Date.new(2025, 8, 25),
  location: 'Chamonix, France',
  is_upcoming_event: true,
  description: '170km mountain ultra marathon'
)
```

### Example 3: OCR Event
```ruby
SportActivity.create!(
  sport_type: 'ocr',
  category: 'event',
  title: 'Spartan Race Super',
  date: Date.new(2025, 6, 10),
  location: 'Lake Tahoe, CA',
  is_upcoming_event: true,
  description: '10km obstacle course race'
)
```

## Benefits

### User Benefits
1. **Clear Event Visibility**: Upcoming events prominently displayed
2. **Sport Recognition**: Emojis make sport types instantly recognizable
3. **Always Current**: Past events automatically hidden from "upcoming" sections
4. **Context Everywhere**: Events shown in sidebar on all pages

### Developer Benefits
1. **Simple Boolean Flag**: Easy to understand and maintain
2. **Automatic Filtering**: Date-based logic handled by scope
3. **No New Tables**: Extends existing `SportActivity` model
4. **Easy Migration Path**: Can extract to separate model later if needed

### Content Benefits
1. **Flexible Categorization**: Sub-types for running (road/trail)
2. **Rich Descriptions**: ActionText support for detailed event info
3. **External Links**: Can link to official event pages
4. **Historical Record**: Past events remain in database

## Future Enhancements

### Potential Additions
- [ ] Event registration links
- [ ] Countdown timers to event dates
- [ ] Event results/recap after completion
- [ ] Multi-day events (start/end date)
- [ ] Event categories (local, national, international)
- [ ] Team events vs individual
- [ ] Event photos/gallery
- [ ] Pre-event training plans
- [ ] Event reminders/notifications

### Refactoring Considerations

**When to Extract to Separate Model:**
- If you add non-sports events (talks, meetups, workshops)
- If events need very different attributes than activities
- If polymorphic associations are needed

**Current Approach is Good Because:**
- ✅ YAGNI principle - only build what's needed now
- ✅ All sports data in one model
- ✅ Easy to query and filter
- ✅ Simple to understand and maintain
- ✅ Can refactor later without breaking changes

## Testing Checklist

### Display Tests
- [ ] Upcoming events show in sidebar (max 3)
- [ ] Upcoming events show on sports index (max 10)
- [ ] Upcoming events filtered by sport type on show pages
- [ ] Past events don't appear in upcoming sections
- [ ] Emojis display correctly for each sport type
- [ ] Sub-types display for running (Road/Trail)

### Admin Tests
- [ ] Can create upcoming event with checkbox
- [ ] Can select OCR sport type
- [ ] Can select road/trail for running
- [ ] Form validates correctly
- [ ] Past events can be marked as upcoming (but won't show)

### Scope Tests
- [ ] `upcoming_events` filters by date
- [ ] `upcoming_events` orders by date (ascending)
- [ ] `past_events` includes only past dates
- [ ] Sport-specific scopes work (`crossfit`, `hyrox`, `running`, `ocr`)
- [ ] Sub-type scopes work (`road_running`, `trail_running`)

## Files Modified

### Models
- ✅ `app/models/sport_activity.rb` - Added scopes, validations, helpers

### Controllers
- ✅ `app/controllers/application_controller.rb` - Updated sidebar data
- ✅ `app/controllers/home_controller.rb` - Updated homepage data
- ✅ `app/controllers/sports_controller.rb` - Added OCR support, updated scopes
- ✅ `app/controllers/admin/sport_activities_controller.rb` - Updated params

### Views
- ✅ `app/views/shared/_sidebar.html.erb` - Added sport emojis, updated display
- ✅ `app/views/sports/index.html.erb` - Updated upcoming events section
- ✅ `app/views/sports/show.html.erb` - Updated events display
- ✅ `app/views/admin/sport_activities/_form.html.erb` - Added new fields

### Migrations
- ✅ `db/migrate/..._add_is_upcoming_event_to_sport_activities.rb`
- ✅ `db/migrate/..._add_sub_type_to_sport_activities.rb`

### Documentation
- ✅ `docs/upcoming-events-feature.md` - This file

## Related Documentation

- `docs/brutalist-design-changes.md` - Design system guidelines
- `docs/sports-brutalist-update.md` - Sports pages styling
- `CLAUDE.md` - Project rules and DRY principles
