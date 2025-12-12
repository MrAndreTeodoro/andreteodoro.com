require "test_helper"

class Admin::SportActivitiesControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @sport_activity = sport_activities(:crossfit_fran)
    sign_in_as_admin
  end

  # Index Tests
  test "should get index" do
    get admin_sport_activities_url
    assert_response :success
  end

  test "should filter by sport type crossfit" do
    get admin_sport_activities_url, params: { sport_type: "crossfit" }
    assert_response :success
  end

  test "should filter by sport type hyrox" do
    get admin_sport_activities_url, params: { sport_type: "hyrox" }
    assert_response :success
  end

  test "should filter by sport type running" do
    get admin_sport_activities_url, params: { sport_type: "running" }
    assert_response :success
  end

  test "should filter by category benchmark" do
    get admin_sport_activities_url, params: { category: "benchmark" }
    assert_response :success
  end

  test "should filter by category workout" do
    get admin_sport_activities_url, params: { category: "workout" }
    assert_response :success
  end

  test "should filter by category event" do
    get admin_sport_activities_url, params: { category: "event" }
    assert_response :success
  end

  test "should filter by personal records" do
    get admin_sport_activities_url, params: { personal_record: "true" }
    assert_response :success
  end

  test "should search activities by title" do
    get admin_sport_activities_url, params: { search: "Fran" }
    assert_response :success
  end

  test "should search activities by description" do
    get admin_sport_activities_url, params: { search: "thrusters" }
    assert_response :success
  end

  test "should combine filters" do
    get admin_sport_activities_url, params: {
      sport_type: "crossfit",
      category: "benchmark",
      personal_record: "true"
    }
    assert_response :success
  end

  # New Tests
  test "should get new" do
    get new_admin_sport_activity_url
    assert_response :success
    assert_select "form"
    assert_select "select[name='sport_activity[sport_type]']"
    assert_select "select[name='sport_activity[category]']"
    assert_select "input[name='sport_activity[title]']"
  end

  # Create Tests
  test "should create sport activity with valid params" do
    assert_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "crossfit",
          category: "benchmark",
          title: "New Benchmark",
          description: "Test benchmark",
          value: "5:00",
          unit: "minutes",
          date: Date.today
        }
      }
    end

    assert_redirected_to admin_sport_activities_url
    assert_equal "Sport activity was successfully created.", flash[:notice]
  end

  test "should create activity with all fields" do
    assert_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "hyrox",
          category: "event",
          title: "Competition",
          description: "Major competition",
          value: "1:25:30",
          unit: "time",
          date: Date.today + 30.days,
          personal_record: true,
          event_name: "HYROX Championship",
          location: "Las Vegas",
          result_url: "https://example.com/results"
        }
      }
    end

    activity = SportActivity.find_by(title: "Competition")
    assert activity.personal_record
    assert_equal "hyrox", activity.sport_type
    assert_equal "event", activity.category
    assert_equal "Las Vegas", activity.location
  end

  test "should not create activity without sport_type" do
    assert_no_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "",
          category: "benchmark",
          title: "Test"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create activity without category" do
    assert_no_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "crossfit",
          category: "",
          title: "Test"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create activity without title" do
    assert_no_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "crossfit",
          category: "benchmark",
          title: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create activity with invalid sport_type" do
    assert_no_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "invalid",
          category: "benchmark",
          title: "Test"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create activity with invalid category" do
    assert_no_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "crossfit",
          category: "invalid",
          title: "Test"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should create activity without optional fields" do
    assert_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "running",
          category: "benchmark",
          title: "Minimal Activity",
          value: "30:00",
          unit: "minutes",
          date: Date.today,
          personal_record: false
        }
      }
    end

    activity = SportActivity.find_by(title: "Minimal Activity")
    # Empty strings are acceptable for optional fields
    assert_not activity.personal_record
  end

  # Edit Tests
  test "should get edit" do
    get edit_admin_sport_activity_url(@sport_activity)
    assert_response :success
    assert_select "form"
    assert_select "select[name='sport_activity[sport_type]']"
    assert_select "input[name='sport_activity[title]'][value=?]", @sport_activity.title
  end

  # Update Tests
  test "should update activity with valid params" do
    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: {
        title: "Updated Title",
        description: "Updated description",
        value: "3:30",
        unit: "minutes"
      }
    }

    assert_redirected_to admin_sport_activities_url
    assert_equal "Sport activity was successfully updated.", flash[:notice]

    @sport_activity.reload
    assert_equal "Updated Title", @sport_activity.title
    assert_equal "Updated description", @sport_activity.description.to_plain_text
    assert_equal "3:30", @sport_activity.value
  end

  test "should update activity sport_type" do
    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: { sport_type: "hyrox" }
    }

    @sport_activity.reload
    assert_equal "hyrox", @sport_activity.sport_type
  end

  test "should update activity category" do
    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: { category: "workout" }
    }

    @sport_activity.reload
    assert_equal "workout", @sport_activity.category
  end

  test "should toggle personal_record status" do
    original_pr = @sport_activity.personal_record

    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: { personal_record: !original_pr }
    }

    @sport_activity.reload
    assert_equal !original_pr, @sport_activity.personal_record
  end

  test "should update event details" do
    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: {
        event_name: "New Event Name",
        location: "New Location",
        result_url: "https://example.com/new-results"
      }
    }

    @sport_activity.reload
    assert_equal "New Event Name", @sport_activity.event_name
    assert_equal "New Location", @sport_activity.location
    assert_equal "https://example.com/new-results", @sport_activity.result_url
  end

  test "should not update activity with invalid sport_type" do
    original_sport_type = @sport_activity.sport_type

    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: { sport_type: "invalid" }
    }

    assert_response :unprocessable_entity

    @sport_activity.reload
    assert_equal original_sport_type, @sport_activity.sport_type
  end

  test "should not update activity with invalid category" do
    original_category = @sport_activity.category

    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: { category: "invalid" }
    }

    assert_response :unprocessable_entity

    @sport_activity.reload
    assert_equal original_category, @sport_activity.category
  end

  test "should not update activity with empty title" do
    original_title = @sport_activity.title

    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: { title: "" }
    }

    assert_response :unprocessable_entity

    @sport_activity.reload
    assert_equal original_title, @sport_activity.title
  end

  # Destroy Tests
  test "should destroy sport activity" do
    assert_difference("SportActivity.count", -1) do
      delete admin_sport_activity_url(@sport_activity)
    end

    assert_redirected_to admin_sport_activities_url
    assert_equal "Sport activity was successfully deleted.", flash[:notice]
  end

  test "should not find destroyed activity" do
    activity_id = @sport_activity.id
    delete admin_sport_activity_url(@sport_activity)

    assert_raises(ActiveRecord::RecordNotFound) do
      SportActivity.find(activity_id)
    end
  end

  # Authorization Tests
  test "should require authentication for index" do
    sign_out

    get admin_sport_activities_url
    assert_redirected_to new_session_url
  end

  test "should require authentication for new" do
    sign_out

    get new_admin_sport_activity_url
    assert_redirected_to new_session_url
  end

  test "should require authentication for create" do
    sign_out

    post admin_sport_activities_url, params: {
      sport_activity: {
        sport_type: "crossfit",
        category: "benchmark",
        title: "Test"
      }
    }
    assert_redirected_to new_session_url
  end

  test "should require authentication for edit" do
    sign_out

    get edit_admin_sport_activity_url(@sport_activity)
    assert_redirected_to new_session_url
  end

  test "should require authentication for update" do
    sign_out

    patch admin_sport_activity_url(@sport_activity), params: {
      sport_activity: { title: "Updated" }
    }
    assert_redirected_to new_session_url
  end

  test "should require authentication for destroy" do
    sign_out

    delete admin_sport_activity_url(@sport_activity)
    assert_redirected_to new_session_url
  end

  # Edge Cases
  test "should handle activity with long title" do
    long_title = "A" * 300

    assert_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "crossfit",
          category: "benchmark",
          title: long_title,
          value: "5:00",
          unit: "minutes",
          date: Date.today
        }
      }
    end

    activity = SportActivity.last
    assert_equal long_title, activity.title
  end

  test "should handle activity with special characters in title" do
    special_title = "Test: WOD & Special 'Characters' (2024)"

    assert_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "crossfit",
          category: "benchmark",
          title: special_title,
          value: "5:00",
          unit: "minutes",
          date: Date.today
        }
      }
    end

    activity = SportActivity.find_by(title: special_title)
    assert_not_nil activity
  end

  test "should handle empty search query" do
    get admin_sport_activities_url, params: { search: "" }
    assert_response :success
  end

  test "should handle search with no results" do
    get admin_sport_activities_url, params: { search: "NonExistentActivity123" }
    assert_response :success
  end

  test "should handle multiple activities with same sport_type" do
    get admin_sport_activities_url, params: { sport_type: "crossfit" }
    assert_response :success
  end

  test "should create crossfit benchmark" do
    assert_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "crossfit",
          category: "benchmark",
          title: "Helen",
          description: "3 rounds: 400m run, 21 KB swings, 12 pull-ups",
          value: "9:30",
          unit: "minutes",
          date: Date.today,
          personal_record: true
        }
      }
    end

    activity = SportActivity.find_by(title: "Helen")
    assert_equal "crossfit", activity.sport_type
    assert_equal "benchmark", activity.category
    assert activity.personal_record
  end

  test "should create hyrox event" do
    assert_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "hyrox",
          category: "event",
          title: "HYROX Las Vegas",
          value: "TBD",
          unit: "time",
          date: 90.days.from_now,
          event_name: "HYROX World Championship",
          location: "Las Vegas, NV"
        }
      }
    end

    activity = SportActivity.find_by(title: "HYROX World Championship")
    assert_equal "hyrox", activity.sport_type
    assert_equal "event", activity.category
  end

  test "should create running workout" do
    assert_difference("SportActivity.count") do
      post admin_sport_activities_url, params: {
        sport_activity: {
          sport_type: "running",
          category: "workout",
          title: "5K Race Result",
          value: "21:45",
          unit: "minutes",
          date: Date.today - 7.days,
          event_name: "City 5K Run",
          location: "Downtown"
        }
      }
    end

    activity = SportActivity.find_by(title: "5K Race Result")
    assert_equal "running", activity.sport_type
    assert_equal "workout", activity.category
  end
end
