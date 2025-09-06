class ApplicationController < ActionController::API
  # def current_user
  #   @current_user ||= User.find(request.headers["X-Current-User-Id"])
  # end

  before_action :set_current_user

  private

  def set_current_user
    if request.headers["X-Current-User-Id"].present?
      @current_user = User.find(request.headers["X-Current-User-Id"])
    end
  end

  def current_user
    @current_user
  end
end
