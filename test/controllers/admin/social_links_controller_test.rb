require "test_helper"

class Admin::SocialLinksControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @social_link = social_links(:twitter_main)
    sign_in_as_admin
  end

  # Index Tests
  test "should get index" do
    get admin_social_links_url
    assert_response :success
  end

  # New Tests
  test "should get new" do
    get new_admin_social_link_url
    assert_response :success
    assert_select "form"
    assert_select "select[name='social_link[platform]']"
    assert_select "input[name='social_link[url]']"
  end

  # Create Tests
  test "should create social link with valid params" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "github",
          url: "https://github.com/testuser",
          username: "testuser"
        }
      }
    end

    assert_redirected_to admin_social_links_url
    assert_equal "Social link was successfully created.", flash[:notice]
  end

  test "should create social link with all fields" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "youtube",
          url: "https://youtube.com/@newchannel",
          follower_count: 50000,
          username: "newchannel",
          display_in_header: true
        }
      }
    end

    social_link = SocialLink.find_by(username: "newchannel")
    assert social_link.display_in_header
    assert_equal 50000, social_link.follower_count
    assert_equal "youtube", social_link.platform
  end

  test "should not create social link without platform" do
    assert_no_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "",
          url: "https://example.com"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create social link without url" do
    assert_no_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "twitter",
          url: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create social link with invalid platform" do
    assert_no_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "invalid_platform",
          url: "https://example.com"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create social link with invalid url" do
    assert_no_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "twitter",
          url: "not-a-valid-url"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create social link with negative follower count" do
    assert_no_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "twitter",
          url: "https://twitter.com/user",
          follower_count: -100
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should create social link without follower count" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "instagram",
          url: "https://instagram.com/user",
          username: "user",
          follower_count: ""
        }
      }
    end

    social_link = SocialLink.find_by(username: "user")
    assert_nil social_link.follower_count
  end

  test "should create twitter link" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "twitter",
          url: "https://twitter.com/newuser",
          username: "newuser",
          follower_count: 1500
        }
      }
    end

    link = SocialLink.find_by(username: "newuser")
    assert_equal "twitter", link.platform
  end

  test "should create linkedin link" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "linkedin",
          url: "https://linkedin.com/in/professional",
          username: "professional",
          display_in_header: true
        }
      }
    end

    link = SocialLink.find_by(username: "professional")
    assert_equal "linkedin", link.platform
    assert link.display_in_header
  end

  test "should create tiktok link" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "tiktok",
          url: "https://tiktok.com/@creator",
          username: "creator",
          follower_count: 125000
        }
      }
    end

    link = SocialLink.find_by(username: "creator")
    assert_equal "tiktok", link.platform
    assert_equal 125000, link.follower_count
  end

  # Edit Tests
  test "should get edit" do
    get edit_admin_social_link_url(@social_link)
    assert_response :success
    assert_select "form"
    assert_select "select[name='social_link[platform]']"
    assert_select "input[name='social_link[url]'][value=?]", @social_link.url
  end

  # Update Tests
  test "should update social link with valid params" do
    patch admin_social_link_url(@social_link), params: {
      social_link: {
        url: "https://twitter.com/updated",
        username: "updated",
        follower_count: 25000
      }
    }

    assert_redirected_to admin_social_links_url
    assert_equal "Social link was successfully updated.", flash[:notice]

    @social_link.reload
    assert_equal "https://twitter.com/updated", @social_link.url
    assert_equal "updated", @social_link.username
    assert_equal 25000, @social_link.follower_count
  end

  test "should update social link platform" do
    patch admin_social_link_url(@social_link), params: {
      social_link: {
        platform: "github",
        url: "https://github.com/user"
      }
    }

    @social_link.reload
    assert_equal "github", @social_link.platform
  end

  test "should update social link follower count" do
    patch admin_social_link_url(@social_link), params: {
      social_link: { follower_count: 100000 }
    }

    @social_link.reload
    assert_equal 100000, @social_link.follower_count
  end

  test "should toggle display_in_header" do
    original_display = @social_link.display_in_header

    patch admin_social_link_url(@social_link), params: {
      social_link: { display_in_header: !original_display }
    }

    @social_link.reload
    assert_equal !original_display, @social_link.display_in_header
  end

  test "should update username" do
    patch admin_social_link_url(@social_link), params: {
      social_link: { username: "newusername" }
    }

    @social_link.reload
    assert_equal "newusername", @social_link.username
  end

  test "should not update social link with invalid platform" do
    original_platform = @social_link.platform

    patch admin_social_link_url(@social_link), params: {
      social_link: { platform: "invalid" }
    }

    assert_response :unprocessable_entity

    @social_link.reload
    assert_equal original_platform, @social_link.platform
  end

  test "should not update social link with invalid url" do
    original_url = @social_link.url

    patch admin_social_link_url(@social_link), params: {
      social_link: { url: "not-valid" }
    }

    assert_response :unprocessable_entity

    @social_link.reload
    assert_equal original_url, @social_link.url
  end

  test "should not update social link with empty platform" do
    original_platform = @social_link.platform

    patch admin_social_link_url(@social_link), params: {
      social_link: { platform: "" }
    }

    assert_response :unprocessable_entity

    @social_link.reload
    assert_equal original_platform, @social_link.platform
  end

  test "should not update social link with empty url" do
    original_url = @social_link.url

    patch admin_social_link_url(@social_link), params: {
      social_link: { url: "" }
    }

    assert_response :unprocessable_entity

    @social_link.reload
    assert_equal original_url, @social_link.url
  end

  test "should not update social link with negative follower count" do
    original_count = @social_link.follower_count

    patch admin_social_link_url(@social_link), params: {
      social_link: { follower_count: -500 }
    }

    assert_response :unprocessable_entity

    @social_link.reload
    assert_equal original_count, @social_link.follower_count
  end

  # Destroy Tests
  test "should destroy social link" do
    assert_difference("SocialLink.count", -1) do
      delete admin_social_link_url(@social_link)
    end

    assert_redirected_to admin_social_links_url
    assert_equal "Social link was successfully deleted.", flash[:notice]
  end

  test "should not find destroyed social link" do
    link_id = @social_link.id
    delete admin_social_link_url(@social_link)

    assert_raises(ActiveRecord::RecordNotFound) do
      SocialLink.find(link_id)
    end
  end

  # Authorization Tests
  test "should require authentication for index" do
    sign_out

    get admin_social_links_url
    assert_redirected_to new_session_url
  end

  test "should require authentication for new" do
    sign_out

    get new_admin_social_link_url
    assert_redirected_to new_session_url
  end

  test "should require authentication for create" do
    sign_out

    post admin_social_links_url, params: {
      social_link: {
        platform: "twitter",
        url: "https://twitter.com/test"
      }
    }
    assert_redirected_to new_session_url
  end

  test "should require authentication for edit" do
    sign_out

    get edit_admin_social_link_url(@social_link)
    assert_redirected_to new_session_url
  end

  test "should require authentication for update" do
    sign_out

    patch admin_social_link_url(@social_link), params: {
      social_link: { username: "Updated" }
    }
    assert_redirected_to new_session_url
  end

  test "should require authentication for destroy" do
    sign_out

    delete admin_social_link_url(@social_link)
    assert_redirected_to new_session_url
  end

  # Edge Cases
  test "should handle social link with zero followers" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "twitter",
          url: "https://twitter.com/newaccount",
          username: "newaccount",
          follower_count: 0
        }
      }
    end

    link = SocialLink.find_by(username: "newaccount")
    assert_equal 0, link.follower_count
  end

  test "should handle large follower counts" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "youtube",
          url: "https://youtube.com/@megainfluencer",
          username: "megainfluencer",
          follower_count: 10000000
        }
      }
    end

    link = SocialLink.find_by(username: "megainfluencer")
    assert_equal 10000000, link.follower_count
  end

  test "should handle all valid platforms" do
    SocialLink::PLATFORMS.each do |platform|
      assert_difference("SocialLink.count") do
        post admin_social_links_url, params: {
          social_link: {
            platform: platform,
            url: "https://#{platform}.com/test#{platform}",
            username: "test#{platform}"
          }
        }
      end
    end
  end

  test "should handle special characters in username" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "twitter",
          url: "https://twitter.com/user_name-123",
          username: "user_name-123"
        }
      }
    end

    link = SocialLink.find_by(username: "user_name-123")
    assert_not_nil link
  end

  test "should handle url with query parameters" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "youtube",
          url: "https://youtube.com/@channelwithparams?sub_confirmation=1",
          username: "channelwithparams"
        }
      }
    end

    link = SocialLink.find_by(username: "channelwithparams")
    assert_includes link.url, "sub_confirmation"
  end

  test "should handle http and https urls" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "github",
          url: "http://github.com/user",
          username: "user"
        }
      }
    end

    link = SocialLink.find_by(username: "user")
    assert_match(/^http/, link.url)
  end

  test "should create multiple links for same platform" do
    first_count = SocialLink.by_platform("twitter").count

    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "twitter",
          url: "https://twitter.com/secondary_account",
          username: "secondary_account"
        }
      }
    end

    assert_equal first_count + 1, SocialLink.by_platform("twitter").count
  end

  test "should update follower count to zero" do
    patch admin_social_link_url(@social_link), params: {
      social_link: { follower_count: 0 }
    }

    @social_link.reload
    assert_equal 0, @social_link.follower_count
  end

  test "should clear follower count" do
    patch admin_social_link_url(@social_link), params: {
      social_link: { follower_count: nil }
    }

    @social_link.reload
    assert_nil @social_link.follower_count
  end

  test "should handle discord server url format" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "discord",
          url: "https://discord.gg/servercode",
          username: "servername"
        }
      }
    end

    link = SocialLink.find_by(username: "servername")
    assert_equal "discord", link.platform
  end

  test "should handle twitch channel url" do
    assert_difference("SocialLink.count") do
      post admin_social_links_url, params: {
        social_link: {
          platform: "twitch",
          url: "https://twitch.tv/streamer",
          username: "streamer",
          follower_count: 5000
        }
      }
    end

    link = SocialLink.find_by(username: "streamer")
    assert_equal "twitch", link.platform
  end
end
