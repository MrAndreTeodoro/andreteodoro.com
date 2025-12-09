require "test_helper"

class BlogPostTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    post = BlogPost.new(title: "Test", slug: "test-unique-slug", content: "Test content")
    assert post.valid?
  end

  test "should require title" do
    post = BlogPost.new(slug: "test", content: "test")
    assert_not post.valid?
  end

  test "should auto-generate slug from title" do
    post = BlogPost.create!(title: "My Great Post", content: "Test content")
    assert_equal "my-great-post", post.slug
  end

  test "should require unique slug" do
    existing = blog_posts(:published_one)
    post = BlogPost.new(title: "Test", slug: existing.slug, content: "test")
    assert_not post.valid?
  end

  test "published scope excludes drafts" do
    assert_not_includes BlogPost.published, blog_posts(:draft_one)
  end

  test "drafted scope includes drafts" do
    assert_includes BlogPost.drafted, blog_posts(:draft_one)
  end

  test "published? returns true for published posts" do
    assert blog_posts(:published_one).published?
  end

  test "published? returns false for drafts" do
    assert_not blog_posts(:draft_one).published?
  end

  test "draft? returns true for drafts" do
    assert blog_posts(:draft_one).draft?
  end

  test "publish! sets published_at" do
    post = blog_posts(:draft_one)
    post.publish!
    post.reload
    assert_not_nil post.published_at
  end

  test "unpublish! clears published_at" do
    post = blog_posts(:published_one)
    post.unpublish!
    post.reload
    assert_nil post.published_at
  end

  test "calculates reading time" do
    post = BlogPost.create!(title: "Long Post", content: "word " * 400)
    assert_equal 2, post.reading_time
  end

  test "formatted_published_date returns date" do
    post = blog_posts(:published_one)
    assert_match /\w+ \d+, \d{4}/, post.formatted_published_date
  end

  test "formatted_published_date returns Draft for drafts" do
    assert_equal "Draft", blog_posts(:draft_one).formatted_published_date
  end

  test "increment_views! increases count" do
    post = blog_posts(:published_one)
    initial = post.views_count
    post.increment_views!
    assert_equal initial + 1, post.views_count
  end

  test "to_param returns slug" do
    post = blog_posts(:published_one)
    assert_equal post.slug, post.to_param
  end

  test "scheduled? returns true for future published_at" do
    post = BlogPost.create!(
      title: "Future Post",
      content: "Coming soon",
      published_at: 1.day.from_now
    )
    assert post.scheduled?
  end

  test "scheduled? returns false for past published_at" do
    post = blog_posts(:published_one)
    assert_not post.scheduled?
  end

  test "scheduled? returns false for drafts" do
    post = blog_posts(:draft_one)
    assert_not post.scheduled?
  end

  test "published? returns false for scheduled posts" do
    post = BlogPost.create!(
      title: "Future Post",
      content: "Coming soon",
      published_at: 1.day.from_now
    )
    assert_not post.published?
  end

  test "scheduled scope includes future posts" do
    future_post = BlogPost.create!(
      title: "Future Post",
      content: "Coming soon",
      published_at: 1.day.from_now
    )
    assert_includes BlogPost.scheduled, future_post
  end

  test "scheduled scope excludes past posts" do
    assert_not_includes BlogPost.scheduled, blog_posts(:published_one)
  end

  test "scheduled scope excludes drafts" do
    assert_not_includes BlogPost.scheduled, blog_posts(:draft_one)
  end

  test "published scope excludes scheduled posts" do
    future_post = BlogPost.create!(
      title: "Future Post",
      content: "Coming soon",
      published_at: 1.day.from_now
    )
    assert_not_includes BlogPost.published, future_post
  end

  test "formatted_published_date shows scheduled date for future posts" do
    post = BlogPost.create!(
      title: "Future Post",
      content: "Coming soon",
      published_at: 1.day.from_now
    )
    assert_match /Scheduled for \w+ \d+, \d{4}/, post.formatted_published_date
  end
end
