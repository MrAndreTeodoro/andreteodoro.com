# Testing Quick Start Guide 🧪

A quick reference for running automated tests in the portfolio management application.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Test Commands](#test-commands)
- [Test Structure](#test-structure)
- [Writing Tests](#writing-tests)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Ensure your development environment is set up:

```bash
# Install dependencies
bin/setup

# Prepare test database
bin/rails db:test:prepare
```

---

## Test Commands

### Run All Tests

```bash
# Run everything
bin/rails test

# Run all model tests
bin/rails test:models

# Run all controller tests (when implemented)
bin/rails test:controllers

# Run all system tests (when implemented)
bin/rails test:system
```

### Run Specific Tests

```bash
# Run single test file
bin/rails test test/models/book_test.rb

# Run single test by line number
bin/rails test test/models/book_test.rb:42

# Run tests matching a pattern
bin/rails test test/models/book_test.rb -n /validation/
```

### Verbose Output

```bash
# Show detailed test output
bin/rails test -v

# Show test names as they run
bin/rails test --verbose
```

### Parallel Execution

```bash
# Run tests in parallel (default)
bin/rails test

# Run tests serially (for debugging)
bin/rails test -j 1
```

---

## Test Structure

### Current Test Coverage

```
test/
├── fixtures/               # Test data
│   ├── books.yml          # 8 book fixtures
│   ├── blog_posts.yml     # Blog post fixtures
│   ├── gear_items.yml     # 14 gear item fixtures
│   ├── projects.yml       # Project fixtures
│   ├── social_links.yml   # 15 social link fixtures
│   └── sport_activities.yml # 13 sport activity fixtures
│
├── models/                 # Model tests (210 tests)
│   ├── book_test.rb       # 48 tests ✅
│   ├── blog_post_test.rb  # 17 tests ✅
│   ├── gear_item_test.rb  # 50 tests ✅
│   ├── project_test.rb    # 33 tests ✅
│   ├── social_link_test.rb # 46 tests ✅
│   └── sport_activity_test.rb # 46 tests ✅
│
└── test_helper.rb          # Test configuration
```

### Test Statistics

- **Total Tests:** 210
- **Total Assertions:** 551
- **Execution Time:** ~0.9 seconds
- **Pass Rate:** 100%
- **Speed:** 225 tests/second

---

## Writing Tests

### Test File Template

```ruby
require "test_helper"

class MyModelTest < ActiveSupport::TestCase
  # Validation Tests
  test "should be valid with valid attributes" do
    record = MyModel.new(required_field: "value")
    assert record.valid?
  end

  test "should require required_field" do
    record = MyModel.new
    assert_not record.valid?
    assert_includes record.errors[:required_field], "can't be blank"
  end

  # Scope Tests
  test "active scope returns only active records" do
    active = MyModel.active
    assert active.all?(&:active?)
  end

  # Helper Method Tests
  test "display_name returns formatted name" do
    record = my_models(:fixture_name)
    assert_equal "Expected Name", record.display_name
  end

  # Callback Tests
  test "sets default value before save" do
    record = MyModel.create!(name: "Test")
    assert_not_nil record.position
  end
end
```

### Testing Patterns

#### 1. Validations

```ruby
# Required field
test "should require field_name" do
  record = Model.new
  assert_not record.valid?
  assert_includes record.errors[:field_name], "can't be blank"
end

# Format validation
test "should validate url format" do
  record = models(:fixture)
  record.url = "invalid"
  assert_not record.valid?
  assert_includes record.errors[:url], "must be a valid URL"
end

# Numericality validation
test "should validate price is non-negative" do
  record = models(:fixture)
  record.price = -1
  assert_not record.valid?
  record.price = 0
  assert record.valid?
end
```

#### 2. Scopes

```ruby
# Filtering scope
test "featured scope returns only featured items" do
  featured = Model.featured
  assert featured.all?(&:featured)
  assert_includes featured, models(:featured_item)
  assert_not_includes featured, models(:normal_item)
end

# Ordering scope
test "recent scope orders by created_at descending" do
  recent = Model.recent
  timestamps = recent.pluck(:created_at)
  assert_equal timestamps, timestamps.sort.reverse
end
```

#### 3. Helper Methods

```ruby
# Boolean helper
test "active? returns true for active records" do
  record = models(:active_record)
  assert record.active?
end

# Formatting helper
test "formatted_price returns price with dollar sign" do
  record = models(:priced_item)
  assert_equal "$99.99", record.formatted_price
end

# Conditional helper
test "has_image? returns true when image present" do
  record = models(:with_image)
  assert record.has_image?
end
```

#### 4. Callbacks

```ruby
# Auto-population
test "sets default position when position is zero" do
  record = Model.create!(name: "Test", position: 0)
  assert record.position > 0
end

# Data normalization
test "normalizes category to lowercase" do
  record = Model.create!(name: "Test", category: "TECH")
  assert_equal "tech", record.category
end
```

### Using Fixtures

```ruby
# Reference fixture in test
test "fixture is loaded correctly" do
  record = books(:atomic_habits)
  assert_equal "Atomic Habits", record.title
  assert_equal 5, record.rating
end

# Create new record in test
test "can create new record" do
  record = Book.create!(
    title: "New Book",
    author: "Test Author"
  )
  assert record.persisted?
end
```

---

## Best Practices

### 1. Test Naming

✅ **Good:**
```ruby
test "should require title"
test "featured scope returns only featured books"
test "star_rating displays correct stars for rated books"
```

❌ **Bad:**
```ruby
test "test_1"
test "validation"
test "it works"
```

### 2. Test Organization

```ruby
class BookTest < ActiveSupport::TestCase
  # Group related tests with comments
  
  # Validation Tests
  test "..." do; end
  
  # Scope Tests
  test "..." do; end
  
  # Helper Method Tests
  test "..." do; end
  
  # Callback Tests
  test "..." do; end
  
  # Integration Tests
  test "..." do; end
end
```

### 3. Assertions

```ruby
# Use specific assertions
assert_equal expected, actual     # Equality
assert_not_equal a, b            # Inequality
assert_nil value                 # Nil check
assert_not_nil value             # Not nil check
assert_includes collection, item # Membership
assert_kind_of Class, object     # Type check
assert_empty collection          # Empty check
assert record.valid?             # Validity
assert_not record.valid?         # Invalidity
```

### 4. Test Data

- Use fixtures for shared test data
- Create records inline for specific test cases
- Keep fixture data realistic and diverse
- Test edge cases (nil, blank, zero, negative)

---

## Troubleshooting

### Tests Fail After Model Changes

```bash
# Reset test database
bin/rails db:test:prepare

# If fixtures are invalid, check:
bin/rails db:fixtures:load RAILS_ENV=test
```

### Slow Tests

```bash
# Run with profiling
bin/rails test --profile

# Check for N+1 queries in tests
# Use includes/eager_loading in scopes
```

### Random Failures

```bash
# Run with specific seed to reproduce
bin/rails test --seed 12345

# Run tests serially
bin/rails test -j 1
```

### Fixture Errors

```yaml
# Ensure fixture has all required fields
book:
  title: "Required Title"
  author: "Required Author"
  # Optional fields can be omitted or nil
```

### Database Issues

```bash
# Drop and recreate test database
bin/rails db:test:prepare

# Check for pending migrations
bin/rails db:migrate:status RAILS_ENV=test
```

---

## CI Integration

### GitHub Actions (Coming Soon)

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
      - name: Install dependencies
        run: bundle install
      - name: Setup database
        run: bin/rails db:test:prepare
      - name: Run tests
        run: bin/rails test
```

---

## Test Coverage (Future)

### Adding SimpleCov

```ruby
# Gemfile
group :test do
  gem 'simplecov', require: false
end

# test/test_helper.rb (at the top)
require 'simplecov'
SimpleCov.start 'rails'

# Run tests with coverage
COVERAGE=true bin/rails test

# View report at coverage/index.html
```

---

## Quick Reference Card

```
# Run all tests
bin/rails test

# Run model tests only
bin/rails test:models

# Run single file
bin/rails test test/models/book_test.rb

# Run single test
bin/rails test test/models/book_test.rb:42

# Verbose output
bin/rails test -v

# With specific seed
bin/rails test --seed 12345

# Full CI check
bin/ci
```

---

## Current Test Status

✅ **Model Tests:** 210 tests, 551 assertions, 100% pass rate  
🟡 **Controller Tests:** Not yet implemented  
🟡 **System Tests:** Not yet implemented  
🟡 **Integration Tests:** Not yet implemented  

**Next Steps:**
1. Implement controller tests for all admin CRUD operations
2. Add system tests for critical user workflows
3. Set up test coverage reporting with SimpleCov
4. Integrate tests into CI/CD pipeline

---

## Additional Resources

- **Main Documentation:** [AUTOMATED_TESTING_COMPLETE.md](./AUTOMATED_TESTING_COMPLETE.md)
- **Testing Summary:** [AUTOMATED_TESTING_SUMMARY.md](./AUTOMATED_TESTING_SUMMARY.md)
- **Rails Testing Guide:** https://guides.rubyonrails.org/testing.html
- **Minitest Documentation:** https://github.com/minitest/minitest

---

**Last Updated:** January 24, 2025  
**Test Framework:** Minitest  
**Rails Version:** 8.1.1  
**Ruby Version:** 3.4.3

---

*Keep your tests green! 🧪✅*
