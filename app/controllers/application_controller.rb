class ApplicationController < ActionController::Base
  before_filter :authenticate_users
  protect_from_forgery
  
  private
  
  def authenticate_users
    authenticate_or_request_with_http_basic("Please provide your URL Fetcher credentials") do |user, password|
      user == ENV["ADMIN_USER"] && password == ENV["ADMIN_PASSWORD"]
    end
  end
end
