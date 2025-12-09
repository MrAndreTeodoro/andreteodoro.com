class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: [ :edit, :update, :destroy ]

  def index
    @projects = Project.all.order(position: :asc, created_at: :desc)

    # Filter by project type
    if params[:type].present?
      @projects = @projects.where(project_type: params[:type])
    end

    # Filter by status
    if params[:status].present?
      @projects = @projects.where(status: params[:status])
    end

    # Filter by featured
    if params[:featured] == "true"
      @projects = @projects.where(featured: true)
    end

    # Search by name only (description is ActionText, stored separately)
    if params[:search].present?
      @projects = @projects.where(
        "name LIKE ?",
        "%#{params[:search]}%"
      )
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to admin_projects_path, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to admin_projects_path, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to admin_projects_path, notice: "Project was successfully deleted.", status: :see_other
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name,
      :description,
      :url,
      :logo_url,
      :project_type,
      :featured,
      :tech_stack,
      :status,
      :position
    )
  end
end
