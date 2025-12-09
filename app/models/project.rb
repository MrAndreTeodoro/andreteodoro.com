class Project < ApplicationRecord
  # Rich Text
  has_rich_text :description

  # Validations
  validates :name, presence: true
  validates :project_type, presence: true, inclusion: { in: %w[startup side_project experiment] }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp([ "http", "https" ]), message: "must be a valid URL" }, allow_blank: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :startups, -> { where(project_type: "startup").order(position: :asc) }
  scope :side_projects, -> { where(project_type: "side_project").order(position: :asc) }
  scope :experiments, -> { where(project_type: "experiment").order(position: :asc) }
  scope :featured, -> { where(featured: true).order(position: :asc) }
  scope :active, -> { where(status: "active").order(position: :asc) }
  scope :archived, -> { where(status: "archived").order(position: :asc) }
  scope :in_development, -> { where(status: "in_development").order(position: :asc) }
  scope :ordered, -> { order(position: :asc) }

  # Callbacks
  before_save :set_default_position

  # Helper methods
  def tech_stack_array
    return [] if tech_stack.blank?

    begin
      JSON.parse(tech_stack)
    rescue JSON::ParserError
      tech_stack.split(",").map(&:strip)
    end
  end

  def tech_stack_array=(array)
    self.tech_stack = array.to_json
  end

  def project_type_display_name
    project_type.to_s.titleize
  end

  def status_display_name
    status.to_s.titleize
  end

  def has_url?
    url.present?
  end

  def has_logo?
    logo_url.present?
  end

  def short_description(length = 150)
    return "" unless description.present?
    description.to_plain_text.truncate(length, separator: " ")
  end

  def active?
    status == "active"
  end

  def archived?
    status == "archived"
  end

  def in_development?
    status == "in_development"
  end

  private

  def set_default_position
    if position.nil? || position.zero?
      max_position = Project.where(project_type: project_type).maximum(:position) || 0
      self.position = max_position + 1
    end
  end
end
