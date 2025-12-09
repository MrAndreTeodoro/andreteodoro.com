class Admin::BooksController < Admin::BaseController
  before_action :set_book, only: [ :edit, :update, :destroy, :purge_cover_image ]

  def index
    @books = Book.all.order(read_date: :desc, created_at: :desc)

    # Filter by category if provided
    if params[:category].present?
      @books = @books.where(category: params[:category])
    end

    # Filter by rating if provided
    if params[:rating].present?
      @books = @books.where(rating: params[:rating])
    end

    # Filter by featured
    if params[:featured] == "true"
      @books = @books.where(featured: true)
    end

    # Filter by reviewed
    if params[:reviewed] == "true"
      @books = @books.where.not(review: nil)
    end

    # Search by title or author
    if params[:search].present?
      @books = @books.where(
        "title LIKE ? OR author LIKE ?",
        "%#{params[:search]}%",
        "%#{params[:search]}%"
      )
    end
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to admin_books_path, notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to admin_books_path, notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to admin_books_path, notice: "Book was successfully deleted.", status: :see_other
  end

  def purge_cover_image
    if @book.cover_image.attached?
      @book.cover_image.purge
      redirect_to edit_admin_book_path(@book), notice: "Cover image was successfully removed."
    else
      redirect_to edit_admin_book_path(@book), alert: "No cover image to remove."
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :title,
      :author,
      :category,
      :rating,
      :review,
      :notes,
      :read_date,
      :featured,
      :isbn,
      :cover_url,
      :cover_image,
      :affiliate_link
    )
  end
end
