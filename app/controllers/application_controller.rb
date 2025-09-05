class ApplicationController < ActionController::API
  def current_user
    @current_user ||= User.find(request.headers["X-Current-User-Id"])
  end
end
