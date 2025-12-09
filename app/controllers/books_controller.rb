class BooksController < ApplicationController
  def index
    @categories = Book.pluck(:category).uniq.compact.sort
    @selected_category = params[:category]

    if @selected_category.present?
      @books = Book.by_category(@selected_category).reviewed
    else
      @books = Book.reviewed
    end

    @featured_books = Book.featured.limit(3)
    @top_rated_books = Book.top_rated.limit(5)
  end
end
