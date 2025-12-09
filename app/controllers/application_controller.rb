class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Load sidebar data for all pages
  before_action :load_sidebar_data

  private

  def load_sidebar_data
    # Only load sidebar data if not on auth pages
    unless controller_name.in?(%w[sessions passwords])
      @sidebar_social_links = SocialLink.header_links
      @sidebar_upcoming_events = SportActivity.events.where("date >= ?", Date.today).limit(3)
      @sidebar_featured_projects = Project.featured.startups.limit(3)
      @sidebar_side_projects = Project.side_projects.limit(12)
      @sidebar_recent_posts = BlogPost.published.recent.limit(3)
    end
  end
end
