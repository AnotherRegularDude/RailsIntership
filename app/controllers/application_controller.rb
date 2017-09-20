class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
