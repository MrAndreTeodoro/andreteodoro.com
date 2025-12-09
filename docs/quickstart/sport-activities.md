# Sport Activities CRUD - Quick Start Guide

## 🚀 Getting Started

### Access the Admin Interface

1. **Start the Rails server** (if not already running):
   ```bash
   bin/dev
   ```

2. **Login to Admin**:
   - URL: `http://localhost:3000/admin/session/new`
   - Email: `admin@example.com`
   - Password: `password`

3. **Navigate to Sport Activities**:
   - From dashboard, click "Manage Sports →"
   - Or go directly to: `http://localhost:3000/admin/sport_activities`

---

## 📋 Common Tasks

### 1. Create a New Activity

**Quick Example - CrossFit Fran**
```
Click "Add Sport Activity" button
→ Sport Type: CrossFit
→ Category: Benchmark
→ Title: Fran
→ Value: 4:32
→ Unit: minutes
→ Description: 21-15-9 Thrusters (95lbs) and Pull-ups
→ Personal Record: ☑ (checked)
→ Click "Create Activity"
```

**Quick Example - Race Result**
```
Click "Add Sport Activity" button
→ Sport Type: Running
→ Category: Result
→ Title: Half Marathon PR
→ Value: 1:42:18
→ Unit: hours
→ Date: 2025-06-15
→ Location: San Diego, CA
→ Personal Record: ☑ (checked)
→ Click "Create Activity"
```

**Quick Example - Upcoming Event**
```
Click "Add Sport Activity" button
→ Sport Type: Hyrox
→ Category: Event
→ Title: World Championships
→ Event Name: Hyrox World Championships
→ Location: Nice, France
→ Date: 2025-05-24
→ Description: Qualified for worlds!
→ Click "Create Activity"
```

### 2. Search for Activities

**By Text**:
- Enter search term in search box (e.g., "Marathon", "Fran", "PR")
- Click "Apply Filters"

**By Sport Type**:
- Select "CrossFit", "Hyrox", or "Running" from Sport Type dropdown
- Click "Apply Filters"

**By Category**:
- Select "Benchmark", "Result", or "Event" from Category dropdown
- Click "Apply Filters"

**Personal Records Only**:
- Select "Personal Records Only" from Personal Records dropdown
- Click "Apply Filters"

**Combined Filters**:
- You can combine any filters together!
- Example: CrossFit + Personal Records Only = All CrossFit PRs

### 3. Edit an Activity

1. Find the activity in the table
2. Click the pencil/edit icon on the right
3. Modify any fields
4. Click "Update Activity"

### 4. Delete an Activity

**From Edit Page**:
1. Click edit icon on activity
2. Scroll to "Danger Zone" (red section at bottom)
3. Click "Delete Activity"
4. Confirm deletion in popup

**From Index Page**:
1. Click trash icon on activity row
2. Confirm deletion in popup

---

## 🎨 Understanding the Interface

### Badge Colors

**Sport Types**:
- 🟠 Orange = CrossFit
- 🟢 Green = Hyrox
- 🔵 Blue = Running

**Categories**:
- 🟣 Purple = Benchmark (standard workouts)
- 🔵 Blue = Result (competition/test results)
- 🟡 Yellow = Event (upcoming/past events)

**Status**:
- ⭐ Yellow with star = Personal Record
- 🟢 Green = Upcoming Event
- ⚫ Gray = Completed Event

### Icons Explained

- ➕ Plus = Add new
- ✏️ Pencil = Edit
- 🗑️ Trash = Delete
- 🔗 Link with arrow = View result URL
- ⭐ Star = Personal Record

---

## 💡 Pro Tips

### When to Use Each Category

**Benchmark**:
- Standard workouts you track over time
- Examples: "Fran", "Back Squat 1RM", "5K PR", "Mile Time"
- Used for: Tracking improvements on specific movements/workouts

**Result**:
- Actual performance from a specific date
- Examples: "CrossFit Open 24.1", "Murph on Memorial Day", "Half Marathon Result"
- Used for: Recording actual competition/workout results

**Event**:
- Upcoming or past events/competitions
- Examples: "Boston Marathon", "CrossFit Games", "Hyrox Championships"
- Used for: Planning and tracking event participation

### Marking Personal Records

✅ **DO mark as PR**:
- Your absolute best result for a specific workout/distance
- New record that beats your previous best
- First time completing something (can be a PR until you beat it)

❌ **DON'T mark as PR**:
- Good results that aren't your best
- Every event or competition
- Benchmarks (unless it's your current best result)

### Using Result URLs

Great uses for Result URL field:
- Official race results page
- Leaderboard link (CrossFit Open, Hyrox, etc.)
- YouTube video of your performance
- Strava activity
- Instagram post
- Competition website

Example URLs:
- `https://games.crossfit.com/athlete/12345`
- `https://hyrox.com/results/event-123/athlete-456`
- `https://www.strava.com/activities/123456789`
- `https://www.youtube.com/watch?v=ABC123`

---

## 🔍 Quick Searches

### Find All PRs
- Personal Records: "Personal Records Only"
- Click "Apply Filters"

### Find Upcoming Events
- Category: "Event"
- Click "Apply Filters"
- Look for green "Upcoming" badges

### Find All CrossFit Benchmarks
- Sport Type: "CrossFit"
- Category: "Benchmark"
- Click "Apply Filters"

### Search for Specific Workout
- Search box: Enter workout name (e.g., "Fran")
- Click "Apply Filters"

---

## 📊 Statistics Dashboard

At the top of the index page, you'll see 4 metric cards:

1. **Total Activities** - Count of all sport activities
2. **Personal Records** - Count of activities marked as PRs
3. **CrossFit** - Count of CrossFit activities
4. **Hyrox** - Count of Hyrox activities

These update automatically based on your filters!

---

## ⚡ Keyboard Shortcuts

While no custom shortcuts are defined, standard browser shortcuts work:

- `Tab` - Navigate between form fields
- `Enter` - Submit forms
- `Esc` - Close confirmation dialogs
- `Ctrl/Cmd + Click` on edit icon - Open in new tab

---

## 🐛 Troubleshooting

### "Can't create activity"
- ✅ Check that Sport Type is selected
- ✅ Check that Category is selected
- ✅ Check that Title is filled in
- These three fields are **required**

### "Activities not showing"
- Click "Clear Filters" button
- Check if you have any filters applied
- Verify data exists: Check stats cards at top

### "Delete confirmation not appearing"
- Ensure JavaScript is enabled
- Try refreshing the page
- Check browser console for errors

### "Form errors not clear"
- Look for red border around fields
- Check error summary at top of form (red box)
- Scroll up to see all validation messages

---

## 📱 Mobile Usage

The interface is fully responsive!

### Mobile Tips:
- Swipe horizontally on table to see all columns
- Use "hamburger" menu to access admin navigation
- Filters stack vertically for easier access
- Action buttons are touch-friendly (larger targets)

---

## 🎯 Sample Workflows

### Workflow 1: After a Competition
1. Go to Sport Activities
2. Click "Add Sport Activity"
3. Select sport type and "Result" category
4. Enter title, value, unit, date
5. Add event name and location
6. Paste result URL if available
7. Check "Personal Record" if applicable
8. Click "Create Activity"

### Workflow 2: Setting Up Benchmarks
1. Create activities with "Benchmark" category
2. Don't add dates or event info
3. Focus on standard workouts you track
4. Mark current best as PR
5. Later, create "Result" entries when you test them

### Workflow 3: Planning Competition Season
1. Create "Event" entries for each competition
2. Add dates in chronological order
3. Include event names and locations
4. After competing, create "Result" entry
5. Add result URL to event entry

---

## 📚 Data Entry Standards

### Recommended Formats

**Times**:
- Minutes: `4:32`, `21:45`
- Hours: `1:42:18`, `3:35:42`
- Seconds: `45.3`, `12.8`

**Weights**:
- `315`, `225`, `95`

**Distances**:
- `5`, `10`, `26.2`

**Reps**:
- `245`, `100`, `50`

**Units**:
- `minutes`, `hours`, `seconds`
- `lbs`, `kg`
- `km`, `miles`
- `reps`, `rounds`

---

## ✅ Checklist for Complete Entry

### Minimal Entry (Required)
- [ ] Sport Type selected
- [ ] Category selected
- [ ] Title filled in

### Good Entry (Recommended)
- [ ] Value and unit added
- [ ] Description provided
- [ ] Date added (for results/events)
- [ ] Personal Record marked if applicable

### Excellent Entry (Best Practice)
- [ ] All fields above complete
- [ ] Event name and location (if applicable)
- [ ] Result URL added
- [ ] Descriptive, searchable title
- [ ] Detailed description with context

---

## 🎓 Learn By Example

Check the seeded data (31 sample activities) for examples:

```bash
# View in console
bin/rails console
SportActivity.first(5).each { |a| puts "#{a.title} - #{a.sport_type} - #{a.category}" }
```

Or browse the index page - sample data includes:
- CrossFit benchmarks (Fran, Back Squat, etc.)
- Hyrox races with times
- Marathon and race results
- Upcoming events

---

## 🚀 Next Steps

1. ✅ Create your first activity
2. ✅ Experiment with filters
3. ✅ Edit an activity
4. ✅ Mark a Personal Record
5. ✅ Add a future event
6. ✅ Link to an official result

---

## 📞 Need Help?

- 📖 Full documentation: `docs/SPORT_ACTIVITIES_CRUD.md`
- 🏗️ Implementation details: `SPORT_ACTIVITIES_IMPLEMENTATION.md`
- 💻 Check the code: `app/controllers/admin/sport_activities_controller.rb`
- 🎨 View templates: `app/views/admin/sport_activities/`

---

**Happy tracking! 🏃‍♂️🏋️‍♂️💪**
