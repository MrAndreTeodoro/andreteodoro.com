class BlogPost < ApplicationRecord
  # Rich Text
  has_rich_text :content
  has_rich_text :excerpt

  # Attachments
  has_one_attached :featured_image

  # Virtual attributes
  attr_accessor :remove_featured_image

  # Callbacks
  before_save :purge_featured_image, if: :remove_featured_image?

  # Validations
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  # Scopes
  scope :published, -> { where("published_at IS NOT NULL AND published_at <= ?", Time.current).order(published_at: :desc) }
  scope :scheduled, -> { where("published_at > ?", Time.current).order(published_at: :asc) }
  scope :drafted, -> { where(published_at: nil).order(created_at: :desc) }
  scope :viral, -> { where(viral: true).published.order(published_at: :desc) }
  scope :featured, -> { where(featured: true).published.order(published_at: :desc) }
  scope :recent, -> { published.limit(5) }
  scope :popular, -> { published.order(views_count: :desc).limit(10) }
  scope :by_year, ->(year) { published.where("EXTRACT(YEAR FROM published_at) = ?", year) }

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  before_save :calculate_reading_time

  # Helper methods
  def published?
    published_at.present? && published_at <= Time.current
  end

  def draft?
    published_at.nil?
  end

  def scheduled?
    published_at.present? && published_at > Time.current
  end

  def publish!
    update(published_at: Time.current)
  end

  def unpublish!
    update(published_at: nil)
  end

  def short_excerpt(length = 150)
    return "" unless excerpt.present?
    excerpt.to_plain_text.truncate(length, separator: " ")
  end

  def formatted_published_date
    return "Draft" if draft?
    return "Scheduled for #{published_at.strftime("%B %d, %Y")}" if scheduled?
    published_at.strftime("%B %d, %Y")
  end

  def reading_time_text
    return "? min read" unless reading_time.present?
    "#{reading_time} min read"
  end

  def increment_views!
    increment!(:views_count)
  end

  def to_param
    slug
  end

  private

  def generate_slug
    base_slug = title.parameterize
    slug_candidate = base_slug
    counter = 1

    while BlogPost.exists?(slug: slug_candidate)
      slug_candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug_candidate
  end

  def calculate_reading_time
    return unless content.present?

    # Average reading speed: 200 words per minute
    words = content.to_plain_text.split.size
    self.reading_time = (words / 200.0).ceil
  end

  def remove_featured_image?
    remove_featured_image.to_s == "1"
  end

  def purge_featured_image
    featured_image.purge_later if featured_image.attached?
  end
end
