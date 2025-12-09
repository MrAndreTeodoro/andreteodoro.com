class Admin::SportActivitiesController < Admin::BaseController
  before_action :set_sport_activity, only: [ :edit, :update, :destroy ]

  def index
    @sport_activities = SportActivity.all.order(created_at: :desc)

    # Filter by sport type if provided
    if params[:sport_type].present?
      @sport_activities = @sport_activities.where(sport_type: params[:sport_type])
    end

    # Filter by category if provided
    if params[:category].present?
      @sport_activities = @sport_activities.where(category: params[:category])
    end

    # Filter by personal records
    if params[:personal_record] == "true"
      @sport_activities = @sport_activities.where(personal_record: true)
    end

    # Search by title or description
    if params[:search].present?
      @sport_activities = @sport_activities.where(
        "title LIKE ? OR description LIKE ?",
        "%#{params[:search]}%",
        "%#{params[:search]}%"
      )
    end
  end

  def new
    @sport_activity = SportActivity.new
  end

  def create
    @sport_activity = SportActivity.new(sport_activity_params)

    if @sport_activity.save
      redirect_to admin_sport_activities_path, notice: "Sport activity was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @sport_activity.update(sport_activity_params)
      redirect_to admin_sport_activities_path, notice: "Sport activity was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sport_activity.destroy
    redirect_to admin_sport_activities_path, notice: "Sport activity was successfully deleted.", status: :see_other
  end

  private

  def set_sport_activity
    @sport_activity = SportActivity.find(params[:id])
  end

  def sport_activity_params
    params.require(:sport_activity).permit(
      :sport_type,
      :category,
      :title,
      :description,
      :value,
      :unit,
      :date,
      :personal_record,
      :event_name,
      :location,
      :result_url
    )
  end
end
