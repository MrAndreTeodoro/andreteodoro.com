class SocialLink < ApplicationRecord
  # Constants
  PLATFORMS = %w[twitter youtube github linkedin instagram facebook tiktok twitch discord].freeze

  # Validations
  validates :platform, presence: true, inclusion: { in: PLATFORMS }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(['http', 'https']), message: "must be a valid URL" }
  validates :follower_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :header_links, -> { where(display_in_header: true).order(:created_at) }
  scope :by_platform, ->(platform) { where(platform: platform) }
  scope :with_followers, -> { where.not(follower_count: nil).order(follower_count: :desc) }
  scope :ordered_by_followers, -> { order(follower_count: :desc) }

  # Helper methods
  def formatted_follower_count
    return nil if follower_count.nil?

    if follower_count >= 1_000_000
      "#{(follower_count / 1_000_000.0).round(1)}M"
    elsif follower_count >= 1_000
      "#{(follower_count / 1_000.0).round(1)}K"
    else
      follower_count.to_s
    end
  end

  def platform_display_name
    platform.titleize
  end

  def icon_name
    case platform
    when 'twitter'
      'twitter-x'
    when 'github'
      'github'
    when 'youtube'
      'youtube'
    when 'linkedin'
      'linkedin'
    when 'instagram'
      'instagram'
    when 'facebook'
      'facebook'
    when 'tiktok'
      'tiktok'
    when 'twitch'
      'twitch'
    when 'discord'
      'discord'
    else
      'link'
    end
  end

  def color_class
    case platform
    when 'twitter'
      'text-blue-400'
    when 'github'
      'text-gray-400'
    when 'youtube'
      'text-red-500'
    when 'linkedin'
      'text-blue-600'
    when 'instagram'
      'text-pink-500'
    when 'facebook'
      'text-blue-500'
    when 'tiktok'
      'text-black'
    when 'twitch'
      'text-purple-500'
    when 'discord'
      'text-indigo-500'
    else
      'text-gray-500'
    end
  end

  def has_followers?
    follower_count.present? && follower_count.positive?
  end
end
