require "test_helper"

class Admin::GearItemsControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @gear_item = gear_items(:macbook_pro)
    sign_in_as_admin
  end

  # Index Tests
  test "should get index" do
    get admin_gear_items_url
    assert_response :success
  end

  test "should filter by category tech" do
    get admin_gear_items_url, params: { category: "tech" }
    assert_response :success
  end

  test "should filter by category fitness" do
    get admin_gear_items_url, params: { category: "fitness" }
    assert_response :success
  end

  test "should filter by category everyday" do
    get admin_gear_items_url, params: { category: "everyday" }
    assert_response :success
  end

  test "should filter by featured" do
    get admin_gear_items_url, params: { featured: "true" }
    assert_response :success
  end

  test "should filter by price range under 100" do
    get admin_gear_items_url, params: { price_range: "under_100" }
    assert_response :success
  end

  test "should filter by price range 100-500" do
    get admin_gear_items_url, params: { price_range: "100_500" }
    assert_response :success
  end

  test "should filter by price range 500-1000" do
    get admin_gear_items_url, params: { price_range: "500_1000" }
    assert_response :success
  end

  test "should filter by price range over 1000" do
    get admin_gear_items_url, params: { price_range: "over_1000" }
    assert_response :success
  end

  test "should search gear items by name" do
    get admin_gear_items_url, params: { search: "MacBook" }
    assert_response :success
  end

  test "should search gear items by description" do
    get admin_gear_items_url, params: { search: "powerful" }
    assert_response :success
  end

  test "should combine filters" do
    get admin_gear_items_url, params: {
      category: "tech",
      featured: "true",
      price_range: "over_1000"
    }
    assert_response :success
  end

  # New Tests
  test "should get new" do
    get new_admin_gear_item_url
    assert_response :success
    assert_select "form"
    assert_select "input[name='gear_item[name]']"
    assert_select "select[name='gear_item[category]']"
  end

  # Create Tests
  test "should create gear item with valid params" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "New Gear",
          category: "tech",
          description: "Test description",
          price: 99.99
        }
      }
    end

    assert_redirected_to admin_gear_items_url
    assert_equal "Gear item was successfully created.", flash[:notice]
  end

  test "should create gear item with all fields" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Complete Gear",
          category: "fitness",
          description: "Complete description",
          price: 149.99,
          featured: true,
          position: 10,
          image_url: "https://example.com/image.jpg",
          affiliate_link: "https://amazon.com/product"
        }
      }
    end

    gear_item = GearItem.find_by(name: "Complete Gear")
    assert gear_item.featured
    assert_equal 149.99, gear_item.price
    assert_equal "fitness", gear_item.category
    assert_equal 10, gear_item.position
  end

  test "should not create gear item without name" do
    assert_no_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "",
          category: "tech"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create gear item without category" do
    assert_no_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Test",
          category: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create gear item with negative price" do
    assert_no_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Test",
          category: "tech",
          price: -10
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create gear item with invalid affiliate link" do
    assert_no_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Test",
          category: "tech",
          affiliate_link: "not-a-url"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should create gear item without price" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "No Price Item",
          category: "tech",
          price: ""
        }
      }
    end

    gear_item = GearItem.find_by(name: "No Price Item")
    assert_nil gear_item.price
  end

  test "should auto-set position when creating with position 0" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Auto Position",
          category: "tech",
          position: 0
        }
      }
    end

    gear_item = GearItem.find_by(name: "Auto Position")
    assert gear_item.position > 0
  end

  # Edit Tests
  test "should get edit" do
    get edit_admin_gear_item_url(@gear_item)
    assert_response :success
    assert_select "form"
    assert_select "input[name='gear_item[name]'][value=?]", @gear_item.name
  end

  # Update Tests
  test "should update gear item with valid params" do
    patch admin_gear_item_url(@gear_item), params: {
      gear_item: {
        name: "Updated Name",
        description: "Updated description",
        price: 999.99
      }
    }

    assert_redirected_to admin_gear_items_url
    assert_equal "Gear item was successfully updated.", flash[:notice]

    @gear_item.reload
    assert_equal "Updated Name", @gear_item.name
    assert_equal "Updated description", @gear_item.description.to_plain_text
    assert_equal 999.99, @gear_item.price
  end

  test "should update gear item category" do
    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { category: "everyday" }
    }

    @gear_item.reload
    assert_equal "everyday", @gear_item.category
  end

  test "should update gear item price" do
    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { price: 2999.99 }
    }

    @gear_item.reload
    assert_equal 2999.99, @gear_item.price
  end

  test "should toggle gear item featured status" do
    original_featured = @gear_item.featured

    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { featured: !original_featured }
    }

    @gear_item.reload
    assert_equal !original_featured, @gear_item.featured
  end

  test "should update gear item position" do
    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { position: 99 }
    }

    @gear_item.reload
    assert_equal 99, @gear_item.position
  end

  test "should update affiliate link and image url" do
    patch admin_gear_item_url(@gear_item), params: {
      gear_item: {
        affiliate_link: "https://new-link.com/product",
        image_url: "https://new-image.com/photo.jpg"
      }
    }

    @gear_item.reload
    assert_equal "https://new-link.com/product", @gear_item.affiliate_link
    assert_equal "https://new-image.com/photo.jpg", @gear_item.image_url
  end

  test "should not update gear item with invalid name" do
    original_name = @gear_item.name

    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { name: "" }
    }

    assert_response :unprocessable_entity

    @gear_item.reload
    assert_equal original_name, @gear_item.name
  end

  test "should not update gear item with invalid category" do
    original_category = @gear_item.category

    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { category: "" }
    }

    assert_response :unprocessable_entity

    @gear_item.reload
    assert_equal original_category, @gear_item.category
  end

  test "should not update gear item with negative price" do
    original_price = @gear_item.price

    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { price: -50 }
    }

    assert_response :unprocessable_entity

    @gear_item.reload
    assert_equal original_price, @gear_item.price
  end

  test "should not update gear item with invalid position" do
    original_position = @gear_item.position

    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { position: -1 }
    }

    assert_response :unprocessable_entity

    @gear_item.reload
    assert_equal original_position, @gear_item.position
  end

  # Destroy Tests
  test "should destroy gear item" do
    assert_difference("GearItem.count", -1) do
      delete admin_gear_item_url(@gear_item)
    end

    assert_redirected_to admin_gear_items_url
    assert_equal "Gear item was successfully deleted.", flash[:notice]
  end

  test "should not find destroyed gear item" do
    item_id = @gear_item.id
    delete admin_gear_item_url(@gear_item)

    assert_raises(ActiveRecord::RecordNotFound) do
      GearItem.find(item_id)
    end
  end

  # Authorization Tests
  test "should require authentication for index" do
    sign_out

    get admin_gear_items_url
    assert_redirected_to new_session_url
  end

  test "should require authentication for new" do
    sign_out

    get new_admin_gear_item_url
    assert_redirected_to new_session_url
  end

  test "should require authentication for create" do
    sign_out

    post admin_gear_items_url, params: {
      gear_item: {
        name: "Test",
        category: "tech"
      }
    }
    assert_redirected_to new_session_url
  end

  test "should require authentication for edit" do
    sign_out

    get edit_admin_gear_item_url(@gear_item)
    assert_redirected_to new_session_url
  end

  test "should require authentication for update" do
    sign_out

    patch admin_gear_item_url(@gear_item), params: {
      gear_item: { name: "Updated" }
    }
    assert_redirected_to new_session_url
  end

  test "should require authentication for destroy" do
    sign_out

    delete admin_gear_item_url(@gear_item)
    assert_redirected_to new_session_url
  end

  # Edge Cases
  test "should handle gear item with long name" do
    long_name = "A" * 300

    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: long_name,
          category: "tech"
        }
      }
    end

    gear_item = GearItem.last
    assert_equal long_name, gear_item.name
  end

  test "should handle gear item with special characters in name" do
    special_name = "Test: Item & Special 'Characters' (2024)"

    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: special_name,
          category: "tech"
        }
      }
    end

    gear_item = GearItem.find_by(name: special_name)
    assert_not_nil gear_item
  end

  test "should handle empty search query" do
    get admin_gear_items_url, params: { search: "" }
    assert_response :success
  end

  test "should handle search with no results" do
    get admin_gear_items_url, params: { search: "NonExistentItem123" }
    assert_response :success
  end

  test "should handle multiple items with same category" do
    get admin_gear_items_url, params: { category: "tech" }
    assert_response :success
  end

  test "should create tech gear item" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "iPad Pro",
          category: "tech",
          description: "Latest iPad with M2 chip",
          price: 1099.00,
          affiliate_link: "https://amazon.com/ipad",
          featured: true
        }
      }
    end

    item = GearItem.find_by(name: "iPad Pro")
    assert_equal "tech", item.category
    assert item.featured
  end

  test "should create fitness gear item" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Reebok Nano X3",
          category: "fitness",
          description: "CrossFit training shoes",
          price: 149.99,
          featured: false
        }
      }
    end

    item = GearItem.find_by(name: "Reebok Nano X3")
    assert_equal "fitness", item.category
    assert_not item.featured
  end

  test "should create everyday gear item" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Leather Wallet",
          category: "everyday",
          description: "Minimalist leather wallet",
          price: 49.99
        }
      }
    end

    item = GearItem.find_by(name: "Leather Wallet")
    assert_equal "everyday", item.category
  end

  test "should handle zero price" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Free Item",
          category: "tech",
          price: 0
        }
      }
    end

    item = GearItem.find_by(name: "Free Item")
    assert_equal 0, item.price
  end

  test "should handle decimal prices" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Decimal Price Item",
          category: "tech",
          price: 99.99
        }
      }
    end

    item = GearItem.find_by(name: "Decimal Price Item")
    assert_equal 99.99, item.price
  end

  test "should normalize category to lowercase" do
    assert_difference("GearItem.count") do
      post admin_gear_items_url, params: {
        gear_item: {
          name: "Case Test",
          category: "TECH"
        }
      }
    end

    item = GearItem.find_by(name: "Case Test")
    assert_equal "tech", item.category
  end
end
