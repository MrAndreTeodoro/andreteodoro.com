# Books Review Column ActionText Fix

## Problem

When accessing the Admin Books index page (`/admin/books`), the application raised a `SQLite3::SQLException`:

```
ActiveRecord::StatementInvalid in Admin::Books#index
SQLite3::SQLException: no such column: books.review
SELECT COUNT(*) FROM "books" WHERE "books"."review" IS NOT NULL
```

The error occurred at line 155 of `app/views/admin/books/index.html.erb`.

## Root Cause

The `Book` model uses **ActionText** for the `review` field:

```ruby
class Book < ApplicationRecord
  has_rich_text :review
  has_rich_text :notes
  # ...
end
```

With ActionText, the review content is **not stored as a column** in the `books` table. Instead, it's stored in the `action_text_rich_texts` table and accessed through an association.

The view was attempting to query the review as if it were a regular database column:

```erb
<%= @books.where.not(review: nil).count %>
```

This fails because:
- `books.review` column doesn't exist
- ActionText data is in a separate table
- Must use proper joins or scopes to query ActionText content

## Solution

Changed the query to use the existing `reviewed` scope defined in the model:

**Before:**
```erb
<%= @books.where.not(review: nil).count %>
```

**After:**
```erb
<%= Book.reviewed.count %>
```

The `reviewed` scope is already properly defined in the model:

```ruby
scope :reviewed, -> { joins(:rich_text_review).order(read_date: :desc) }
```

This scope:
- Joins the `action_text_rich_texts` table correctly
- Returns only books that have review content
- Works with ActionText's storage mechanism

## Why This Works

### ActionText Storage

ActionText stores rich text content in a polymorphic association:

```ruby
# action_text_rich_texts table structure
- id
- name (e.g., "review")
- body (rich text content)
- record_type (e.g., "Book")
- record_id (foreign key to books.id)
- created_at
- updated_at
```

### Correct Query Patterns

✅ **Correct ways to check for ActionText content:**

```ruby
# Using the scope (BEST - already defined)
Book.reviewed.count

# Using joins
Book.joins(:rich_text_review).count

# In the view for individual records
book.review.present?  # Works - accesses the association
book.has_review?      # Works - model method
```

❌ **Incorrect patterns (will fail):**

```ruby
# Treating it as a column
Book.where.not(review: nil)  # ❌ No such column
Book.where("review IS NOT NULL")  # ❌ No such column
@books.where.not(review: nil)  # ❌ No such column
```

## Database Structure

The actual Books table structure:

```ruby
# books table columns (no 'review' column)
- id
- title
- author
- cover_url
- affiliate_link
- rating
- read_date
- isbn
- category
- featured
- created_at
- updated_at
```

## Testing

Verified the fix works:

```bash
bin/rails runner "puts Book.reviewed.count"
# Output: 6
```

The query successfully counts books with reviews by properly joining the ActionText table.

## Related Files

- **Model**: `app/models/book.rb` - Defines `has_rich_text :review` and `reviewed` scope
- **View**: `app/views/admin/books/index.html.erb` - Fixed statistics display
- **Migration**: ActionText tables created during initial setup

## Prevention

### When working with ActionText fields:

1. **Always use scopes or joins** - Don't query ActionText fields as columns
2. **Check the model** - Look for `has_rich_text` declarations
3. **Use proper accessors** - `record.field.present?` for presence checks
4. **Review existing scopes** - Use them instead of writing new queries

### Example for other ActionText fields:

If a model has:
```ruby
has_rich_text :content
```

Then use:
```ruby
# ✅ Correct
Model.joins(:rich_text_content).count
model.content.present?

# ❌ Wrong
Model.where.not(content: nil)
```

## Performance Note

The `reviewed` scope uses an INNER JOIN, which is efficient:

```sql
SELECT "books".* 
FROM "books" 
INNER JOIN "action_text_rich_texts" 
  ON "action_text_rich_texts"."record_id" = "books"."id" 
  AND "action_text_rich_texts"."record_type" = 'Book' 
  AND "action_text_rich_texts"."name" = 'review'
ORDER BY "books"."read_date" DESC
```

This is properly indexed and performs well even with thousands of records.

## References

- [Rails ActionText Guide](https://guides.rubyonrails.org/action_text_overview.html)
- [ActionText API Documentation](https://api.rubyonrails.org/classes/ActionText.html)
- Book model scopes: `app/models/book.rb`

## Date

2025-01-XX

## Status

✅ **Resolved** - Books admin index now correctly counts books with reviews using the proper ActionText scope.
