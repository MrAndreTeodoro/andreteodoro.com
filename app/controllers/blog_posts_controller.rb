class BlogPostsController < ApplicationController

  def index
    @blog_posts = BlogPost.published
    @featured_posts = BlogPost.featured.limit(3)
    @viral_posts = BlogPost.viral.limit(5)
    @popular_posts = BlogPost.popular.limit(5)

    # Get available years for filtering
    @years = BlogPost.published
                    .pluck(:published_at)
                    .map(&:year)
                    .uniq
                    .sort
                    .reverse

    # Filter by year if provided
    if params[:year].present?
      @blog_posts = @blog_posts.by_year(params[:year])
      @selected_year = params[:year].to_i
    end

    # Search functionality
    if params[:query].present?
      search_term = "%#{params[:query]}%"
      @blog_posts = @blog_posts.left_joins(:rich_text_content, :rich_text_excerpt)
        .where(
          "blog_posts.title LIKE ? OR action_text_rich_texts.body LIKE ?",
          search_term,
          search_term
        )
        .distinct
    end

    # Limit results to avoid loading too many at once
    @blog_posts = @blog_posts.limit(20)
  end

  def show
    @blog_post = BlogPost.find_by!(slug: params[:slug])

    unless @blog_post.published?
      redirect_to blog_path, alert: "Blog post not found"
      return
    end

    # Increment view count
    @blog_post.increment_views!

    # Related posts (same category or recent)
    @related_posts = BlogPost.published
                            .where.not(id: @blog_post.id)
                            .limit(3)
                            .order(published_at: :desc)
  rescue ActiveRecord::RecordNotFound
    redirect_to blog_path, alert: "Blog post not found"
  end
end
