class Book < ApplicationRecord
  # ActiveStorage
  has_one_attached :cover_image

  # Rich Text
  has_rich_text :review
  has_rich_text :notes

  # Validations
  validates :title, presence: true
  validates :author, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validates :affiliate_link, format: { with: URI::DEFAULT_PARSER.make_regexp([ "http", "https" ]), message: "must be a valid URL" }, allow_blank: true

  # Scopes
  scope :reviewed, -> { joins(:rich_text_review).order(read_date: :desc) }
  scope :with_notes, -> { joins(:rich_text_notes) }
  scope :featured, -> { where(featured: true).order(read_date: :desc) }
  scope :by_category, ->(category) { where(category: category).order(read_date: :desc) }
  scope :recently_read, -> { order(read_date: :desc).limit(10) }
  scope :top_rated, -> { where(rating: 4..5).order(rating: :desc, read_date: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }

  # Callbacks
  before_validation :normalize_category

  # Helper methods
  def star_rating
    return "Not rated" if rating.nil?
    return "Invalid rating" if rating < 1 || rating > 5
    "★" * rating + "☆" * (5 - rating)
  end

  def has_review?
    review.present?
  end

  def has_notes?
    notes.present?
  end

  def read_this_year?
    read_date.present? && read_date.year == Date.today.year
  end

  def excerpt(length = 150)
    return "" unless review.present?
    review.to_plain_text.truncate(length, separator: " ")
  end

  def cover_image_url
    if cover_image.attached?
      cover_image
    elsif cover_url.present?
      cover_url
    else
      nil
    end
  end

  def has_cover?
    cover_image.attached? || cover_url.present?
  end

  private

  def normalize_category
    self.category = category.to_s.downcase.strip if category.present?
  end
end
