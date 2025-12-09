require "test_helper"

class BookTest < ActiveSupport::TestCase
  # Validation Tests
  test "should be valid with valid attributes" do
    book = Book.new(
      title: "Test Book",
      author: "Test Author",
      read_date: Date.today
    )
    assert book.valid?
  end

  test "should require title" do
    book = Book.new(author: "Test Author")
    assert_not book.valid?
    assert_includes book.errors[:title], "can't be blank"
  end

  test "should require author" do
    book = Book.new(title: "Test Book")
    assert_not book.valid?
    assert_includes book.errors[:author], "can't be blank"
  end

  test "should validate rating is between 1 and 5" do
    book = books(:atomic_habits)

    book.rating = 0
    assert_not book.valid?
    assert_includes book.errors[:rating], "is not included in the list"

    book.rating = 6
    assert_not book.valid?

    book.rating = 1
    assert book.valid?

    book.rating = 5
    assert book.valid?

    book.rating = 3
    assert book.valid?
  end

  test "should allow nil rating" do
    book = books(:unrated_book)
    assert book.valid?
    assert_nil book.rating
  end

  test "should validate affiliate_link format when present" do
    book = books(:atomic_habits)

    book.affiliate_link = "invalid-url"
    assert_not book.valid?
    assert_includes book.errors[:affiliate_link], "must be a valid URL"

    book.affiliate_link = "https://example.com"
    assert book.valid?

    book.affiliate_link = "http://example.com/book"
    assert book.valid?

    book.affiliate_link = ""
    assert book.valid? # Blank is allowed

    book.affiliate_link = nil
    assert book.valid? # Nil is allowed
  end

  # Scope Tests
  test "reviewed scope returns only books with reviews" do
    reviewed = Book.reviewed
    assert reviewed.all? { |b| b.review.present? }
    assert_includes reviewed, books(:atomic_habits)
    assert_includes reviewed, books(:deep_work)
    assert_not_includes reviewed, books(:sapiens)
  end

  test "reviewed scope orders by read_date descending" do
    reviewed = Book.reviewed
    read_dates = reviewed.pluck(:read_date)
    assert_equal read_dates, read_dates.sort.reverse
  end

  test "with_notes scope returns only books with notes" do
    with_notes = Book.with_notes
    assert with_notes.all? { |b| b.notes.present? }
    assert_includes with_notes, books(:atomic_habits)
    assert_includes with_notes, books(:sapiens)
    assert_not_includes with_notes, books(:deep_work)
  end

  test "featured scope returns only featured books" do
    featured = Book.featured
    assert featured.all?(&:featured)
    assert_includes featured, books(:atomic_habits)
    assert_includes featured, books(:sapiens)
    assert_not_includes featured, books(:deep_work)
  end

  test "featured scope orders by read_date descending" do
    featured = Book.featured
    read_dates = featured.pluck(:read_date)
    assert_equal read_dates, read_dates.sort.reverse
  end

  test "by_category scope filters by category" do
    productivity_books = Book.by_category("productivity")
    assert productivity_books.all? { |b| b.category == "productivity" }
    assert_includes productivity_books, books(:atomic_habits)
    assert_includes productivity_books, books(:deep_work)
    assert_not_includes productivity_books, books(:sapiens)
  end

  test "by_category scope orders by read_date descending" do
    productivity_books = Book.by_category("productivity")
    read_dates = productivity_books.pluck(:read_date)
    assert_equal read_dates, read_dates.sort.reverse
  end

  test "recently_read scope returns last 10 books" do
    recently_read = Book.recently_read
    assert recently_read.count <= 10
  end

  test "recently_read scope orders by read_date descending" do
    recently_read = Book.recently_read
    read_dates = recently_read.pluck(:read_date)
    assert_equal read_dates, read_dates.sort.reverse
  end

  test "top_rated scope returns books with rating 4 or 5" do
    top_rated = Book.top_rated
    assert top_rated.all? { |b| b.rating.present? && b.rating >= 4 }
    assert_includes top_rated, books(:atomic_habits)
    assert_includes top_rated, books(:deep_work)
    assert_not_includes top_rated, books(:low_rated)
  end

  test "top_rated scope orders by rating then read_date descending" do
    top_rated = Book.top_rated
    # 5-star books should come before 4-star books
    ratings = top_rated.pluck(:rating)
    assert_equal ratings, ratings.sort.reverse
  end

  test "by_rating scope filters by specific rating" do
    five_star = Book.by_rating(5)
    assert five_star.all? { |b| b.rating == 5 }
    assert_includes five_star, books(:atomic_habits)
    assert_includes five_star, books(:sapiens)
    assert_not_includes five_star, books(:deep_work)

    four_star = Book.by_rating(4)
    assert four_star.all? { |b| b.rating == 4 }
    assert_includes four_star, books(:deep_work)
  end

  # Helper Method Tests
  test "star_rating displays correct stars for rated books" do
    book_5_stars = books(:atomic_habits)
    assert_equal "★★★★★", book_5_stars.star_rating

    book_4_stars = books(:deep_work)
    assert_equal "★★★★☆", book_4_stars.star_rating

    book_2_stars = books(:low_rated)
    assert_equal "★★☆☆☆", book_2_stars.star_rating
  end

  test "star_rating returns message for unrated books" do
    book = books(:unrated_book)
    assert_equal "Not rated", book.star_rating
  end

  test "has_review? returns true when review present" do
    book = books(:atomic_habits)
    assert book.has_review?
  end

  test "has_review? returns false when review blank" do
    book = books(:sapiens)
    assert_not book.has_review?
  end

  test "has_notes? returns true when notes present" do
    book = books(:atomic_habits)
    assert book.has_notes?
  end

  test "has_notes? returns false when notes blank" do
    book = books(:deep_work)
    assert_not book.has_notes?
  end

  test "read_this_year? returns true for books read this year" do
    book = books(:current_year_book)
    assert book.read_this_year?
  end

  test "read_this_year? returns false for books read in previous years" do
    # Create a book with a read_date from last year
    book = Book.new(
      title: "Old Book",
      author: "Test Author",
      read_date: Date.new(Date.today.year - 1, 6, 15)
    )
    assert_not book.read_this_year?
  end

  test "read_this_year? returns false when read_date is nil" do
    book = Book.new(title: "Test", author: "Author", read_date: nil)
    assert_not book.read_this_year?
  end

  test "excerpt returns truncated review" do
    book = books(:atomic_habits)
    excerpt = book.excerpt(50)
    assert excerpt.length <= 53 # 50 + "..."
    assert excerpt.include?("...")
  end

  test "excerpt uses custom length" do
    book = books(:atomic_habits)
    short_excerpt = book.excerpt(20)
    long_excerpt = book.excerpt(100)
    assert short_excerpt.length < long_excerpt.length
  end

  test "excerpt uses default length of 150" do
    book = books(:atomic_habits)
    default_excerpt = book.excerpt
    # Verify it uses default length
    assert default_excerpt.length <= 153
  end

  test "excerpt returns empty string when no review" do
    book = books(:sapiens)
    assert_equal "", book.excerpt
  end

  # Callback Tests
  test "normalizes category to lowercase before validation" do
    book = Book.create!(
      title: "Test Book",
      author: "Test Author",
      category: "BUSINESS"
    )
    assert_equal "business", book.category
  end

  test "normalizes category strips whitespace" do
    book = Book.create!(
      title: "Test Book",
      author: "Test Author",
      category: "  productivity  "
    )
    assert_equal "productivity", book.category
  end

  test "normalizes mixed case category" do
    book = books(:tech_book)
    # Fixture has "Programming" which should be normalized
    book.save!
    assert_equal "programming", book.category
  end

  test "handles nil category in normalization" do
    book = Book.new(
      title: "Test Book",
      author: "Test Author",
      category: nil
    )
    assert book.valid?
    assert_nil book.category
  end

  # Integration Tests
  test "can create book with only required fields" do
    book = Book.create!(
      title: "Minimal Book",
      author: "Minimal Author"
    )
    assert book.persisted?
    assert_equal "Minimal Book", book.title
    assert_equal "Minimal Author", book.author
  end

  test "can create book with all fields" do
    book = Book.create!(
      title: "Complete Book",
      author: "Complete Author",
      cover_url: "https://example.com/cover.jpg",
      affiliate_link: "https://amazon.com/book",
      review: "Great book!",
      notes: "Key insights here.",
      rating: 5,
      read_date: Date.today,
      isbn: "9781234567890",
      category: "test",
      featured: true
    )
    assert book.persisted?
    assert book.featured
    assert_equal 5, book.rating
  end

  test "multiple books can have same category" do
    productivity_books = Book.by_category("productivity")
    assert productivity_books.count >= 2
  end

  test "books with same rating can exist" do
    five_star_books = Book.by_rating(5)
    assert five_star_books.count >= 2
  end
end
