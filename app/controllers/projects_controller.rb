class ProjectsController < ApplicationController
  def index
    @featured_projects = Project.featured.limit(6)
    @startups = Project.startups
    @side_projects = Project.side_projects
    @experiments = Project.experiments

    # Filter by type if provided
    @selected_type = params[:type]

    if @selected_type.present?
      @projects = Project.where(project_type: @selected_type).ordered
    else
      @projects = Project.ordered
    end
  end
end
