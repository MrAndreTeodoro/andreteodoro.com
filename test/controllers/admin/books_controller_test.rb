require "test_helper"

class Admin::BooksControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @book = books(:atomic_habits)
    sign_in_as_admin
  end

  # Index Tests
  test "should get index" do
    get admin_books_url
    assert_response :success
  end

  test "should filter by category" do
    get admin_books_url, params: { category: "productivity" }
    assert_response :success
  end

  test "should filter by rating" do
    get admin_books_url, params: { rating: "5" }
    assert_response :success
  end

  test "should filter by featured" do
    get admin_books_url, params: { featured: "true" }
    assert_response :success
  end

  test "should filter by reviewed" do
    get admin_books_url, params: { reviewed: "true" }
    assert_response :success
  end

  test "should search books by title" do
    get admin_books_url, params: { search: "Atomic" }
    assert_response :success
  end

  test "should search books by author" do
    get admin_books_url, params: { search: "Clear" }
    assert_response :success
  end

  # New Tests
  test "should get new" do
    get new_admin_book_url
    assert_response :success
    assert_select "form"
    assert_select "input[name='book[title]']"
    assert_select "input[name='book[author]']"
  end

  # Create Tests
  test "should create book with valid params" do
    assert_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: "New Book",
          author: "New Author",
          category: "business",
          rating: 4
        }
      }
    end

    assert_redirected_to admin_books_url
    assert_equal "Book was successfully created.", flash[:notice]
  end

  test "should create book with all fields" do
    assert_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: "Complete Book",
          author: "Complete Author",
          category: "tech",
          rating: 5,
          review: "Great book!",
          notes: "Key insights here",
          read_date: Date.today,
          featured: true,
          isbn: "9781234567890",
          cover_url: "https://example.com/cover.jpg",
          affiliate_link: "https://amazon.com/book"
        }
      }
    end

    book = Book.find_by(title: "Complete Book")
    assert book.featured
    assert_equal 5, book.rating
    assert_equal "tech", book.category
  end

  test "should not create book without title" do
    assert_no_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: "",
          author: "Author"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create book without author" do
    assert_no_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: "Title",
          author: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create book with invalid rating" do
    assert_no_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: "Title",
          author: "Author",
          rating: 6
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create book with invalid affiliate link" do
    assert_no_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: "Title",
          author: "Author",
          affiliate_link: "not-a-url"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should create book without rating" do
    assert_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: "Unrated Book",
          author: "Author",
          rating: ""
        }
      }
    end

    book = Book.find_by(title: "Unrated Book")
    assert_nil book.rating
  end

  # Edit Tests
  test "should get edit" do
    get edit_admin_book_url(@book)
    assert_response :success
    assert_select "form"
    assert_select "input[name='book[title]'][value=?]", @book.title
    assert_select "input[name='book[author]'][value=?]", @book.author
  end

  # Update Tests
  test "should update book with valid params" do
    patch admin_book_url(@book), params: {
      book: {
        title: "Updated Title",
        author: "Updated Author"
      }
    }

    assert_redirected_to admin_books_url
    assert_equal "Book was successfully updated.", flash[:notice]

    @book.reload
    assert_equal "Updated Title", @book.title
    assert_equal "Updated Author", @book.author
  end

  test "should update book rating" do
    patch admin_book_url(@book), params: {
      book: { rating: 3 }
    }

    @book.reload
    assert_equal 3, @book.rating
  end

  test "should update book category" do
    patch admin_book_url(@book), params: {
      book: { category: "fiction" }
    }

    @book.reload
    assert_equal "fiction", @book.category
  end

  test "should toggle book featured status" do
    original_featured = @book.featured

    patch admin_book_url(@book), params: {
      book: { featured: !original_featured }
    }

    @book.reload
    assert_equal !original_featured, @book.featured
  end

  test "should update book review and notes" do
    patch admin_book_url(@book), params: {
      book: {
        review: "Updated review content",
        notes: "Updated notes content"
      }
    }

    @book.reload
    assert_equal "Updated review content", @book.review.to_plain_text
    assert_equal "Updated notes content", @book.notes.to_plain_text
  end

  test "should not update book with invalid title" do
    original_title = @book.title

    patch admin_book_url(@book), params: {
      book: { title: "" }
    }

    assert_response :unprocessable_entity

    @book.reload
    assert_equal original_title, @book.title
  end

  test "should not update book with invalid author" do
    original_author = @book.author

    patch admin_book_url(@book), params: {
      book: { author: "" }
    }

    assert_response :unprocessable_entity

    @book.reload
    assert_equal original_author, @book.author
  end

  test "should not update book with invalid rating" do
    original_rating = @book.rating

    patch admin_book_url(@book), params: {
      book: { rating: 0 }
    }

    assert_response :unprocessable_entity

    @book.reload
    assert_equal original_rating, @book.rating
  end

  # Destroy Tests
  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete admin_book_url(@book)
    end

    assert_redirected_to admin_books_url
    assert_equal "Book was successfully deleted.", flash[:notice]
  end

  test "should not find destroyed book" do
    book_id = @book.id
    delete admin_book_url(@book)

    assert_raises(ActiveRecord::RecordNotFound) do
      Book.find(book_id)
    end
  end

  # Authorization Tests
  test "should require authentication for index" do
    sign_out

    get admin_books_url
    assert_redirected_to new_session_url
  end

  test "should require authentication for new" do
    sign_out

    get new_admin_book_url
    assert_redirected_to new_session_url
  end

  test "should require authentication for create" do
    sign_out

    post admin_books_url, params: {
      book: {
        title: "Test",
        author: "Author"
      }
    }
    assert_redirected_to new_session_url
  end

  test "should require authentication for edit" do
    sign_out

    get edit_admin_book_url(@book)
    assert_redirected_to new_session_url
  end

  test "should require authentication for update" do
    sign_out

    patch admin_book_url(@book), params: {
      book: { title: "Updated" }
    }
    assert_redirected_to new_session_url
  end

  test "should require authentication for destroy" do
    sign_out

    delete admin_book_url(@book)
    assert_redirected_to new_session_url
  end

  # Edge Cases
  test "should handle book with long title" do
    long_title = "A" * 300

    assert_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: long_title,
          author: "Author"
        }
      }
    end

    book = Book.find_by(author: "Author")
    assert_equal long_title, book.title
  end

  test "should handle book with special characters in title" do
    special_title = "Test: Book & Special 'Characters' (2024)"

    assert_difference("Book.count") do
      post admin_books_url, params: {
        book: {
          title: special_title,
          author: "Author"
        }
      }
    end

    book = Book.find_by(title: special_title)
    assert_not_nil book
  end

  test "should handle multiple books with same category" do
    get admin_books_url, params: { category: "productivity" }
    assert_response :success
  end

  test "should handle empty search query" do
    get admin_books_url, params: { search: "" }
    assert_response :success
  end

  test "should handle search with no results" do
    get admin_books_url, params: { search: "NonExistentBookTitle123" }
    assert_response :success
  end
end
