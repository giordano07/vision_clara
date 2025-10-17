class Admin::ApplicationController < ActiveAdmin::ResourceController
  # Include CSRF protection
  protect_from_forgery with: :exception
  
  # Ensure CSRF token is available in views
  before_action :ensure_csrf_token
  
  private
  
  def ensure_csrf_token
    @csrf_token = form_authenticity_token
  end
end