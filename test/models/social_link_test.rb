require "test_helper"

class SocialLinkTest < ActiveSupport::TestCase
  # Validation Tests
  test "should be valid with valid attributes" do
    social_link = SocialLink.new(
      platform: "twitter",
      url: "https://twitter.com/test"
    )
    assert social_link.valid?
  end

  test "should require platform" do
    social_link = SocialLink.new(url: "https://twitter.com/test")
    assert_not social_link.valid?
    assert_includes social_link.errors[:platform], "can't be blank"
  end

  test "should require url" do
    social_link = SocialLink.new(platform: "twitter")
    assert_not social_link.valid?
    assert_includes social_link.errors[:url], "can't be blank"
  end

  test "should only accept valid platforms" do
    social_link = social_links(:twitter_main)

    social_link.platform = "invalid_platform"
    assert_not social_link.valid?
    assert_includes social_link.errors[:platform], "is not included in the list"

    # Test all valid platforms
    SocialLink::PLATFORMS.each do |platform|
      social_link.platform = platform
      assert social_link.valid?, "#{platform} should be a valid platform"
    end
  end

  test "should validate url format" do
    social_link = social_links(:twitter_main)

    social_link.url = "invalid-url"
    assert_not social_link.valid?
    assert_includes social_link.errors[:url], "must be a valid URL"

    social_link.url = "https://example.com"
    assert social_link.valid?

    social_link.url = "http://example.com/profile"
    assert social_link.valid?
  end

  test "should validate follower_count is non-negative integer" do
    social_link = social_links(:twitter_main)

    social_link.follower_count = -1
    assert_not social_link.valid?
    assert_includes social_link.errors[:follower_count], "must be greater than or equal to 0"

    social_link.follower_count = 0
    assert social_link.valid?

    social_link.follower_count = 1000
    assert social_link.valid?

    social_link.follower_count = 1.5
    assert_not social_link.valid?
    assert_includes social_link.errors[:follower_count], "must be an integer"
  end

  test "should allow nil follower_count" do
    social_link = social_links(:instagram_personal)
    assert social_link.valid?
    assert_nil social_link.follower_count
  end

  # Scope Tests
  test "header_links scope returns only header links" do
    header_links = SocialLink.header_links
    assert header_links.all?(&:display_in_header)
    assert_includes header_links, social_links(:twitter_main)
    assert_includes header_links, social_links(:github_profile)
    assert_not_includes header_links, social_links(:linkedin_profile)
  end

  test "header_links scope orders by created_at" do
    header_links = SocialLink.header_links
    created_ats = header_links.pluck(:created_at)
    assert_equal created_ats, created_ats.sort
  end

  test "by_platform scope filters by platform" do
    twitter_links = SocialLink.by_platform("twitter")
    assert twitter_links.all? { |link| link.platform == "twitter" }
    assert_includes twitter_links, social_links(:twitter_main)
    assert_includes twitter_links, social_links(:twitter_secondary)
    assert_not_includes twitter_links, social_links(:github_profile)
  end

  test "with_followers scope returns only links with follower count" do
    with_followers = SocialLink.with_followers
    assert with_followers.all? { |link| link.follower_count.present? }
    assert_includes with_followers, social_links(:twitter_main)
    assert_includes with_followers, social_links(:youtube_channel)
    assert_not_includes with_followers, social_links(:instagram_personal)
  end

  test "with_followers scope orders by follower_count descending" do
    with_followers = SocialLink.with_followers
    follower_counts = with_followers.pluck(:follower_count)
    assert_equal follower_counts, follower_counts.sort.reverse
  end

  test "ordered_by_followers scope orders by follower_count descending" do
    ordered = SocialLink.ordered_by_followers
    follower_counts = ordered.pluck(:follower_count).compact
    assert_equal follower_counts, follower_counts.sort.reverse
  end

  # Helper Method Tests
  test "formatted_follower_count formats millions correctly" do
    link = social_links(:youtube_channel)
    assert_equal "2.5M", link.formatted_follower_count

    link = social_links(:mega_influencer)
    assert_equal "15.0M", link.formatted_follower_count
  end

  test "formatted_follower_count formats thousands correctly" do
    link = social_links(:twitter_main)
    assert_equal "15.0K", link.formatted_follower_count

    link = social_links(:tiktok_account)
    assert_equal "125.0K", link.formatted_follower_count
  end

  test "formatted_follower_count shows exact count under 1000" do
    link = social_links(:github_profile)
    assert_equal "500", link.formatted_follower_count

    link = social_links(:under_thousand)
    assert_equal "999", link.formatted_follower_count
  end

  test "formatted_follower_count returns nil when no followers" do
    link = social_links(:instagram_personal)
    assert_nil link.formatted_follower_count
  end

  test "formatted_follower_count handles zero followers" do
    link = social_links(:zero_followers)
    assert_equal "0", link.formatted_follower_count
  end

  test "formatted_follower_count handles boundary cases" do
    # Exactly 1000
    link = social_links(:thousand_followers)
    assert_equal "1.0K", link.formatted_follower_count

    # Exactly 1M
    link = social_links(:million_followers)
    assert_equal "1.0M", link.formatted_follower_count

    # Just under 1M
    link = social_links(:under_million)
    assert_equal "1000.0K", link.formatted_follower_count
  end

  test "platform_display_name returns titleized platform" do
    twitter = social_links(:twitter_main)
    assert_equal "Twitter", twitter.platform_display_name

    github = social_links(:github_profile)
    assert_equal "Github", github.platform_display_name

    youtube = social_links(:youtube_channel)
    assert_equal "Youtube", youtube.platform_display_name
  end

  test "icon_name returns correct icon for each platform" do
    assert_equal "twitter-x", social_links(:twitter_main).icon_name
    assert_equal "github", social_links(:github_profile).icon_name
    assert_equal "youtube", social_links(:youtube_channel).icon_name
    assert_equal "linkedin", social_links(:linkedin_profile).icon_name
    assert_equal "instagram", social_links(:instagram_personal).icon_name
    assert_equal "facebook", social_links(:facebook_page).icon_name
    assert_equal "tiktok", social_links(:tiktok_account).icon_name
    assert_equal "twitch", social_links(:twitch_channel).icon_name
    assert_equal "discord", social_links(:discord_server).icon_name
  end

  test "icon_name returns link for unknown platform" do
    link = SocialLink.new(platform: "twitter", url: "https://twitter.com/test")
    # Temporarily change platform to test fallback (not in validation list, so we'll stub it)
    link.define_singleton_method(:platform) { "unknown" }
    assert_equal "link", link.icon_name
  end

  test "color_class returns correct color for each platform" do
    assert_equal "text-blue-400", social_links(:twitter_main).color_class
    assert_equal "text-gray-400", social_links(:github_profile).color_class
    assert_equal "text-red-500", social_links(:youtube_channel).color_class
    assert_equal "text-blue-600", social_links(:linkedin_profile).color_class
    assert_equal "text-pink-500", social_links(:instagram_personal).color_class
    assert_equal "text-blue-500", social_links(:facebook_page).color_class
    assert_equal "text-black", social_links(:tiktok_account).color_class
    assert_equal "text-purple-500", social_links(:twitch_channel).color_class
    assert_equal "text-indigo-500", social_links(:discord_server).color_class
  end

  test "color_class returns default color for unknown platform" do
    link = SocialLink.new(platform: "twitter", url: "https://twitter.com/test")
    link.define_singleton_method(:platform) { "unknown" }
    assert_equal "text-gray-500", link.color_class
  end

  test "has_followers? returns true when follower count is positive" do
    link = social_links(:twitter_main)
    assert link.has_followers?
  end

  test "has_followers? returns false when follower count is zero" do
    link = social_links(:zero_followers)
    assert_not link.has_followers?
  end

  test "has_followers? returns false when follower count is nil" do
    link = social_links(:instagram_personal)
    assert_not link.has_followers?
  end

  # Integration Tests
  test "can create social link with only required fields" do
    social_link = SocialLink.create!(
      platform: "twitter",
      url: "https://twitter.com/minimal"
    )
    assert social_link.persisted?
    assert_equal "twitter", social_link.platform
    assert_equal "https://twitter.com/minimal", social_link.url
  end

  test "can create social link with all fields" do
    social_link = SocialLink.create!(
      platform: "youtube",
      url: "https://youtube.com/@complete",
      follower_count: 50000,
      username: "complete",
      display_in_header: true
    )
    assert social_link.persisted?
    assert social_link.display_in_header
    assert_equal "50.0K", social_link.formatted_follower_count
  end

  test "multiple links can have same platform" do
    twitter_links = SocialLink.by_platform("twitter")
    assert twitter_links.count >= 2
  end

  test "can have links from all supported platforms" do
    SocialLink::PLATFORMS.each do |platform|
      link = SocialLink.create!(
        platform: platform,
        url: "https://#{platform}.com/test"
      )
      assert link.persisted?, "Should be able to create link for #{platform}"
    end
  end

  test "header links can be from different platforms" do
    header_links = SocialLink.header_links
    platforms = header_links.pluck(:platform).uniq
    assert platforms.count >= 2
  end

  test "links with and without followers can coexist" do
    with_followers = SocialLink.with_followers
    all_links = SocialLink.all

    assert with_followers.count < all_links.count
    assert with_followers.count > 0
  end

  test "follower count formatting is consistent" do
    # Create links with specific follower counts
    small = SocialLink.create!(platform: "twitter", url: "https://twitter.com/small", follower_count: 500)
    medium = SocialLink.create!(platform: "twitter", url: "https://twitter.com/medium", follower_count: 5000)
    large = SocialLink.create!(platform: "twitter", url: "https://twitter.com/large", follower_count: 5000000)

    assert_equal "500", small.formatted_follower_count
    assert_equal "5.0K", medium.formatted_follower_count
    assert_equal "5.0M", large.formatted_follower_count
  end

  test "constants are properly defined" do
    assert_kind_of Array, SocialLink::PLATFORMS
    assert SocialLink::PLATFORMS.include?("twitter")
    assert SocialLink::PLATFORMS.include?("github")
    assert SocialLink::PLATFORMS.include?("youtube")
    assert_equal 9, SocialLink::PLATFORMS.length
  end
end
