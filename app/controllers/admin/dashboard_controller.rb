class Admin::DashboardController < Admin::BaseController
  def index
    # Dashboard statistics
    @stats = {
      sport_activities: SportActivity.count,
      books: Book.count,
      gear_items: GearItem.count,
      projects: Project.count,
      blog_posts: BlogPost.count,
      social_links: SocialLink.count
    }

    # Recent additions
    @recent_sport_activities = SportActivity.order(created_at: :desc).limit(5)
    @recent_books = Book.order(created_at: :desc).limit(5)
    @recent_blog_posts = BlogPost.order(created_at: :desc).limit(5)
    @recent_projects = Project.order(created_at: :desc).limit(5)

    # Quick stats
    @published_posts = BlogPost.published.count
    @draft_posts = BlogPost.drafted.count
    @total_views = BlogPost.sum(:views_count)
    @featured_books = Book.featured.count
    @active_projects = Project.active.count
  end
end
