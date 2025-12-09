require "test_helper"

class Admin::ProjectsControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @project = projects(:startup_one)
    sign_in_as_admin
  end

  # Index Tests
  test "should get index" do
    get admin_projects_url
    assert_response :success
  end

  test "should filter by project type" do
    get admin_projects_url, params: { type: "startup" }
    assert_response :success
    # All results should be startups
  end

  test "should filter by status" do
    get admin_projects_url, params: { status: "active" }
    assert_response :success
  end

  test "should filter by featured" do
    get admin_projects_url, params: { featured: "true" }
    assert_response :success
  end

  test "should search projects" do
    get admin_projects_url, params: { search: "FitTrack" }
    assert_response :success
  end

  # New Tests
  test "should get new" do
    get new_admin_project_url
    assert_response :success
    assert_select "form"
  end

  # Create Tests
  test "should create project with valid params" do
    assert_difference("Project.count") do
      post admin_projects_url, params: {
        project: {
          name: "New Project",
          project_type: "startup",
          description: "Test description",
          status: "active"
        }
      }
    end

    assert_redirected_to admin_projects_url
    assert_equal "Project was successfully created.", flash[:notice]
  end

  test "should not create project with invalid params" do
    assert_no_difference("Project.count") do
      post admin_projects_url, params: {
        project: {
          name: "",
          project_type: "invalid"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should create project with tech stack" do
    assert_difference("Project.count") do
      post admin_projects_url, params: {
        project: {
          name: "Tech Project",
          project_type: "startup",
          tech_stack: '["Ruby", "Rails", "PostgreSQL"]'
        }
      }
    end

    project = Project.find_by(name: "Tech Project")
    assert_includes project.tech_stack_array, "Ruby"
  end

  # Edit Tests
  test "should get edit" do
    get edit_admin_project_url(@project)
    assert_response :success
    assert_select "form"
  end

  # Update Tests
  test "should update project with valid params" do
    patch admin_project_url(@project), params: {
      project: {
        name: "Updated Name",
        description: "Updated description"
      }
    }

    assert_redirected_to admin_projects_url
    assert_equal "Project was successfully updated.", flash[:notice]

    @project.reload
    assert_equal "Updated Name", @project.name
  end

  test "should not update project with invalid params" do
    patch admin_project_url(@project), params: {
      project: {
        name: "",
        project_type: "invalid"
      }
    }

    assert_response :unprocessable_entity

    @project.reload
    assert_not_equal "", @project.name
  end

  test "should update project status" do
    patch admin_project_url(@project), params: {
      project: { status: "archived" }
    }

    @project.reload
    assert_equal "archived", @project.status
  end

  # Destroy Tests
  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete admin_project_url(@project)
    end

    assert_redirected_to admin_projects_url
    assert_equal "Project was successfully deleted.", flash[:notice]
  end

  # Authorization Tests
  test "should require authentication" do
    sign_out

    get admin_projects_url
    assert_redirected_to new_session_url
  end
end
