require "test_helper"

class SportActivityTest < ActiveSupport::TestCase
  # Validation Tests
  test "should be valid with valid attributes" do
    activity = SportActivity.new(
      sport_type: "crossfit",
      category: "benchmark",
      title: "Test Activity"
    )
    assert activity.valid?
  end

  test "should require sport_type" do
    activity = SportActivity.new(category: "benchmark", title: "Test")
    assert_not activity.valid?
    assert_includes activity.errors[:sport_type], "can't be blank"
  end

  test "should require category" do
    activity = SportActivity.new(sport_type: "crossfit", title: "Test")
    assert_not activity.valid?
    assert_includes activity.errors[:category], "can't be blank"
  end

  test "should require title" do
    activity = SportActivity.new(sport_type: "crossfit", category: "benchmark")
    assert_not activity.valid?
    assert_includes activity.errors[:title], "can't be blank"
  end

  test "should only accept valid sport types" do
    activity = sport_activities(:crossfit_fran)

    activity.sport_type = "invalid_sport"
    assert_not activity.valid?
    assert_includes activity.errors[:sport_type], "is not included in the list"

    activity.sport_type = "crossfit"
    assert activity.valid?

    activity.sport_type = "hyrox"
    assert activity.valid?

    activity.sport_type = "running"
    assert activity.valid?
  end

  test "should only accept valid categories" do
    activity = sport_activities(:crossfit_fran)

    activity.category = "invalid_category"
    assert_not activity.valid?
    assert_includes activity.errors[:category], "is not included in the list"

    activity.category = "benchmark"
    assert activity.valid?

    activity.category = "result"
    assert activity.valid?

    activity.category = "event"
    assert activity.valid?
  end

  # Scope Tests
  test "crossfit scope returns only crossfit activities" do
    crossfit_activities = SportActivity.crossfit
    assert crossfit_activities.all? { |a| a.sport_type == "crossfit" }
    assert_includes crossfit_activities, sport_activities(:crossfit_fran)
    assert_includes crossfit_activities, sport_activities(:crossfit_murph)
    assert_not_includes crossfit_activities, sport_activities(:hyrox_run)
  end

  test "hyrox scope returns only hyrox activities" do
    hyrox_activities = SportActivity.hyrox
    assert hyrox_activities.all? { |a| a.sport_type == "hyrox" }
    assert_includes hyrox_activities, sport_activities(:hyrox_run)
    assert_includes hyrox_activities, sport_activities(:hyrox_upcoming_event)
    assert_not_includes hyrox_activities, sport_activities(:crossfit_fran)
  end

  test "running scope returns only running activities" do
    running_activities = SportActivity.running
    assert running_activities.all? { |a| a.sport_type == "running" }
    assert_includes running_activities, sport_activities(:running_5k)
    assert_includes running_activities, sport_activities(:running_marathon)
    assert_not_includes running_activities, sport_activities(:crossfit_fran)
  end

  test "benchmarks scope returns only benchmark activities" do
    benchmarks = SportActivity.benchmarks
    assert benchmarks.all? { |a| a.category == "benchmark" }
    assert_includes benchmarks, sport_activities(:crossfit_fran)
    assert_includes benchmarks, sport_activities(:hyrox_run)
    assert_not_includes benchmarks, sport_activities(:crossfit_competition)
  end

  test "results scope returns only result activities" do
    results = SportActivity.results
    assert results.all? { |a| a.category == "result" }
    assert_includes results, sport_activities(:crossfit_competition)
    assert_includes results, sport_activities(:running_10k_result)
    assert_not_includes results, sport_activities(:crossfit_fran)
  end

  test "results scope orders by date descending" do
    results = SportActivity.results
    dates = results.pluck(:date)
    assert_equal dates, dates.sort.reverse
  end

  test "events scope returns only event activities" do
    events = SportActivity.events
    assert events.all? { |a| a.category == "event" }
    assert_includes events, sport_activities(:hyrox_upcoming_event)
    assert_includes events, sport_activities(:running_marathon)
    assert_not_includes events, sport_activities(:crossfit_fran)
  end

  test "events scope orders by date ascending" do
    events = SportActivity.events
    dates = events.pluck(:date)
    assert_equal dates, dates.sort
  end

  test "personal_records scope returns only personal records" do
    prs = SportActivity.personal_records
    assert prs.all?(&:personal_record)
    assert_includes prs, sport_activities(:crossfit_fran)
    assert_includes prs, sport_activities(:hyrox_run)
    assert_not_includes prs, sport_activities(:crossfit_murph)
  end

  test "recent scope returns last 10 activities" do
    recent = SportActivity.recent
    assert recent.count <= 10
  end

  test "recent scope orders by created_at descending" do
    recent = SportActivity.recent
    created_ats = recent.pluck(:created_at)
    assert_equal created_ats, created_ats.sort.reverse
  end

  # Helper Method Tests
  test "formatted_value returns value with unit" do
    activity = sport_activities(:crossfit_fran)
    assert_equal "3:45 minutes", activity.formatted_value
  end

  test "formatted_value returns just value when no unit" do
    activity = SportActivity.new(
      sport_type: "crossfit",
      category: "benchmark",
      title: "Test",
      value: "100"
    )
    assert_equal "100", activity.formatted_value
  end

  test "formatted_value returns nil when no value" do
    activity = sport_activities(:hyrox_upcoming_event)
    assert_nil activity.formatted_value
  end

  test "sport_display_name returns capitalized sport type" do
    crossfit = sport_activities(:crossfit_fran)
    assert_equal "Crossfit", crossfit.sport_display_name

    hyrox = sport_activities(:hyrox_run)
    assert_equal "Hyrox", hyrox.sport_display_name

    running = sport_activities(:running_5k)
    assert_equal "Running", running.sport_display_name
  end

  test "category_display_name returns capitalized category" do
    benchmark = sport_activities(:crossfit_fran)
    assert_equal "Benchmark", benchmark.category_display_name

    result = sport_activities(:crossfit_competition)
    assert_equal "Result", result.category_display_name

    event = sport_activities(:hyrox_upcoming_event)
    assert_equal "Event", event.category_display_name
  end

  test "upcoming? returns true for future events" do
    activity = sport_activities(:hyrox_upcoming_event)
    assert activity.upcoming?
  end

  test "upcoming? returns false for past events" do
    activity = sport_activities(:hyrox_past_event)
    assert_not activity.upcoming?
  end

  test "upcoming? returns false for non-event categories" do
    activity = sport_activities(:crossfit_fran)
    assert_not activity.upcoming?
  end

  test "upcoming? returns false when date is nil" do
    activity = SportActivity.new(
      sport_type: "crossfit",
      category: "event",
      title: "No Date Event",
      date: nil
    )
    assert_not activity.upcoming?
  end

  test "past? returns true for past dates" do
    activity = sport_activities(:hyrox_past_event)
    assert activity.past?
  end

  test "past? returns true for today" do
    activity = SportActivity.new(
      sport_type: "crossfit",
      category: "benchmark",
      title: "Today",
      date: Date.today
    )
    assert activity.past?
  end

  test "past? returns false for future dates" do
    activity = sport_activities(:hyrox_upcoming_event)
    assert_not activity.past?
  end

  test "past? returns false when date is nil" do
    activity = SportActivity.new(
      sport_type: "crossfit",
      category: "benchmark",
      title: "No Date",
      date: nil
    )
    assert_not activity.past?
  end

  # Integration Tests
  test "can create activity with only required fields" do
    activity = SportActivity.create!(
      sport_type: "crossfit",
      category: "benchmark",
      title: "Minimal Activity"
    )
    assert activity.persisted?
    assert_equal "crossfit", activity.sport_type
    assert_equal "benchmark", activity.category
  end

  test "can create activity with all fields" do
    activity = SportActivity.create!(
      sport_type: "running",
      category: "result",
      title: "Complete Activity",
      description: "Full description here",
      value: "25:00",
      unit: "minutes",
      date: Date.today,
      event_name: "Test Event",
      location: "Test Location",
      result_url: "https://example.com/results",
      personal_record: true
    )
    assert activity.persisted?
    assert activity.personal_record
    assert_equal "25:00 minutes", activity.formatted_value
  end

  test "can combine scopes for crossfit personal records" do
    crossfit_prs = SportActivity.crossfit.personal_records
    assert crossfit_prs.all? { |a| a.sport_type == "crossfit" && a.personal_record }
    assert_includes crossfit_prs, sport_activities(:crossfit_fran)
    assert_not_includes crossfit_prs, sport_activities(:hyrox_run)
  end

  test "can combine scopes for hyrox benchmarks" do
    hyrox_benchmarks = SportActivity.hyrox.benchmarks
    assert hyrox_benchmarks.all? { |a| a.sport_type == "hyrox" && a.category == "benchmark" }
    assert_includes hyrox_benchmarks, sport_activities(:hyrox_run)
  end

  test "can combine scopes for running events" do
    running_events = SportActivity.running.events
    assert running_events.all? { |a| a.sport_type == "running" && a.category == "event" }
    assert_includes running_events, sport_activities(:running_marathon)
  end

  test "multiple activities can have same sport_type and category" do
    crossfit_benchmarks = SportActivity.crossfit.benchmarks
    assert crossfit_benchmarks.count >= 2
  end

  test "activities with nil date are handled correctly" do
    activity = SportActivity.create!(
      sport_type: "crossfit",
      category: "benchmark",
      title: "No Date",
      date: nil
    )
    assert_not activity.past?
    assert_not activity.upcoming?
  end

  test "activities can have empty optional fields" do
    activity = SportActivity.create!(
      sport_type: "hyrox",
      category: "event",
      title: "Minimal Event",
      description: nil,
      value: nil,
      unit: nil,
      event_name: nil,
      location: nil,
      result_url: nil
    )
    assert activity.valid?
    assert_nil activity.formatted_value
  end
end
