require "test_helper"

class Admin::BlogPostsControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @blog_post = blog_posts(:published_one)
    @draft = blog_posts(:draft_one)
    sign_in_as_admin
  end

  # Index Tests
  test "should get index" do
    get admin_blog_posts_url
    assert_response :success
  end

  test "should filter by published status" do
    get admin_blog_posts_url, params: { status: "published" }
    assert_response :success
  end

  test "should filter by draft status" do
    get admin_blog_posts_url, params: { status: "draft" }
    assert_response :success
  end

  test "should filter by featured" do
    get admin_blog_posts_url, params: { featured: "true" }
    assert_response :success
  end

  test "should filter by viral" do
    get admin_blog_posts_url, params: { viral: "true" }
    assert_response :success
  end

  test "should search blog posts" do
    get admin_blog_posts_url, params: { search: "Rails" }
    assert_response :success
  end

  # New Tests
  test "should get new" do
    get new_admin_blog_post_url
    assert_response :success
    assert_select "form"
  end

  # Create Tests
  test "should create blog post with valid params" do
    assert_difference("BlogPost.count") do
      post admin_blog_posts_url, params: {
        blog_post: {
          title: "New Blog Post",
          content: "This is test content for the blog post.",
          excerpt: "Test excerpt"
        }
      }
    end

    assert_redirected_to admin_blog_posts_url
    assert_equal "Blog post was successfully created.", flash[:notice]
  end

  test "should auto-generate slug when not provided" do
    post admin_blog_posts_url, params: {
      blog_post: {
        title: "My Awesome Post",
        content: "Content here"
      }
    }

    post = BlogPost.find_by(title: "My Awesome Post")
    assert_equal "my-awesome-post", post.slug
  end

  test "should not create blog post with invalid params" do
    assert_no_difference("BlogPost.count") do
      post admin_blog_posts_url, params: {
        blog_post: {
          title: "",
          content: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # Edit Tests
  test "should get edit" do
    # Use ID directly instead of the object to avoid routing issues
    get edit_admin_blog_post_url(id: @blog_post.id)
    assert_response :success
    assert_select "form"
  end

  # Update Tests
  test "should update blog post with valid params" do
    patch admin_blog_post_url(id: @blog_post.id), params: {
      blog_post: {
        title: "Updated Title",
        content: "Updated content"
      }
    }

    assert_redirected_to admin_blog_posts_url
    assert_equal "Blog post was successfully updated.", flash[:notice]

    @blog_post.reload
    assert_equal "Updated Title", @blog_post.title
  end

  test "should not update blog post with invalid params" do
    patch admin_blog_post_url(id: @blog_post.id), params: {
      blog_post: {
        title: "",
        content: ""
      }
    }

    assert_response :unprocessable_entity
  end

  # Destroy Tests
  test "should destroy blog post" do
    blog_post_id = @blog_post.id

    assert_difference("BlogPost.count", -1) do
      delete admin_blog_post_url(id: @blog_post.id)
    end

    assert_redirected_to admin_blog_posts_url
    assert_equal "Blog post was successfully deleted.", flash[:notice]

    assert_raises(ActiveRecord::RecordNotFound) do
      BlogPost.find(blog_post_id)
    end
  end

  # Publish Tests
  test "should publish draft post" do
    assert_nil @draft.published_at

    patch publish_admin_blog_post_url(id: @draft.id)

    @draft.reload
    assert_not_nil @draft.published_at
    assert_redirected_to admin_blog_posts_url
    assert_equal "Blog post was successfully published.", flash[:notice]
  end

  # Unpublish Tests
  test "should unpublish published post" do
    assert_not_nil @blog_post.published_at

    patch unpublish_admin_blog_post_url(id: @blog_post.id)

    @blog_post.reload
    assert_nil @blog_post.published_at
    assert_redirected_to admin_blog_posts_url
    assert_equal "Blog post was moved to drafts.", flash[:notice]
  end

  # Authorization Tests
  test "should require authentication" do
    sign_out

    get admin_blog_posts_url
    assert_redirected_to new_session_url
  end
end
