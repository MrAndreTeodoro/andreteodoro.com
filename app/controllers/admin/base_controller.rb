class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_authentication
  before_action :set_no_cache_headers

  private

  def require_authentication
    unless authenticated?
      redirect_to new_session_path, alert: "You must be signed in to access the admin area."
    end
  end

  def set_no_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
