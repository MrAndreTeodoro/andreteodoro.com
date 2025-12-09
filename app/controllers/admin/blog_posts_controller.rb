class Admin::BlogPostsController < Admin::BaseController
  before_action :set_blog_post, only: [ :edit, :update, :destroy, :publish, :unpublish ]

  def index
    @blog_posts = BlogPost.all.order(created_at: :desc)

    # Filter by status
    if params[:status] == "published"
      @blog_posts = @blog_posts.published
    elsif params[:status] == "draft"
      @blog_posts = @blog_posts.drafted
    elsif params[:status] == "scheduled"
      @blog_posts = @blog_posts.scheduled
    end

    # Filter by viral
    if params[:viral] == "true"
      @blog_posts = @blog_posts.where(viral: true)
    end

    # Filter by featured
    if params[:featured] == "true"
      @blog_posts = @blog_posts.where(featured: true)
    end

    # Filter by year
    if params[:year].present?
      @blog_posts = @blog_posts.by_year(params[:year])
    end

    # Search by title, excerpt, or content
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @blog_posts = @blog_posts.left_joins(:rich_text_content, :rich_text_excerpt)
        .where(
          "blog_posts.title LIKE ? OR action_text_rich_texts.body LIKE ?",
          search_term,
          search_term
        )
        .distinct
    end
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)

    if @blog_post.save
      redirect_to admin_blog_posts_path, notice: "Blog post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to admin_blog_posts_path, notice: "Blog post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to admin_blog_posts_path, notice: "Blog post was successfully deleted.", status: :see_other
  end

  def publish
    if @blog_post.publish!
      redirect_to admin_blog_posts_path, notice: "Blog post was successfully published."
    else
      redirect_to admin_blog_posts_path, alert: "Failed to publish blog post."
    end
  end

  def unpublish
    if @blog_post.unpublish!
      redirect_to admin_blog_posts_path, notice: "Blog post was moved to drafts."
    else
      redirect_to admin_blog_posts_path, alert: "Failed to unpublish blog post."
    end
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(
      :title,
      :slug,
      :excerpt,
      :content,
      :published_at,
      :featured,
      :viral,
      :featured_image,
      :remove_featured_image
    )
  end
end
