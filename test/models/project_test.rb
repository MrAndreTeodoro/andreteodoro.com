require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  # Validation Tests
  test "should be valid with valid attributes" do
    project = Project.new(
      name: "Test Project",
      project_type: "startup",
      status: "active",
      position: 1
    )
    assert project.valid?
  end

  test "should require name" do
    project = Project.new(project_type: "startup")
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "should require project_type" do
    project = Project.new(name: "Test")
    assert_not project.valid?
    assert_includes project.errors[:project_type], "can't be blank"
  end

  test "should only accept valid project types" do
    project = projects(:startup_one)

    project.project_type = "invalid_type"
    assert_not project.valid?

    project.project_type = "startup"
    assert project.valid?

    project.project_type = "side_project"
    assert project.valid?

    project.project_type = "experiment"
    assert project.valid?
  end

  test "should validate URL format when present" do
    project = projects(:startup_one)

    project.url = "invalid-url"
    assert_not project.valid?
    assert_includes project.errors[:url], "must be a valid URL"

    project.url = "https://example.com"
    assert project.valid?

    project.url = ""
    assert project.valid? # URL is optional
  end

  test "should validate position is non-negative integer" do
    project = projects(:startup_one)

    project.position = -1
    assert_not project.valid?

    project.position = 0
    assert project.valid?

    project.position = 5
    assert project.valid?
  end

  # Scope Tests
  test "startups scope returns only startups" do
    startups = Project.startups
    assert startups.all? { |p| p.project_type == "startup" }
    assert_includes startups, projects(:startup_one)
    assert_not_includes startups, projects(:side_project_one)
  end

  test "side_projects scope returns only side projects" do
    side_projects = Project.side_projects
    assert side_projects.all? { |p| p.project_type == "side_project" }
    assert_includes side_projects, projects(:side_project_one)
  end

  test "experiments scope returns only experiments" do
    experiments = Project.experiments
    assert experiments.all? { |p| p.project_type == "experiment" }
    assert_includes experiments, projects(:experiment_one)
  end

  test "featured scope returns only featured projects" do
    featured = Project.featured
    assert featured.all?(&:featured)
    assert_includes featured, projects(:startup_one)
    assert_not_includes featured, projects(:startup_two)
  end

  test "active scope returns only active projects" do
    active = Project.active
    assert active.all? { |p| p.status == "active" }
    assert_includes active, projects(:startup_one)
    assert_not_includes active, projects(:archived_project)
  end

  test "archived scope returns only archived projects" do
    archived = Project.archived
    assert archived.all? { |p| p.status == "archived" }
    assert_includes archived, projects(:archived_project)
  end

  test "in_development scope returns only in_development projects" do
    in_dev = Project.in_development
    assert in_dev.all? { |p| p.status == "in_development" }
    assert_includes in_dev, projects(:startup_two)
  end

  test "ordered scope orders by position" do
    projects = Project.ordered
    positions = projects.pluck(:position)
    assert_equal positions, positions.sort
  end

  # Helper Method Tests
  test "tech_stack_array parses JSON correctly" do
    project = projects(:startup_one)
    array = project.tech_stack_array
    assert_kind_of Array, array
    assert_includes array, "Rails 8"
  end

  test "tech_stack_array handles blank tech_stack" do
    project = Project.new(name: "Test", project_type: "startup", tech_stack: nil)
    assert_equal [], project.tech_stack_array
  end

  test "tech_stack_array handles CSV format" do
    project = Project.new(name: "Test", project_type: "startup", tech_stack: "Rails, PostgreSQL, React")
    array = project.tech_stack_array
    assert_equal [ "Rails", "PostgreSQL", "React" ], array
  end

  test "tech_stack_array= sets JSON" do
    project = projects(:startup_one)
    project.tech_stack_array = [ "Ruby", "Rails" ]
    assert project.tech_stack.include?("Ruby")
  end

  test "project_type_display_name returns titleized type" do
    project = projects(:side_project_one)
    assert_equal "Side Project", project.project_type_display_name
  end

  test "status_display_name returns titleized status" do
    project = projects(:startup_two)
    assert_equal "In Development", project.status_display_name
  end

  test "has_url? returns true when url present" do
    project = projects(:startup_one)
    assert project.has_url?
  end

  test "has_url? returns false when url blank" do
    project = Project.new(name: "Test", project_type: "startup", url: nil)
    assert_not project.has_url?
  end

  test "has_logo? returns true when logo_url present" do
    project = projects(:startup_one)
    assert project.has_logo?
  end

  test "has_logo? returns false when logo_url blank" do
    project = projects(:side_project_one)
    assert_not project.has_logo?
  end

  test "short_description truncates description" do
    project = projects(:startup_one)
    short = project.short_description(20)
    assert short.length <= 23 # 20 + "..."
  end

  test "short_description returns empty string when no description" do
    project = Project.new(name: "Test", project_type: "startup", description: nil)
    assert_equal "", project.short_description
  end

  test "active? returns true for active projects" do
    project = projects(:startup_one)
    assert project.active?
  end

  test "archived? returns true for archived projects" do
    project = projects(:archived_project)
    assert project.archived?
  end

  test "in_development? returns true for in_development projects" do
    project = projects(:startup_two)
    assert project.in_development?
  end

  # Callback Tests
  test "sets default position when position is nil" do
    project = Project.create!(
      name: "Auto Position",
      project_type: "startup"
    )
    assert_not_nil project.position
    assert project.position > 0
  end

  test "sets default position when position is zero" do
    project = Project.create!(
      name: "Auto Position",
      project_type: "startup",
      position: 0
    )
    assert project.position > 0
  end

  test "keeps manual position when set" do
    project = Project.create!(
      name: "Manual Position",
      project_type: "startup",
      position: 99
    )
    assert_equal 99, project.position
  end

  test "auto position is scoped by project_type" do
    # Get max position for startups
    max_startup_position = Project.startups.maximum(:position) || 0

    # Create new startup
    new_startup = Project.create!(
      name: "New Startup",
      project_type: "startup",
      position: 0
    )

    # Should be max + 1
    assert_equal max_startup_position + 1, new_startup.position

    # Create new side project with position 0
    new_side_project = Project.create!(
      name: "New Side Project",
      project_type: "side_project",
      position: 0
    )

    # Should have its own position sequence
    max_side_project_position = Project.side_projects.where.not(id: new_side_project.id).maximum(:position) || 0
    assert_equal max_side_project_position + 1, new_side_project.position
  end
end
