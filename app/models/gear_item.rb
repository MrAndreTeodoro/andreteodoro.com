class GearItem < ApplicationRecord
  # ActiveStorage
  has_one_attached :product_image

  # Rich Text
  has_rich_text :description

  # Validations
  validates :name, presence: true
  validates :category, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :affiliate_link, format: { with: URI::DEFAULT_PARSER.make_regexp(['http', 'https']), message: "must be a valid URL" }, allow_blank: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :featured, -> { where(featured: true).order(position: :asc) }
  scope :by_category, ->(category) { where(category: category).order(position: :asc) }
  scope :tech, -> { where(category: 'tech').order(position: :asc) }
  scope :fitness, -> { where(category: 'fitness').order(position: :asc) }
  scope :everyday, -> { where(category: 'everyday').order(position: :asc) }
  scope :with_price, -> { where.not(price: nil).order(price: :asc) }
  scope :ordered, -> { order(position: :asc) }

  # Callbacks
  before_validation :normalize_category
  before_save :set_default_position

  # Helper methods
  def formatted_price
    return "Price not available" if price.nil?
    "$#{price.round(2)}"
  end

  def has_affiliate_link?
    affiliate_link.present?
  end

  def category_display_name
    category.to_s.titleize
  end

  def has_image?
    product_image.attached? || image_url.present?
  end

  def product_image_url
    if product_image.attached?
      product_image
    elsif image_url.present?
      image_url
    else
      nil
    end
  end

  def short_description(length = 100)
    return "" unless description.present?
    description.to_plain_text.truncate(length, separator: ' ')
  end

  private

  def normalize_category
    self.category = category.to_s.downcase.strip if category.present?
  end

  def set_default_position
    if position.nil? || position.zero?
      max_position = GearItem.where(category: category).maximum(:position) || 0
      self.position = max_position + 1
    end
  end
end
