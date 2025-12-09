require "test_helper"

class GearItemTest < ActiveSupport::TestCase
  # Validation Tests
  test "should be valid with valid attributes" do
    gear_item = GearItem.new(
      name: "Test Item",
      category: "tech",
      position: 1
    )
    assert gear_item.valid?
  end

  test "should require name" do
    gear_item = GearItem.new(category: "tech")
    assert_not gear_item.valid?
    assert_includes gear_item.errors[:name], "can't be blank"
  end

  test "should require category" do
    gear_item = GearItem.new(name: "Test Item")
    assert_not gear_item.valid?
    assert_includes gear_item.errors[:category], "can't be blank"
  end

  test "should validate price is non-negative" do
    gear_item = gear_items(:macbook_pro)

    gear_item.price = -1
    assert_not gear_item.valid?
    assert_includes gear_item.errors[:price], "must be greater than or equal to 0"

    gear_item.price = 0
    assert gear_item.valid?

    gear_item.price = 99.99
    assert gear_item.valid?
  end

  test "should allow nil price" do
    gear_item = gear_items(:resistance_bands)
    assert gear_item.valid?
    assert_nil gear_item.price
  end

  test "should validate affiliate_link format when present" do
    gear_item = gear_items(:macbook_pro)

    gear_item.affiliate_link = "invalid-url"
    assert_not gear_item.valid?
    assert_includes gear_item.errors[:affiliate_link], "must be a valid URL"

    gear_item.affiliate_link = "https://example.com"
    assert gear_item.valid?

    gear_item.affiliate_link = "http://example.com/product"
    assert gear_item.valid?

    gear_item.affiliate_link = ""
    assert gear_item.valid? # Blank is allowed

    gear_item.affiliate_link = nil
    assert gear_item.valid? # Nil is allowed
  end

  test "should validate position is non-negative integer" do
    gear_item = gear_items(:macbook_pro)

    gear_item.position = -1
    assert_not gear_item.valid?
    assert_includes gear_item.errors[:position], "must be greater than or equal to 0"

    gear_item.position = 0
    assert gear_item.valid?

    gear_item.position = 5
    assert gear_item.valid?

    gear_item.position = 1.5
    assert_not gear_item.valid?
    assert_includes gear_item.errors[:position], "must be an integer"
  end

  # Scope Tests
  test "featured scope returns only featured items" do
    featured = GearItem.featured
    assert featured.all?(&:featured)
    assert_includes featured, gear_items(:macbook_pro)
    assert_includes featured, gear_items(:kettlebell)
    assert_not_includes featured, gear_items(:iphone)
  end

  test "featured scope orders by position ascending" do
    featured = GearItem.featured
    positions = featured.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "by_category scope filters by category" do
    tech_items = GearItem.by_category("tech")
    assert tech_items.all? { |item| item.category == "tech" }
    assert_includes tech_items, gear_items(:macbook_pro)
    assert_includes tech_items, gear_items(:iphone)
    assert_not_includes tech_items, gear_items(:kettlebell)
  end

  test "by_category scope orders by position ascending" do
    tech_items = GearItem.by_category("tech")
    positions = tech_items.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "tech scope returns only tech items" do
    tech_items = GearItem.tech
    assert tech_items.all? { |item| item.category == "tech" }
    assert_includes tech_items, gear_items(:macbook_pro)
    assert_includes tech_items, gear_items(:iphone)
    assert_not_includes tech_items, gear_items(:kettlebell)
  end

  test "tech scope orders by position ascending" do
    tech_items = GearItem.tech
    positions = tech_items.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "fitness scope returns only fitness items" do
    fitness_items = GearItem.fitness
    assert fitness_items.all? { |item| item.category == "fitness" }
    assert_includes fitness_items, gear_items(:kettlebell)
    assert_includes fitness_items, gear_items(:resistance_bands)
    assert_not_includes fitness_items, gear_items(:macbook_pro)
  end

  test "fitness scope orders by position ascending" do
    fitness_items = GearItem.fitness
    positions = fitness_items.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "everyday scope returns only everyday items" do
    everyday_items = GearItem.everyday
    assert everyday_items.all? { |item| item.category == "everyday" }
    assert_includes everyday_items, gear_items(:backpack)
    assert_includes everyday_items, gear_items(:water_bottle)
    assert_not_includes everyday_items, gear_items(:macbook_pro)
  end

  test "everyday scope orders by position ascending" do
    everyday_items = GearItem.everyday
    positions = everyday_items.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "with_price scope returns only items with price" do
    with_price = GearItem.with_price
    assert with_price.all? { |item| item.price.present? }
    assert_includes with_price, gear_items(:macbook_pro)
    assert_includes with_price, gear_items(:kettlebell)
    assert_not_includes with_price, gear_items(:resistance_bands)
  end

  test "with_price scope orders by price ascending" do
    with_price = GearItem.with_price
    prices = with_price.pluck(:price)
    assert_equal prices, prices.sort
  end

  test "ordered scope orders by position ascending" do
    ordered = GearItem.ordered
    positions = ordered.pluck(:position)
    assert_equal positions, positions.sort
  end

  # Helper Method Tests
  test "formatted_price returns formatted price with dollar sign" do
    gear_item = gear_items(:macbook_pro)
    assert_equal "$3499.0", gear_item.formatted_price

    gear_item = gear_items(:kettlebell)
    assert_equal "$89.99", gear_item.formatted_price

    gear_item = gear_items(:notebook)
    assert_equal "$19.99", gear_item.formatted_price
  end

  test "formatted_price returns message when price is nil" do
    gear_item = gear_items(:resistance_bands)
    assert_equal "Price not available", gear_item.formatted_price
  end

  test "formatted_price rounds to 2 decimal places" do
    gear_item = GearItem.new(
      name: "Test",
      category: "tech",
      price: 99.999
    )
    assert_equal "$100.0", gear_item.formatted_price
  end

  test "has_affiliate_link? returns true when affiliate_link present" do
    gear_item = gear_items(:macbook_pro)
    assert gear_item.has_affiliate_link?
  end

  test "has_affiliate_link? returns false when affiliate_link blank" do
    gear_item = gear_items(:iphone)
    assert_not gear_item.has_affiliate_link?
  end

  test "category_display_name returns titleized category" do
    tech_item = gear_items(:macbook_pro)
    assert_equal "Tech", tech_item.category_display_name

    fitness_item = gear_items(:kettlebell)
    assert_equal "Fitness", fitness_item.category_display_name

    everyday_item = gear_items(:backpack)
    assert_equal "Everyday", everyday_item.category_display_name
  end

  test "has_image? returns true when image_url present" do
    gear_item = gear_items(:macbook_pro)
    assert gear_item.has_image?
  end

  test "has_image? returns false when image_url blank" do
    gear_item = gear_items(:water_bottle)
    assert_not gear_item.has_image?
  end

  test "short_description truncates description" do
    gear_item = gear_items(:macbook_pro)
    short = gear_item.short_description(50)
    assert short.length <= 53 # 50 + "..."
    assert short.include?("...")
  end

  test "short_description uses custom length" do
    gear_item = gear_items(:macbook_pro)
    short_desc = gear_item.short_description(20)
    long_desc = gear_item.short_description(150)
    assert short_desc.length < long_desc.length
  end

  test "short_description uses default length of 100" do
    gear_item = gear_items(:macbook_pro)
    default_desc = gear_item.short_description
    assert default_desc.length <= 103
  end

  test "short_description returns empty string when no description" do
    gear_item = gear_items(:foam_roller)
    assert_equal "", gear_item.short_description
  end

  # Callback Tests
  test "normalizes category to lowercase before validation" do
    gear_item = GearItem.create!(
      name: "Test Item",
      category: "TECH"
    )
    assert_equal "tech", gear_item.category
  end

  test "normalizes category strips whitespace" do
    gear_item = GearItem.create!(
      name: "Test Item",
      category: "  fitness  "
    )
    assert_equal "fitness", gear_item.category
  end

  test "normalizes mixed case category" do
    gear_item = gear_items(:keyboard)
    gear_item.save!
    assert_equal "tech", gear_item.category
  end

  test "handles nil category in normalization" do
    gear_item = GearItem.new(
      name: "Test Item",
      category: nil
    )
    assert_not gear_item.valid? # Category is required
  end

  test "sets default position when position is zero" do
    # Position validation requires a number, so callback handles 0 as "no position set"
    max_tech_position = GearItem.tech.maximum(:position) || 0

    gear_item = GearItem.create!(
      name: "Auto Position Item",
      category: "tech",
      position: 0
    )

    assert gear_item.position > 0
    assert_equal max_tech_position + 1, gear_item.position
  end

  test "auto-increments position for new items in same category" do
    # Get current max position for fitness category
    max_fitness_position = GearItem.fitness.maximum(:position) || 0

    gear_item = GearItem.create!(
      name: "New Fitness Item",
      category: "fitness",
      position: 0
    )

    assert gear_item.position > 0
    assert_equal max_fitness_position + 1, gear_item.position
  end

  test "keeps manual position when set" do
    gear_item = GearItem.create!(
      name: "Manual Position Item",
      category: "tech",
      position: 99
    )
    assert_equal 99, gear_item.position
  end

  test "auto position is scoped by category" do
    # Get max position for tech items
    max_tech_position = GearItem.tech.maximum(:position) || 0

    # Create new tech item with position 0
    new_tech = GearItem.create!(
      name: "New Tech Item",
      category: "tech",
      position: 0
    )

    # Should be max + 1
    assert_equal max_tech_position + 1, new_tech.position

    # Get max position for fitness items
    max_fitness_position = GearItem.fitness.maximum(:position) || 0

    # Create new fitness item with position 0
    new_fitness = GearItem.create!(
      name: "New Fitness Item",
      category: "fitness",
      position: 0
    )

    # Should have its own position sequence
    assert_equal max_fitness_position + 1, new_fitness.position
  end

  # Integration Tests
  test "can create gear item with only required fields" do
    gear_item = GearItem.create!(
      name: "Minimal Item",
      category: "tech"
    )
    assert gear_item.persisted?
    assert_equal "Minimal Item", gear_item.name
    assert_equal "tech", gear_item.category
    assert gear_item.position > 0 # Should auto-set position
  end

  test "can create gear item with all fields" do
    gear_item = GearItem.create!(
      name: "Complete Item",
      description: "Full description here",
      category: "everyday",
      affiliate_link: "https://amazon.com/item",
      image_url: "https://example.com/image.jpg",
      price: 99.99,
      featured: true,
      position: 50
    )
    assert gear_item.persisted?
    assert gear_item.featured
    assert_equal 50, gear_item.position
    assert_equal "$99.99", gear_item.formatted_price
  end

  test "multiple items can have same category" do
    tech_items = GearItem.tech
    assert tech_items.count >= 2
  end

  test "featured items can be from different categories" do
    featured = GearItem.featured
    categories = featured.pluck(:category).uniq
    assert categories.count >= 2
  end

  test "can filter featured items by category" do
    featured_tech = GearItem.featured.where(category: "tech")
    assert featured_tech.all? { |item| item.featured && item.category == "tech" }
  end

  test "items without prices are excluded from with_price scope" do
    with_price = GearItem.with_price
    assert with_price.none? { |item| item.price.nil? }
  end

  test "cheap and expensive items can coexist" do
    expensive = GearItem.with_price.where("price > ?", 1000).first
    cheap = GearItem.with_price.where("price < ?", 50).first

    assert expensive.present?
    assert cheap.present?
    assert expensive.price > cheap.price
  end
end
