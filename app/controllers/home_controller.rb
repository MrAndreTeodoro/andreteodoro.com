class HomeController < ApplicationController
  def index
    # Load data for homepage sections
    @social_links = SocialLink.header_links

    # Sports - featured activities
    @crossfit_benchmarks = SportActivity.crossfit.benchmarks.limit(3)
    @hyrox_benchmarks = SportActivity.hyrox.benchmarks.limit(3)
    @running_benchmarks = SportActivity.running.benchmarks.limit(3)

    @recent_results = SportActivity.workouts.limit(5)
    @upcoming_events = SportActivity.upcoming_events.limit(3)

    # Projects
    @featured_projects = Project.featured.startups.limit(3)
    @side_projects = Project.side_projects.limit(12)

    # Books
    @featured_books = Book.featured.limit(3)

    # Gear
    @featured_gear = GearItem.featured.limit(6)

    # Blog
    @recent_posts = BlogPost.published.recent
  end
end
