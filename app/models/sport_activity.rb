class SportActivity < ApplicationRecord
  # Rich Text
  has_rich_text :description

  # Validations
  validates :sport_type, presence: true, inclusion: { in: %w[crossfit hyrox running ocr] }
  validates :sub_type, inclusion: { in: %w[road trail], allow_blank: true }
  validates :category, presence: true, inclusion: { in: %w[benchmark workout event] }
  validates :title, presence: true
  validates :value, presence: true
  validates :unit, presence: true
  validates :date, presence: true

  # Scopes
  scope :crossfit, -> { where(sport_type: "crossfit") }
  scope :hyrox, -> { where(sport_type: "hyrox") }
  scope :running, -> { where(sport_type: "running") }
  scope :ocr, -> { where(sport_type: "ocr") }
  scope :road_running, -> { running.where(sub_type: "road") }
  scope :trail_running, -> { running.where(sub_type: "trail") }
  scope :benchmarks, -> { where(category: "benchmark") }
  scope :workouts, -> { where(category: "workout").order(date: :desc) }
  scope :events, -> { where(category: "event") }
  scope :upcoming_events, -> { events.where("date >= ?", Date.today).order(date: :asc) }
  scope :past_events, -> { events.where("date < ?", Date.today).order(date: :desc) }
  scope :past_activities, -> { where("date < ?", Date.today).order(date: :desc) }
  scope :personal_records, -> { where(personal_record: true) }
  scope :recent, -> { order(created_at: :desc).limit(10) }

  # Helper methods
  def formatted_value
    return "#{value} #{unit}" if value.present? && unit.present?
    value
  end

  def sport_display_name
    case sport_type
    when "ocr"
      "OCR"
    when "running"
      sub_type.present? ? "#{sub_type.capitalize} Running" : "Running"
    else
      sport_type.capitalize
    end
  end

  def category_display_name
    category.capitalize
  end

  def upcoming?
    category == "event" && date >= Date.today
  end

  def past?
    date < Date.today
  end

  def full_sport_name
    if sport_type == "running" && sub_type.present?
      "#{sub_type.capitalize} Running"
    elsif sport_type == "ocr"
      "OCR"
    else
      sport_type.capitalize
    end
  end

  def sport_emoji
    case sport_type
    when "crossfit"
      "🏋️"
    when "hyrox"
      "⚡"
    when "running"
      "🏃"
    when "ocr"
      "🧗"
    else
      "🏅" # Default sports emoji
    end
  end

  def run_type_emoji
    return nil unless sport_type == "running"

    case sub_type
    when "road"
      "🛣️"
    when "trail"
      "⛰️"
    else
      nil
    end
  end

  def run_type_badge
    return nil unless sport_type == "running" && sub_type.present?

    case sub_type
    when "road"
      "Road"
    when "trail"
      "Trail"
    end
  end
end
