class SportsController < ApplicationController
  def index
    # Show all sports overview
    @crossfit_benchmarks = SportActivity.crossfit.benchmarks
    @hyrox_benchmarks = SportActivity.hyrox.benchmarks
    @running_benchmarks = SportActivity.running.benchmarks

    @recent_workouts = SportActivity.workouts.limit(15)
    @upcoming_events = SportActivity.upcoming_events.limit(10)
  end

  def show
    # Show individual sport detail
    @sport_type = params[:id]

    unless %w[crossfit hyrox running ocr].include?(@sport_type)
      redirect_to sports_path, alert: "Invalid sport type"
      return
    end

    @benchmarks = SportActivity.where(sport_type: @sport_type).benchmarks
    @workouts = SportActivity.where(sport_type: @sport_type).workouts.limit(20)
    @upcoming_events = SportActivity.where(sport_type: @sport_type).upcoming_events
    @past_activities = SportActivity.where(sport_type: @sport_type).past_activities.limit(20)
    @personal_records = SportActivity.where(sport_type: @sport_type).personal_records
  end
end
