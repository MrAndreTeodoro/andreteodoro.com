class SportActivity < ApplicationRecord
  # Rich Text
  has_rich_text :description

  # Validations
  validates :sport_type, presence: true, inclusion: { in: %w[crossfit hyrox running] }
  validates :category, presence: true, inclusion: { in: %w[benchmark result event] }
  validates :title, presence: true

  # Scopes
  scope :crossfit, -> { where(sport_type: "crossfit") }
  scope :hyrox, -> { where(sport_type: "hyrox") }
  scope :running, -> { where(sport_type: "running") }
  scope :benchmarks, -> { where(category: "benchmark") }
  scope :results, -> { where(category: "result").order(date: :desc) }
  scope :events, -> { where(category: "event").order(date: :asc) }
  scope :personal_records, -> { where(personal_record: true) }
  scope :recent, -> { order(created_at: :desc).limit(10) }

  # Helper methods
  def formatted_value
    return "#{value} #{unit}" if value.present? && unit.present?
    value
  end

  def sport_display_name
    sport_type.capitalize
  end

  def category_display_name
    category.capitalize
  end

  def upcoming?
    category == "event" && date.present? && date > Date.today
  end

  def past?
    date.present? && date <= Date.today
  end
end
