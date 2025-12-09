# Sport Activities CRUD Documentation

## Overview

The Sport Activities CRUD provides a comprehensive admin interface for managing sports achievements, benchmarks, results, and events. This system supports CrossFit, Hyrox, and Running activities with advanced filtering, search, and categorization.

## Features

### 1. **Index Page** (`/admin/sport_activities`)

#### Search & Filters
- **Search Bar**: Search by title or description
- **Sport Type Filter**: CrossFit, Hyrox, Running
- **Category Filter**: Benchmark, Result, Event
- **Personal Records Filter**: Show only PR activities

#### Statistics Dashboard
- Total Activities count
- Personal Records count
- CrossFit activities count
- Hyrox activities count

#### Activities Table
Displays comprehensive information for each activity:
- **Activity Column**: Title, description, event name, location
- **Sport Type Badge**: Color-coded (CrossFit=Orange, Hyrox=Green, Running=Blue)
- **Category Badge**: Color-coded (Benchmark=Purple, Result=Blue, Event=Yellow)
- **Result**: Formatted value with unit
- **Date**: Activity date
- **Status Badges**: 
  - Personal Record (yellow star)
  - Upcoming Event (green)
  - Completed Event (gray)
- **Actions**: View result URL, Edit, Delete

### 2. **Create Page** (`/admin/sport_activities/new`)

#### Form Sections

**Basic Information**
- Sport Type (required): Dropdown - CrossFit, Hyrox, Running
- Category (required): Dropdown - Benchmark, Result, Event
- Title (required): Text input
- Description (optional): Textarea

**Result Information**
- Value: Text input (e.g., "3:45", "21:30", "1500")
- Unit: Text input (e.g., "minutes", "lbs", "kg", "km")
- Date: Date picker
- Personal Record: Checkbox with star icon

**Event Information** (Optional)
- Event Name: Text input (e.g., "Boston Marathon")
- Location: Text input (e.g., "Boston, MA")
- Result URL: URL input (link to official results/video)

#### Tips Section
Provides helpful guidance for:
- Understanding Benchmarks vs Results vs Events
- When to mark Personal Records
- Best practices for adding result URLs

### 3. **Edit Page** (`/admin/sport_activities/:id/edit`)

#### Features
- Same form as Create page
- Activity info banner showing current details with badges
- Creation date display
- Danger Zone section for deletion

#### Danger Zone
- Clear warning about permanent deletion
- Confirmation dialog before delete
- Red-themed UI to indicate destructive action

## Data Model

### SportActivity Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sport_type` | string | Yes | Type of sport: crossfit, hyrox, running |
| `category` | string | Yes | Category: benchmark, result, event |
| `title` | string | Yes | Activity title |
| `description` | text | No | Detailed description |
| `value` | string | No | Result value (time, weight, distance) |
| `unit` | string | No | Unit of measurement |
| `date` | date | No | Activity date |
| `personal_record` | boolean | No | Whether this is a PR (default: false) |
| `event_name` | string | No | Name of competition/event |
| `location` | string | No | Location of event |
| `result_url` | string | No | Link to official results |

### Validations

```ruby
validates :sport_type, presence: true, inclusion: { in: %w[crossfit hyrox running] }
validates :category, presence: true, inclusion: { in: %w[benchmark result event] }
validates :title, presence: true
```

### Scopes

```ruby
scope :crossfit, -> { where(sport_type: 'crossfit') }
scope :hyrox, -> { where(sport_type: 'hyrox') }
scope :running, -> { where(sport_type: 'running') }
scope :benchmarks, -> { where(category: 'benchmark') }
scope :results, -> { where(category: 'result').order(date: :desc) }
scope :events, -> { where(category: 'event').order(date: :asc) }
scope :personal_records, -> { where(personal_record: true) }
scope :recent, -> { order(created_at: :desc).limit(10) }
```

### Helper Methods

```ruby
def formatted_value
  return "#{value} #{unit}" if value.present? && unit.present?
  value
end

def sport_display_name
  sport_type.capitalize
end

def category_display_name
  category.capitalize
end

def upcoming?
  category == 'event' && date.present? && date > Date.today
end

def past?
  date.present? && date <= Date.today
end
```

## Controller Actions

### Index
- Lists all activities with filters applied
- Supports search by title/description
- Filters by sport_type, category, and personal_record
- Returns filtered collection

### New
- Initializes empty SportActivity object
- Renders form with helpful tips

### Create
- Creates new activity with strong parameters
- Redirects to index on success
- Re-renders form with errors on failure

### Edit
- Loads existing activity
- Shows activity info banner
- Includes danger zone for deletion

### Update
- Updates activity with strong parameters
- Redirects to index on success
- Re-renders form with errors on failure

### Destroy
- Deletes activity
- Shows confirmation dialog
- Redirects to index with success message

## Routes

```ruby
namespace :admin do
  resources :sport_activities
end
```

### Available Routes
- `GET /admin/sport_activities` - Index
- `GET /admin/sport_activities/new` - New form
- `POST /admin/sport_activities` - Create
- `GET /admin/sport_activities/:id/edit` - Edit form
- `PATCH /admin/sport_activities/:id` - Update
- `DELETE /admin/sport_activities/:id` - Destroy

## UI Components

### Color Coding

**Sport Types**
- CrossFit: Orange (`bg-orange-100 text-orange-800`)
- Hyrox: Green (`bg-green-100 text-green-800`)
- Running: Blue (`bg-blue-100 text-blue-800`)

**Categories**
- Benchmark: Purple (`bg-purple-100 text-purple-800`)
- Result: Blue (`bg-blue-100 text-blue-800`)
- Event: Yellow (`bg-yellow-100 text-yellow-800`)

**Status Badges**
- Personal Record: Yellow with star icon
- Upcoming Event: Green
- Completed Event: Gray

### Icons

- **Lightning Bolt**: Sport Activities (general)
- **Plus**: Add new activity
- **Pencil**: Edit activity
- **Trash**: Delete activity
- **External Link**: View result URL
- **Star**: Personal Record
- **Info Circle**: Tips/help

## Usage Examples

### Creating a CrossFit Benchmark
```
Sport Type: CrossFit
Category: Benchmark
Title: Fran
Value: 4:32
Unit: minutes
Description: 21-15-9 Thrusters (95lbs) and Pull-ups
Personal Record: ☑
```

### Creating a Hyrox Result
```
Sport Type: Hyrox
Category: Result
Title: Hyrox Dallas
Value: 1:26:45
Unit: hours
Date: 2025-09-15
Location: Dallas, TX
Personal Record: ☑
Description: New PR! Improved pacing strategy
Result URL: https://hyrox.com/results/...
```

### Creating an Upcoming Event
```
Sport Type: Running
Category: Event
Title: Boston Marathon
Event Name: Boston Marathon
Location: Boston, MA
Date: 2025-04-21
Description: Qualified! BQ-5 minutes. Dream race!
```

## Search & Filter Examples

### Find all CrossFit Personal Records
- Sport Type: CrossFit
- Personal Records: Personal Records Only

### Search for "Marathon" events
- Search: Marathon
- Category: Event

### View all Hyrox results
- Sport Type: Hyrox
- Category: Result

## Best Practices

1. **Consistent Units**: Use standard units (minutes, lbs, kg, km)
2. **Date Accuracy**: Always include dates for results and events
3. **Descriptive Titles**: Use clear, searchable titles
4. **PR Marking**: Only mark true personal records
5. **Result URLs**: Add links to official results when available
6. **Event Details**: Include event name and location for competitions

## Technical Details

### Turbo Frame Integration
- Forms use `turbo: true` for seamless submissions
- Delete confirmations use `data-turbo-confirm`
- Smooth page transitions with Turbo Drive

### Responsive Design
- Mobile-first approach with Tailwind CSS
- Responsive grid layouts (1-2-3 columns)
- Touch-friendly action buttons
- Collapsible table on mobile

### Accessibility
- ARIA labels for screen readers
- Semantic HTML structure
- Keyboard navigation support
- Clear focus indicators
- Proper form validation feedback

## Future Enhancements

- [ ] Bulk import from CSV
- [ ] Activity comparisons (PR vs current)
- [ ] Charts and graphs for progress tracking
- [ ] Export to PDF/spreadsheet
- [ ] Activity photos/videos upload
- [ ] Social sharing capabilities
- [ ] Training plan integration
- [ ] Activity tags/labels
- [ ] Advanced statistics dashboard
- [ ] Activity comments/notes timeline

## Troubleshooting

### Activities not appearing
- Check filters are cleared
- Verify data was saved correctly
- Check database with `rails console`

### Form validation errors
- Ensure sport_type and category are selected
- Title is required
- Check allowed values match model validations

### Delete not working
- Ensure Turbo is loaded
- Check for JavaScript errors
- Verify user permissions

## Support

For issues or feature requests, refer to the main project README or contact the development team.
