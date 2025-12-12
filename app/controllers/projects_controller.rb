class ProjectsController < ApplicationController
  def index
    @featured_projects = Project.featured.limit(6)
    @types = Project.pluck(:project_type).uniq.compact.sort
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

  def show
    @project = Project.find(params[:id])
    @related_projects = Project.where(project_type: @project.project_type)
                               .where.not(id: @project.id)
                               .ordered
                               .limit(3)
  end
end
