class SportsController < ApplicationController
  def index
    # Show all sports overview
    @crossfit_benchmarks = SportActivity.crossfit.benchmarks
    @hyrox_benchmarks = SportActivity.hyrox.benchmarks
    @running_benchmarks = SportActivity.running.benchmarks

    @recent_results = SportActivity.results.limit(15)
    @upcoming_events = SportActivity.events.where("date >= ?", Date.today).limit(10)
  end

  def show
    # Show individual sport detail
    @sport_type = params[:id]

    unless %w[crossfit hyrox running].include?(@sport_type)
      redirect_to sports_path, alert: "Invalid sport type"
      return
    end

    @benchmarks = SportActivity.where(sport_type: @sport_type).benchmarks
    @results = SportActivity.where(sport_type: @sport_type).results.limit(20)
    @events = SportActivity.where(sport_type: @sport_type).events
    @personal_records = SportActivity.where(sport_type: @sport_type).personal_records
  end
end
